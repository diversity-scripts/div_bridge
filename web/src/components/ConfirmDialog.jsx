import { useState } from 'react';
import { motion } from 'framer-motion';
import { DynamicIcon } from '../utils/icons';
import { parseText } from '../utils/parser';
import { post } from '../utils/fetch';
import '../styles/InputDialog.css';

export const ConfirmDialog = ({ data, onClose }) => {
  const {
    id,
    heading,
    message,
    confirmText = 'Confirm',
    cancelText = 'Cancel',
    confirmWord,
    placeholder,
    icon,
    type = 'default'
  } = data;

  const [inputValue, setInputValue] = useState('');
  const isMatch = !confirmWord || inputValue.toLowerCase() === confirmWord.toLowerCase();

  const handleConfirm = () => {
    if (!isMatch) return;
    post('confirmDialogResult', { id, confirmed: true, value: inputValue });
    onClose();
  };

  const handleCancel = () => {
    post('confirmDialogResult', { id, confirmed: false, value: null });
    onClose();
  };

  const typeColor = type === 'danger' ? 'var(--error)' : 'var(--brand)';
  const typeRgbVal = type === 'danger' ? '237, 66, 69' : '93, 54, 176';

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
          {icon && (
            <div style={{ display: 'flex', justifyContent: 'center', marginBottom: '4px' }}>
              <div style={{ fontSize: '32px', color: typeColor, filter: `drop-shadow(0 0 10px ${typeColor})` }}>
                <DynamicIcon name={icon} />
              </div>
            </div>
          )}
          <p style={{ fontFamily: 'var(--font-sans)', fontSize: '14px', color: '#c1c2c5', lineHeight: 1.6, margin: 0, textAlign: 'center' }}>
            {parseText(message)}
          </p>
          {confirmWord && (
            <div style={{ marginTop: '8px' }}>
              <p style={{ fontFamily: 'var(--font-sans)', fontSize: '12px', color: '#7a7d82', margin: '0 0 8px 0', textAlign: 'center' }}>
                Type <strong style={{ color: '#fff' }}>{confirmWord}</strong> to confirm
              </p>
              <input
                type="text"
                className="input-field"
                placeholder={placeholder || `Type "${confirmWord}" to confirm`}
                value={inputValue}
                onChange={(e) => setInputValue(e.target.value)}
                onKeyDown={(e) => { if (e.key === 'Enter' && isMatch) handleConfirm(); }}
                autoFocus
                style={isMatch && inputValue.length > 0 ? { borderColor: `rgba(${typeRgbVal}, 0.5)`, boxShadow: `0 0 0 2px rgba(${typeRgbVal}, 0.1)` } : {}}
              />
            </div>
          )}
        </div>

        <div className="input-dialog-footer">
          <motion.button
            className="btn btn-cancel"
            onClick={handleCancel}
            whileHover={{ scale: 1.05, filter: "brightness(1.2)" }}
            whileTap={{ scale: 0.95 }}
          >
            {cancelText}
          </motion.button>
          <motion.button
            className="btn"
            onClick={handleConfirm}
            whileHover={isMatch ? { scale: 1.05, filter: "brightness(1.1)" } : {}}
            whileTap={isMatch ? { scale: 0.95 } : {}}
            style={{
              opacity: isMatch ? 1 : 0.4,
              cursor: isMatch ? 'pointer' : 'not-allowed',
              background: typeColor,
              color: 'white',
              boxShadow: `0 2px 8px ${type === 'danger' ? 'rgba(237, 66, 69, 0.3)' : 'rgba(93, 54, 176, 0.3)'}`
            }}
          >
            {confirmText}
          </motion.button>
        </div>
      </motion.div>
    </div>
  );
};
