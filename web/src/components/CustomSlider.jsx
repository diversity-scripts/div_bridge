import React, { useRef, useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import '../styles/CustomSlider.css';

export const CustomSlider = ({ value, min, max, step = 1, onChange, disabled, range = false }) => {
  const trackRef = useRef(null);
  const [draggingHandle, setDraggingHandle] = useState(null);
  const [hoveredHandle, setHoveredHandle] = useState(null);
  const [clickedHandle, setClickedHandle] = useState(null);
  const clickedTimerRef = useRef(null);

  const getPercentage = (v) => Math.min(100, Math.max(0, ((v - min) / (max - min)) * 100));

  const [localValue, setLocalValue] = useState(value);

  useEffect(() => {
    if (!draggingHandle) {
      setLocalValue(value);
    }
  }, [value, draggingHandle]);

  const calculateValueFromPointer = (clientX) => {
    if (!trackRef.current) return;
    const rect = trackRef.current.getBoundingClientRect();
    const x = clientX - rect.left;
    const p = Math.max(0, Math.min(1, x / rect.width));
    const newValue = min + p * (max - min);
    const steppedValue = Math.round(newValue / step) * step;
    return Math.min(max, Math.max(min, steppedValue));
  };

  const triggerTemporaryTooltip = (handle) => {
    if (clickedTimerRef.current) clearTimeout(clickedTimerRef.current);
    setClickedHandle(handle);
    clickedTimerRef.current = setTimeout(() => {
      setClickedHandle(null);
    }, 1000);
  };

  const handleTrackClick = (e) => {
    if (disabled || draggingHandle) return;
    const newValue = calculateValueFromPointer(e.clientX);

    if (range) {
      const [currentMin, currentMax] = localValue;
      const handle = Math.abs(newValue - currentMin) < Math.abs(newValue - currentMax) ? 'min' : 'max';
      if (handle === 'min') {
        onChange([Math.min(newValue, currentMax), currentMax]);
      } else {
        onChange([currentMin, Math.max(newValue, currentMin)]);
      }
      triggerTemporaryTooltip(handle);
    } else {
      onChange(newValue);
      triggerTemporaryTooltip('single');
    }
  };

  useEffect(() => {
    const handlePointerMove = (e) => {
      if (!draggingHandle) return;
      const newValue = calculateValueFromPointer(e.clientX);

      if (range) {
        const [currentMin, currentMax] = localValue;
        if (draggingHandle === 'min') {
          const nextMin = Math.min(newValue, currentMax);
          setLocalValue([nextMin, currentMax]);
          onChange([nextMin, currentMax]);
        } else if (draggingHandle === 'max') {
          const nextMax = Math.max(newValue, currentMin);
          setLocalValue([currentMin, nextMax]);
          onChange([currentMin, nextMax]);
        }
      } else {
        setLocalValue(newValue);
        onChange(newValue);
      }
    };

    const handlePointerUp = () => {
      setDraggingHandle(null);
    };

    if (draggingHandle) {
      window.addEventListener('pointermove', handlePointerMove);
      window.addEventListener('pointerup', handlePointerUp);
    }

    return () => {
      window.removeEventListener('pointermove', handlePointerMove);
      window.removeEventListener('pointerup', handlePointerUp);
    };
  }, [draggingHandle, localValue, min, max, step, onChange, range]);

  const renderThumb = (val, type) => {
    const isVisible = draggingHandle === type || hoveredHandle === type || clickedHandle === type;

    return (
      <motion.div
        className="custom-slider-thumb"
        onPointerDown={(e) => {
          if (disabled) return;
          e.stopPropagation();
          setDraggingHandle(type);
        }}
        onMouseEnter={() => setHoveredHandle(type)}
        onMouseLeave={() => setHoveredHandle(null)}
        animate={{ left: `${getPercentage(val)}%` }}
        transition={draggingHandle ? { duration: 0 } : { type: "spring", stiffness: 400, damping: 30 }}
        style={{
          x: "-50%",
          y: "-50%",
          position: 'absolute',
          top: '50%',
          zIndex: draggingHandle === type ? 3 : 2
        }}
      >
        <AnimatePresence>
          {isVisible && (
            <motion.div
              className="slider-tooltip"
              initial={{ opacity: 0, y: 0, scale: 0.8, x: "-50%" }}
              animate={{ opacity: 1, y: -28, scale: 1, x: "-50%" }}
              exit={{ opacity: 0, y: 0, scale: 0.8, x: "-50%" }}
              transition={{ duration: 0.15 }}
            >
              {val}
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>
    );
  };

  const fillStyle = range ? {
    left: `${getPercentage(localValue[0])}%`,
    width: `${getPercentage(localValue[1]) - getPercentage(localValue[0])}%`
  } : {
    left: 0,
    width: `${getPercentage(localValue)}%`
  };

  return (
    <div
      className={`custom-slider-container ${disabled ? 'disabled' : ''} ${range ? 'range' : ''}`}
      onClick={handleTrackClick}
    >
      <div className="custom-slider-track" ref={trackRef}>
        <motion.div
          className="custom-slider-fill"
          animate={fillStyle}
          transition={draggingHandle ? { duration: 0 } : { type: "spring", stiffness: 400, damping: 30 }}
        />
      </div>
      {range ? (
        <>
          {renderThumb(localValue[0], 'min')}
          {renderThumb(localValue[1], 'max')}
        </>
      ) : (
        renderThumb(localValue, 'single')
      )}
    </div>
  );
};
