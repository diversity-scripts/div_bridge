import React, { useState, useEffect, useRef, useCallback } from 'react';
import { motion } from 'framer-motion';

/**
 * Lockpick Minigame — Skyrim-style circular lock.
 *
 * Player rotates a pick around a circular lock using A/D or Arrow keys,
 * then presses E/SPACE to attempt a turn. A proximity glow gets brighter
 * as the pick approaches the hidden sweet spot.
 *
 * Uses refs for timing-critical state (angle, sweet spot, finished flag)
 * and useState for render-triggering state (picks, display angle, proximity).
 */

const ROTATION_SPEED = 2.5; // degrees per frame at 60fps
const LOCK_SIZE = 200;
const PICK_LENGTH = 80;

// --- Pure utility functions (exported for testing) ---

/**
 * Generate a random sweet spot position on the lock circle.
 * @returns {number} Center angle in degrees [0, 360)
 */
export function generateSweetSpot() {
  return Math.random() * 360;
}

/**
 * Compute proximity value (0–1) based on angular distance from sweet spot.
 *
 * @param {number} angle - Current pick angle in degrees [0, 360)
 * @param {number} center - Sweet spot center angle in degrees [0, 360)
 * @param {number} range - Total proximity range in degrees
 * @returns {number} 0 if outside range, 0–1 graduated value if inside (1 = dead center)
 */
export function computeProximity(angle, center, range) {
  const diff = Math.abs(angle - center);
  const angularDistance = Math.min(diff, 360 - diff);
  const halfRange = range / 2;
  if (angularDistance > halfRange) return 0;
  return 1 - (angularDistance / halfRange);
}

/**
 * Check if the current angle is within the sweet spot.
 *
 * @param {number} angle - Current pick angle in degrees [0, 360)
 * @param {number} center - Sweet spot center angle in degrees [0, 360)
 * @param {number} size - Sweet spot width in degrees
 * @returns {boolean} true if angle is within the sweet spot
 */
export function isInSweetSpot(angle, center, size) {
  const diff = Math.abs(angle - center);
  const angularDistance = Math.min(diff, 360 - diff);
  return angularDistance <= size / 2;
}

// --- Config clamping/defaults per design error handling table ---

function clampConfig(config) {
  let { picks = 3, sweetSpotSize = 30, proximityRange = 60, timeLimit = 20000 } = config;

  if (typeof picks !== 'number' || picks <= 0) picks = 1;
  if (typeof sweetSpotSize !== 'number' || sweetSpotSize <= 0) sweetSpotSize = 10;
  if (sweetSpotSize > 360) sweetSpotSize = 360;
  if (typeof proximityRange !== 'number' || proximityRange <= 0) proximityRange = 60;
  if (proximityRange > 360) proximityRange = 360;
  if (typeof timeLimit !== 'number' || timeLimit <= 0) timeLimit = 20000;

  return { picks, sweetSpotSize, proximityRange, timeLimit };
}

// --- Component ---

export function Lockpick({ config, onResult, cancelKey }) {
  const { picks, sweetSpotSize, proximityRange, timeLimit } = clampConfig(config);

  // Refs for timing-critical state
  const angleRef = useRef(0);
  const sweetSpotRef = useRef(null);
  const isFinishedRef = useRef(false);
  const animFrameRef = useRef(null);
  const keysDownRef = useRef(new Set());
  const timerIntervalRef = useRef(null);
  const onResultRef = useRef(onResult);
  onResultRef.current = onResult;

  // Render state
  const [picksRemaining, setPicksRemaining] = useState(picks);
  const [displayAngle, setDisplayAngle] = useState(0);
  const [proximity, setProximity] = useState(0);
  const [timeRemaining, setTimeRemaining] = useState(timeLimit);
  const [breakAnim, setBreakAnim] = useState(false);

  // Generate sweet spot on mount
  useEffect(() => {
    sweetSpotRef.current = generateSweetSpot();
  }, []);

  // Timer countdown (50ms ticks for smooth display)
  useEffect(() => {
    const startTime = Date.now();

    timerIntervalRef.current = setInterval(() => {
      if (isFinishedRef.current) {
        clearInterval(timerIntervalRef.current);
        return;
      }
      const elapsed = Date.now() - startTime;
      const remaining = Math.max(0, timeLimit - elapsed);
      setTimeRemaining(remaining);

      if (remaining <= 0) {
        clearInterval(timerIntervalRef.current);
        timerIntervalRef.current = null;
        if (!isFinishedRef.current) {
          isFinishedRef.current = true;
          onResultRef.current(false);
        }
      }
    }, 50);

    return () => {
      if (timerIntervalRef.current) {
        clearInterval(timerIntervalRef.current);
        timerIntervalRef.current = null;
      }
    };
  }, [timeLimit]);

  // rAF-based rotation loop
  useEffect(() => {
    let lastTime = performance.now();

    const loop = (now) => {
      if (isFinishedRef.current) return;
      const dt = (now - lastTime) / 16.67; // normalize to 60fps
      lastTime = now;

      const keys = keysDownRef.current;
      let delta = 0;
      if (keys.has('a') || keys.has('arrowleft')) delta -= ROTATION_SPEED * dt;
      if (keys.has('d') || keys.has('arrowright')) delta += ROTATION_SPEED * dt;

      if (delta !== 0) {
        angleRef.current = ((angleRef.current + delta) % 360 + 360) % 360;
        setDisplayAngle(angleRef.current);
        if (sweetSpotRef.current !== null) {
          setProximity(computeProximity(angleRef.current, sweetSpotRef.current, proximityRange));
        }
      }

      animFrameRef.current = requestAnimationFrame(loop);
    };

    animFrameRef.current = requestAnimationFrame(loop);
    return () => {
      if (animFrameRef.current) {
        cancelAnimationFrame(animFrameRef.current);
      }
    };
  }, [proximityRange]);

  // Attempt turn handler
  const attemptTurn = useCallback(() => {
    if (isFinishedRef.current || sweetSpotRef.current === null) return;

    if (isInSweetSpot(angleRef.current, sweetSpotRef.current, sweetSpotSize)) {
      // Success
      isFinishedRef.current = true;
      onResultRef.current(true);
    } else {
      // Break pick
      setBreakAnim(true);
      setTimeout(() => setBreakAnim(false), 400);

      setPicksRemaining((prev) => {
        const next = prev - 1;
        if (next <= 0 && !isFinishedRef.current) {
          isFinishedRef.current = true;
          // Small delay so break animation is visible
          setTimeout(() => onResultRef.current(false), 200);
        }
        return next;
      });
    }
  }, [sweetSpotSize]);

  // Keydown/keyup handlers
  useEffect(() => {
    const handleKeyDown = (e) => {
      if (isFinishedRef.current) return;
      const key = e.key.toLowerCase();

      // Turn attempt
      if (key === 'e' || key === ' ') {
        e.preventDefault();
        attemptTurn();
        return;
      }

      // Rotation keys
      if (['a', 'd', 'arrowleft', 'arrowright'].includes(key)) {
        e.preventDefault();
        keysDownRef.current.add(key);
      }
    };

    const handleKeyUp = (e) => {
      const key = e.key.toLowerCase();
      keysDownRef.current.delete(key);
    };

    window.addEventListener('keydown', handleKeyDown);
    window.addEventListener('keyup', handleKeyUp);
    return () => {
      window.removeEventListener('keydown', handleKeyDown);
      window.removeEventListener('keyup', handleKeyUp);
    };
  }, [attemptTurn]);

  // Derived values
  const timerProgress = timeLimit > 0 ? timeRemaining / timeLimit : 0;
  const timerSeconds = (timeRemaining / 1000).toFixed(1);

  // Glow color based on proximity
  const glowOpacity = proximity;
  const glowColor = `rgba(var(--brand-rgb), ${glowOpacity * 0.6})`;

  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ type: 'spring', stiffness: 400, damping: 30 }}
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        gap: '16px',
        fontFamily: 'var(--font-sans)',
        pointerEvents: 'all',
      }}
    >
      {/* Pick counter */}
      <div style={{
        display: 'flex',
        gap: '6px',
        alignItems: 'center',
      }}>
        {Array.from({ length: picks }, (_, i) => (
          <svg
            key={i}
            width="16"
            height="28"
            viewBox="0 0 16 28"
            style={{
              opacity: i < picksRemaining ? 1 : 0.3,
              filter: i < picksRemaining ? 'none' : 'grayscale(1)',
              transition: 'opacity 0.3s ease, filter 0.3s ease',
            }}
          >
            {/* Simple lockpick icon */}
            <rect x="7" y="0" width="2" height="20" rx="1" fill="rgba(255,255,255,0.8)" />
            <rect x="5" y="18" width="6" height="3" rx="1.5" fill="rgba(255,255,255,0.6)" />
            <circle cx="8" cy="25" r="2.5" fill="none" stroke="rgba(255,255,255,0.6)" strokeWidth="1.5" />
          </svg>
        ))}
      </div>

      {/* Circular lock with pick */}
      <motion.div
        animate={breakAnim ? { x: [0, -6, 5, -4, 3, -2, 1, 0] } : {}}
        transition={breakAnim ? { duration: 0.4 } : {}}
        style={{
          position: 'relative',
          width: `${LOCK_SIZE}px`,
          height: `${LOCK_SIZE}px`,
        }}
      >
        {/* Lock circle SVG */}
        <svg
          width={LOCK_SIZE}
          height={LOCK_SIZE}
          viewBox={`0 0 ${LOCK_SIZE} ${LOCK_SIZE}`}
          style={{ position: 'absolute', top: 0, left: 0 }}
        >
          {/* Outer ring */}
          <circle
            cx={LOCK_SIZE / 2}
            cy={LOCK_SIZE / 2}
            r={LOCK_SIZE / 2 - 4}
            fill="rgb(28, 29, 31)"
            stroke="rgba(255, 255, 255, 0.08)"
            strokeWidth="2"
          />
          {/* Inner ring detail */}
          <circle
            cx={LOCK_SIZE / 2}
            cy={LOCK_SIZE / 2}
            r={LOCK_SIZE / 2 - 20}
            fill="none"
            stroke="rgba(255, 255, 255, 0.04)"
            strokeWidth="1"
          />
          {/* Keyhole center */}
          <circle
            cx={LOCK_SIZE / 2}
            cy={LOCK_SIZE / 2}
            r="12"
            fill="rgba(0, 0, 0, 0.6)"
            stroke="rgba(255, 255, 255, 0.1)"
            strokeWidth="1.5"
          />
        </svg>

        {/* Proximity glow overlay */}
        <div style={{
          position: 'absolute',
          top: 0,
          left: 0,
          width: '100%',
          height: '100%',
          borderRadius: '50%',
          background: `radial-gradient(circle at 50% 50%, ${glowColor}, transparent 70%)`,
          opacity: glowOpacity > 0 ? 1 : 0,
          transition: 'opacity 0.1s ease',
          pointerEvents: 'none',
        }} />

        {/* Pick indicator */}
        <div style={{
          position: 'absolute',
          top: '50%',
          left: '50%',
          width: '2px',
          height: `${PICK_LENGTH}px`,
          transformOrigin: '50% 0%',
          transform: `translate(-50%, 0) rotate(${displayAngle}deg)`,
          pointerEvents: 'none',
        }}>
          <div style={{
            width: '2px',
            height: '100%',
            background: 'linear-gradient(to bottom, rgba(255,255,255,0.9), rgba(255,255,255,0.4))',
            borderRadius: '1px',
            boxShadow: proximity > 0.5
              ? `0 0 ${8 + proximity * 8}px rgba(var(--brand-rgb), ${proximity * 0.6})`
              : '0 0 4px rgba(255,255,255,0.3)',
          }} />
          {/* Pick tip */}
          <div style={{
            position: 'absolute',
            bottom: '-4px',
            left: '50%',
            transform: 'translateX(-50%)',
            width: '6px',
            height: '6px',
            borderRadius: '50%',
            background: proximity > 0.7 ? 'var(--brand)' : 'rgba(255,255,255,0.8)',
            boxShadow: proximity > 0.5
              ? `0 0 8px rgba(var(--brand-rgb), ${proximity})`
              : 'none',
            transition: 'background 0.15s ease',
          }} />
        </div>
      </motion.div>

      {/* Instructions */}
      <div style={{
        display: 'flex',
        gap: '16px',
        alignItems: 'center',
        fontSize: '12px',
        fontWeight: 500,
        color: 'rgba(255, 255, 255, 0.4)',
      }}>
        <span>
          <kbd style={{
            fontFamily: 'var(--font-sans)',
            fontWeight: 700,
            color: '#fff',
            background: 'rgba(0, 0, 0, 0.25)',
            padding: '2px 7px',
            borderRadius: '5px',
            border: '1px solid rgba(255, 255, 255, 0.05)',
            borderBottomWidth: '2px',
            margin: '0 3px',
          }}>A/←</kbd>
          <kbd style={{
            fontFamily: 'var(--font-sans)',
            fontWeight: 700,
            color: '#fff',
            background: 'rgba(0, 0, 0, 0.25)',
            padding: '2px 7px',
            borderRadius: '5px',
            border: '1px solid rgba(255, 255, 255, 0.05)',
            borderBottomWidth: '2px',
            margin: '0 3px',
          }}>D/→</kbd> Rotate
        </span>
        <span>
          <kbd style={{
            fontFamily: 'var(--font-sans)',
            fontWeight: 700,
            color: '#fff',
            background: 'rgba(0, 0, 0, 0.25)',
            padding: '2px 7px',
            borderRadius: '5px',
            border: '1px solid rgba(255, 255, 255, 0.05)',
            borderBottomWidth: '2px',
            margin: '0 3px',
          }}>E/SPACE</kbd> Turn
        </span>
      </div>

      {/* Timer bar */}
      <div style={{
        width: `${LOCK_SIZE}px`,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        gap: '4px',
      }}>
        <div style={{
          width: '100%',
          height: '4px',
          borderRadius: '2px',
          background: 'rgba(255, 255, 255, 0.08)',
          overflow: 'hidden',
        }}>
          <div style={{
            height: '100%',
            borderRadius: '2px',
            width: `${timerProgress * 100}%`,
            background: timerProgress > 0.3 ? 'var(--brand)' : 'var(--error)',
            transition: 'width 0.05s linear, background 0.3s ease',
          }} />
        </div>
        <span style={{
          fontSize: '11px',
          fontWeight: 600,
          color: timerProgress > 0.3 ? 'rgba(255, 255, 255, 0.4)' : 'var(--error)',
          fontVariantNumeric: 'tabular-nums',
        }}>
          {timerSeconds}s
        </span>
      </div>
    </motion.div>
  );
}
