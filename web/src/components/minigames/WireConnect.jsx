import React, { useState, useEffect, useRef, useCallback, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

/**
 * WireConnect minigame component.
 *
 * The player connects matching colored endpoint pairs by drawing paths through
 * grid cells. Paths cannot cross existing locked paths. All pairs must be
 * connected before the timer expires.
 */

const WIRE_COLORS = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6', '#1abc9c'];

// Cell states
const CELL_EMPTY = 'empty';
const CELL_ENDPOINT = 'endpoint';
const CELL_PATH = 'path';

/**
 * Generate endpoint pairs that are always solvable by building solution paths first.
 * 
 * Algorithm (path-first generation):
 * 1. Start with an empty grid
 * 2. For each pair, perform a random walk from a random empty cell
 * 3. The walk creates a path of a minimum length
 * 4. The start and end of each walk become the pair's endpoints
 * 5. Since paths are placed without crossing, the puzzle is always solvable
 *    (the player just needs to retrace the generated paths)
 */
function generateEndpoints(gridSize, pairCount) {
  const actualPairs = Math.min(pairCount, gridSize, WIRE_COLORS.length);
  const grid = Array.from({ length: gridSize }, () => Array(gridSize).fill(-1)); // -1 = empty
  
  const pairs = [];
  // Longer paths = harder puzzles. Scale aggressively with grid size.
  const minPathLength = Math.max(4, Math.floor(gridSize * 1.4));
  // Minimum Manhattan distance between start and end endpoints
  const minEndpointDistance = Math.max(3, Math.floor(gridSize * 0.5));
  
  for (let i = 0; i < actualPairs; i++) {
    // Try to generate a valid path — only add the pair if we get a full connected path
    const path = generateRandomPath(grid, gridSize, minPathLength, minEndpointDistance, i);
    
    if (path && path.length >= 3) {
      // Mark ALL path cells on grid — this reserves the space so future paths route around
      for (const cell of path) {
        grid[cell.row][cell.col] = i;
      }
      
      pairs.push({
        colorIndex: i,
        color: WIRE_COLORS[i % WIRE_COLORS.length],
        start: { row: path[0].row, col: path[0].col },
        end: { row: path[path.length - 1].row, col: path[path.length - 1].col },
      });
    }
    // If we can't generate a valid path, skip this pair entirely
    // This guarantees every pair in the result is always solvable
  }
  
  // If we got fewer pairs than requested, try once more with shorter min length
  if (pairs.length < actualPairs) {
    const remaining = actualPairs - pairs.length;
    for (let i = 0; i < remaining; i++) {
      const path = generateRandomPath(grid, gridSize, 3, 2, pairs.length + i);
      if (path && path.length >= 3) {
        for (const cell of path) {
          grid[cell.row][cell.col] = pairs.length;
        }
        pairs.push({
          colorIndex: pairs.length,
          color: WIRE_COLORS[pairs.length % WIRE_COLORS.length],
          start: { row: path[0].row, col: path[0].col },
          end: { row: path[path.length - 1].row, col: path[path.length - 1].col },
        });
      }
    }
  }
  
  return pairs;
}

/**
 * Generate a random path on the grid using a random walk.
 * Returns array of {row, col} cells forming the path.
 */
function generateRandomPath(grid, gridSize, minLength, minEndpointDist, colorIndex) {
  const directions = [
    { row: -1, col: 0 }, // up
    { row: 1, col: 0 },  // down
    { row: 0, col: -1 }, // left
    { row: 0, col: 1 },  // right
  ];
  
  // Find all empty cells to start from
  const emptyCells = [];
  for (let r = 0; r < gridSize; r++) {
    for (let c = 0; c < gridSize; c++) {
      if (grid[r][c] === -1) {
        emptyCells.push({ row: r, col: c });
      }
    }
  }
  
  if (emptyCells.length < minLength) return null;
  
  // Try multiple starting positions to find a good long path
  const maxAttempts = 30;
  let bestPath = null;
  
  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    // Pick a random empty starting cell
    const startIdx = Math.floor(Math.random() * emptyCells.length);
    const start = emptyCells[startIdx];
    
    if (grid[start.row][start.col] !== -1) continue;
    
    // Random walk — prefer directions that keep the path going longer
    const path = [{ row: start.row, col: start.col }];
    const visited = new Set();
    visited.add(cellKey(start.row, start.col));
    
    const targetLength = minLength + Math.floor(Math.random() * Math.ceil(gridSize * 0.8));
    
    for (let step = 0; step < targetLength * 4 && path.length < targetLength; step++) {
      const current = path[path.length - 1];
      
      // Shuffle directions but prefer moves that have more open neighbors (winding paths)
      const shuffledDirs = [...directions];
      for (let i = shuffledDirs.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [shuffledDirs[i], shuffledDirs[j]] = [shuffledDirs[j], shuffledDirs[i]];
      }
      
      // Score each direction by how many open neighbors the target cell has
      const scoredDirs = shuffledDirs.map(dir => {
        const nr = current.row + dir.row;
        const nc = current.col + dir.col;
        if (nr < 0 || nr >= gridSize || nc < 0 || nc >= gridSize) return { dir, score: -1 };
        if (grid[nr][nc] !== -1 || visited.has(cellKey(nr, nc))) return { dir, score: -1 };
        
        // Count open neighbors of the target cell (more = better for longer paths)
        let openNeighbors = 0;
        for (const d of directions) {
          const nnr = nr + d.row;
          const nnc = nc + d.col;
          if (nnr >= 0 && nnr < gridSize && nnc >= 0 && nnc < gridSize &&
              grid[nnr][nnc] === -1 && !visited.has(cellKey(nnr, nnc))) {
            openNeighbors++;
          }
        }
        return { dir, score: openNeighbors };
      }).filter(d => d.score >= 0);
      
      if (scoredDirs.length === 0) break; // stuck
      
      // Pick a direction — bias toward cells with more open neighbors (keeps path alive longer)
      scoredDirs.sort((a, b) => b.score - a.score);
      // 70% chance to pick the best direction, 30% random for variety
      const pick = Math.random() < 0.7 ? scoredDirs[0] : scoredDirs[Math.floor(Math.random() * scoredDirs.length)];
      
      const nr = current.row + pick.dir.row;
      const nc = current.col + pick.dir.col;
      path.push({ row: nr, col: nc });
      visited.add(cellKey(nr, nc));
    }
    
    // Check that endpoints are far enough apart (Manhattan distance)
    if (path.length >= minLength) {
      const startCell = path[0];
      const endCell = path[path.length - 1];
      const dist = Math.abs(startCell.row - endCell.row) + Math.abs(startCell.col - endCell.col);
      
      if (dist >= minEndpointDist && (!bestPath || path.length > bestPath.length)) {
        bestPath = path;
      }
    } else if (!bestPath || path.length > bestPath.length) {
      bestPath = path;
    }
    
    if (bestPath && bestPath.length >= minLength) {
      const s = bestPath[0];
      const e = bestPath[bestPath.length - 1];
      if (Math.abs(s.row - e.row) + Math.abs(s.col - e.col) >= minEndpointDist) break;
    }
  }
  
  return bestPath;
}

/**
 * Check if two cells are adjacent (horizontal or vertical only)
 */
function isAdjacent(a, b) {
  const rowDiff = Math.abs(a.row - b.row);
  const colDiff = Math.abs(a.col - b.col);
  return (rowDiff === 1 && colDiff === 0) || (rowDiff === 0 && colDiff === 1);
}

/**
 * Get cell key for lookup
 */
function cellKey(row, col) {
  return `${row},${col}`;
}

export function WireConnect({ config, onResult, cancelKey }) {
  const { gridSize = 5, pairs: pairCount = 4, timeLimit = 35000 } = config;

  // Dynamic cell size based on grid - smaller cells for larger grids
  const cellSize = gridSize <= 5 ? 48 : gridSize <= 6 ? 42 : gridSize <= 7 ? 36 : 32;

  // Generate endpoint pairs once on mount
  const endpointPairs = useMemo(
    () => generateEndpoints(gridSize, Math.min(pairCount, WIRE_COLORS.length)),
    [gridSize, pairCount]
  );

  // State
  const [phase, setPhase] = useState('ready'); // 'ready' | 'playing'
  const [lockedPaths, setLockedPaths] = useState([]); // Array of { colorIndex, cells: [{row, col}] }
  const [activePath, setActivePath] = useState(null); // { colorIndex, cells: [{row, col}] } or null
  const [activeStartPair, setActiveStartPair] = useState(null); // which pair is being drawn
  const [invalidFlash, setInvalidFlash] = useState(null); // {row, col} cell that flashed invalid
  const [timeRemaining, setTimeRemaining] = useState(timeLimit);
  const [completedPairs, setCompletedPairs] = useState(new Set());
  const [isDrawing, setIsDrawing] = useState(false);

  const isFinishedRef = useRef(false);
  const timerIntervalRef = useRef(null);
  const invalidTimeoutRef = useRef(null);
  const onResultRef = useRef(onResult);
  onResultRef.current = onResult;

  // Ready phase: show grid for 1.5s before allowing interaction and starting timer
  useEffect(() => {
    const readyTimer = setTimeout(() => {
      setPhase('playing');
    }, 1500);
    return () => clearTimeout(readyTimer);
  }, []);

  // Build a set of cells occupied by locked paths for quick lookup
  const lockedCellMap = useMemo(() => {
    const map = new Map(); // cellKey -> colorIndex
    for (const path of lockedPaths) {
      for (const cell of path.cells) {
        map.set(cellKey(cell.row, cell.col), path.colorIndex);
      }
    }
    return map;
  }, [lockedPaths]);

  // Build endpoint lookup
  const endpointMap = useMemo(() => {
    const map = new Map(); // cellKey -> { pairIndex, isStart }
    for (let i = 0; i < endpointPairs.length; i++) {
      const pair = endpointPairs[i];
      map.set(cellKey(pair.start.row, pair.start.col), { pairIndex: i, isStart: true });
      map.set(cellKey(pair.end.row, pair.end.col), { pairIndex: i, isStart: false });
    }
    return map;
  }, [endpointPairs]);

  // Finish the game
  const finish = useCallback((success) => {
    if (isFinishedRef.current) return;
    isFinishedRef.current = true;

    if (timerIntervalRef.current) {
      clearInterval(timerIntervalRef.current);
      timerIntervalRef.current = null;
    }

    setTimeout(() => {
      onResultRef.current(success);
    }, 400);
  }, []);

  // Timer countdown — only starts when phase is 'playing'
  useEffect(() => {
    if (phase !== 'playing') return;

    const startTime = Date.now();
    setTimeRemaining(timeLimit);

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
  }, [phase, timeLimit, finish]);

  // Check if all pairs are connected
  useEffect(() => {
    if (completedPairs.size >= endpointPairs.length && !isFinishedRef.current) {
      finish(true);
    }
  }, [completedPairs, endpointPairs.length, finish]);

  // Flash invalid feedback
  const showInvalidFlash = useCallback((row, col) => {
    setInvalidFlash({ row, col });
    if (invalidTimeoutRef.current) clearTimeout(invalidTimeoutRef.current);
    invalidTimeoutRef.current = setTimeout(() => {
      setInvalidFlash(null);
    }, 400);
  }, []);

  // Handle cell interaction (start or extend path)
  const handleCellInteraction = useCallback((row, col) => {
    if (isFinishedRef.current || phase !== 'playing') return;

    const key = cellKey(row, col);
    const endpointInfo = endpointMap.get(key);

    // If no active path, check if clicking an endpoint to start
    if (!activePath) {
      if (!endpointInfo) return; // clicked empty cell, nothing to do
      if (completedPairs.has(endpointInfo.pairIndex)) return; // already completed

      // Start a new path from this endpoint
      const pair = endpointPairs[endpointInfo.pairIndex];
      setActivePath({
        colorIndex: pair.colorIndex,
        cells: [{ row, col }],
      });
      setActiveStartPair(endpointInfo);
      setIsDrawing(true);
      return;
    }

    // Active path exists - try to extend it
    const lastCell = activePath.cells[activePath.cells.length - 1];

    // Check adjacency
    if (!isAdjacent(lastCell, { row, col })) return;

    // Check if cell is already in the current active path (backtracking)
    const existingIdx = activePath.cells.findIndex(c => c.row === row && c.col === col);
    if (existingIdx >= 0) {
      // Allow backtracking: trim path to that point
      setActivePath(prev => ({
        ...prev,
        cells: prev.cells.slice(0, existingIdx + 1),
      }));
      return;
    }

    // Check if cell is occupied by a locked path
    if (lockedCellMap.has(key)) {
      showInvalidFlash(row, col);
      return;
    }

    // Check if cell is an endpoint
    if (endpointInfo) {
      // Is it the matching endpoint for our active pair?
      if (endpointInfo.pairIndex === activeStartPair.pairIndex && endpointInfo.isStart !== activeStartPair.isStart) {
        // Successfully connected! Lock the path
        const completedPath = {
          colorIndex: activePath.colorIndex,
          cells: [...activePath.cells, { row, col }],
        };
        setLockedPaths(prev => [...prev, completedPath]);
        setCompletedPairs(prev => new Set([...prev, endpointInfo.pairIndex]));
        setActivePath(null);
        setActiveStartPair(null);
        setIsDrawing(false);
        return;
      }

      // It's a different endpoint or the same one we started from - invalid
      if (endpointInfo.pairIndex === activeStartPair.pairIndex) {
        // Same endpoint we started from - ignore
        return;
      }

      // Different pair's endpoint - can't cross
      showInvalidFlash(row, col);
      return;
    }

    // Extend the path
    setActivePath(prev => ({
      ...prev,
      cells: [...prev.cells, { row, col }],
    }));
  }, [activePath, activeStartPair, endpointMap, lockedCellMap, completedPairs, endpointPairs, showInvalidFlash, phase]);

  // Handle mouse down on a cell
  const handleMouseDown = useCallback((row, col) => {
    handleCellInteraction(row, col);
  }, [handleCellInteraction]);

  // Handle mouse enter while drawing
  const handleMouseEnter = useCallback((row, col) => {
    if (!isDrawing || !activePath) return;
    handleCellInteraction(row, col);
  }, [isDrawing, activePath, handleCellInteraction]);

  // Handle mouse up - cancel active path if not completed
  const handleMouseUp = useCallback(() => {
    if (activePath && isDrawing) {
      // Check if the last cell is the matching endpoint
      const lastCell = activePath.cells[activePath.cells.length - 1];
      const key = cellKey(lastCell.row, lastCell.col);
      const endpointInfo = endpointMap.get(key);

      if (endpointInfo && endpointInfo.pairIndex === activeStartPair.pairIndex && endpointInfo.isStart !== activeStartPair.isStart) {
        // Path was completed on mouse up - already handled in handleCellInteraction
      } else {
        // Path not completed - cancel it
        setActivePath(null);
        setActiveStartPair(null);
      }
      setIsDrawing(false);
    }
  }, [activePath, isDrawing, endpointMap, activeStartPair]);

  // Global mouse up listener
  useEffect(() => {
    window.addEventListener('mouseup', handleMouseUp);
    return () => window.removeEventListener('mouseup', handleMouseUp);
  }, [handleMouseUp]);

  // Timer progress
  const timerProgress = timeLimit > 0 ? timeRemaining / timeLimit : 0;
  const timerSeconds = Math.ceil(timeRemaining / 1000);

  // Build active path cell set for rendering
  const activePathCells = useMemo(() => {
    if (!activePath) return new Map();
    const map = new Map();
    for (const cell of activePath.cells) {
      map.set(cellKey(cell.row, cell.col), activePath.colorIndex);
    }
    return map;
  }, [activePath]);

  return (
    <motion.div
      className="wire-connect-container"
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
        userSelect: 'none',
      }}
    >
      {/* Timer */}
      <div style={{
        width: '100%',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        gap: '8px',
      }}>
        <AnimatePresence mode="wait">
          <motion.span
            key={phase === 'ready' ? 'ready' : 'timer'}
            initial={{ opacity: 0, y: -6 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 6 }}
            transition={{ duration: 0.2 }}
            style={{
              fontSize: '13px',
              fontWeight: 600,
              color: phase === 'ready' ? 'var(--brand)' : timerProgress > 0.3 ? 'rgba(255, 255, 255, 0.7)' : 'var(--error)',
              textTransform: 'uppercase',
              letterSpacing: '0.5px',
            }}
          >
            {phase === 'ready' ? 'GET READY' : `${timerSeconds}s`}
          </motion.span>
        </AnimatePresence>

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

      {/* Grid */}
      <motion.div
        style={{
          display: 'grid',
          gridTemplateColumns: `repeat(${gridSize}, 1fr)`,
          gap: '4px',
          width: '100%',
          maxWidth: `${gridSize * (cellSize + 4) + (gridSize - 1) * 4}px`,
        }}
        initial="hidden"
        animate="visible"
        variants={{
          hidden: {},
          visible: {
            transition: { staggerChildren: 0.02 },
          },
        }}
      >
        {Array.from({ length: gridSize * gridSize }, (_, idx) => {
          const row = Math.floor(idx / gridSize);
          const col = idx % gridSize;
          const key = cellKey(row, col);

          // Determine cell state
          const endpointInfo = endpointMap.get(key);
          const lockedColor = lockedCellMap.get(key);
          const activeColor = activePathCells.get(key);
          const isInvalid = invalidFlash && invalidFlash.row === row && invalidFlash.col === col;
          const isCompleted = endpointInfo && completedPairs.has(endpointInfo.pairIndex);

          let colorIndex = null;
          let cellType = CELL_EMPTY;

          if (endpointInfo) {
            cellType = CELL_ENDPOINT;
            colorIndex = endpointPairs[endpointInfo.pairIndex].colorIndex;
          } else if (lockedColor !== undefined) {
            cellType = CELL_PATH;
            colorIndex = lockedColor;
          } else if (activeColor !== undefined) {
            cellType = CELL_PATH;
            colorIndex = activeColor;
          }

          return (
            <GridCell
              key={idx}
              row={row}
              col={col}
              cellSize={cellSize}
              cellType={cellType}
              colorIndex={colorIndex}
              color={colorIndex !== null ? WIRE_COLORS[colorIndex % WIRE_COLORS.length] : null}
              isLocked={lockedColor !== undefined}
              isActive={activeColor !== undefined}
              isEndpoint={!!endpointInfo}
              isCompleted={isCompleted}
              isInvalid={isInvalid}
              onMouseDown={handleMouseDown}
              onMouseEnter={handleMouseEnter}
            />
          );
        })}
      </motion.div>

      {/* Progress indicator */}
      <div style={{
        display: 'flex',
        gap: '8px',
        alignItems: 'center',
      }}>
        {endpointPairs.map((pair, idx) => (
          <motion.div
            key={idx}
            animate={{
              scale: completedPairs.has(idx) ? [1, 1.3, 1] : 1,
              opacity: completedPairs.has(idx) ? 1 : 0.4,
            }}
            transition={{ duration: 0.3 }}
            style={{
              width: '12px',
              height: '12px',
              borderRadius: '50%',
              background: pair.color,
              boxShadow: completedPairs.has(idx) ? `0 0 8px ${pair.color}` : 'none',
              border: completedPairs.has(idx)
                ? `2px solid ${pair.color}`
                : '2px solid rgba(255, 255, 255, 0.2)',
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
function GridCell({
  row,
  col,
  cellSize,
  cellType,
  colorIndex,
  color,
  isLocked,
  isActive,
  isEndpoint,
  isCompleted,
  isInvalid,
  onMouseDown,
  onMouseEnter,
}) {
  const getBackground = () => {
    if (isInvalid) return 'rgba(231, 76, 60, 0.4)';
    if (isEndpoint && color) {
      if (isCompleted) return `${color}33`; // completed endpoint - subtle fill
      return `${color}22`; // endpoint background
    }
    if (isLocked && color) return `${color}55`; // locked path segment
    if (isActive && color) return `${color}44`; // active drawing path
    return 'rgba(0, 0, 0, 0.2)';
  };

  const getBorder = () => {
    if (isInvalid) return '1px solid rgba(231, 76, 60, 0.8)';
    if (isEndpoint && color) return `1px solid ${color}88`;
    if (isLocked && color) return `1px solid ${color}66`;
    if (isActive && color) return `1px solid ${color}55`;
    return '1px solid rgba(255, 255, 255, 0.04)';
  };

  const getBoxShadow = () => {
    if (isInvalid) return '0 0 12px rgba(231, 76, 60, 0.5), inset 0 0 6px rgba(231, 76, 60, 0.3)';
    if (isLocked && color) return `0 0 6px ${color}44`;
    if (isEndpoint && isCompleted && color) return `0 0 10px ${color}66`;
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
        scale: isInvalid ? [1, 1.1, 0.95, 1] : 1,
      }}
      transition={{
        duration: 0.2,
        ease: 'easeOut',
        scale: isInvalid ? { duration: 0.3, times: [0, 0.3, 0.6, 1] } : { duration: 0.15 },
      }}
      onMouseDown={(e) => {
        e.preventDefault();
        onMouseDown(row, col);
      }}
      onMouseEnter={() => onMouseEnter(row, col)}
      style={{
        width: `${cellSize}px`,
        height: `${cellSize}px`,
        borderRadius: '6px',
        position: 'relative',
        cursor: 'pointer',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      {/* Endpoint circle */}
      {isEndpoint && color && (
        <motion.div
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          transition={{ type: 'spring', stiffness: 300, damping: 20, delay: 0.1 }}
          style={{
            width: `${Math.round(cellSize * 0.58)}px`,
            height: `${Math.round(cellSize * 0.58)}px`,
            borderRadius: '50%',
            border: `3px solid ${color}`,
            boxShadow: isCompleted
              ? `0 0 14px ${color}, inset 0 0 8px ${color}44`
              : `0 0 10px ${color}88`,
            background: isCompleted ? `${color}44` : 'transparent',
          }}
        />
      )}

      {/* Path segment indicator */}
      {!isEndpoint && (isLocked || isActive) && color && (
        <motion.div
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          transition={{ duration: 0.15, ease: 'easeOut' }}
          style={{
            width: `${Math.round(cellSize * 0.33)}px`,
            height: `${Math.round(cellSize * 0.33)}px`,
            borderRadius: '4px',
            background: color,
            opacity: isLocked ? 0.9 : 0.6,
            boxShadow: isLocked ? `0 0 8px ${color}88` : 'none',
          }}
        />
      )}
    </motion.div>
  );
}
