import React, { useEffect, useRef } from 'react';
import { motion, AnimatePresence, useMotionValue, useTransform, animate } from 'framer-motion';
import { parseText } from '../utils/parser.jsx';
import { DynamicIcon } from '../utils/icons.jsx';

const stateIcons = {
  success: 'circle-check',
  error:   'circle-xmark',
};

const textVariants = {
  initial: { opacity: 0, y: 10 },
  animate: { opacity: 1, y: 0 },
  exit: { opacity: 0, y: -10 },
};

function usePrevious(value) {
  const ref = useRef();
  useEffect(() => {
    ref.current = value;
  });
  return ref.current;
}

export function TaskNotification({ data }) {
  const { icon, title, text, progress = 0, duration = 0, type = 'info', finishedState } = data;
  const prevData = usePrevious(data);

  const animatedProgress = useMotionValue(prevData ? prevData.progress : 0);

  useEffect(() => {
    const wasFinished = prevData?.finishedState;
    const isFinished = !!finishedState;

    if (isFinished && !wasFinished) {
      animatedProgress.stop();
      const current = animatedProgress.get();
      const remaining = 100 - current;
      const calculatedDuration = Math.max(0.2, remaining / 10);
      animate(animatedProgress, 100, { duration: calculatedDuration, ease: 'linear' });
    } else if (!isFinished) {
      animate(animatedProgress, progress, { duration: duration / 1000, ease: 'linear' });
    }
  }, [data, animatedProgress, duration, finishedState, progress, prevData]);

  const roundedProgress = useTransform(animatedProgress, v => Math.round(v));
  const width = useTransform(animatedProgress, v => `${v}%`);

  const IconComponent = finishedState ? null : DynamicIcon;
  const iconName = finishedState ? stateIcons[finishedState] : (icon || 'gear');
  const displayClass = finishedState || type;

  return (
    <motion.div
      initial={{ opacity: 0, x: 50 }}
      animate={{ opacity: 1, x: 0 }}
      exit={{ opacity: 0, x: 50 }}
      transition={{ type: 'spring', stiffness: 400, damping: 25 }}
    >
      <motion.div
        className={`task-item ${displayClass}`}
        animate={{
          background: `radial-gradient(circle at 30px 50%, rgba(var(--${displayClass}-rgb, var(--default-rgb)), 0.1), transparent 60%), linear-gradient(180deg, rgb(42, 43, 46), rgb(33, 34, 36))`
        }}
        transition={{ duration: 0.5 }}
      >
        <div className="icon-container">
          <AnimatePresence mode="wait">
            <motion.div
              key={iconName || finishedState}
              initial={{ opacity: 0, scale: 0.8 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.8 }}
            >
              {finishedState
                ? <i className={`fa-solid ${iconName}`} />
                : <DynamicIcon name={iconName} />
              }
            </motion.div>
          </AnimatePresence>
        </div>
        <div className="task-content">
          <AnimatePresence mode="wait">
            <motion.h4
              key={title}
              className="task-title"
              variants={textVariants}
              initial="initial"
              animate="animate"
              exit="exit"
              transition={{ duration: 0.3 }}
            >
              {parseText(title)}
            </motion.h4>
          </AnimatePresence>
          <AnimatePresence mode="wait">
            <motion.p
              key={text}
              className="task-text"
              variants={textVariants}
              initial="initial"
              animate="animate"
              exit="exit"
              transition={{ duration: 0.3 }}
            >
              {parseText(text)}
            </motion.p>
          </AnimatePresence>
          <div className="task-progress-container">
            <div className="task-progress-background">
              <motion.div
                className="task-progress-fill"
                style={{ width, backgroundColor: `var(--${displayClass})` }}
              />
            </div>
            <div className="task-progress-percent">
              <motion.span>{roundedProgress}</motion.span>
              <span>%</span>
            </div>
          </div>
        </div>
      </motion.div>
    </motion.div>
  );
}

