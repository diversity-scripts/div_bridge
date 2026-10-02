import { useEffect, useState, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

// Parse text into segments with their styling, stripping all markup
function parseSegments(text) {
  if (!text) return [];
  const segments = [];
  let i = 0;
  let currentStyle = {};

  while (i < text.length) {
    // <color:#XXXXXX>...</color>
    const colorMatch = text.slice(i).match(/^<color:(#[\da-fA-F]{6})>(.*?)<\/color>/);
    if (colorMatch) {
      if (colorMatch[2]) {
        segments.push({ text: colorMatch[2], style: { color: colorMatch[1] } });
      }
      i += colorMatch[0].length;
      continue;
    }

    // |#XXXXXX|...|
    const pipeMatch = text.slice(i).match(/^\|(#[\da-fA-F]{6})\|(.*?)\|/);
    if (pipeMatch) {
      if (pipeMatch[2]) {
        segments.push({ text: pipeMatch[2], style: { color: pipeMatch[1] } });
      }
      i += pipeMatch[0].length;
      continue;
    }

    // ~r~ color codes
    const codeMatch = text.slice(i).match(/^~([rgbypocmuws])~/);
    if (codeMatch) {
      const colorMap = { r: 'var(--error)', g: 'var(--success)', b: 'var(--info)', y: 'var(--warning)', p: '#9C27B0', o: '#FF9800', c: 'var(--default)', m: '#607D8B', u: '#000', w: 'inherit', s: 'inherit' };
      currentStyle = { color: colorMap[codeMatch[1]] };
      i += 3;
      continue;
    }

    // ~n~ newline
    if (text.slice(i, i + 3) === '~n~') {
      segments.push({ text: '\n', style: {}, isBreak: true });
      i += 3;
      continue;
    }

    // *bold*
    const boldMatch = text.slice(i).match(/^\*([^*]+)\*/);
    if (boldMatch) {
      segments.push({ text: boldMatch[1], style: { ...currentStyle, fontWeight: 800 } });
      i += boldMatch[0].length;
      continue;
    }

    // ~keybind~
    const kbMatch = text.slice(i).match(/^~([^~]+)~/);
    if (kbMatch) {
      segments.push({ text: kbMatch[1], style: {}, isKbd: true });
      i += kbMatch[0].length;
      continue;
    }

    // Regular character — collect consecutive plain chars
    let plain = '';
    while (i < text.length && text[i] !== '<' && text[i] !== '|' && text[i] !== '~' && text[i] !== '*') {
      plain += text[i];
      i++;
    }
    if (plain) {
      segments.push({ text: plain, style: { ...currentStyle } });
    }
  }

  return segments;
}

export const Subtitle = ({ data }) => {
  const [visibleChars, setVisibleChars] = useState(0);
  const [isVisible, setIsVisible] = useState(false);
  const intervalRef = useRef(null);
  const timeoutRef = useRef(null);

  const segments = data ? parseSegments(data.text || '') : [];
  const totalChars = segments.reduce((sum, seg) => sum + (seg.isBreak ? 0 : seg.text.length), 0);

  useEffect(() => {
    if (intervalRef.current) clearInterval(intervalRef.current);
    if (timeoutRef.current) clearTimeout(timeoutRef.current);

    if (!data) {
      setIsVisible(false);
      setVisibleChars(0);
      return;
    }

    const { typeSpeed = 30, duration = 5000 } = data;
    setIsVisible(true);
    setVisibleChars(0);

    let count = 0;
    intervalRef.current = setInterval(() => {
      count++;
      setVisibleChars(count);
      if (count >= totalChars) {
        clearInterval(intervalRef.current);
        intervalRef.current = null;
        if (duration > 0) {
          timeoutRef.current = setTimeout(() => {
            setIsVisible(false);
          }, duration);
        }
      }
    }, typeSpeed);

    return () => {
      if (intervalRef.current) clearInterval(intervalRef.current);
      if (timeoutRef.current) clearTimeout(timeoutRef.current);
    };
  }, [data, totalChars]);

  const position = data?.position || 'bottom';
  const showBackground = data?.background || false;

  // Render segments with character limit
  const renderSegments = () => {
    let charsShown = 0;
    return segments.map((seg, idx) => {
      if (seg.isBreak) {
        return charsShown <= visibleChars ? <br key={idx} /> : null;
      }

      const remaining = visibleChars - charsShown;
      if (remaining <= 0) return null;

      const visibleText = seg.text.slice(0, remaining);
      charsShown += seg.text.length;

      if (seg.isKbd) {
        return (
          <kbd key={idx} style={{
            fontFamily: 'var(--font-sans)', fontWeight: 700, color: '#fff',
            background: 'rgba(0, 0, 0, 0.25)', padding: '3px 7px', borderRadius: '5px',
            border: '1px solid rgba(255, 255, 255, 0.05)', borderBottomWidth: '2px',
            boxShadow: 'inset 0 -1px 0 rgba(255, 255, 255, 0.1)', margin: '0 2px', verticalAlign: 'middle'
          }}>
            {visibleText}
          </kbd>
        );
      }

      return (
        <span key={idx} style={seg.style}>
          {visibleText}
        </span>
      );
    });
  };

  return (
    <AnimatePresence>
      {isVisible && (
        <motion.div
          key="subtitle"
          initial={{ opacity: 0, y: position === 'top' ? -15 : 15 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: position === 'top' ? -15 : 15 }}
          transition={{ duration: 0.3, ease: [0.4, 0, 0.2, 1] }}
          style={{
            position: 'absolute',
            left: 0,
            right: 0,
            [position === 'top' ? 'top' : 'bottom']: position === 'top' ? '8vh' : '12vh',
            display: 'flex',
            justifyContent: 'center',
            pointerEvents: 'none',
            zIndex: 100
          }}
        >
          <div style={{
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            gap: '4px',
            maxWidth: '60vw',
            textAlign: 'center',
            ...(showBackground ? {
              background: 'rgba(0, 0, 0, 0.55)',
              padding: '12px 24px',
              borderRadius: '8px',
              border: '1px solid rgba(255, 255, 255, 0.06)'
            } : {
              padding: '8px 16px'
            })
          }}>
            {data.speaker && (
              <span style={{
                fontFamily: 'var(--font-sans)',
                fontWeight: 800,
                fontSize: '14px',
                color: data.speakerColor || 'var(--brand)',
                textShadow: showBackground ? 'none' : '0 2px 8px rgba(0, 0, 0, 0.9), 0 0 2px rgba(0, 0, 0, 1)'
              }}>
                {data.speaker}
              </span>
            )}
            <span style={{
              fontFamily: 'var(--font-sans)',
              fontWeight: 500,
              fontSize: '16px',
              color: '#ffffff',
              lineHeight: 1.5,
              textShadow: showBackground ? 'none' : '0 2px 8px rgba(0, 0, 0, 0.9), 0 0 2px rgba(0, 0, 0, 1), 0 0 20px rgba(0, 0, 0, 0.5)'
            }}>
              {renderSegments()}
            </span>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
};
