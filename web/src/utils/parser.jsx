import React from 'react';

const colorMap = {
  'r': 'var(--error)',
  'g': 'var(--success)',
  'b': 'var(--info)',
  'y': 'var(--warning)',
  'p': '#9C27B0',
  'o': '#FF9800',
  'c': 'var(--default)',
  'm': '#607D8B',
  'u': '#000000',
  'w': 'inherit',
  's': 'inherit',
};

export function parseText(text) {
  if (!text) return '';

  const regex = /(~[rgbypocmuws]~|~n~|<color:#[\da-fA-F]{6}>.*?<\/color>|\|#[\da-fA-F]{6}\|.*?\||\*\*[^*]+\*\*|\*[^*]+\*|~[^~]+~)/g;

  const parts = text.split(regex);
  const elements = [];
  let currentColor = null;

  parts.forEach((part, index) => {
    if (!part) return;

    if (part.match(/^~[rgbypocmuws]~$/)) {
      const code = part.charAt(1);
      currentColor = colorMap[code];
      return;
    }

    if (part === '~n~') {
      elements.push(<br key={`br-${index}`} />);
      return;
    }

    if (part.startsWith('<color:#') && part.endsWith('</color>')) {
      const match = part.match(/<color:(#[\da-fA-F]{6})>(.*?)<\/color>/);
      if (match && match[1] && match[2]) {
        elements.push(
          <span key={index} style={{ color: match[1] }}>
            {match[2]}
          </span>
        );
      }
      return;
    }

    if (part.startsWith('|#') && part.endsWith('|')) {
      const match = part.match(/\|(#[\da-fA-F]{6})\|(.*?)\|/);
      if (match && match[1] && match[2]) {
        elements.push(
          <span key={index} style={{ color: match[1] }}>
            {match[2]}
          </span>
        );
      }
      return;
    }

    if (part.startsWith('**') && part.endsWith('**')) {
      elements.push(
        <strong key={index} style={{ color: currentColor }}>
          {part.substring(2, part.length - 2)}
        </strong>
      );
      return;
    }

    if (part.startsWith('*') && part.endsWith('*')) {
      elements.push(
        <em key={index} style={{ color: currentColor }}>
          {part.substring(1, part.length - 1)}
        </em>
      );
      return;
    }

    if (part.startsWith('~') && part.endsWith('~')) {
      elements.push(
        <kbd key={index}>
          {part.substring(1, part.length - 1)}
        </kbd>
      );
      return;
    }

    elements.push(
      <span key={index} style={{ color: currentColor }}>
        {part}
      </span>
    );
  });

  return elements;
}
