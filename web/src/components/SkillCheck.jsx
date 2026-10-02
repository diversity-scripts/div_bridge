import React, { useState, useEffect, useRef } from 'react';
import { motion } from 'framer-motion';
import { post } from '../utils/fetch';

const MIN_ZONE_START_DEG = 180;
const MAX_ZONE_START_DEG = 320;

export function SkillCheck({ data, config, onComplete, onResult, cancelKey }) {
  // Support both legacy (data prop) and unified API (config prop)
  const resolvedData = config || data;
  const { key = 'E', speed, areaSize } = resolvedData;

  const [rotation, setRotation] = useState(0);
  const absoluteRotationRef = useRef(0);

  const successStartRef = useRef(
    MIN_ZONE_START_DEG + Math.random() * (MAX_ZONE_START_DEG - MIN_ZONE_START_DEG)
  );

  const [result, setResult] = useState(null);
  const frameId = useRef();
  const isFinishedRef = useRef(false);

  useEffect(() => {
    const handleResult = (success) => {
      if (isFinishedRef.current) return;
      isFinishedRef.current = true;
      cancelAnimationFrame(frameId.current);
      setResult(success ? 'success' : 'failure');

      if (onResult) {
        // Unified API path: let the orchestrator handle posting the result
        onResult(success);
      } else {
        // Legacy path: post skillCheckResult directly
        post('skillCheckResult', { success });
        setTimeout(onComplete, 800);
      }
    };

    const loop = () => {
      if (isFinishedRef.current) return;

      const nextAbsoluteRotation = absoluteRotationRef.current + (speed * 2);
      if (nextAbsoluteRotation >= 360) {
        handleResult(false);
        return;
      }
      absoluteRotationRef.current = nextAbsoluteRotation;
      setRotation(nextAbsoluteRotation);
      frameId.current = requestAnimationFrame(loop);
    };
    frameId.current = requestAnimationFrame(loop);

    const handleKeyDown = (e) => {
      if (isFinishedRef.current) return;

      const targetKey = key || 'E';

      if (e.key.toUpperCase() === targetKey.toUpperCase()) {
        const successStart = successStartRef.current;
        const successEnd = successStart + areaSize;
        const currentRotation = absoluteRotationRef.current;
        const inZone = currentRotation >= successStart && currentRotation <= successEnd;
        handleResult(inZone);
      } else if (e.key.toUpperCase() === 'X') {
        handleResult(false);
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => {
      cancelAnimationFrame(frameId.current);
      window.removeEventListener('keydown', handleKeyDown);
    };
  }, [key, speed, areaSize, onComplete, onResult]);

  const resultVariants = {
    hidden: { opacity: 0, scale: 0 },
    visible: { opacity: 1, scale: 1, transition: { type: "spring", stiffness: 300, damping: 20 } },
    exitFailure: { opacity: 0, scale: 0, transition: { duration: 0.3, ease: "backIn" } },
    exitSuccess: { opacity: 0, scale: 0, transition: { duration: 0.3, ease: "backIn" } }
  };

  const successStart = successStartRef.current;

  return (
    <motion.div
      className="skillcheck-wrapper"
      variants={resultVariants}
      initial="hidden"
      animate="visible"
      exit={result === 'success' ? 'exitSuccess' : 'exitFailure'}
    >
      <motion.div
        className={`skillcheck-circle ${result}`}
        animate={{ scale: result ? (result === 'success' ? 1.1 : 0.9) : 1 }}
        transition={{ type: 'spring', stiffness: 400, damping: 10 }}
      >
        <div
          className="skillcheck-area"
          style={{
            transform: `rotate(${successStart}deg)`,
            '--area-size-deg': `${areaSize}deg`
          }}
        />
        <div className="skillcheck-needle" style={{ transform: `rotate(${rotation}deg)` }} />
        <div className="skillcheck-key-prompt">
          <kbd>{key}</kbd>
        </div>
      </motion.div>
    </motion.div>
  );
}
