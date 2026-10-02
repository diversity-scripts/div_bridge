/**
 * DynamicIcon — renders a FontAwesome solid icon by name.
 *
 * Accepts bare names ('xmark', 'wrench') or prefixed ('fa-xmark', 'fa-wrench').
 * Always renders as fa-solid. Falls back to 'circle-question' if name is missing.
 */
export const DynamicIcon = ({ name, className = '', style, ...props }) => {
  const iconName = name
    ? name.replace(/^fa-/, '')
    : 'circle-question';

  return <i className={`fa-solid fa-${iconName} ${className}`} style={style} {...props} />;
};