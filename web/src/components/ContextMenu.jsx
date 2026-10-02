import { useEffect, useRef, useState, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { DynamicIcon } from '../utils/icons.jsx';
import { parseText } from '../utils/parser.jsx';
import { post } from '../utils/fetch.jsx';

const getColor = (color) => {
    if (!color) return null;
    if (color.startsWith('#') || color.startsWith('rgb')) return color;
    return color;
};

const getGlowColor = (color) => {
    if (!color) return 'rgba(var(--brand-rgb), 0.25)';
    if (color.startsWith('#') && color.length === 7) {
        const r = parseInt(color.slice(1, 3), 16);
        const g = parseInt(color.slice(3, 5), 16);
        const b = parseInt(color.slice(5, 7), 16);
        return `rgba(${r}, ${g}, ${b}, 0.25)`;
    }
    return color;
};

export function ContextMenu({ data, onClose }) {
  const { title, description, options, position = 'top-right', canClose = true, menu, searchable } = data;
  const menuRef = useRef(null);
  const [hoveredItem, setHoveredItem] = useState(null);
  const [metaTop, setMetaTop] = useState(0);
  const hoverTimeoutRef = useRef(null);
  const [searchQuery, setSearchQuery] = useState('');

  const prevDataRef = useRef(data);
  const directionRef = useRef(0);

  if (prevDataRef.current.id !== data.id) {
      if (data.menu === prevDataRef.current.id) {
          directionRef.current = 1;
      } else if (prevDataRef.current.menu === data.id) {
          directionRef.current = -1;
      } else {
          directionRef.current = 0;
      }
      prevDataRef.current = data;
  }

  const direction = directionRef.current;

  useEffect(() => { setHoveredItem(null); setSearchQuery(''); }, [data.id]);

  // Preload images from options into browser cache
  useEffect(() => {
      if (!options) return;
      options.forEach(item => {
          if (item.image) {
              const img = new Image();
              img.src = item.image;
          }
      });
  }, [data.id, options]);

  useEffect(() => {
    const handleKeyDown = (e) => {
      if (e.key === 'Escape' && canClose !== false) { onClose(); post('closeContext'); }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [onClose, canClose]);

  const handleItemClick = (item, index) => {
    if (item.disabled || item.readOnly) return;
    post('clickContext', { menuId: data.id, index: index + 1, data: item });
  };

  const handleMouseEnter = (item, e) => {
      if (hoverTimeoutRef.current) { clearTimeout(hoverTimeoutRef.current); hoverTimeoutRef.current = null; }
      setHoveredItem(item);
      if (menuRef.current) {
          const menuRect = menuRef.current.getBoundingClientRect();
          const itemRect = e.currentTarget.getBoundingClientRect();
          setMetaTop((itemRect.top - menuRect.top) + (itemRect.height / 2));
      }
  };

  const handleMouseLeave = () => { hoverTimeoutRef.current = setTimeout(() => { setHoveredItem(null); }, 150); };
  const handleMetaMouseEnter = () => { if (hoverTimeoutRef.current) { clearTimeout(hoverTimeoutRef.current); hoverTimeoutRef.current = null; } };
  const handleMetaMouseLeave = () => { hoverTimeoutRef.current = setTimeout(() => { setHoveredItem(null); }, 150); };
  const handleBack = () => { post('backContext', { menuId: data.id, parentId: menu }); };

  const positionStyles = {
    'top-right': { top: '5vh', right: '5vw' },
    'top-left': { top: '5vh', left: '5vw' },
    'center-right': { top: '50%', right: '5vw', translateY: '-50%' },
    'center-left': { top: '50%', left: '5vw', translateY: '-50%' },
    'center': { top: '50%', left: '50%', translateX: '-50%', translateY: '-50%' },
  };

  const currentStyle = positionStyles[position] || positionStyles['top-right'];
  const flexDirection = (position.includes('left') && !position.includes('center-right')) ? 'row' : 'row-reverse';
  const isRow = flexDirection === 'row';

  const listVariants = {
      enter: (dir) => ({ x: dir === 0 ? 0 : (dir > 0 ? '100%' : '-100%'), opacity: 0, position: 'relative' }),
      center: { x: 0, opacity: 1, position: 'relative', transition: { duration: 0.35, ease: [0.4, 0.0, 0.2, 1] } },
      exit: (dir) => ({ x: dir === 0 ? 0 : (dir > 0 ? '-100%' : '100%'), opacity: 0, position: 'absolute', top: 0, left: 0, right: 0, transition: { duration: 0.25, ease: [0.4, 0.0, 0.2, 1] } })
  };

  const titleVariants = {
      enter: (dir) => ({ x: dir === 0 ? 0 : (dir > 0 ? 50 : -50), opacity: 0 }),
      center: { x: 0, opacity: 1, transition: { duration: 0.35, ease: [0.4, 0.0, 0.2, 1] } },
      exit: (dir) => ({ x: dir === 0 ? 0 : (dir > 0 ? -50 : 50), opacity: 0, transition: { duration: 0.2, ease: [0.4, 0.0, 0.2, 1] } })
  };

  const [metaHeight, setMetaHeight] = useState('auto');
  const metaContentRef = useCallback((node) => {
      if (node) { setMetaHeight(node.getBoundingClientRect().height); }
  }, [hoveredItem]);

  return (
    <motion.div
        className="context-wrapper"
        style={{ ...currentStyle, flexDirection }}
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        exit={{ opacity: 0, scale: 0.95, transition: { duration: 0.1 } }}
    >
        <motion.div
            className="context-menu-container"
            layout="size"
            transition={{ type: "spring", stiffness: 400, damping: 32 }}
            ref={menuRef}
            style={{ willChange: 'transform' }}
        >
            <motion.div className="context-menu-header" layout="position">
                <div style={{ position: 'relative', zIndex: 20, width: 26, height: 26 }}>
                    <AnimatePresence mode="popLayout" initial={false}>
                        {menu ? (
                            <motion.button key="back-btn" className="context-header-btn back" onClick={handleBack}
                                style={{ position: 'absolute', top: 0, left: 0, width: '100%', height: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
                                initial={{ x: -20, opacity: 0 }} animate={{ x: 0, opacity: 1, transition: { duration: 0.2 } }} exit={{ x: -20, opacity: 0, transition: { duration: 0.2 } }}>
                                <i className="fa-solid fa-chevron-left" style={{ fontSize: '14px', fontWeight: 900 }} />
                            </motion.button>
                        ) : (
                            <motion.div key="spacer" style={{ position: 'absolute', top: 0, left: 0, width: '100%', height: '100%' }}
                                initial={{ opacity: 0 }} animate={{ opacity: 1, transition: { duration: 0.2 } }} exit={{ opacity: 0, transition: { duration: 0 } }} />
                        )}
                    </AnimatePresence>
                </div>

                <div className="context-title-area">
                    <AnimatePresence mode="popLayout" custom={direction} initial={false}>
                        <motion.div key={data.id} custom={direction} variants={titleVariants} initial="enter" animate="center" exit="exit" className="context-title-block">
                            <h2 className="context-menu-title">{parseText(title)}</h2>
                            {description && <p className="context-menu-description">{parseText(description)}</p>}
                        </motion.div>
                    </AnimatePresence>
                </div>

                {canClose !== false && (
                    <button className="context-header-btn close" style={{ zIndex: 2, position: 'relative', width: 26, height: 26, flexShrink: 0 }} onClick={() => { onClose(); post('closeContext'); }}>
                        <i className="fa-solid fa-xmark" style={{ fontSize: '14px', fontWeight: 900 }} />
                    </button>
                )}
            </motion.div>

            <motion.div layout="position" style={{ position: 'relative', overflow: 'hidden' }}>
                {searchable && (
                    <motion.div className="context-search-wrapper" layout="position">
                        <input
                            type="text"
                            className="context-search-input"
                            placeholder="Search..."
                            value={searchQuery}
                            onChange={(e) => setSearchQuery(e.target.value)}
                            autoFocus
                        />
                    </motion.div>
                )}
                <AnimatePresence mode="popLayout" custom={direction} initial={false}>
                    <motion.div key={data.id} custom={direction} variants={listVariants} initial="enter" animate="center" exit="exit" className="context-content-wrapper" style={{ zIndex: 1 }}>
                        <div className="context-menu-items">
                            {options && options.map((item, idx) => ({ ...item, _origIdx: idx })).filter(item => {
                                if (!searchQuery) return true;
                                const q = searchQuery.toLowerCase();
                                return (item.title && item.title.toLowerCase().includes(q)) ||
                                       (item.description && item.description.toLowerCase().includes(q));
                            }).map((item, index) => (
                            <div key={index}
                                className={`context-menu-item ${item.disabled ? 'disabled' : ''} ${item.readOnly ? 'readonly' : ''} ${item.description ? 'has-description' : ''}`}
                                style={{ background: (item.colorScheme && !item.disabled) ? `radial-gradient(circle at 10% 50%, ${getColor(item.colorScheme)}14, transparent 60%), rgba(0, 0, 0, 0.2)` : undefined }}
                                onClick={() => handleItemClick(item, item._origIdx)}
                                onMouseEnter={(e) => handleMouseEnter(item, e)}
                                onMouseLeave={handleMouseLeave}
                            >
                                <div className="context-item-left">
                                {item.icon && (
                                    <div className="context-item-icon" style={{ color: getColor(item.iconColor), '--icon-glow': getGlowColor(item.iconColor) }}>
                                        <DynamicIcon name={item.icon} className={item.iconAnimation ? `icon-${item.iconAnimation}` : ''} />
                                    </div>
                                )}
                                <div className="context-item-content">
                                    <div className="context-item-title">{parseText(item.title)}</div>
                                    {item.description && <div className="context-item-description">{parseText(item.description)}</div>}
                                    {item.progress !== undefined && (
                                        <div className="context-item-progress">
                                            <div className="progress-fill" style={{ width: `${Math.min(100, Math.max(0, item.progress))}%`, backgroundColor: getColor(item.colorScheme) || 'var(--info)' }} />
                                        </div>
                                    )}
                                </div>
                                </div>
                                <div className="context-item-right">
                                {(item.arrow || item.menu) && <i className="fa-solid fa-chevron-right context-arrow" style={{ fontSize: '16px', fontWeight: 900 }} />}
                                </div>
                            </div>
                            ))}
                            </div>
                    </motion.div>
                </AnimatePresence>
            </motion.div>
        </motion.div>

        <AnimatePresence>
            {hoveredItem && (hoveredItem.metadata || hoveredItem.image) && (
                <motion.div key="metadata-wrapper" className="context-metadata-wrapper"
                    style={{ position: 'absolute', [isRow ? 'left' : 'right']: '100%', [isRow ? 'marginLeft' : 'marginRight']: '10px' }}
                    initial={{ opacity: 0, y: '-50%', top: metaTop }}
                    animate={{ opacity: 1, y: '-50%', top: metaTop }}
                    exit={{ opacity: 0, y: '-50%' }}
                    transition={{ type: "spring", stiffness: 400, damping: 30, opacity: { duration: 0.15 } }}
                    onMouseEnter={handleMetaMouseEnter} onMouseLeave={handleMetaMouseLeave}
                >
                    <motion.div className="context-metadata-container" animate={{ height: metaHeight }} transition={{ type: "spring", stiffness: 400, damping: 32 }}>
                        <div ref={metaContentRef} className="context-meta-content">
                            {hoveredItem.image && <img src={hoveredItem.image} alt="" className="context-meta-image" />}
                            {hoveredItem.metadata && (
                                <div className="context-meta-list">
                                    {Array.isArray(hoveredItem.metadata) ? hoveredItem.metadata.map((meta, i) => (
                                        <div key={i} className="meta-row"><span className="meta-label">{meta.label}</span><span className="meta-value">{meta.value}</span></div>
                                    )) : Object.entries(hoveredItem.metadata).map(([key, value], i) => (
                                        <div key={i} className="meta-row"><span className="meta-label">{key}</span><span className="meta-value">{value}</span></div>
                                    ))}
                                </div>
                            )}
                        </div>
                    </motion.div>
                </motion.div>
            )}
        </AnimatePresence>
    </motion.div>
  );
}

