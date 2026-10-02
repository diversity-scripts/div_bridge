import React from 'react';
import { motion } from 'framer-motion';
import { parseText } from '../utils/parser.jsx';
import { DynamicIcon } from '../utils/icons.jsx';

export function Prompt({ data }) {
  const { icon, text } = data;

  return (
    <motion.div
      layout
      className="prompt-item"
      initial={{ opacity: 0, scale: 0.8, y: 10 }}
      animate={{ opacity: 1, scale: 1, y: 0 }}
      exit={{ opacity: 0, scale: 0.8, y: 10 }}
      transition={{ type: 'spring', stiffness: 400, damping: 25 }}
    >
      {icon && <DynamicIcon name={icon} className="prompt-icon" />}
      <span className="prompt-text">{parseText(text)}</span>
    </motion.div>
  );
}
