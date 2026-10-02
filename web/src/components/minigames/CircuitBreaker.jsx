import React, { useState, useEffect, useRef, useCallback, useMemo } from 'react';
import { motion } from 'framer-motion';

/**
 * Shuffle an array in place using Fisher-Yates algorithm.
 */
export function shuffleArray(arr) {
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}

/**
 * Generate a circuit breaker puzzle (Among Us style).
 *
 * Goal: Turn ALL switches ON. But each switch, when toggled ON, may turn
 * OFF some other switches. There's a specific order that works.
 *
 * Algorithm:
 * 1. Generate a valid solution order (a permutation of all switch indices)
 * 2. For each switch (except the ones at the end), assign "disruptions" —
 *    switches that get turned OFF when this one is toggled ON, BUT only
 *    switches that come LATER in the solution order can be disrupted.
 *    This guarantees that if you follow the solution order, nothing gets undone.
 * 3. If you toggle a switch ON out of order, it may turn off earlier ones,
 *    forcing you to redo them.
 *
 * @param {number} gridSize - Number of switches (arranged in rows)
 * @param {number} disruptionCount - How many disruption links to create
 * @returns {{ solutionOrder: number[], disruptions: Map<number, number[]> }}
 */
export function generatePuzzle(gridSize, disruptionCount) {
  // Generate solution order — the correct sequence to flip switches
  const solutionOrder = Array.from({ length: gridSize }, (_, i) => i);
  shuffleArray(solutionOrder);

  // Create disruption map: when switch X is turned ON, it turns OFF switches in its disruption list
  // Key insight: disruptions only target switches that are NOT yet in the "safe" zone
  // A switch is "safe" if it comes AFTER the current one in solution order
  // This means: if you flip them in the RIGHT order, disruptions don't matter
  // because disrupted switches haven't been turned on yet
  const disruptions = new Map();

  // Build position lookup: solutionOrder[pos] = switchIndex
  // We want: for switch at position P in solution, it can disrupt switches at positions < P
  // (i.e., switches that were turned on BEFORE it in the wrong order)
  // Actually — let's think of it differently:
  // If you flip switch X (which is at position P in solution), it disrupts switches
  // that are at positions > P. So if you flip X too early (before its prerequisites),
  // those later switches might already be ON and get turned off.

  // Simpler approach: each switch can disrupt 1-2 other switches.
  // The disruption only fires when you turn the switch ON.
  // The solution order guarantees: if you go in order, by the time you flip switch at pos P,
  // none of the switches it disrupts (at pos > P) are ON yet, so no harm done.

  const actualDisruptions = Math.min(disruptionCount, gridSize - 1);
  const candidates = [...solutionOrder]; // copy

  for (let d = 0; d < actualDisruptions; d++) {
    // Pick a switch that's NOT the last in solution order to be the disruptor
    const posInSolution = d % (gridSize - 1); // cycle through positions 0..n-2
    const disruptorIdx = solutionOrder[posInSolution];

    // It disrupts a switch that comes BEFORE it in solution order
    // (meaning: if you flip the disruptor AFTER its target is already ON, the target gets turned off)
    // Wait — we want the WRONG order to cause problems.
    // Let's say: switch at solution position P disrupts switch at solution position P+1
    // So if you flip P+1 first (ON), then flip P (ON), P's disruption turns P+1 OFF.
    // That means you MUST flip P before P+1.

    const targetPos = posInSolution + 1;
    if (targetPos < gridSize) {
      const targetIdx = solutionOrder[targetPos];
      if (!disruptions.has(disruptorIdx)) {
        disruptions.set(disruptorIdx, []);
      }
      // Only add if not already there
      const existing = disruptions.get(disruptorIdx);
      if (!existing.includes(targetIdx)) {
        existing.push(targetIdx);
      }
    }
  }

  return { solutionOrder, disruptions };
}

/**
 * Apply a toggle. When turning ON, apply disruptions (turn off linked switches).
 * When turning OFF, no side effects.
 */
export function applyToggle(switches, index, disruptions) {
  const next = [...switches];
  const wasOff = !next[index];
  next[index] = !next[index];

  // Only apply disruptions when turning ON
  if (wasOff && disruptions.has(index)) {
    for (const target of disruptions.get(index)) {
      next[target] = false; // turn off disrupted switches
    }
  }

  return next;
}

/**
 * CircuitBreaker minigame — Among Us electrical style.
 *
 * All switches start OFF. Goal: get them ALL ON.
 * Each switch may disrupt (turn off) other switches when flipped ON.
 * Find the right order to flip them all on without undoing progress.
 */
export function CircuitBreaker({ config, onResult, cancelKey }) {
  let {
    switchCount = 9,
    linkedPairs: disruptionCount = 3,
    timeLimit = 20000,
    maxMoves = null,
  } = config;

  // Clamp
  if (switchCount < 4) switchCount = 9;
  if (disruptionCount < 0) disruptionCount = 0;
  if (disruptionCount >= switchCount) disruptionCount = switchCount - 1;

  // Grid layout: square grid (gridSize x gridSize)
  const gridSide = Math.round(Math.sqrt(switchCount));
  const cols = gridSide;
  const rows = gridSide;
  // Force switchCount to be a perfect square
  switchCount = gridSide * gridSide;

  // Refs
  const isFinishedRef = useRef(false);
  const onResultRef = useRef(onResult);
  const disruptionsRef = useRef(new Map());
  const timerIntervalRef = useRef(null);
  onResultRef.current = onResult;

  // State
  const [switches, setSwitches] = useState([]);
  const [movesUsed, setMovesUsed] = useState(0);
  const [timeRemaining, setTimeRemaining] = useState(timeLimit);
  const [lastToggled, setLastToggled] = useState(null);
  const [disrupted, setDisrupted] = useState([]); // indices that just got disrupted (for flash animation)

  // Generate puzzle on mount
  useEffect(() => {
    const puzzle = generatePuzzle(switchCount, disruptionCount);
    setSwitches(Array(switchCount).fill(false));
    disruptionsRef.current = puzzle.disruptions;
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  // Timer countdown
  useEffect(() => {
    const startTime = Date.now();
    setTimeRemaining(timeLimit);

    timerIntervalRef.current = setInterval(() => {
      if (isFinishedRef.current) return;
      const elapsed = Date.now() - startTime;
      const remaining = Math.max(0, timeLimit - elapsed);
      setTimeRemaining(remaining);

      if (remaining <= 0) {
        clearInterval(timerIntervalRef.current);
        timerIntervalRef.current = null;
        if (!isFinishedRef.current) {
          isFinishedRef.current = true;
          setTimeout(() => onResultRef.current(false), 600);
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

  // Handle toggle
  const handleToggle = useCallback((index) => {
    if (isFinishedRef.current) return;
    if (maxMoves && movesUsed >= maxMoves) return;

    const newSwitches = applyToggle(switches, index, disruptionsRef.current);
    setSwitches(newSwitches);
    setMovesUsed(prev => prev + 1);
    setLastToggled(index);

    // Show which switches got disrupted
    if (!switches[index] && disruptionsRef.current.has(index)) {
      const targets = disruptionsRef.current.get(index).filter(t => switches[t]); // only ones that were ON
      setDisrupted(targets);
      setTimeout(() => setDisrupted([]), 500);
    } else {
      setDisrupted([]);
    }

    // Check win — all ON
    if (newSwitches.every(v => v === true)) {
      isFinishedRef.current = true;
      setTimeout(() => onResultRef.current(true), 400);
      return;
    }

    // Check move limit
    if (maxMoves && movesUsed + 1 >= maxMoves) {
      if (!newSwitches.every(v => v === true)) {
        isFinishedRef.current = true;
        setTimeout(() => onResultRef.current(false), 600);
      }
    }
  }, [switches, movesUsed, maxMoves]);

  // Timer progress
  const timerProgress = timeLimit > 0 ? timeRemaining / timeLimit : 0;
  const timerSeconds = (timeRemaining / 1000).toFixed(1);

  // Count how many are ON
  const onCount = switches.filter(v => v).length;

  const cellSize = 52;

  if (switches.length === 0) return null;

  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      exit={{ opacity: 0, scale: 0.95 }}
      transition={{ type: 'spring', stiffness: 400, damping: 30 }}
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        gap: '16px',
        padding: '16px',
        pointerEvents: 'all',
        fontFamily: 'var(--font-sans)',
        userSelect: 'none',
      }}
    >
      {/* Progress indicator */}
      <div style={{
        display: 'flex',
        alignItems: 'center',
        gap: '8px',
      }}>
        <span style={{
          fontSize: '13px',
          fontWeight: 700,
          color: 'rgba(255, 255, 255, 0.6)',
        }}>
          {onCount} / {switchCount}
        </span>
        <span style={{
          fontSize: '11px',
          fontWeight: 600,
          color: 'rgba(255, 255, 255, 0.3)',
          textTransform: 'uppercase',
          letterSpacing: '0.5px',
        }}>
          online
        </span>
      </div>

      {/* Switch Grid — 2 rows */}
      <div style={{
        display: 'grid',
        gridTemplateColumns: `repeat(${cols}, ${cellSize}px)`,
        gap: '8px',
      }}>
        {switches.map((isOn, idx) => {
          const wasDisrupted = disrupted.includes(idx);

          return (
            <motion.div
              key={`s-${idx}`}
              onClick={() => handleToggle(idx)}
              animate={{
                scale: wasDisrupted ? [1, 0.85, 1.05, 1] : 1,
                x: wasDisrupted ? [0, -3, 3, -2, 0] : 0,
              }}
              transition={
                wasDisrupted
                  ? { duration: 0.4 }
                  : { duration: 0.15 }
              }
              whileHover={{ scale: 1.06, borderColor: 'rgba(255, 255, 255, 0.25)' }}
              whileTap={{ scale: 0.92 }}
              style={{
                width: `${cellSize}px`,
                height: `${cellSize}px`,
                borderRadius: '10px',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                background: isOn
                  ? 'rgba(var(--success-rgb), 0.25)'
                  : wasDisrupted
                    ? 'rgba(var(--error-rgb), 0.2)'
                    : 'rgba(0, 0, 0, 0.35)',
                border: isOn
                  ? '2px solid rgba(var(--success-rgb), 0.6)'
                  : wasDisrupted
                    ? '2px solid rgba(var(--error-rgb), 0.5)'
                    : '2px solid rgba(255, 255, 255, 0.08)',
                boxShadow: isOn
                  ? '0 0 14px rgba(var(--success-rgb), 0.3), inset 0 0 6px rgba(var(--success-rgb), 0.1)'
                  : wasDisrupted
                    ? '0 0 12px rgba(var(--error-rgb), 0.3)'
                    : 'inset 0 2px 4px rgba(0, 0, 0, 0.3)',
                transition: 'background 0.2s ease, border-color 0.2s ease, box-shadow 0.2s ease',
              }}
            >
              {/* Power indicator */}
              <motion.div
                animate={{
                  scale: isOn ? 1 : 0.5,
                  opacity: isOn ? 1 : 0.25,
                }}
                transition={{ type: 'spring', stiffness: 500, damping: 25 }}
                style={{
                  width: `${Math.round(cellSize * 0.38)}px`,
                  height: `${Math.round(cellSize * 0.38)}px`,
                  borderRadius: '50%',
                  background: isOn
                    ? 'rgba(var(--success-rgb), 0.9)'
                    : 'rgba(255, 255, 255, 0.15)',
                  boxShadow: isOn
                    ? '0 0 12px rgba(var(--success-rgb), 0.7)'
                    : 'none',
                }}
              />
            </motion.div>
          );
        })}
      </div>

      {/* Move Counter */}
      {maxMoves && (
        <span style={{
          fontSize: '13px',
          fontWeight: 600,
          color: movesUsed >= maxMoves - 3
            ? 'var(--error)'
            : 'rgba(255, 255, 255, 0.5)',
        }}>
          Moves: {movesUsed} / {maxMoves}
        </span>
      )}

      {/* Timer */}
      <div style={{
        width: '100%',
        maxWidth: `${cols * (cellSize + 8)}px`,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        gap: '6px',
      }}>
        <span style={{
          fontSize: '13px',
          fontWeight: 700,
          color: timerProgress > 0.3
            ? 'rgba(255, 255, 255, 0.5)'
            : 'var(--error)',
          fontVariantNumeric: 'tabular-nums',
        }}>
          {timerSeconds}s
        </span>

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
    </motion.div>
  );
}
