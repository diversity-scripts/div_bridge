import React, { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Portal } from './Portal';
import '../styles/CustomColorPicker.css';

const hexToHsv = (hex) => {
  let r = 0, g = 0, b = 0;
  if (hex.length === 4) {
    r = "0x" + hex[1] + hex[1];
    g = "0x" + hex[2] + hex[2];
    b = "0x" + hex[3] + hex[3];
  } else if (hex.length === 7) {
    r = "0x" + hex[1] + hex[2];
    g = "0x" + hex[3] + hex[4];
    b = "0x" + hex[5] + hex[6];
  }
  r /= 255; g /= 255; b /= 255;
  let cmin = Math.min(r, g, b), cmax = Math.max(r, g, b), delta = cmax - cmin;
  let h = 0, s = 0, v = 0;

  if (delta === 0) h = 0;
  else if (cmax === r) h = ((g - b) / delta) % 6;
  else if (cmax === g) h = (b - r) / delta + 2;
  else h = (r - g) / delta + 4;
  h = Math.round(h * 60);
  if (h < 0) h += 360;

  s = delta === 0 ? 0 : delta / cmax;
  v = cmax;
  return { h, s, v };
};

const hsvToRgb = (h, s, v) => {
  let c = v * s;
  let x = c * (1 - Math.abs(((h / 60) % 2) - 1));
  let m = v - c;
  let r = 0, g = 0, b = 0;
  if (0 <= h && h < 60) { r = c; g = x; b = 0; }
  else if (60 <= h && h < 120) { r = x; g = c; b = 0; }
  else if (120 <= h && h < 180) { r = 0; g = c; b = x; }
  else if (180 <= h && h < 240) { r = 0; g = x; b = c; }
  else if (240 <= h && h < 300) { r = x; g = 0; b = c; }
  else if (300 <= h && h < 360) { r = c; g = 0; b = x; }

  r = Math.round((r + m) * 255);
  g = Math.round((g + m) * 255);
  b = Math.round((b + m) * 255);
  return { r, g, b };
};

const rgbToHex = (r, g, b) => {
  return "#" + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
};

export const CustomColorPicker = ({
  value,
  onChange,
  placeholder = "#RRGGBB",
  disabled = false
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const containerRef = useRef(null);
  const popupRef = useRef(null);
  const [hexValue, setHexValue] = useState(value || '#ffffff');
  const [hsv, setHsv] = useState({ h: 0, s: 0, v: 1 });
  const [isAdvanced, setIsAdvanced] = useState(false);

  useEffect(() => {
    if (value) {
      setHexValue(value);
      setHsv(hexToHsv(value));
    }
  }, [value]);

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (
        containerRef.current &&
        !containerRef.current.contains(event.target) &&
        popupRef.current &&
        !popupRef.current.contains(event.target)
      ) {
        setIsOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const swatches = [
    '#fa5252', '#e64980', '#be4bdb', '#7950f2', '#4c6ef5',
    '#228be6', '#15aabf', '#12b886', '#40c057', '#82c91e',
    '#fab005', '#fd7e14', '#ffffff', '#868e96', '#212529'
  ];

  const handleHexChange = (e) => {
    const val = e.target.value;
    setHexValue(val);
    if (/^#[0-9A-F]{6}$/i.test(val)) {
      setHsv(hexToHsv(val));
      onChange(val);
    }
  };

  const handleSwatchClick = (color) => {
    setHexValue(color);
    setHsv(hexToHsv(color));
    onChange(color);
  };

  const satValRef = useRef(null);
  const hueRef = useRef(null);
  const [dragging, setDragging] = useState(null);

  const updateSV = (e) => {
    if (!satValRef.current) return;
    const rect = satValRef.current.getBoundingClientRect();
    let x = e.clientX - rect.left;
    let y = e.clientY - rect.top;
    x = Math.max(0, Math.min(x, rect.width));
    y = Math.max(0, Math.min(y, rect.height));

    const newS = x / rect.width;
    const newV = 1 - (y / rect.height);

    const newHsv = { ...hsv, s: newS, v: newV };
    setHsv(newHsv);
    const rgb = hsvToRgb(newHsv.h, newS, newV);
    const hex = rgbToHex(rgb.r, rgb.g, rgb.b);
    setHexValue(hex);
    onChange(hex);
  };

  const updateHue = (e) => {
    if (!hueRef.current) return;
    const rect = hueRef.current.getBoundingClientRect();
    let x = e.clientX - rect.left;
    x = Math.max(0, Math.min(x, rect.width));
    const newH = (x / rect.width) * 360;

    const newHsv = { ...hsv, h: newH };
    setHsv(newHsv);
    const rgb = hsvToRgb(newH, hsv.s, hsv.v);
    const hex = rgbToHex(rgb.r, rgb.g, rgb.b);
    setHexValue(hex);
    onChange(hex);
  };

  const handleMouseMove = (e) => {
    if (dragging === 'sv') updateSV(e);
    if (dragging === 'h') updateHue(e);
  };

  const handleMouseUp = () => {
    setDragging(null);
  };

  useEffect(() => {
    if (dragging) {
      window.addEventListener('mousemove', handleMouseMove);
      window.addEventListener('mouseup', handleMouseUp);
      return () => {
        window.removeEventListener('mousemove', handleMouseMove);
        window.removeEventListener('mouseup', handleMouseUp);
      };
    }
  }, [dragging]);

  return (
    <div className={`custom-colorpicker-container ${disabled ? 'disabled' : ''}`} ref={containerRef}>
      <div className="color-preview-wrapper">
        <div
          className="color-preview-box"
          style={{ backgroundColor: hexValue }}
          onClick={() => !disabled && setIsOpen(!isOpen)}
        />
        <input
          type="text"
          className="color-hex-input"
          value={hexValue}
          onChange={handleHexChange}
          placeholder={placeholder}
          maxLength={7}
          disabled={disabled}
        />
      </div>

      <Portal targetRef={containerRef} isOpen={isOpen} onClose={() => setIsOpen(false)} matchWidth={false}>
        <AnimatePresence>
          {isOpen && (
            <motion.div
              layout
              className="custom-colorpicker-popup"
              initial={{ opacity: 0, y: -5 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -5 }}
              transition={{
                layout: { type: 'spring', stiffness: 350, damping: 35, mass: 1 },
                opacity: { duration: 0.15 }
              }}
              style={{ position: 'relative', top: 0, left: 0 }}
            >
              {!isAdvanced ? (
                <>
                  <motion.div layout="position" className="color-swatches-grid">
                    {swatches.map(color => (
                      <div
                        key={color}
                        className={`color-swatch ${hexValue.toLowerCase() === color.toLowerCase() ? 'selected' : ''}`}
                        style={{ backgroundColor: color }}
                        onClick={() => handleSwatchClick(color)}
                      />
                    ))}
                  </motion.div>
                  <motion.div layout="position" className="color-picker-footer" onClick={() => setIsAdvanced(true)}>
                    <span>Advanced Mode</span>
                    <i className="fa-solid fa-sliders" style={{ fontSize: '14px' }} />
                  </motion.div>
                </>
              ) : (
                <div className="advanced-picker">
                  <div
                    className="sat-val-area"
                    ref={satValRef}
                    style={{ backgroundColor: `hsl(${hsv.h}, 100%, 50%)` }}
                    onMouseDown={(e) => { setDragging('sv'); updateSV(e); }}
                  >
                    <div className="sat-layer"></div>
                    <div className="val-layer"></div>
                    <div
                      className="picker-cursor"
                      style={{
                        left: `${hsv.s * 100}%`,
                        top: `${(1 - hsv.v) * 100}%`,
                        backgroundColor: hexValue
                      }}
                    />
                  </div>
                  <div className="hue-slider-container">
                    <div
                      className="hue-slider"
                      ref={hueRef}
                      onMouseDown={(e) => { setDragging('h'); updateHue(e); }}
                    >
                      <div
                        className="hue-cursor"
                        style={{ left: `${(hsv.h / 360) * 100}%` }}
                      />
                    </div>
                  </div>
                  <div className="color-picker-footer" onClick={() => setIsAdvanced(false)}>
                    <i className="fa-solid fa-grid-2" style={{ fontSize: '14px' }} />
                    <span>Swatches</span>
                  </div>
                </div>
              )}
            </motion.div>
          )}
        </AnimatePresence>
      </Portal>
    </div>
  );
};

