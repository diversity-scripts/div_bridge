import React, { useState, useEffect, useRef, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

const PHASES = {
  PREVIEW: 'preview',
  ACTIVE: 'active',
  DONE: 'done',
};

export function RapidKeySequence({ config, onResult, cancelKey }) {
  const { keys, duration, showDuration = 1500 } = config;

  const [phase, setPhase] = useState(PHASES.PREVIEW);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [timeLeft, setTimeLeft] = useState(duration);
  const [result, setResult] = useState(null); // 'success' | 'error' | null

  const isFinishedRef = useRef(false);
  const timerRef = useRef(null);
  const countdownRef = useRef(null);
  const startTimeRef = useRef(null);
  const onResultRef = useRef(onResult);
  onResultRef.current = onResult;

  // Finish the minigame
  const finish = useCallback((success) => {
    if (isFinishedRef.current) return;
    isFinishedRef.current = true;

    setResult(success ? 'success' : 'error');
    setPhase(PHASES.DONE);

    // Clear timers
    if (timerRef.current) clearTimeout(timerRef.current);
    if (countdownRef.current) cancelAnimationFrame(countdownRef.current);

    // Delay before calling onResult to allow animation
    setTimeout(() => {
      onResultRef.current(success);
    }, 500);
  }, []);

  // Preview phase → Active phase transition
  useEffect(() => {
    if (phase !== PHASES.PREVIEW) return;

    const previewTimer = setTimeout(() => {
      if (isFinishedRef.current) return;
      setPhase(PHASES.ACTIVE);
    }, showDuration);

    return () => clearTimeout(previewTimer);
  }, [phase, showDuration]);

  // Active phase: start countdown timer
  useEffect(() => {
    if (phase !== PHASES.ACTIVE) return;

    startTimeRef.current = Date.now();

    // Main timeout for failure
    timerRef.current = setTimeout(() => {
      finish(false);
    }, duration);

    // Countdown animation frame loop
    const updateCountdown = () => {
      if (isFinishedRef.current) return;
      const elapsed = Date.now() - startTimeRef.current;
      const remaining = Math.max(0, duration - elapsed);
      setTimeLeft(remaining);

      if (remaining > 0) {
        countdownRef.current = requestAnimationFrame(updateCountdown);
      }
    };
    countdownRef.current = requestAnimationFrame(updateCountdown);

    return () => {
      if (timerRef.current) clearTimeout(timerRef.current);
      if (countdownRef.current) cancelAnimationFrame(countdownRef.current);
    };
  }, [phase, duration, finish]);

  // Keydown listener
  useEffect(() => {
    const handleKeyDown = (e) => {
      if (isFinishedRef.current) return;

      // Cancel key is handled by the orchestrator, but ignore it here
      if (e.key === cancelKey || e.code === cancelKey) return;

      // Only process keys during active phase
      if (phase !== PHASES.ACTIVE) return;

      const pressedKey = e.key.toUpperCase();
      const expectedKey = keys[currentIndex].toUpperCase();

      if (pressedKey === expectedKey) {
        const nextIndex = currentIndex + 1;
        setCurrentIndex(nextIndex);

        // Check if all keys completed
        if (nextIndex >= keys.length) {
          finish(true);
        }
      } else {
        // Wrong key = immediate failure
        finish(false);
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [phase, currentIndex, keys, cancelKey, finish]);

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      if (timerRef.current) clearTimeout(timerRef.current);
      if (countdownRef.current) cancelAnimationFrame(countdownRef.current);
    };
  }, []);

  const timerProgress = phase === PHASES.ACTIVE ? timeLeft / duration : 1;
  const timerSeconds = (timeLeft / 1000).toFixed(1);

  return (
    <motion.div
      className="rapid-key-sequence"
      initial={{ opacity: 0, scale: 0.95, y: 10 }}
      animate={{
        opacity: 1,
        scale: result === 'success' ? 1.02 : 1,
        y: 0,
        x: result === 'error' ? [0, -6, 6, -4, 4, 0] : 0,
      }}
      exit={{ opacity: 0, scale: 0.95 }}
      transition={{
        type: 'spring',
        stiffness: 400,
        damping: 30,
        x: { duration: 0.4, ease: 'easeInOut' },
      }}
      style={styles.container}
    >
      {/* Phase label */}
      <AnimatePresence mode="wait">
        <motion.div
          key={phase + (result || '')}
          initial={{ opacity: 0, y: -8 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: 8 }}
          transition={{ duration: 0.2 }}
          style={styles.phaseLabel}
        >
          {phase === PHASES.PREVIEW && 'Memorize the sequence...'}
          {phase === PHASES.ACTIVE && 'Press the keys!'}
          {phase === PHASES.DONE && (result === 'success' ? 'Success!' : 'Failed!')}
        </motion.div>
      </AnimatePresence>

      {/* Key sequence display */}
      <div style={styles.keysRow}>
        <AnimatePresence>
          {keys.map((key, index) => {
            const isCompleted = index < currentIndex;
            const isCurrent = index === currentIndex && phase === PHASES.ACTIVE;
            const isFailed = result === 'error' && index === currentIndex;

            return (
              <motion.div
                key={`${key}-${index}`}
                initial={{ opacity: 0, scale: 0, y: 10 }}
                animate={{
                  opacity: 1,
                  scale: isCurrent ? 1.15 : 1,
                  y: 0,
                }}
                transition={{
                  delay: index * 0.06,
                  type: 'spring',
                  stiffness: 400,
                  damping: 25,
                }}
                style={{
                  ...styles.keyBadge,
                  ...(isCompleted ? styles.keyCompleted : {}),
                  ...(isCurrent ? styles.keyCurrent : {}),
                  ...(isFailed ? styles.keyFailed : {}),
                }}
              >
                {isCompleted ? (
                  <motion.span
                    initial={{ scale: 0 }}
                    animate={{ scale: 1 }}
                    transition={{ type: 'spring', stiffness: 500, damping: 20 }}
                    style={styles.checkmark}
                  >
                    ✓
                  </motion.span>
                ) : (
                  <span style={styles.keyText}>{key}</span>
                )}
              </motion.div>
            );
          })}
        </AnimatePresence>
      </div>

      {/* Timer bar */}
      <div style={styles.timerContainer}>
        <div style={styles.timerBarBackground}>
          <motion.div
            style={{
              ...styles.timerBarFill,
              backgroundColor:
                timerProgress > 0.3
                  ? 'var(--brand)'
                  : timerProgress > 0.15
                  ? 'var(--warning)'
                  : 'var(--error)',
            }}
            animate={{ width: `${timerProgress * 100}%` }}
            transition={{ duration: 0.1, ease: 'linear' }}
          />
        </div>
        <span style={styles.timerText}>
          {phase === PHASES.PREVIEW ? 'GET READY' : `${timerSeconds}s`}
        </span>
      </div>
    </motion.div>
  );
}

const styles = {
  container: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    gap: '20px',
    fontFamily: 'var(--font-sans)',
    pointerEvents: 'all',
    minWidth: '320px',
  },
  phaseLabel: {
    fontSize: '13px',
    fontWeight: 600,
    color: 'rgba(255, 255, 255, 0.5)',
    textTransform: 'uppercase',
    letterSpacing: '1px',
  },
  keysRow: {
    display: 'flex',
    alignItems: 'center',
    gap: '10px',
    flexWrap: 'wrap',
    justifyContent: 'center',
  },
  keyBadge: {
    width: '48px',
    height: '48px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: '10px',
    background: 'rgba(255, 255, 255, 0.06)',
    border: '1px solid rgba(255, 255, 255, 0.1)',
    transition: 'background 0.2s, border-color 0.2s, box-shadow 0.2s',
  },
  keyCompleted: {
    background: 'rgba(var(--success-rgb), 0.15)',
    borderColor: 'rgba(var(--success-rgb), 0.4)',
    boxShadow: '0 0 12px rgba(var(--success-rgb), 0.2)',
  },
  keyCurrent: {
    background: 'rgba(var(--brand-rgb), 0.2)',
    borderColor: 'var(--brand)',
    boxShadow: '0 0 16px rgba(var(--brand-rgb), 0.4)',
  },
  keyFailed: {
    background: 'rgba(var(--error-rgb), 0.2)',
    borderColor: 'var(--error)',
    boxShadow: '0 0 16px rgba(var(--error-rgb), 0.4)',
  },
  keyText: {
    fontSize: '18px',
    fontWeight: 700,
    color: '#fff',
    textShadow: '0 1px 2px rgba(0, 0, 0, 0.5)',
  },
  checkmark: {
    fontSize: '18px',
    fontWeight: 700,
    color: 'var(--success)',
  },
  timerContainer: {
    width: '100%',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    gap: '6px',
  },
  timerBarBackground: {
    width: '100%',
    height: '6px',
    borderRadius: '3px',
    background: 'rgba(255, 255, 255, 0.08)',
    overflow: 'hidden',
  },
  timerBarFill: {
    height: '100%',
    borderRadius: '3px',
    boxShadow: '0 0 8px rgba(var(--brand-rgb), 0.4)',
  },
  timerText: {
    fontSize: '12px',
    fontWeight: 600,
    color: 'rgba(255, 255, 255, 0.5)',
    fontVariantNumeric: 'tabular-nums',
  },
};
