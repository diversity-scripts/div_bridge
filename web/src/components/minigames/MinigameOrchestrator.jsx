import React, { useState, useEffect, useCallback, useRef } from 'react';
import { AnimatePresence, motion } from 'framer-motion';
import { post } from '../../utils/fetch';
import { StageIndicator } from './StageIndicator';
import { SkillCheck } from '../SkillCheck';

// Lazy-style imports for minigame components (created in later tasks)
import { RapidKeySequence } from './RapidKeySequence';
import { MemoryPattern } from './MemoryPattern';
import { TimingBar } from './TimingBar';
import { WireConnect } from './WireConnect';
import { NumberPad } from './NumberPad';
import { Lockpick } from './Lockpick';
import { CircuitBreaker } from './CircuitBreaker';

const MINIGAME_COMPONENTS = {
  skillcheck: SkillCheck,
  rapidkeys: RapidKeySequence,
  memory: MemoryPattern,
  timingbar: TimingBar,
  wireconnect: WireConnect,
  numberpad: NumberPad,
  lockpick: Lockpick,
  circuitbreaker: CircuitBreaker,
};

// Fields categorized for escalation algorithm
const TIME_FIELDS = ['duration', 'timeLimit', 'previewDuration'];
const ZONE_FIELDS = ['zoneSize', 'areaSize', 'sweetSpotSize'];
const SPEED_FIELDS = ['speed'];
const INTEGER_FIELDS = ['patternLength', 'pairs', 'switchCount', 'linkedPairs'];

/**
 * Applies the escalation algorithm to a base config for a given stage number.
 * Stage is 1-indexed.
 */
export function applyEscalation(baseConfig, stageNumber) {
  if (stageNumber <= 1) return { ...baseConfig };

  const escalated = { ...baseConfig };
  const N = stageNumber;

  // Time-based fields: multiply by (1 - 0.1 * (N-1))
  for (const field of TIME_FIELDS) {
    if (typeof escalated[field] === 'number') {
      escalated[field] = escalated[field] * (1 - 0.1 * (N - 1));
    }
  }

  // Zone-based fields: multiply by (1 - 0.15 * (N-1))
  for (const field of ZONE_FIELDS) {
    if (typeof escalated[field] === 'number') {
      escalated[field] = escalated[field] * (1 - 0.15 * (N - 1));
    }
  }

  // Speed fields: multiply by (1 + 0.2 * (N-1))
  for (const field of SPEED_FIELDS) {
    if (typeof escalated[field] === 'number') {
      escalated[field] = escalated[field] * (1 + 0.2 * (N - 1));
    }
  }

  // Integer fields: add (N-1)
  for (const field of INTEGER_FIELDS) {
    if (typeof escalated[field] === 'number') {
      escalated[field] = escalated[field] + (N - 1);
    }
  }

  return escalated;
}

/**
 * Resolves the config for a specific stage.
 * If stageConfigs is provided, use the corresponding entry.
 * If escalate is true and no stageConfigs, apply escalation algorithm.
 * Otherwise, use the base config as-is.
 */
export function resolveStageConfig(baseConfig, stageNumber, stageConfigs, escalate) {
  if (stageConfigs && stageConfigs[stageNumber - 1]) {
    return stageConfigs[stageNumber - 1];
  }

  if (escalate) {
    return applyEscalation(baseConfig, stageNumber);
  }

  return { ...baseConfig };
}

// Strip orchestrator-level fields from config before passing to minigame component
function getMinigameConfig(config) {
  const { stages, stageConfigs, escalate, cancelKey, ...minigameConfig } = config;
  return minigameConfig;
}

const STAGE_TRANSITION_DURATION = 600; // ms between stages

export function MinigameOrchestrator({ data, onClose }) {
  const { type, config, cancelKey = 'Backspace' } = data;

  const stages = config.stages || 1;
  const stageConfigs = config.stageConfigs || null;
  const escalate = config.escalate || false;

  const [currentStage, setCurrentStage] = useState(1);
  const [stageResults, setStageResults] = useState(
    Array.from({ length: stages }, () => 'pending')
  );
  const [isTransitioning, setIsTransitioning] = useState(false);
  const [isDismissing, setIsDismissing] = useState(false);
  const [stageKey, setStageKey] = useState(0);

  const isFinishedRef = useRef(false);
  const cancelKeyRef = useRef(cancelKey);
  cancelKeyRef.current = cancelKey;

  // Play start sound on mount
  useEffect(() => {
    post('playSound', { sound: 'start' });
  }, []);

  // Post the final minigame result
  const postResult = useCallback((success) => {
    if (isFinishedRef.current) return;
    isFinishedRef.current = true;

    post('minigameResult', { success, type });

    // Clean up immediately — let AnimatePresence handle exit animation
    if (onClose) onClose();
  }, [type, onClose]);

  // Handle cancel with dismissal animation
  const handleCancel = useCallback(() => {
    if (isFinishedRef.current || isDismissing) return;
    setIsDismissing(true);

    // Brief visual feedback then post result
    setTimeout(() => {
      postResult(false);
    }, 300);
  }, [postResult, isDismissing]);

  // Cancel key detection
  useEffect(() => {
    const handleKeyDown = (e) => {
      if (isFinishedRef.current || isDismissing) return;

      if (e.key === cancelKeyRef.current || e.code === cancelKeyRef.current) {
        e.preventDefault();
        e.stopPropagation();
        handleCancel();
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [handleCancel, isDismissing]);

  // Handle result from a single stage
  const handleStageResult = useCallback((success) => {
    if (isFinishedRef.current || isDismissing) return;

    if (!success) {
      // Any stage failure = entire minigame fails
      setStageResults(prev => {
        const next = [...prev];
        next[currentStage - 1] = 'failed';
        return next;
      });
      postResult(false);
      return;
    }

    // Stage succeeded
    setStageResults(prev => {
      const next = [...prev];
      next[currentStage - 1] = 'success';
      return next;
    });

    if (currentStage >= stages) {
      // All stages completed successfully
      postResult(true);
    } else {
      // Advance to next stage with transition
      setIsTransitioning(true);
      setTimeout(() => {
        setCurrentStage(prev => prev + 1);
        setStageKey(prev => prev + 1);
        setIsTransitioning(false);
      }, STAGE_TRANSITION_DURATION);
    }
  }, [currentStage, stages, postResult, isDismissing]);

  // Resolve config for the current stage
  const baseConfig = getMinigameConfig(config);
  const currentConfig = resolveStageConfig(baseConfig, currentStage, stageConfigs, escalate);

  // Get the component for this minigame type
  const MinigameComponent = MINIGAME_COMPONENTS[type];

  // Handle unknown type - fail immediately
  useEffect(() => {
    if (!MinigameComponent) {
      postResult(false);
    }
  }, [MinigameComponent, postResult]);

  if (!MinigameComponent) {
    return null;
  }

  // Build stage results for indicator
  const indicatorResults = stageResults.map((result, idx) => {
    if (idx === currentStage - 1 && result === 'pending') return 'active';
    return result;
  });

  // For skillcheck, render directly without the stage container (it uses its own full-screen positioning)
  if (type === 'skillcheck') {
    return (
      <motion.div
        className="minigame-orchestrator"
        initial={{ opacity: 0 }}
        animate={{ opacity: isDismissing ? 0 : 1 }}
        exit={{ opacity: 0, transition: { duration: 0.15 } }}
        transition={{ duration: 0.2 }}
      >
        <MinigameComponent
          config={currentConfig}
          onResult={handleStageResult}
          cancelKey={cancelKey}
        />
      </motion.div>
    );
  }

  return (
    <motion.div
      className="minigame-orchestrator"
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{
        opacity: isDismissing ? 0 : 1,
        scale: isDismissing ? 0.95 : 1,
      }}
      exit={{ opacity: 0, scale: 0.95, transition: { duration: 0.15 } }}
      transition={{ type: 'spring', stiffness: 400, damping: 30 }}
    >
      <motion.div
        className="minigame-stage-container"
        layout="size"
        transition={{ type: 'spring', stiffness: 400, damping: 32 }}
        style={{ willChange: 'transform' }}
      >
        {stages > 1 && (
          <motion.div layout="position">
            <StageIndicator
              total={stages}
              current={currentStage}
              results={indicatorResults}
            />
          </motion.div>
        )}

        <AnimatePresence mode="wait">
          {!isTransitioning && (
            <motion.div
              key={`stage-${stageKey}`}
              initial={{ opacity: 0, scale: 0.97, y: 6 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.97, y: -6 }}
              transition={{ type: 'spring', stiffness: 400, damping: 30 }}
            >
              <MinigameComponent
                config={currentConfig}
                onResult={handleStageResult}
                cancelKey={cancelKey}
              />
            </motion.div>
          )}
        </AnimatePresence>

        {isTransitioning && (
          <motion.div
            className="minigame-stage-transition"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.2 }}
          >
            <span className="stage-transition-text">
              Stage {currentStage + 1} / {stages}
            </span>
          </motion.div>
        )}
      </motion.div>
    </motion.div>
  );
}
