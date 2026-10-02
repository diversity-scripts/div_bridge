import React, { useState, useEffect, useRef, useCallback, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

/**
 * NumberPad Minigame
 *
 * A virtual numeric keypad (0-9) where the player enters a target code
 * within a time limit and limited attempts.
 *
 * Features:
 * - Code display area showing entered digits with placeholder dots
 * - Countdown timer
 * - Optional scrambled keypad layout per attempt
 * - Error shake animation on wrong code
 * - Success scale-up animation on correct code
 */

/** Standard keypad layout: 1-9 in rows, 0 at bottom center */
const STANDARD_LAYOUT = ['1', '2', '3', '4', '5', '6', '7', '8', '9', null, '0', null];

/**
 * Generate a scrambled layout of digits 0-9 in a 4-row x 3-col grid.
 * All 10 digits placed randomly, with 2 empty slots.
 */
function generateScrambledLayout() {
  const digits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  // Fisher-Yates shuffle
  for (let i = digits.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [digits[i], digits[j]] = [digits[j], digits[i]];
  }

  // Place 10 digits into 12 slots (3x4 grid), 2 slots will be empty
  const slots = new Array(12).fill(null);
  const positions = [];
  for (let i = 0; i < 12; i++) positions.push(i);

  // Shuffle positions and pick first 10 for digits
  for (let i = positions.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [positions[i], positions[j]] = [positions[j], positions[i]];
  }

  for (let i = 0; i < 10; i++) {
    slots[positions[i]] = digits[i];
  }

  return slots;
}

export function NumberPad({ config, onResult, cancelKey }) {
  const { code = '1234', attempts = 3, timeLimit = 20000, scramble = false } = config;

  const [enteredCode, setEnteredCode] = useState('');
  const [remainingAttempts, setRemainingAttempts] = useState(attempts);
  const [timeRemaining, setTimeRemaining] = useState(timeLimit);
  const [displayState, setDisplayState] = useState('idle'); // 'idle' | 'error' | 'success'
  const [layout, setLayout] = useState(() => scramble ? generateScrambledLayout() : STANDARD_LAYOUT);

  const isFinishedRef = useRef(false);
  const timerIntervalRef = useRef(null);
  const onResultRef = useRef(onResult);
  onResultRef.current = onResult;

  // Finish the game
  const finish = useCallback((success) => {
    if (isFinishedRef.current) return;
    isFinishedRef.current = true;

    setDisplayState(success ? 'success' : 'error');

    if (timerIntervalRef.current) {
      clearInterval(timerIntervalRef.current);
      timerIntervalRef.current = null;
    }

    // Delay for visual feedback
    setTimeout(() => {
      onResultRef.current(success);
    }, 500);
  }, []);

  // Start countdown timer on mount
  useEffect(() => {
    const startTime = Date.now();

    timerIntervalRef.current = setInterval(() => {
      const elapsed = Date.now() - startTime;
      const remaining = Math.max(0, timeLimit - elapsed);
      setTimeRemaining(remaining);

      if (remaining <= 0) {
        clearInterval(timerIntervalRef.current);
        timerIntervalRef.current = null;
        finish(false);
      }
    }, 50);

    return () => {
      if (timerIntervalRef.current) {
        clearInterval(timerIntervalRef.current);
        timerIntervalRef.current = null;
      }
    };
  }, [timeLimit, finish]);

  // Handle digit press
  const handleDigitPress = useCallback((digit) => {
    if (isFinishedRef.current || displayState === 'error' || displayState === 'success') return;

    const newCode = enteredCode + digit;
    setEnteredCode(newCode);

    // Check if we've entered enough digits
    if (newCode.length === code.length) {
      if (newCode === code) {
        // Correct code — success
        finish(true);
      } else {
        // Wrong code — decrement attempts
        const newAttempts = remainingAttempts - 1;
        setRemainingAttempts(newAttempts);

        if (newAttempts <= 0) {
          // No attempts left — failure
          finish(false);
        } else {
          // Flash error, clear code, re-scramble if needed
          setDisplayState('error');
          setTimeout(() => {
            setEnteredCode('');
            setDisplayState('idle');
            if (scramble) {
              setLayout(generateScrambledLayout());
            }
          }, 500);
        }
      }
    }
  }, [enteredCode, code, remainingAttempts, scramble, finish, displayState]);

  // Timer progress (1 = full, 0 = expired)
  const timerProgress = timeLimit > 0 ? timeRemaining / timeLimit : 0;
  const timerSeconds = Math.ceil(timeRemaining / 1000);

  return (
    <motion.div
      className="numberpad-container"
      initial={{ opacity: 0, scale: 0.95, y: 8 }}
      animate={{ opacity: 1, scale: 1, y: 0 }}
      exit={{ opacity: 0, scale: 0.95 }}
      transition={{ type: 'spring', stiffness: 400, damping: 30 }}
      style={{ pointerEvents: 'all' }}
    >
      {/* Timer */}
      <div className="numberpad-timer" style={{ width: '100%' }}>
        <div style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          gap: '8px',
          marginBottom: '6px',
        }}>
          <span style={{
            fontSize: '13px',
            fontWeight: 600,
            color: timerProgress > 0.3 ? 'rgba(255, 255, 255, 0.5)' : 'var(--error)',
          }}>
            {timerSeconds}s
          </span>
        </div>
        <div style={{
          width: '100%',
          height: '4px',
          borderRadius: '2px',
          background: 'rgba(255, 255, 255, 0.1)',
          overflow: 'hidden',
        }}>
          <motion.div
            style={{
              height: '100%',
              borderRadius: '2px',
              background: timerProgress > 0.3 ? 'var(--brand)' : 'var(--error)',
            }}
            animate={{ width: `${timerProgress * 100}%` }}
            transition={{ duration: 0.05, ease: 'linear' }}
          />
        </div>
      </div>

      {/* Code display area */}
      <motion.div
        className={`numberpad-display${displayState === 'error' ? ' numberpad-display--error' : ''}${displayState === 'success' ? ' numberpad-display--success' : ''}`}
        animate={
          displayState === 'error'
            ? { x: [0, -6, 5, -4, 3, -2, 1, 0], borderColor: 'rgba(var(--error-rgb), 0.6)' }
            : displayState === 'success'
              ? { scale: [1, 1.06, 1], borderColor: 'rgba(var(--success-rgb), 0.6)' }
              : { x: 0, scale: 1 }
        }
        transition={{ duration: 0.4, ease: 'easeOut' }}
      >
        {Array.from({ length: code.length }, (_, idx) => {
          const hasDigit = idx < enteredCode.length;
          return (
            <motion.span
              key={idx}
              initial={hasDigit ? { scale: 0.5, opacity: 0 } : false}
              animate={{ scale: 1, opacity: 1 }}
              style={{
                display: 'inline-block',
                width: '20px',
                height: '28px',
                lineHeight: '28px',
                textAlign: 'center',
                fontSize: hasDigit ? '24px' : '12px',
                fontWeight: 800,
                color: hasDigit
                  ? displayState === 'success' ? 'var(--success)' : displayState === 'error' ? 'var(--error)' : '#fff'
                  : 'rgba(255, 255, 255, 0.25)',
              }}
            >
              {hasDigit ? enteredCode[idx] : '●'}
            </motion.span>
          );
        })}
      </motion.div>

      {/* Keypad grid */}
      <motion.div
        className="numberpad-grid"
        initial="hidden"
        animate="visible"
        variants={{
          hidden: {},
          visible: {
            transition: { staggerChildren: 0.03 },
          },
        }}
      >
        {layout.map((digit, idx) => (
          <KeyButton
            key={`${idx}-${digit}`}
            digit={digit}
            index={idx}
            onPress={handleDigitPress}
            disabled={isFinishedRef.current || displayState === 'error'}
          />
        ))}
      </motion.div>

      {/* Attempts remaining */}
      <span className="numberpad-attempts">
        {remainingAttempts} attempt{remainingAttempts !== 1 ? 's' : ''} remaining
      </span>
    </motion.div>
  );
}

/**
 * Individual key button component with framer-motion animations
 */
function KeyButton({ digit, index, onPress, disabled }) {
  if (digit === null) {
    // Empty slot
    return <div style={{ width: '56px', height: '56px' }} />;
  }

  return (
    <motion.button
      className="numberpad-key"
      variants={{
        hidden: { opacity: 0, scale: 0.7, y: 8 },
        visible: { opacity: 1, scale: 1, y: 0 },
      }}
      whileHover={!disabled ? { scale: 1.08, background: 'rgba(255, 255, 255, 0.12)' } : {}}
      whileTap={!disabled ? { scale: 0.92, background: 'rgba(var(--brand-rgb), 0.3)' } : {}}
      onClick={() => !disabled && onPress(digit)}
      style={{
        cursor: disabled ? 'default' : 'pointer',
        opacity: disabled ? 0.5 : 1,
      }}
      type="button"
    >
      {digit}
    </motion.button>
  );
}
