import React from 'react';
import { motion } from 'framer-motion';
import { post } from '../utils/fetch';
import '../styles/InputDialog.css';

export const AlertDialog = ({ data, onClose }) => {
  const { id, heading, message, buttons = ['OK'] } = data;

  const handleClick = (index) => {
    const isSingleButton = buttons.length === 1;
    const confirmed = isSingleButton ? true : index === 0;
    post('alertDialogResult', { id, confirmed });
    onClose();
  };

  return (
    <div className="input-dialog-overlay">
      <motion.div
        className="input-dialog-container"
        initial={{ opacity: 0, scale: 0.95, y: 20 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        exit={{ opacity: 0, scale: 0.95, y: 20 }}
        transition={{ duration: 0.2 }}
      >
        <div className="input-dialog-header">
          <h2>{heading}</h2>
        </div>

        <div className="input-dialog-body">
          <p style={{ fontFamily: 'var(--font-sans)', fontSize: '14px', color: '#c1c2c5', lineHeight: 1.6, margin: 0 }}>
            {message}
          </p>
        </div>

        <div className="input-dialog-footer">
          {buttons.length === 2 && (
            <motion.button
              className="btn btn-cancel"
              onClick={() => handleClick(1)}
              whileHover={{ scale: 1.05, filter: "brightness(1.2)" }}
              whileTap={{ scale: 0.95 }}
            >
              {buttons[1]}
            </motion.button>
          )}
          <motion.button
            className="btn btn-confirm"
            onClick={() => handleClick(0)}
            whileHover={{ scale: 1.05, filter: "brightness(1.1)" }}
            whileTap={{ scale: 0.95 }}
          >
            {buttons[0]}
          </motion.button>
        </div>
      </motion.div>
    </div>
  );
};
