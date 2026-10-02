import React, { useState, useEffect, useRef } from 'react';
import { Notification } from './components/Notification';
import { TaskNotification } from './components/TaskNotification';
import { Prompt } from './components/Prompt';
import { KeybindsDisplay } from './components/KeybindsDisplay';
import { SkillCheck } from './components/SkillCheck';
import { ContextMenu } from './components/ContextMenu';
import { ProgressBar } from './components/ProgressBar';
import { InputDialog } from './components/InputDialog';
import { AlertDialog } from './components/AlertDialog';
import { ConfirmDialog } from './components/ConfirmDialog';
import { FloatingLabels } from './components/FloatingLabel';
import { Subtitle } from './components/Subtitle';
import { MinigameOrchestrator } from './components/minigames/MinigameOrchestrator';
import { AnimatePresence, motion } from 'framer-motion';
import { post } from './utils/fetch';
import './styles/App.css';
import './styles/ContextMenu.css';
import './styles/Minigames.css';

let uiIdCounter = 0;
const TICK_RATE = 100;
const FINISH_STATE_DURATION = 5000;

async function sendToggleFocus() {
  await post('toggleFocus');
}

function App() {
  const [notifications, setNotifications] = useState([]);
  const [tasks, setTasks] = useState({});
  const [prompts, setPrompts] = useState({});
  const [keybinds, setKeybinds] = useState([]);
  const [pressedKey, setPressedKey] = useState(null);
  const [skillCheck, setSkillCheck] = useState(null);
  const [contextMenu, setContextMenu] = useState(null);
  const [progress, setProgress] = useState(null);
  const [inputDialog, setInputDialog] = useState(null);
  const [alertDialog, setAlertDialog] = useState(null);
  const [confirmDialog, setConfirmDialog] = useState(null);
  const [floatingLabels, setFloatingLabels] = useState({});
  const [subtitle, setSubtitle] = useState(null);
  const [minigame, setMinigame] = useState(null);
  const [isFocused, setIsFocused] = useState(false);
  const configRef = useRef({
    Priorities: {}, Text: {}, DefaultDuration: 5000, Colors: {}, PromptPositions: {},
  });

  const hasActionable = notifications.some(n => n.hasActions);

  useEffect(() => {
    const interval = setInterval(() => {
      setNotifications(prev => prev.map(n => ({ ...n, timeLeft: n.timeLeft - TICK_RATE })).filter(n => n.timeLeft > 0));
      setTasks(prev => {
        const newTasks = { ...prev };
        let hasChanged = false;
        for (const id in newTasks) {
          if (newTasks[id].finishTime && Date.now() > newTasks[id].finishTime) {
            delete newTasks[id];
            hasChanged = true;
          }
        }
        return hasChanged ? newTasks : prev;
      });
    }, TICK_RATE);
    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    const handleMessage = (event) => {
      const { action, data, id, state, config, key } = event.data;

      if (action === 'setup') {
        configRef.current = config;
        const style = document.createElement('style');
        style.innerHTML = `:root {--success: ${config.Colors.success}; --error: ${config.Colors.error}; --warning: ${config.Colors.warning}; --info: ${config.Colors.info}; --default: ${config.Colors.default}; --brand: ${config.Colors.brand || '#5D36B0'};}`;
        document.head.appendChild(style);
        return;
      }
      if (action === 'updateFocusState') { setIsFocused(state); return; }
      if (action === 'startTask') { setTasks(prev => ({ ...prev, [id]: { id, type: 'info', progress: 0, ...data } })); return; }
      if (action === 'updateTask') { setTasks(prev => (prev[id] ? { ...prev, [id]: { ...prev[id], ...data } } : prev)); return; }
      if (action === 'finishTask') { setTasks(prev => { if (!prev[id]) return prev; const currentTask = prev[id]; return { ...prev, [id]: { ...currentTask, ...data, finishedState: data.state, finishTime: Date.now() + FINISH_STATE_DURATION } }; }); return; }
      if (action === 'cancelTask') { setTasks(prev => { const newTasks = { ...prev }; delete newTasks[id]; return newTasks; }); return; }
      if (action === 'setKeybinds') { setKeybinds(data); return; }
      if (action === 'keybindPressed') { setPressedKey(key); setTimeout(() => setPressedKey(null), 200); return; }
      if (action === 'showSkillCheck') { setSkillCheck(data); return; }
      if (action === 'showContext') { setContextMenu(data); return; }
      if (action === 'hideContext') { setContextMenu(null); return; }
      if (action === 'progress') { setProgress(data); return; }
      if (action === 'cancelProgress') { setProgress(prev => prev ? { ...prev, cancelled: true } : null); return; }
      if (action === 'inputDialog') { setInputDialog({ ...data, id: data.id || Date.now() }); return; }
      if (action === 'closeInputDialog') { setInputDialog(null); return; }
      if (action === 'alertDialog') { setAlertDialog({ ...data, id: data.id || Date.now() }); return; }
      if (action === 'closeAlertDialog') { setAlertDialog(null); return; }
      if (action === 'confirmDialog') { setConfirmDialog({ ...data, id: data.id || Date.now() }); return; }
      if (action === 'closeConfirmDialog') { setConfirmDialog(null); return; }
      if (action === 'batchFloatingLabels') {
        const { labels } = event.data;
        setFloatingLabels(prev => {
          const next = { ...prev };
          for (const item of labels) {
            if (item.action === 'hide') {
              // Set opacity to 0 to trigger exit animation, then remove after delay
              if (next[item.id]) {
                next[item.id] = { ...next[item.id], _hiding: true, opacity: 0 };
              }
            }
          }
          for (const item of labels) {
            if (item.action === 'show') {
              next[item.id] = {
                id: item.id,
                x: item.x,
                y: item.y,
                opacity: item.opacity,
                lod: item.lod,
                text: item.text,
                subText: item.subText,
                icon: item.icon,
                color: item.color,
                key: item.key,
                position: item.position,
              };
            }
          }
          return next;
        });
        // Clean up hidden labels after exit animation completes
        setTimeout(() => {
          setFloatingLabels(prev => {
            const next = { ...prev };
            let changed = false;
            for (const id in next) {
              if (next[id]._hiding) {
                delete next[id];
                changed = true;
              }
            }
            return changed ? next : prev;
          });
        }, 300);
        return;
      }
      if (action === 'showFloatingLabel') { setFloatingLabels(prev => ({ ...prev, [id]: { id, ...data } })); return; }
      if (action === 'updateFloatingLabel') { setFloatingLabels(prev => (prev[id] ? { ...prev, [id]: { ...prev[id], ...data } } : prev)); return; }
      if (action === 'hideFloatingLabel') { 
        setFloatingLabels(prev => (prev[id] ? { ...prev, [id]: { ...prev[id], _hiding: true, opacity: 0 } } : prev));
        setTimeout(() => { setFloatingLabels(prev => { const n = { ...prev }; if (n[id] && n[id]._hiding) delete n[id]; return n; }); }, 300);
        return; 
      }
      if (action === 'showMinigame') { setMinigame({ ...data, id: data.id || Date.now() }); return; }
      if (action === 'hideMinigame') { setMinigame(null); return; }
      if (action === 'showSubtitle') { setSubtitle({ ...data, _key: Date.now() }); return; }
      if (action === 'hideSubtitle') { setSubtitle(null); return; }
      if (action === 'show') {
        const notificationKey = `${data.type}-${data.title}-${data.text}`;
        setNotifications(prev => {
          const existing = prev.find(n => n.key === notificationKey);
          const hasActions = data.actions ? true : false;
          const duration = hasActions ? (data.duration || 999999999) : (data.duration || configRef.current.DefaultDuration);
          if (existing) {
            let nextState = prev.map(n => n.key === notificationKey ? { ...n, count: n.count + 1, timeLeft: duration, initialDuration: duration, shake: true, _resetKey: Date.now() } : n);
            return nextState.sort((a, b) => (a.priority || 99) - (b.priority || 99));
          } else {
            const newNotification = { ...data, luaId: data.id, uiId: uiIdCounter++, key: notificationKey, count: 1, timeLeft: duration, initialDuration: duration, shake: false, hasActions: hasActions, priority: hasActions ? 1 : configRef.current.Priorities[data.type] || 99 };
            let nextState = [...prev, newNotification];
            return nextState.sort((a, b) => a.priority - b.priority);
          }
        });
      } else if (action === 'update') {
        setNotifications(prev => prev.map(n => {
          if (n.luaId === id) {
            const updatedData = { ...n, ...data };
            // Reset the lifetime timer and restart the progress-bar animation.
            // The bar only re-runs when its React key (_resetKey) changes, so
            // bump it even if the duration is unchanged.
            const duration = data.duration || n.initialDuration;
            updatedData.timeLeft = duration;
            updatedData.initialDuration = duration;
            updatedData._resetKey = Date.now();
            updatedData.shake = true;
            // Keep the grouping key in sync so a changed title/text still matches.
            updatedData.key = `${updatedData.type}-${updatedData.title}-${updatedData.text}`;
            return updatedData;
          }
          return n;
        }));
      } else if (action === 'dismiss') {
        setNotifications(prev => prev.filter(n => n.luaId !== id));
      } else if (action === 'showPrompt') {
        setPrompts(prev => ({ ...prev, [id]: { id, ...data } }));
      } else if (action === 'hidePrompt') {
        setPrompts(prev => { const newPrompts = { ...prev }; delete newPrompts[id]; return newPrompts; });
      }
    };
    window.addEventListener('message', handleMessage);
    return () => window.removeEventListener('message', handleMessage);
  }, []);

  useEffect(() => {
    const handleKeyUp = (event) => {
      if (hasActionable && isFocused && event.code === `Key${configRef.current.Text?.keyDisplay?.toUpperCase() || 'G'}`) {
        post('toggleFocus');
      }
    };
    window.addEventListener('keyup', handleKeyUp);
    return () => window.removeEventListener('keyup', handleKeyUp);
  }, [hasActionable, isFocused]);

  useEffect(() => {
    const shakeNotifications = notifications.filter(n => n.shake);
    if (shakeNotifications.length > 0) {
      const timer = setTimeout(() => {
        setNotifications(prev => prev.map(n => (n.shake ? { ...n, shake: false } : n)));
      }, 500);
      return () => clearTimeout(timer);
    }
  }, [notifications]);

  const groupedPrompts = Object.values(prompts).reduce((acc, prompt) => {
    const position = prompt.position || 'bottom-center';
    if (!acc[position]) acc[position] = [];
    acc[position].push(prompt);
    return acc;
  }, {});

  return (
    <>
      <div className="notification-container">
        <AnimatePresence>
          {Object.values(tasks).map((task) => (
            <TaskNotification key={task.id} data={task} />
          ))}
        </AnimatePresence>
        <AnimatePresence>
          {notifications.map((n) => (
            <Notification key={n.uiId} data={n} isFocused={isFocused} config={configRef.current} />
          ))}
        </AnimatePresence>
      </div>

      <div className="prompts-wrapper">
        {configRef.current.PromptPositions && Object.keys(configRef.current.PromptPositions).map((position) => {
          const promptList = groupedPrompts[position] || [];
          return (
            <motion.div layout key={position} className="prompt-container" style={configRef.current.PromptPositions[position]}>
              <AnimatePresence>
                {promptList.map((prompt) => (
                  <Prompt key={prompt.id} data={prompt} />
                ))}
              </AnimatePresence>
            </motion.div>
          );
        })}
      </div>

      <KeybindsDisplay keybinds={keybinds} pressedKey={pressedKey} />

      <AnimatePresence>
        {skillCheck && <SkillCheck key={skillCheck.id} data={skillCheck} onComplete={() => setSkillCheck(null)} />}
      </AnimatePresence>

      <AnimatePresence>
        {contextMenu && <ContextMenu key="context-menu" data={contextMenu} onClose={() => setContextMenu(null)} />}
      </AnimatePresence>

      <AnimatePresence>
        {progress && <ProgressBar key="progress-instance" data={progress} />}
      </AnimatePresence>

      <AnimatePresence>
        {inputDialog && (
          <InputDialog key={inputDialog.id} data={inputDialog} onClose={() => setInputDialog(null)} />
        )}
      </AnimatePresence>

      <AnimatePresence>
        {alertDialog && (
          <AlertDialog key={alertDialog.id} data={alertDialog} onClose={() => setAlertDialog(null)} />
        )}
      </AnimatePresence>

      <AnimatePresence>
        {confirmDialog && (
          <ConfirmDialog key={confirmDialog.id} data={confirmDialog} onClose={() => setConfirmDialog(null)} />
        )}
      </AnimatePresence>

      <AnimatePresence>
        {minigame && (
          <MinigameOrchestrator
            key={minigame.id}
            data={minigame}
            onClose={() => setMinigame(null)}
          />
        )}
      </AnimatePresence>

      <FloatingLabels labels={floatingLabels} />

      <Subtitle key={subtitle?._key} data={subtitle} />
    </>
  );
}

export default App;
