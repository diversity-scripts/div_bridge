import { motion } from 'framer-motion';

const dotColors = {
  pending: 'rgba(255, 255, 255, 0.25)',
  success: 'var(--success)',
  failed: 'var(--error)',
  active: 'var(--brand)',
};

export function StageIndicator({ total, current, results }) {
  return (
    <div
      style={{
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        gap: '10px',
        padding: '8px 0',
        fontFamily: 'var(--font-sans)',
      }}
    >
      {results.map((status, index) => (
        <motion.div
          key={index}
          initial={{ opacity: 0, scale: 0 }}
          animate={{
            opacity: 1,
            scale: status === 'active' ? 1.3 : 1,
            backgroundColor: dotColors[status] || dotColors.pending,
          }}
          transition={{
            duration: 0.3,
            type: 'spring',
            stiffness: 300,
            damping: 20,
          }}
          style={{
            width: 10,
            height: 10,
            borderRadius: '50%',
            boxShadow:
              status === 'active'
                ? '0 0 8px rgba(var(--brand-rgb), 0.6)'
                : status === 'success'
                ? '0 0 6px rgba(var(--success-rgb), 0.4)'
                : status === 'failed'
                ? '0 0 6px rgba(var(--error-rgb), 0.4)'
                : 'none',
          }}
        />
      ))}
    </div>
  );
}
