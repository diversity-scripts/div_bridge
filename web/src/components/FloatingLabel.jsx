import { motion, AnimatePresence } from 'framer-motion';
import { DynamicIcon } from '../utils/icons';
import { parseText } from '../utils/parser';

export const FloatingLabels = ({ labels }) => {
  if (!labels || Object.keys(labels).length === 0) return null;

  return (
    <div style={{
      position: 'absolute', top: 0, left: 0,
      width: '100vw', height: '100vh',
      pointerEvents: 'none', zIndex: 50
    }}>
      <AnimatePresence>
        {Object.values(labels).map((label) => (
          <FloatingLabel key={label.id} label={label} />
        ))}
      </AnimatePresence>
    </div>
  );
};

const FloatingLabel = ({ label }) => {
  const { id, x, y, opacity = 1, lod = 'near', text, subText, icon, color, key: keyHint } = label;

  const showText = true;
  const showSubText = lod === 'near';

  const posX = `${(x || 0) * 100}%`;
  const posY = `${(y || 0) * 100}%`;

  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.8, left: posX, top: posY }}
      animate={{ opacity: opacity, scale: 1, left: posX, top: posY }}
      exit={{ opacity: 0, scale: 0.8 }}
      transition={{
        left: { duration: 0.06, ease: 'linear' },
        top: { duration: 0.06, ease: 'linear' },
        opacity: { duration: 0.25, ease: 'easeOut' },
        scale: { duration: 0.2, ease: 'easeOut' },
      }}
      style={{
        position: 'absolute',
        pointerEvents: 'none',
        translateX: '-50%',
        translateY: '-50%',
      }}
    >
      <div style={{
        display: 'inline-flex',
        alignItems: 'center',
        gap: '10px',
        background: 'radial-gradient(circle at 10% 50%, rgba(var(--default-rgb), 0.1), transparent 60%), linear-gradient(180deg, rgb(35, 36, 39), rgb(28, 29, 31))',
        padding: '10px 16px',
        borderRadius: '10px',
        border: '1px solid rgba(255, 255, 255, 0.08)',
        boxShadow: '0 8px 20px rgba(0, 0, 0, 0.4)',
        whiteSpace: 'nowrap',
      }}>
        {icon && (
          <div style={{
            fontSize: '18px',
            color: color || 'var(--brand)',
            filter: `drop-shadow(0 0 6px ${color || 'var(--brand)'})`
          }}>
            <DynamicIcon name={icon} />
          </div>
        )}

        <AnimatePresence mode="wait">
          {showText && (
            <motion.div
              key={subText ? `text-${lod}` : 'text-static'}
              initial={subText ? { opacity: 0, width: 0 } : false}
              animate={{ opacity: 1, width: 'auto' }}
              exit={subText ? { opacity: 0, width: 0 } : undefined}
              transition={{ duration: 0.2 }}
              style={{ display: 'flex', flexDirection: 'column', gap: '2px', overflow: 'hidden' }}
            >
              <span style={{
                fontFamily: 'var(--font-sans)',
                fontWeight: 700,
                fontSize: '13px',
                color: '#fff'
              }}>
                {parseText(text)}
              </span>
              {showSubText && subText && (
                <span style={{
                  fontFamily: 'var(--font-sans)',
                  fontWeight: 500,
                  fontSize: '11px',
                  color: '#99AAB5'
                }}>
                  {parseText(subText)}
                </span>
              )}
            </motion.div>
          )}
        </AnimatePresence>

        {keyHint && (
          <kbd style={{
            fontFamily: 'var(--font-sans)',
            fontWeight: 700,
            fontSize: '12px',
            color: '#fff',
            background: 'rgba(0, 0, 0, 0.3)',
            padding: '4px 8px',
            borderRadius: '5px',
            border: '1px solid rgba(255, 255, 255, 0.08)',
            borderBottomWidth: '2px',
            marginLeft: '4px'
          }}>
            {keyHint}
          </kbd>
        )}
      </div>
    </motion.div>
  );
};
