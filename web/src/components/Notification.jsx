import React, { useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { AnimatedCounter } from './AnimatedCounter';
import { parseText } from '../utils/parser.jsx';
import { post } from '../utils/fetch';

const notificationConfig = {
  success: { icon: 'circle-check',  defaultTitle: 'Success' },
  error:   { icon: 'circle-xmark',  defaultTitle: 'Error' },
  warning: { icon: 'triangle-exclamation', defaultTitle: 'Warning' },
  info:    { icon: 'circle-info',   defaultTitle: 'Information' },
  default: { icon: 'comment',       defaultTitle: 'Notification' },
};

async function handleActionClick(notificationId, actionId) {
  post('onAction', { notificationId, actionId });
}

async function handleTimeout(notificationId) {
  post('onTimeout', { notificationId });
}

export function Notification({ data, isFocused, config }) {
  const { luaId, type = 'default', title, text, count, timeLeft, initialDuration, shake, actions, _resetKey } = data;

  const { icon: iconClass, defaultTitle } = notificationConfig[type] || notificationConfig.default;
  const displayTitle = title || defaultTitle;

  useEffect(() => {
    if (timeLeft <= 0 && (actions || initialDuration > 0)) {
      handleTimeout(luaId);
    }
  }, [timeLeft, luaId, actions, initialDuration]);

  const variants = {
    hidden: { opacity: 0, x: 50, scale: 0.95 },
    visible: {
      opacity: 1,
      x: 0,
      scale: 1,
      transition: { type: 'spring', stiffness: 400, damping: 25 }
    },
    shake: {
      x: [0, -6, 5, -4, 3, -1, 0],
      scale: 1,
      opacity: 1,
      transition: { duration: 0.6 }
    },
    exit: {
      opacity: 0,
      x: 50,
      scale: 0.95,
      transition: { duration: 0.2 }
    }
  };

  const hasTimeout = initialDuration < 999999999;

  return (
    <motion.div
      layout
      initial={{ opacity: 0, height: 0 }}
      animate={{ opacity: 1, height: 'auto' }}
      exit={{ opacity: 0, height: 0 }}
      transition={{
        layout: { type: 'spring', stiffness: 350, damping: 35, mass: 1 },
        opacity: { duration: 0.2 }
      }}
    >
      <motion.div
        className={`notification-item ${type}`}
        variants={variants}
        initial="hidden"
        animate={shake ? "shake" : "visible"}
        exit="exit"
      >
        <div className="icon-container">
          <i className={`fa-solid fa-${iconClass}`} />
        </div>
        <div className="text-content">
          <h4 className="notification-title">
            <AnimatePresence mode="wait" initial={false}>
              <motion.span
                key={displayTitle}
                initial={{ opacity: 0, y: -5 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: 5 }}
                transition={{ duration: 0.2 }}
                style={{ display: 'inline-block' }}
              >
                {parseText(displayTitle)}
              </motion.span>
            </AnimatePresence>
            {count > 1 && <AnimatedCounter count={count} />}
          </h4>
          <AnimatePresence mode="wait" initial={false}>
            <motion.p
              key={text}
              className="notification-text"
              initial={{ opacity: 0, y: -5 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: 5 }}
              transition={{ duration: 0.2 }}
            >
              {parseText(text)}
            </motion.p>
          </AnimatePresence>
          {actions && (
            <div className="notification-actions">
              <div className="action-buttons">
                {Object.entries(data.actions).map(([actionId, actionData]) => (
                  <button
                    key={actionId}
                    className={`action-button action-${actionId}`}
                    onClick={() => handleActionClick(luaId, actionId)}
                  >
                    {actionData.label}
                  </button>
                ))}
              </div>
            </div>
          )}
        </div>
        {(hasTimeout) && (
          <motion.div
            key={`progress-${_resetKey || 0}`}
            className="progress-bar"
            initial={{ width: "100%" }}
            animate={{ width: "0%" }}
            transition={{ duration: initialDuration / 1000, ease: 'linear' }}
          />
        )}
        <AnimatePresence>
          {actions && (
            <motion.div
              className="action-tooltip"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1, transition: { delay: 0.5 } }}
              exit={{ opacity: 0 }}
            >
              {isFocused ? (
                <span>Press <strong className="key-style">{config.Text.keyDisplay}</strong> {config.Text.exit}</span>
              ) : (
                <span>Press <strong className="key-style">{config.Text.keyDisplay}</strong> {config.Text.interact}</span>
              )}
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>
    </motion.div>
  );
}

