import React, { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { DynamicIcon } from '../utils/icons';
import { Portal } from './Portal';
import '../styles/CustomSelect.css';

export const CustomSelect = ({
  options,
  value,
  onChange,
  placeholder = "Select an option",
  disabled = false,
  className = "",
  multiple = false,
  maxSelected = null,
  searchable = false
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const [searchTerm, setSearchTerm] = useState("");
  const containerRef = useRef(null);
  const searchInputRef = useRef(null);

  useEffect(() => {
    if (!isOpen) {
      setSearchTerm("");
    } else if (searchable && searchInputRef.current) {
      setTimeout(() => searchInputRef.current?.focus(), 50);
    }
  }, [isOpen, searchable]);

  const isSelected = (val) => {
    if (multiple) {
      return Array.isArray(value) && value.includes(val);
    }
    return value === val;
  };

  const filteredOptions = options?.filter(opt =>
    opt.label.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const getDisplayLabel = () => {
    if (multiple) {
      if (!value || value.length === 0) return placeholder;
      const selectedLabels = options
        ?.filter(opt => value.includes(opt.value))
        .map(opt => opt.label);
      if (selectedLabels.length === 0) return placeholder;
      if (selectedLabels.length <= 2) return selectedLabels.join(", ");
      return `${selectedLabels.length} selected`;
    } else {
      const selectedOption = options?.find(opt => opt.value === value);
      return selectedOption ? selectedOption.label : placeholder;
    }
  };

  const handleSelect = (optionValue) => {
    if (disabled) return;
    if (multiple) {
      let newValue = Array.isArray(value) ? [...value] : [];
      if (newValue.includes(optionValue)) {
        newValue = newValue.filter(v => v !== optionValue);
      } else {
        if (maxSelected && newValue.length >= maxSelected) return;
        newValue.push(optionValue);
      }
      onChange(newValue);
    } else {
      onChange(optionValue);
      setIsOpen(false);
    }
  };

  return (
    <div
      className={`custom-select-container ${disabled ? 'disabled' : ''} ${className}`}
      ref={containerRef}
    >
      <div
        className={`custom-select-trigger ${isOpen ? 'open' : ''}`}
        onClick={() => !disabled && setIsOpen(!isOpen)}
      >
        <span className={`select-value ${(multiple ? (!value || value.length === 0) : !value) ? 'placeholder' : ''}`}>
          {getDisplayLabel()}
        </span>
        <i className={`fa-solid fa-chevron-down select-arrow ${isOpen ? 'rotated' : ''}`} />
      </div>

      <Portal targetRef={containerRef} isOpen={isOpen} onClose={() => setIsOpen(false)}>
        <AnimatePresence>
          {isOpen && (
            <motion.div
              layout="size"
              className="custom-select-options"
              initial={{ opacity: 0, y: -5 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -5 }}
              transition={{
                layout: { type: 'spring', stiffness: 300, damping: 30, mass: 0.8 },
                opacity: { duration: 0.15 }
              }}
              style={{ position: 'relative', top: 0, left: 0, width: '100%', overflow: 'hidden' }}
            >
              {searchable && (
                <motion.div layout="position" className="custom-select-search-wrapper">
                  <i className="fa-solid fa-magnifying-glass search-icon" style={{ fontSize: '14px' }} />
                  <input
                    ref={searchInputRef}
                    type="text"
                    className="custom-select-search-input"
                    placeholder="Search..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    onClick={(e) => e.stopPropagation()}
                  />
                </motion.div>
              )}
              <div className="custom-select-scroll">
                {filteredOptions?.map((option) => {
                  const active = isSelected(option.value);
                  return (
                    <motion.div
                      layout
                      key={option.value}
                      className={`custom-option ${active ? 'selected' : ''} ${multiple ? 'multi' : ''}`}
                      onClick={(e) => {
                        e.stopPropagation();
                        handleSelect(option.value);
                      }}
                    >
                      {multiple && (
                        <div className={`option-checkbox ${active ? 'checked' : ''}`}>
                          {active && <i className="fa-solid fa-check" style={{ fontSize: '12px' }} />}
                        </div>
                      )}
                      {!multiple && active && <i className="fa-solid fa-check option-check" style={{ fontSize: '14px' }} />}
                      <span className="option-label">{option.label}</span>
                    </motion.div>
                  );
                })}
                {(!filteredOptions || filteredOptions.length === 0) && (
                  <motion.div layout className="custom-option no-results">No options available</motion.div>
                )}
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </Portal>
    </div>
  );
};

