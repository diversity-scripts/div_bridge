import React, { useState, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Portal } from './Portal';
import '../styles/CustomTimePicker.css';

export const CustomTimePicker = ({
  value,
  onChange,
  placeholder = "Select time",
  disabled = false
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const containerRef = useRef(null);

  const [hour, setHour] = useState(value ? value.split(':')[0] : '12');
  const [minute, setMinute] = useState(value ? value.split(':')[1] : '00');

  const hours = Array.from({ length: 24 }, (_, i) => String(i).padStart(2, '0'));
  const minutes = Array.from({ length: 60 }, (_, i) => String(i).padStart(2, '0'));

  const handleTimeChange = (newHour, newMinute) => {
    const h = newHour || hour;
    const m = newMinute || minute;
    setHour(h);
    setMinute(m);
    onChange(`${h}:${m}`);
  };

  return (
    <div className={`custom-timepicker-container ${disabled ? 'disabled' : ''}`} ref={containerRef}>
      <div
        className={`custom-timepicker-trigger ${isOpen ? 'open' : ''}`}
        onClick={() => !disabled && setIsOpen(!isOpen)}
      >
        <span className={`timepicker-value ${!value ? 'placeholder' : ''}`}>
          {value || placeholder}
        </span>
        <i className="fa-solid fa-clock timepicker-icon" />
      </div>

      <Portal targetRef={containerRef} isOpen={isOpen} onClose={() => setIsOpen(false)}>
        <AnimatePresence>
          {isOpen && (
            <motion.div
              className="custom-timepicker-popup"
              initial={{ opacity: 0, y: -5 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -5 }}
              transition={{ duration: 0.15 }}
              style={{ position: 'relative', top: 0, left: 0, width: '100%' }}
            >
              <div className="timepicker-columns">
                <div className="timepicker-column">
                  <div className="column-label">Hour</div>
                  <div className="column-list">
                    {hours.map(h => (
                      <div
                        key={h}
                        className={`time-item ${hour === h ? 'selected' : ''}`}
                        onClick={() => handleTimeChange(h, null)}
                      >
                        {h}
                      </div>
                    ))}
                  </div>
                </div>
                <div className="timepicker-column">
                  <div className="column-label">Minute</div>
                  <div className="column-list">
                    {minutes.map(m => (
                      <div
                        key={m}
                        className={`time-item ${minute === m ? 'selected' : ''}`}
                        onClick={() => handleTimeChange(null, m)}
                      >
                        {m}
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </Portal>
    </div>
  );
};

