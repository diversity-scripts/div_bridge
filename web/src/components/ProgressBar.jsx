import { useEffect, useState, useRef } from 'react';
import { motion, useMotionValue, useTransform, animate, AnimatePresence } from 'framer-motion';
import { parseText } from '../utils/parser.jsx';
import { DynamicIcon } from '../utils/icons.jsx';
import '../styles/ProgressBar.css';

export const ProgressBar = ({ data }) => {
  const {
    duration = 0, label = '', subtitle = '', icon = '', type = 'bar', position = 'bottom',
    colorScheme = 'brand', stages = 0, activeStage = 0, cancelKey = null
  } = data || {};

  const progressValue = useMotionValue(0);
  const [isVisible, setIsVisible] = useState(false);
  const [animationDone, setAnimationDone] = useState(false);

  const currentControls = useRef();
  const currentTimeoutId = useRef();

  useEffect(() => {
    if (currentControls.current) currentControls.current.stop();

    if (!data || duration === 0) {
      setAnimationDone(true);
      setIsVisible(false);
      return;
    }

    if (data.cancelled) {
      setAnimationDone(true);
      return;
    }

    setIsVisible(true);
    setAnimationDone(false);
    progressValue.set(0);

    const localControls = animate(progressValue, 100, {
      duration: duration / 1000,
      ease: "linear"
    });
    currentControls.current = localControls;
    localControls.then(() => { setAnimationDone(true); });

    return () => {
      if (currentControls.current) currentControls.current.stop();
    };
  }, [data, duration, label, activeStage, stages]);

  useEffect(() => {
    if (currentTimeoutId.current) clearTimeout(currentTimeoutId.current);

    if (!animationDone || !isVisible) return;

    const delay = data && data.cancelled ? 300 : 1500;

    currentTimeoutId.current = setTimeout(() => {
      setIsVisible(false);
    }, delay);

    return () => {
      if (currentTimeoutId.current) clearTimeout(currentTimeoutId.current);
    };
  }, [animationDone, isVisible, stages, activeStage, data]);

  const percentageText = useTransform(progressValue, v => `${Math.round(v)}%`);
  const widthPercent = useTransform(progressValue, v => `${v}%`);
  const pathLength = useTransform(progressValue, v => v / 100);

  const accentColor = colorScheme.startsWith('#') || colorScheme.startsWith('rgb') 
    ? colorScheme 
    : `var(--${colorScheme})`;

  const motionVariants = {
    initial: { opacity: 0, y: 60, x: "-50%", scale: 0.9 },
    animate: {
      opacity: 1, y: 0, x: "-50%", scale: 1,
      transition: { type: "spring", stiffness: 400, damping: 32 }
    },
    exit: {
      opacity: 0, y: 40, x: "-50%", scale: 0.9,
      transition: { duration: 0.35, ease: [0.4, 0.0, 0.2, 1] }
    }
  };

  return (
    <AnimatePresence>
      {isVisible && (
        <motion.div
          key="progress-bar-inner"
          className={`progress-wrapper ${type} ${position}`}
          initial="initial"
          animate="animate"
          exit="exit"
          variants={motionVariants}
          style={{ '--accent-color': accentColor }}
        >
          {type === 'bar' ? (
            <div className="progress-bar-container">
              <div className="progress-main-body">
                <div className="progress-header-layout">
                  <div className="progress-icon-wrap">
                    <DynamicIcon name={icon || 'gear'} />
                  </div>
                  <div className="progress-title-container">
                    <AnimatePresence mode="wait">
                      <motion.div
                        key={label}
                        initial={{ opacity: 0, y: 8 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0, y: -8 }}
                        className="progress-title-text"
                      >
                        {parseText(label)}
                      </motion.div>
                    </AnimatePresence>
                  </div>
                  {stages > 0 && (
                    <div className="progress-stages-dots">
                      {[...Array(stages)].map((_, i) => (
                        <div key={i} className={`prog-dot ${i < activeStage ? 'active' : ''}`} />
                      ))}
                    </div>
                  )}
                  <motion.div className="progress-percent-num">{percentageText}</motion.div>
                </div>
                <div className="progress-subtitle-container">
                  <AnimatePresence mode="wait">
                    {subtitle && (
                      <motion.div
                        key={subtitle}
                        initial={{ opacity: 0, x: -15 }}
                        animate={{ opacity: 1, x: 0 }}
                        exit={{ opacity: 0, x: 15 }}
                        className="progress-sub-label"
                      >
                        {parseText(subtitle)}
                      </motion.div>
                    )}
                  </AnimatePresence>
                </div>
                <div className="progress-track-bg">
                  <motion.div
                    className="progress-fill-accent"
                    style={{ width: widthPercent }}
                  />
                </div>
              </div>
              {cancelKey && (
                <div className="progress-footer-bar">
                  <div className="progress-cancel-hint">
                    Press <strong>{cancelKey}</strong> to cancel
                  </div>
                </div>
              )}
            </div>
          ) : (
            <div className="prog-circle-container">
              <div className="prog-circle-visual">
                <svg className="prog-circle-svg" viewBox="0 0 100 100">
                  <circle className="prog-circle-path-bg" cx="50" cy="50" r="42" />
                  <motion.circle
                    className="prog-circle-path-fg" cx="50" cy="50" r="42"
                    style={{ pathLength, stroke: accentColor }}
                  />
                </svg>
                <div className="prog-circle-center-icon">
                  <DynamicIcon name={icon || 'gear'} />
                </div>
              </div>
              <div className="prog-circle-info-card">
                <AnimatePresence mode="wait">
                  <motion.div
                    key={label}
                    initial={{ opacity: 0, scale: 0.9 }}
                    animate={{ opacity: 1, scale: 1 }}
                    exit={{ opacity: 0, scale: 0.9 }}
                    className="prog-circle-title"
                  >
                    {parseText(label)}
                  </motion.div>
                </AnimatePresence>
                <motion.div className="prog-circle-percent">{percentageText}</motion.div>
              </div>
            </div>
          )}
        </motion.div>
      )}
    </AnimatePresence>
  );
};

