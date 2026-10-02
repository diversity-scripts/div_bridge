import React, { useState, useEffect, useRef, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

/**
 * TimingBar Minigame
 *
 * Uses CSS transition for smooth indicator movement.
 * Position calculation uses the exact same start time as the CSS transition.
 */

const BAR_WIDTH = 300;

function getZoneWidth(zoneSize, zoneShrink, round) {
  return Math.max(zoneSize - zoneShrink * (round - 1), 2);
}

function generateZoneStart(zoneWidth) {
  return Math.random() * (100 - zoneWidth);
}

export function TimingBar({ config, onResult, cancelKey }) {
  const { rounds = 3, speed = 1.5, zoneSize = 22, zoneShrink = 3, key: configKey = 'SPACE' } = config;

  // Duration for indicator to cross full bar (in seconds)
  // speed is px/frame at 60fps => frames to cross = BAR_WIDTH/speed => seconds = frames/60
  const duration = (BAR_WIDTH / speed) / 60;

  const [currentRound, setCurrentRound] = useState(1);
  const [started, setStarted] = useState(false);
  const [zoneStart, setZoneStart] = useState(() => {
    const width = getZoneWidth(zoneSize, zoneShrink, 1);
    return generateZoneStart(width);
  });
  const [roundResult, setRoundResult] = useState(null);
  const [isTransitioning, setIsTransitioning] = useState(false);
  const [indicatorLeft, setIndicatorLeft] = useState('0%');
  const [timeRemaining, setTimeRemaining] = useState(duration * rounds * 1000);

  const isFinishedRef = useRef(false);
  const startTimeRef = useRef(0);
  const currentRoundRef = useRef(1);
  const zoneStartRef = useRef(zoneStart);
  const failTimeoutRef = useRef(null);
  const onResultRef = useRef(onResult);
  const timerIntervalRef = useRef(null);

  currentRoundRef.current = currentRound;
  zoneStartRef.current = zoneStart;
  onResultRef.current = onResult;

  const totalTimeLimit = duration * rounds * 1000 + (rounds - 1) * 800 + 2000; // account for transitions + buffer

  const currentZoneWidth = getZoneWidth(zoneSize, zoneShrink, currentRound);

  // Overall countdown timer
  useEffect(() => {
    const startTime = Date.now();

    timerIntervalRef.current = setInterval(() => {
      if (isFinishedRef.current) {
        clearInterval(timerIntervalRef.current);
        return;
      }
      const elapsed = Date.now() - startTime;
      const remaining = Math.max(0, totalTimeLimit - elapsed);
      setTimeRemaining(remaining);

      if (remaining <= 0) {
        clearInterval(timerIntervalRef.current);
        timerIntervalRef.current = null;
        if (!isFinishedRef.current) {
          isFinishedRef.current = true;
          setRoundResult('fail');
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
  }, [totalTimeLimit]);

  // Start the animation for current round
  useEffect(() => {
    if (isTransitioning || isFinishedRef.current) return;

    // Reset to left
    setIndicatorLeft('0%');
    setStarted(false);

    // Use double-rAF to ensure the browser has painted 0% before we transition to 100%
    let raf1, raf2;
    raf1 = requestAnimationFrame(() => {
      raf2 = requestAnimationFrame(() => {
        if (isFinishedRef.current) return;
        startTimeRef.current = Date.now();
        setIndicatorLeft('100%');
        setStarted(true);

        // Fail timeout when indicator reaches end
        failTimeoutRef.current = setTimeout(() => {
          if (!isFinishedRef.current) {
            isFinishedRef.current = true;
            setRoundResult('fail');
            onResultRef.current(false);
          }
        }, duration * 1000 + 100);
      });
    });

    return () => {
      cancelAnimationFrame(raf1);
      cancelAnimationFrame(raf2);
      if (failTimeoutRef.current) clearTimeout(failTimeoutRef.current);
    };
  }, [currentRound, isTransitioning, duration]);

  // Handle key release
  useEffect(() => {
    const handleKeyUp = (e) => {
      if (isFinishedRef.current || isTransitioning || !started) return;

      const targetKey = configKey.toUpperCase();
      const pressedKey = e.key === ' ' ? 'SPACE' : e.key.toUpperCase();
      const pressedCode = e.code.toUpperCase();

      if (pressedKey !== targetKey && pressedCode !== targetKey) return;
      e.preventDefault();

      if (failTimeoutRef.current) {
        clearTimeout(failTimeoutRef.current);
        failTimeoutRef.current = null;
      }

      // Calculate position: elapsed / total duration * 100
      const elapsed = Date.now() - startTimeRef.current;
      const pos = Math.min((elapsed / (duration * 1000)) * 100, 100);

      const zStart = zoneStartRef.current;
      const zWidth = getZoneWidth(zoneSize, zoneShrink, currentRoundRef.current);
      const zEnd = zStart + zWidth;
      const inZone = pos >= zStart && pos <= zEnd;

      // Freeze the indicator at current position
      setIndicatorLeft(`${pos}%`);
      setStarted(false);

      if (!inZone) {
        isFinishedRef.current = true;
        setRoundResult('fail');
        onResultRef.current(false);
      } else {
        setRoundResult('success');

        if (currentRoundRef.current >= rounds) {
          isFinishedRef.current = true;
          onResultRef.current(true);
        } else {
          setIsTransitioning(true);
          setTimeout(() => {
            const nextRound = currentRoundRef.current + 1;
            const nextZoneWidth = getZoneWidth(zoneSize, zoneShrink, nextRound);
            const nextZoneStart = generateZoneStart(nextZoneWidth);

            setCurrentRound(nextRound);
            setZoneStart(nextZoneStart);
            zoneStartRef.current = nextZoneStart;
            setRoundResult(null);
            setIsTransitioning(false);
          }, 600);
        }
      }
    };

    window.addEventListener('keyup', handleKeyUp);
    return () => window.removeEventListener('keyup', handleKeyUp);
  }, [configKey, zoneSize, zoneShrink, rounds, isTransitioning, started, duration]);

  const resultColor = roundResult === 'success'
    ? 'var(--success)'
    : roundResult === 'fail'
      ? 'var(--error)'
      : null;

  const timerProgress = totalTimeLimit > 0 ? timeRemaining / totalTimeLimit : 0;
  const timerSeconds = (timeRemaining / 1000).toFixed(1);

  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ type: 'spring', stiffness: 400, damping: 30 }}
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        gap: '12px',
        fontFamily: 'var(--font-sans)',
        pointerEvents: 'all',
      }}
    >
      <AnimatePresence mode="wait">
        <motion.span
          key={currentRound}
          initial={{ opacity: 0, y: -6 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: 6 }}
          transition={{ duration: 0.2 }}
          style={{
            fontSize: '13px',
            fontWeight: 600,
            color: 'rgba(255, 255, 255, 0.7)',
          }}
        >
          Round {currentRound}/{rounds}
        </motion.span>
      </AnimatePresence>

      {/* Bar */}
      <div style={{
        position: 'relative',
        width: `${BAR_WIDTH}px`,
        height: '30px',
        borderRadius: '14px',
        background: 'linear-gradient(180deg, rgb(35, 36, 39), rgb(28, 29, 31))',
        border: resultColor
          ? `1.5px solid ${resultColor}`
          : '1px solid rgba(255, 255, 255, 0.08)',
        boxShadow: resultColor
          ? `0 0 12px ${resultColor}40`
          : '0 8px 20px rgba(0, 0, 0, 0.3)',
        overflow: 'hidden',
      }}>
        {/* Target zone */}
        <div style={{
          position: 'absolute',
          top: 0,
          bottom: 0,
          left: `${zoneStart}%`,
          width: `${currentZoneWidth}%`,
          background: 'rgba(var(--brand-rgb), 0.35)',
          borderLeft: '2px solid var(--brand)',
          borderRight: '2px solid var(--brand)',
          borderRadius: '4px',
        }} />

        {/* Indicator — CSS transition drives the movement */}
        <div style={{
          position: 'absolute',
          top: '2px',
          bottom: '2px',
          left: indicatorLeft,
          width: '4px',
          borderRadius: '2px',
          background: '#fff',
          boxShadow: '0 0 8px rgba(255, 255, 255, 0.8)',
          transform: 'translateX(-50%)',
          transition: started ? `left ${duration}s linear` : 'none',
        }} />
      </div>

      <span style={{
        fontSize: '12px',
        fontWeight: 500,
        color: 'rgba(255, 255, 255, 0.4)',
      }}>
        Release <kbd style={{
          fontFamily: 'var(--font-sans)',
          fontWeight: 700,
          color: '#fff',
          background: 'rgba(0, 0, 0, 0.25)',
          padding: '2px 7px',
          borderRadius: '5px',
          border: '1px solid rgba(255, 255, 255, 0.05)',
          borderBottomWidth: '2px',
          margin: '0 3px',
        }}>{configKey}</kbd> in the zone
      </span>

      {/* Timer bar */}
      <div style={{
        width: `${BAR_WIDTH}px`,
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
