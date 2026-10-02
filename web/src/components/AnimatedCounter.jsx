import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';

export function AnimatedCounter({ count }) {
  const [prevCount, setPrevCount] = useState(count);

  useEffect(() => {
    const timeout = setTimeout(() => setPrevCount(count), 0);
    return () => clearTimeout(timeout);
  }, [count]);

  const variants = {
    enter: { y: '100%' },
    center: { y: '0%' },
    exit: { y: '-100%' },
  };

  return (
    <div className="notification-count">
      <span>x</span>
      <div className="count-flipper">
        <span className="count-sizer" aria-hidden="true">{count}</span>
        <motion.span
          key={prevCount}
          className="count-digit"
          initial="center"
          animate="exit"
          variants={variants}
          transition={{ type: 'tween', ease: 'easeOut', duration: 0.3 }}
        >
          {prevCount}
        </motion.span>
        <motion.span
          key={count}
          className="count-digit"
          initial="enter"
          animate="center"
          variants={variants}
          transition={{ type: 'tween', ease: 'easeOut', duration: 0.3 }}
        >
          {count}
        </motion.span>
      </div>
    </div>
  );
}
