import React, { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { DynamicIcon } from '../utils/icons';
import { Portal } from './Portal';
import '../styles/CustomDatePicker.css';

export const CustomDatePicker = ({
  value,
  onChange,
  min,
  max,
  placeholder = "Select date",
  disabled = false
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const containerRef = useRef(null);
  const [viewDate, setViewDate] = useState(new Date());
  const [viewMode, setViewMode] = useState('days');
  const [direction, setDirection] = useState(0);

  const parseDate = (dateStr) => {
    if (!dateStr) return null;
    const [y, m, d] = dateStr.split('-').map(Number);
    return new Date(y, m - 1, d);
  };

  const selectedDate = parseDate(value);

  const viewYear = viewDate.getFullYear();
  const startYear = Math.floor(viewYear / 12) * 12;

  useEffect(() => {
    if (selectedDate) {
      setViewDate(selectedDate);
    }
  }, [value, isOpen]);

  const getDaysInMonth = (year, month) => new Date(year, month + 1, 0).getDate();
  const getFirstDayOfMonth = (year, month) => new Date(year, month, 1).getDay();

  const handleDateClick = (day) => {
    const newDate = new Date(viewDate.getFullYear(), viewDate.getMonth(), day);
    const dateString = `${newDate.getFullYear()}-${String(newDate.getMonth() + 1).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
    onChange(dateString);
    setIsOpen(false);
  };

  const changeMonth = (delta) => {
    setDirection(delta);
    setViewDate(new Date(viewDate.getFullYear(), viewDate.getMonth() + delta, 1));
  };

  const changeYearPage = (delta) => {
    setDirection(delta);
    setViewDate(new Date(viewDate.getFullYear() + (delta * 12), 0, 1));
  };

  const slideVariants = {
    enter: (direction) => ({ x: direction > 0 ? '100%' : '-100%', opacity: 0 }),
    center: { x: 0, opacity: 1 },
    exit: (direction) => ({ x: direction > 0 ? '-100%' : '100%', opacity: 0 })
  };

  const renderCalendar = () => {
    const year = viewDate.getFullYear();
    const month = viewDate.getMonth();
    const daysInMonth = getDaysInMonth(year, month);
    const firstDay = getFirstDayOfMonth(year, month);
    const days = [];

    for (let i = 0; i < firstDay; i++) {
      days.push(<div key={`empty-${i}`} className="calendar-day empty"></div>);
    }

    for (let d = 1; d <= daysInMonth; d++) {
      const isSelected = selectedDate &&
        selectedDate.getDate() === d &&
        selectedDate.getMonth() === month &&
        selectedDate.getFullYear() === year;
      const isToday = new Date().getDate() === d &&
        new Date().getMonth() === month &&
        new Date().getFullYear() === year;

      days.push(
        <div
          key={d}
          className={`calendar-day ${isSelected ? 'selected' : ''} ${isToday ? 'today' : ''}`}
          onClick={() => handleDateClick(d)}
        >
          {d}
        </div>
      );
    }
    return days;
  };

  const renderYears = () => {
    const todayYear = new Date().getFullYear();
    const selectedYear = selectedDate ? selectedDate.getFullYear() : null;
    const years = [];

    for (let i = 0; i < 12; i++) {
      const y = startYear + i;
      const isToday = y === todayYear;
      const isSelected = y === selectedYear;

      years.push(
        <div
          key={y}
          className={`calendar-year ${isSelected ? 'selected' : ''} ${isToday ? 'current' : ''}`}
          onClick={() => {
            setViewDate(new Date(y, viewDate.getMonth(), 1));
            setViewMode('days');
          }}
        >
          {y}
        </div>
      );
    }
    return years;
  };

  const monthNames = ["January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  const titleVariants = {
    enter: (dir) => ({ x: dir === 0 ? 0 : (dir > 0 ? 50 : -50), opacity: 0 }),
    center: { x: 0, opacity: 1, transition: { duration: 0.3, ease: [0.4, 0.0, 0.2, 1] } },
    exit: (dir) => ({ x: dir === 0 ? 0 : (dir > 0 ? -50 : 50), opacity: 0, transition: { duration: 0.2, ease: [0.4, 0.0, 0.2, 1] } })
  };

  return (
    <div className={`custom-datepicker-container ${disabled ? 'disabled' : ''}`} ref={containerRef}>
      <div
        className={`custom-datepicker-trigger ${isOpen ? 'open' : ''}`}
        onClick={() => !disabled && setIsOpen(!isOpen)}
      >
        <span className={`datepicker-value ${!value ? 'placeholder' : ''}`}>
          {value || placeholder}
        </span>
        <i className="fa-solid fa-calendar datepicker-icon" />
      </div>

      <Portal targetRef={containerRef} isOpen={isOpen} onClose={() => setIsOpen(false)}>
        <AnimatePresence>
          {isOpen && (
            <motion.div
              layout="size"
              className="custom-datepicker-popup"
              initial={{ opacity: 0, y: -5 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -5 }}
              transition={{
                layout: { type: 'spring', stiffness: 300, damping: 30, mass: 0.8 },
                opacity: { duration: 0.15 }
              }}
              style={{ position: 'relative', top: 0, left: 0, width: '100%', overflow: 'hidden' }}
            >
              <motion.div layout="position" className="datepicker-header">
                <motion.button
                  className="nav-btn"
                  onClick={() => viewMode === 'days' ? changeMonth(-1) : changeYearPage(-1)}
                  whileHover={{ scale: 1.05, filter: "brightness(1.2)" }}
                  whileTap={{ scale: 0.95 }}
                >
                  <i className="fa-solid fa-chevron-left" style={{ fontSize: '16px' }} />
                </motion.button>

                <motion.div
                  className="current-month clickable"
                  onClick={() => setViewMode(viewMode === 'days' ? 'years' : 'days')}
                  whileHover={{ scale: 1.02, filter: "brightness(1.1)" }}
                  whileTap={{ scale: 0.98 }}
                  style={{
                    position: 'relative',
                    minWidth: 180,
                    display: 'flex',
                    justifyContent: 'center',
                    overflow: 'hidden',
                    maskImage: 'linear-gradient(to right, transparent, black 15%, black 85%, transparent)',
                    WebkitMaskImage: 'linear-gradient(to right, transparent, black 15%, black 85%, transparent)'
                  }}
                >
                  <AnimatePresence mode="popLayout" custom={direction} initial={false}>
                    <motion.div
                      key={viewMode === 'days' ? `month-${viewDate.getMonth()}-${viewDate.getFullYear()}` : `years-${viewDate.getFullYear()}`}
                      custom={direction}
                      variants={titleVariants}
                      initial="enter"
                      animate="center"
                      exit="exit"
                      style={{ display: 'flex', alignItems: 'center', gap: 6, whiteSpace: 'nowrap' }}
                    >
                      {viewMode === 'days' ? (
                        <>
                          <span className="month-part">{monthNames[viewDate.getMonth()]}</span>
                          <span>{viewDate.getFullYear()}</span>
                        </>
                      ) : (
                        <span>{startYear} - {startYear + 11}</span>
                      )}
                    </motion.div>
                  </AnimatePresence>
                </motion.div>

                <motion.button
                  className="nav-btn"
                  onClick={() => viewMode === 'days' ? changeMonth(1) : changeYearPage(1)}
                  whileHover={{ scale: 1.05, filter: "brightness(1.2)" }}
                  whileTap={{ scale: 0.95 }}
                >
                  <i className="fa-solid fa-chevron-right" style={{ fontSize: '16px' }} />
                </motion.button>
              </motion.div>

              {viewMode === 'days' ? (
                <motion.div layout>
                  <motion.div layout="position" className="datepicker-weekdays">
                    <span className="weekday">Su</span>
                    <span className="weekday">Mo</span>
                    <span className="weekday">Tu</span>
                    <span className="weekday">We</span>
                    <span className="weekday">Th</span>
                    <span className="weekday">Fr</span>
                    <span className="weekday">Sa</span>
                  </motion.div>
                  <div style={{ position: 'relative' }}>
                    <AnimatePresence mode="popLayout" initial={false} custom={direction}>
                      <motion.div
                        key={viewDate.getMonth() + '-' + viewDate.getFullYear()}
                        custom={direction}
                        variants={slideVariants}
                        initial="enter"
                        animate="center"
                        exit="exit"
                        transition={{ type: 'spring', stiffness: 300, damping: 30 }}
                        className="datepicker-grid"
                        style={{ width: '100%' }}
                      >
                        {renderCalendar()}
                      </motion.div>
                    </AnimatePresence>
                  </div>
                </motion.div>
              ) : (
                <motion.div layout style={{ position: 'relative' }}>
                  <AnimatePresence mode="popLayout" initial={false} custom={direction}>
                    <motion.div
                      key={viewDate.getFullYear()}
                      custom={direction}
                      variants={slideVariants}
                      initial="enter"
                      animate="center"
                      exit="exit"
                      transition={{ type: 'spring', stiffness: 300, damping: 30 }}
                      className="datepicker-years-grid"
                      style={{ width: '100%' }}
                    >
                      {renderYears()}
                    </motion.div>
                  </AnimatePresence>
                </motion.div>
              )}
            </motion.div>
          )}
        </AnimatePresence>
      </Portal>
    </div>
  );
};

