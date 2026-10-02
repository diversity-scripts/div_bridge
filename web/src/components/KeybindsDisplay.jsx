import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';

const containerVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      when: "beforeChildren",
      staggerChildren: 0.05
    }
  },
  exit: {
    opacity: 0,
    y: 20,
    transition: {
      when: "afterChildren",
      staggerChildren: 0.05,
      staggerDirection: -1
    }
  }
};

const itemVariants = {
  hidden: { opacity: 0, y: 10 },
  visible: { opacity: 1, y: 0 },
  exit: { opacity: 0, y: 10 },
};

const pressVariants = {
  pressed: { scale: 0.92, transition: { type: 'spring', stiffness: 500, damping: 20 } },
  idle: { scale: 1 },
};

export function KeybindsDisplay({ keybinds, pressedKey }) {
  const sortedKeybinds = [...keybinds].sort((a, b) => a.action.length - b.action.length);

  return (
    <div className="keybinds-wrapper">
      <AnimatePresence>
        {sortedKeybinds && sortedKeybinds.length > 0 && (
          <motion.div
            className="keybinds-container"
            variants={containerVariants}
            initial="hidden"
            animate="visible"
            exit="exit"
          >
            {sortedKeybinds.map((kb) => (
              <motion.div
                key={kb.action}
                className="keybind-item"
                variants={itemVariants}
              >
                <motion.div
                  className="keybind-item-content"
                  variants={pressVariants}
                  animate={pressedKey === kb.key ? 'pressed' : 'idle'}
                >
                  <kbd className="keybind-key">{kb.key}</kbd>
                  <span className="keybind-action">{kb.action}</span>
                </motion.div>
              </motion.div>
            ))}
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
