import React, { useState } from 'react';
import { motion, AnimatePresence, LayoutGroup } from 'framer-motion';
import { DynamicIcon } from '../utils/icons';
import { CustomSelect } from './CustomSelect';
import { CustomDatePicker } from './CustomDatePicker';
import { CustomTimePicker } from './CustomTimePicker';
import { CustomColorPicker } from './CustomColorPicker';
import { CustomSlider } from './CustomSlider';
import '../styles/InputDialog.css';
import { post } from '../utils/fetch';

export const InputDialog = ({ data, onClose }) => {
  const {
    id,
    heading,
    rows = [],
    options = { allowCancel: true }
  } = data;

  // Normalize select options: support arrays of strings and missing labels
  const normalizeSelectOptions = (opts) => {
    if (!opts) return [];
    return opts.map(opt => {
      if (typeof opt === 'string') return { value: opt, label: opt };
      if (typeof opt === 'number') return { value: opt, label: String(opt) };
      return { value: opt.value, label: opt.label || String(opt.value) };
    });
  };

  const [formValues, setFormValues] = useState(() => {
    const initialValues = [];
    rows.forEach((row, index) => {
      if (typeof row === 'string') {
        initialValues[index] = '';
      } else {
        if (row.type === 'checkbox') {
          initialValues[index] = row.checked || false;
        } else if (row.type === 'multi-select') {
          initialValues[index] = row.default || [];
        } else if (row.type === 'date-range') {
          initialValues[index] = row.default || ['', ''];
        } else if (row.type === 'number') {
          initialValues[index] = row.default !== undefined ? row.default : '';
        } else {
          initialValues[index] = row.default || '';
        }
      }
    });
    return initialValues;
  });

  const handleInputChange = (index, value) => {
    const newValues = [...formValues];
    newValues[index] = value;
    setFormValues(newValues);
  };

  const handleSubmit = () => {
    for (let i = 0; i < rows.length; i++) {
      const row = rows[i];
      const val = formValues[i];
      if (typeof row === 'string') continue;
      if (row.required) {
        if (row.type === 'checkbox') {
          if (!val) return;
        } else if (!val || val === '') {
          return;
        }
      }
      if (row.type === 'number') {
        if (row.min !== undefined && Number(val) < row.min) return;
        if (row.max !== undefined && Number(val) > row.max) return;
      }
      if (row.type === 'input' || row.type === 'textarea') {
        if (row.min && val.length < row.min) return;
        if (row.max && val.length > row.max) return;
      }
    }

    // Ensure number fields are actual numbers in output
    const outputValues = formValues.map((val, i) => {
      const row = rows[i];
      if (typeof row !== 'string' && row.type === 'number') {
        if (val === '' || val === undefined) return null;
        return Number(val);
      }
      return val;
    });

    post('inputDialogSubmit', { id: id, values: outputValues });
    onClose();
  };

  const handleCancel = () => {
    if (options.allowCancel !== false) {
      post('inputDialogCancel', { id: id });
      onClose();
    }
  };

  // ESC to close
  React.useEffect(() => {
    const handleKeyDown = (e) => {
      if (e.key === 'Escape') {
        handleCancel();
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, []);

  const renderField = (row, index) => {
    if (typeof row === 'string') {
      return (
        <div key={index} className="input-group">
          <label className="input-label">{row}</label>
          <input
            type="text"
            className="input-field"
            value={formValues[index]}
            onChange={(e) => handleInputChange(index, e.target.value)}
          />
        </div>
      );
    }

    const { type, label, description, placeholder, icon, disabled, required, min, max, step, options: selectOptions } = row;

    const commonProps = { disabled, required, placeholder };

    const renderInputWrapper = (children, hasIcon = false) => (
      <div key={index} className={`input-group ${type}`}>
        <div className="label-container">
          <label className="input-label">
            {label} {required && <span className="required">*</span>}
          </label>
        </div>
        <div className={`input-field-container ${hasIcon ? 'has-icon' : ''}`}>
          {hasIcon && icon && (
            <div className="input-icon-wrapper">
              <DynamicIcon name={icon} className="input-icon-inside" />
            </div>
          )}
          {children}
        </div>
        {description && <span className="input-description">{description}</span>}
      </div>
    );

    switch (type) {
      case 'checkbox':
        return (
          <div key={index} className="input-group checkbox-group">
            <label className="checkbox-container">
              <input
                type="checkbox"
                checked={formValues[index]}
                disabled={disabled}
                onChange={(e) => handleInputChange(index, e.target.checked)}
              />
              <span className="checkmark"></span>
              <span className="checkbox-label">{label}</span>
            </label>
            {description && <span className="input-description indent">{description}</span>}
          </div>
        );

      case 'number':
        return renderInputWrapper(
          <input
            type="number"
            className="input-field"
            value={formValues[index]}
            min={min}
            max={max}
            step={step || 'any'}
            onChange={(e) => handleInputChange(index, e.target.value)}
            {...commonProps}
          />,
          !!icon
        );

      case 'textarea':
        return renderInputWrapper(
          <textarea
            className="input-field textarea"
            value={formValues[index]}
            rows={row.min || 3}
            maxLength={row.max}
            onChange={(e) => handleInputChange(index, e.target.value)}
            {...commonProps}
          />,
          false
        );

      case 'select':
        return renderInputWrapper(
          <CustomSelect
            options={normalizeSelectOptions(selectOptions)}
            value={formValues[index]}
            onChange={(val) => handleInputChange(index, val)}
            placeholder={placeholder}
            disabled={disabled}
            searchable={row.searchable}
          />,
          !!icon
        );

      case 'multi-select':
        return renderInputWrapper(
          <CustomSelect
            options={normalizeSelectOptions(selectOptions)}
            value={formValues[index]}
            onChange={(val) => handleInputChange(index, val)}
            placeholder={placeholder || "Select options"}
            disabled={disabled}
            multiple={true}
            maxSelected={row.maxSelectedValues}
            searchable={row.searchable}
          />,
          !!icon
        );

      case 'slider':
      case 'range-slider': {
        const isRange = type === 'range-slider';
        const sliderVal = formValues[index] !== undefined ? formValues[index] : (isRange ? [min || 0, max || 100] : (min || 0));

        return renderInputWrapper(
          <div className="slider-wrapper">
            {!!icon && (
              <div className="slider-icon-wrapper">
                <DynamicIcon name={icon} className="input-icon-inside" />
              </div>
            )}
            <div className="slider-container">
              <CustomSlider
                value={sliderVal}
                min={min}
                max={max}
                step={step}
                onChange={(val) => handleInputChange(index, val)}
                disabled={disabled}
                range={isRange}
              />
            </div>
          </div>,
          false
        );
      }

      case 'color':
        return renderInputWrapper(
          <CustomColorPicker
            value={formValues[index]}
            onChange={(val) => handleInputChange(index, val)}
            placeholder={placeholder}
            disabled={disabled}
          />,
          false
        );

      case 'date':
        return renderInputWrapper(
          <CustomDatePicker
            value={formValues[index]}
            onChange={(val) => handleInputChange(index, val)}
            min={min}
            max={max}
            disabled={disabled}
            placeholder={placeholder}
          />,
          false
        );

      case 'time':
        return renderInputWrapper(
          <CustomTimePicker
            value={formValues[index]}
            onChange={(val) => handleInputChange(index, val)}
            disabled={disabled}
            placeholder={placeholder}
          />,
          false
        );

      default:
        return renderInputWrapper(
          <input
            type="text"
            className="input-field"
            value={formValues[index]}
            maxLength={max}
            onChange={(e) => handleInputChange(index, e.target.value)}
            {...commonProps}
          />,
          !!icon
        );
    }
  };

  const isWide = options.size === 'lg' || options.layout === 'grid';

  return (
    <div className="input-dialog-overlay">
      <LayoutGroup>
        <motion.div
          layout
          className={`input-dialog-container ${isWide ? 'wide' : ''}`}
          initial={{ opacity: 0, scale: 0.95, y: 20 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={{ opacity: 0, scale: 0.95, y: 20 }}
          transition={{ duration: 0.2 }}
        >
          <div className="input-dialog-header">
            <h2>{heading}</h2>
          </div>

          <motion.div layout className={`input-dialog-body ${isWide ? 'grid' : ''}`}>
            {rows.map((row, index) => (
              <motion.div layout key={index} style={{ width: '100%' }}>
                {renderField(row, index)}
              </motion.div>
            ))}
          </motion.div>

          <div className="input-dialog-footer">
            {options.allowCancel !== false && (
              <motion.button
                className="btn btn-cancel"
                onClick={handleCancel}
                whileHover={{ scale: 1.05, filter: "brightness(1.2)" }}
                whileTap={{ scale: 0.95 }}
              >
                Cancel
              </motion.button>
            )}
            <motion.button
              className="btn btn-confirm"
              onClick={handleSubmit}
              whileHover={{ scale: 1.05, filter: "brightness(1.1)" }}
              whileTap={{ scale: 0.95 }}
            >
              Confirm
            </motion.button>
          </div>
        </motion.div>
      </LayoutGroup>
    </div>
  );
};
