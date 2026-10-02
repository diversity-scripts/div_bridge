import React, { useState, useEffect, useRef, useCallback, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

/**
 * MemoryPattern minigame component.
 *
 * Phases:
 * 1. Preview: highlights pattern cells sequentially
 * 2. Input: player clicks cells in order to reproduce the pattern
 */

// Generate an array of `length` unique random indices from 0 to max-1
function generatePattern(gridSize, patternLength) {
  const totalCells = gridSize * gridSize;
  const indices = [];
  const used = new Set();

  while (indices.length < patternLength) {
    const idx = Math.floor(Math.random() * totalCells);
    if (!used.has(idx)) {
      used.add(idx);
      indices.push(idx);
    }
  }

  return indices;
}

const PHASES = {
  READY: 'ready',
  PREVIEW: 'preview',
  INPUT: 'input',
  DONE: 'done',
};

export function MemoryPattern({ config, onResult, cancelKey }) {
  const { gridSize = 4, patternLength = 5, previewDuration = 2000, timeLimit = 10000 } = config;

  // Generate pattern once on mount
  const pattern = useMemo(() => generatePattern(gridSize, patternLength), [gridSize, patternLength]);

  const [phase, setPhase] = useState(PHASES.READY);
  const [previewIndex, setPreviewIndex] = useState(-1); // which cell is currently highlighted in preview
  const [currentInputIndex, setCurrentInputIndex] = useState(0);
  const [correctCells, setCorrectCells] = useState([]); // cells correctly clicked
  const [failedCell, setFailedCell] = useState(null);
  const [timeRemaining, setTimeRemaining] = useState(timeLimit);

  const isFinishedRef = useRef(false);
  const timerIntervalRef = useRef(null);
  const previewTimeoutRef = useRef(null);
  const onResultRef = useRef(onResult);
  onResultRef.current = onResult;

  // Finish the game
  const finish = useCallback((success) => {
    if (isFinishedRef.current) return;
    isFinishedRef.current = true;
    setPhase(PHASES.DONE);

    if (timerIntervalRef.current) {
      clearInterval(timerIntervalRef.current);
      timerIntervalRef.current = null;
    }

    // Small delay for visual feedback before calling result
    setTimeout(() => {
      onResultRef.current(success);
    }, 400);
  }, []);

  // Ready phase: brief pause before starting preview
  useEffect(() => {
    if (phase !== PHASES.READY) return;

    const readyTimer = setTimeout(() => {
      setPhase(PHASES.PREVIEW);
    }, 1500); // 1.5 second "get ready" pause

    return () => clearTimeout(readyTimer);
  }, [phase]);

  // Preview phase: highlight cells sequentially
  useEffect(() => {
    if (phase !== PHASES.PREVIEW) return;

    const stepDuration = previewDuration / patternLength;
    let step = 0;

    // Show first cell immediately
    setPreviewIndex(0);
    step = 1;

    const interval = setInterval(() => {
      if (step < patternLength) {
        setPreviewIndex(step);
        step++;
      } else {
        clearInterval(interval);
        // Pause after last cell shown so player can process, then transition to input
        previewTimeoutRef.current = setTimeout(() => {
          setPreviewIndex(-1);
          setPhase(PHASES.INPUT);
        }, 1000);
      }
    }, stepDuration);

    return () => {
      clearInterval(interval);
      if (previewTimeoutRef.current) {
        clearTimeout(previewTimeoutRef.current);
      }
    };
  }, [phase, patternLength, previewDuration]);

  // Start countdown timer from the beginning (includes preview time)
  useEffect(() => {
    if (phase === PHASES.DONE) return;
    if (phase === PHASES.READY) return; // don't start until preview begins

    if (phase === PHASES.PREVIEW) {
      // Start the overall timer when preview begins
      const totalTime = previewDuration + 1000 + timeLimit; // preview + pause + input time
      const startTime = Date.now();
      setTimeRemaining(totalTime);

      timerIntervalRef.current = setInterval(() => {
        const elapsed = Date.now() - startTime;
        const remaining = Math.max(0, totalTime - elapsed);
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
    }
  }, [phase, previewDuration, timeLimit, finish]);

  // Timer progress — use total time (preview + pause + input)
  const totalTime = previewDuration + 1000 + timeLimit;
  const timerProgress = totalTime > 0 ? timeRemaining / totalTime : 0;
  const handleCellClick = useCallback((cellIndex) => {
    if (phase !== PHASES.INPUT || isFinishedRef.current) return;

    const expectedCell = pattern[currentInputIndex];

    if (cellIndex === expectedCell) {
      // Correct click
      const newCorrectCells = [...correctCells, cellIndex];
      setCorrectCells(newCorrectCells);
      const nextIndex = currentInputIndex + 1;
      setCurrentInputIndex(nextIndex);

      // Check if all cells reproduced
      if (nextIndex >= patternLength) {
        finish(true);
      }
    } else {
      // Incorrect click - immediate failure
      setFailedCell(cellIndex);
      finish(false);
    }
  }, [phase, pattern, currentInputIndex, correctCells, patternLength, finish]);

  const totalCells = gridSize * gridSize;

  return (
    <motion.div
      className="memory-pattern-container"
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      exit={{ opacity: 0, scale: 0.95 }}
      transition={{ type: 'spring', stiffness: 400, damping: 30 }}
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        gap: '16px',
        pointerEvents: 'all',
        fontFamily: 'var(--font-sans)',
        minWidth: '280px',
      }}
    >
      {/* Phase indicator / Timer */}
      <div style={{
        width: '100%',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        gap: '8px',
      }}>
        <AnimatePresence mode="wait">
          <motion.span
            key={phase}
            initial={{ opacity: 0, y: -8 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 8 }}
            transition={{ duration: 0.2 }}
            style={{
              fontSize: '13px',
              fontWeight: 600,
              color: phase === PHASES.READY ? 'rgba(255, 255, 255, 0.5)' : phase === PHASES.PREVIEW ? 'var(--brand)' : 'rgba(255, 255, 255, 0.7)',
              textTransform: 'uppercase',
              letterSpacing: '0.5px',
            }}
          >
            {phase === PHASES.READY ? 'Get Ready...' : phase === PHASES.PREVIEW ? 'Memorize' : phase === PHASES.INPUT ? 'Reproduce' : 'Done'}
          </motion.span>
        </AnimatePresence>

        {/* Timer bar (visible from preview phase onwards) */}
        {phase !== PHASES.READY && (
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
        )}
      </div>

      {/* Grid */}
      <motion.div
        style={{
          display: 'grid',
          gridTemplateColumns: `repeat(${gridSize}, 1fr)`,
          gap: '6px',
          width: '100%',
          maxWidth: `${gridSize * 60 + (gridSize - 1) * 6}px`,
          aspectRatio: '1',
        }}
        initial="hidden"
        animate="visible"
        variants={{
          hidden: {},
          visible: {
            transition: { staggerChildren: 0.03 },
          },
        }}
      >
        {Array.from({ length: totalCells }, (_, idx) => (
          <Cell
            key={idx}
            index={idx}
            phase={phase}
            isPreviewHighlighted={phase === PHASES.PREVIEW && pattern[previewIndex] === idx}
            isCorrect={correctCells.includes(idx)}
            isFailed={failedCell === idx}
            isClickable={phase === PHASES.INPUT && !isFinishedRef.current}
            onClick={handleCellClick}
          />
        ))}
      </motion.div>

      {/* Progress dots showing pattern progress */}
      <div style={{
        display: 'flex',
        gap: '6px',
        alignItems: 'center',
      }}>
        {pattern.map((_, idx) => (
          <motion.div
            key={idx}
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ delay: idx * 0.03, type: 'spring', stiffness: 400, damping: 20 }}
            style={{
              width: '8px',
              height: '8px',
              borderRadius: '50%',
              background: idx < currentInputIndex
                ? 'var(--success)'
                : (phase === PHASES.PREVIEW && idx <= previewIndex)
                  ? 'var(--brand)'
                  : idx === currentInputIndex && phase === PHASES.INPUT
                    ? 'rgba(255, 255, 255, 0.5)'
                    : 'rgba(255, 255, 255, 0.15)',
              boxShadow: idx < currentInputIndex
                ? '0 0 6px rgba(var(--success-rgb), 0.5)'
                : (phase === PHASES.PREVIEW && idx <= previewIndex)
                  ? '0 0 6px rgba(var(--brand-rgb), 0.4)'
                  : 'none',
              transition: 'all 0.2s ease',
            }}
          />
        ))}
      </div>
    </motion.div>
  );
}

/**
 * Individual grid cell component
 */
function Cell({ index, phase, isPreviewHighlighted, isCorrect, isFailed, isClickable, onClick }) {
  const getBackground = () => {
    if (isFailed) return 'rgba(var(--error-rgb), 0.6)';
    if (isCorrect) return 'rgba(var(--success-rgb), 0.5)';
    if (isPreviewHighlighted) return 'rgba(var(--brand-rgb), 0.7)';
    return 'rgba(255, 255, 255, 0.06)';
  };

  const getBorder = () => {
    if (isFailed) return '1px solid rgba(var(--error-rgb), 0.8)';
    if (isCorrect) return '1px solid rgba(var(--success-rgb), 0.6)';
    if (isPreviewHighlighted) return '1px solid rgba(var(--brand-rgb), 0.9)';
    return '1px solid rgba(255, 255, 255, 0.08)';
  };

  const getBoxShadow = () => {
    if (isFailed) return '0 0 12px rgba(var(--error-rgb), 0.4), inset 0 0 8px rgba(var(--error-rgb), 0.2)';
    if (isCorrect) return '0 0 12px rgba(var(--success-rgb), 0.4), inset 0 0 8px rgba(var(--success-rgb), 0.2)';
    if (isPreviewHighlighted) return '0 0 16px rgba(var(--brand-rgb), 0.6), inset 0 0 10px rgba(var(--brand-rgb), 0.3)';
    return 'none';
  };

  return (
    <motion.div
      variants={{
        hidden: { opacity: 0, scale: 0.8 },
        visible: { opacity: 1, scale: 1 },
      }}
      animate={{
        background: getBackground(),
        border: getBorder(),
        boxShadow: getBoxShadow(),
        scale: isPreviewHighlighted ? 1.05 : isFailed ? [1, 1.1, 0.95, 1] : 1,
      }}
      transition={{
        duration: 0.25,
        ease: 'easeOut',
        scale: isFailed ? { duration: 0.3, times: [0, 0.3, 0.6, 1] } : { duration: 0.2 },
      }}
      whileHover={isClickable ? { scale: 1.05, background: 'rgba(255, 255, 255, 0.12)' } : {}}
      whileTap={isClickable ? { scale: 0.95 } : {}}
      onClick={() => isClickable && onClick(index)}
      style={{
        aspectRatio: '1',
        borderRadius: '8px',
        cursor: isClickable ? 'pointer' : 'default',
        transition: 'cursor 0.1s',
      }}
    />
  );
}
