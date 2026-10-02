import { useEffect, useState, useRef, useLayoutEffect } from 'react';
import { createPortal } from 'react-dom';

export const Portal = ({ children, targetRef, isOpen, onClose, matchWidth = true }) => {
  const [position, setPosition] = useState({ top: 0, left: 0, width: 0 });
  const portalRef = useRef(null);

  const updatePosition = () => {
    if (targetRef.current && isOpen) {
      const rect = targetRef.current.getBoundingClientRect();
      let top = rect.bottom + 4;
      setPosition({
        top: top,
        left: rect.left,
        width: rect.width
      });
    }
  };

  useLayoutEffect(() => {
    if (isOpen) {
      updatePosition();
    }
    window.addEventListener('resize', updatePosition);
    window.addEventListener('scroll', updatePosition, true);
    return () => {
      window.removeEventListener('resize', updatePosition);
      window.removeEventListener('scroll', updatePosition, true);
    };
  }, [isOpen, targetRef]);

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (
        portalRef.current &&
        !portalRef.current.contains(event.target) &&
        targetRef.current &&
        !targetRef.current.contains(event.target)
      ) {
        onClose();
      }
    };

    if (isOpen) {
      document.addEventListener('mousedown', handleClickOutside);
    }

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [isOpen, onClose, targetRef]);

  return createPortal(
    <div
      ref={portalRef}
      style={{
        position: 'fixed',
        top: position.top,
        left: position.left,
        width: matchWidth ? position.width : 'auto',
        zIndex: 9999,
        pointerEvents: isOpen ? 'none' : 'none'
      }}
    >
      <div style={{ pointerEvents: 'auto', width: matchWidth ? '100%' : 'fit-content' }}>
        {children}
      </div>
    </div>,
    document.body
  );
};
