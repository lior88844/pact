// Pact — Today (refined hierarchy: tasks as focal point, day navigation arrows)
const { useState: useStateT, useEffect: useEffectT, useRef: useRefT } = React;

/* ---------- Daily Signal — quieter, editorial ---------- */
function DailyInsightCard({ text }) {
  return (
    <div style={{
      background: 'transparent',
      borderTop: '1px solid var(--hairline)',
      borderBottom: '1px solid var(--hairline)',
      padding: '14px 4px 14px 0',
      display: 'flex', gap: 12,
      position: 'relative',
    }}>
      <div style={{
        width: 2, alignSelf: 'stretch',
        background: 'var(--you)', opacity: 0.5,
        borderRadius: 2, marginLeft: 2,
      }}/>
      <div style={{ flex: 1 }}>
        <div className="tracked" style={{ color: 'var(--ink-3)', fontSize: 9, marginBottom: 4 }}>
          Daily signal
        </div>
        <div className="editorial" style={{
          fontSize: 16, lineHeight: 1.4, color: 'var(--ink-1)',
          fontWeight: 400, textWrap: 'pretty', fontStyle: 'italic',
        }}>"{text}"</div>
      </div>
    </div>
  );
}

/* ---------- Mood / state — bigger touch, softer fill, scale-pop ---------- */
function StateSelector({ value, onChange, readOnly = false, label }) {
  const [popId, setPopId] = useStateT(null);
  return (
    <div>
      <div className="tracked" style={{ color: 'var(--ink-3)', marginBottom: 10, paddingLeft: 2, fontSize: 9 }}>
        {label}
      </div>
      <div style={{
        display: 'flex', gap: 10, overflowX: 'auto', paddingBottom: 4, paddingLeft: 1, paddingRight: 1, paddingTop: 2,
      }} className="no-scrollbar">
        {STATES.map(s => {
          const active = value === s.id;
          return (
            <button key={s.id}
              onClick={() => {
                if (readOnly) return;
                haptic('light');
                setPopId(s.id);
                setTimeout(() => setPopId(null), 320);
                onChange(s.id);
              }}
              disabled={readOnly && !active}
              className={popId === s.id ? 'chip-pop' : ''}
              style={{
                flexShrink: 0,
                padding: '10px 14px',
                borderRadius: 100,
                background: active ? 'var(--card)' : 'transparent',
                border: `1px solid ${active ? 'var(--ink-0)' : 'var(--hairline)'}`,
                color: active ? 'var(--ink-0)' : 'var(--ink-2)',
                fontSize: 13, fontWeight: active ? 600 : 500,
                display: 'flex', alignItems: 'center', gap: 7,
                transition: 'all 280ms cubic-bezier(0.2, 0.8, 0.2, 1)',
                transform: active ? 'scale(1.03)' : 'scale(1)',
                boxShadow: active
                  ? '0 0 0 4px var(--you-glow), 0 6px 16px -6px rgba(20,18,12,0.18)'
                  : 'none',
                opacity: readOnly && !active ? 0.35 : 1,
                cursor: readOnly ? 'default' : 'pointer',
                letterSpacing: '-0.005em',
              }}>
              <span style={{ fontSize: 12, opacity: active ? 1 : 0.6 }}>{s.glyph}</span>
              {s.label}
            </button>
          );
        })}
      </div>
    </div>
  );
}

/* ---------- You/Partner toggle — stronger contrast, sliding pill ---------- */
function UserToggle({ value, onChange }) {
  const isYou = value === 'you';
  return (
    <div style={{
      position: 'relative',
      display: 'flex', alignItems: 'stretch',
      padding: 4, borderRadius: 100,
      background: 'var(--bg-2)',
      border: '1px solid var(--hairline)',
      boxShadow: 'inset 0 1px 2px rgba(20,18,12,0.04)',
    }}>
      <div style={{
        position: 'absolute',
        top: 4, bottom: 4,
        left: isYou ? 4 : '50%',
        width: 'calc(50% - 4px)',
        background: 'var(--ink-0)',
        borderRadius: 100,
        boxShadow: '0 4px 12px -3px rgba(20,18,12,0.25), 0 1px 0 rgba(255,255,255,0.06) inset',
        transition: 'left 380ms cubic-bezier(0.34, 1.2, 0.4, 1)',
      }}/>
      {[
        { id: 'you', label: 'You', color: 'var(--you)' },
        { id: 'partner', label: 'Maya', color: 'var(--pal)' },
      ].map(t => {
        const active = value === t.id;
        return (
          <button key={t.id} onClick={() => { haptic('light'); onChange(t.id); }} style={{
            position: 'relative', zIndex: 1,
            flex: 1,
            padding: '11px 12px',
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
            color: active ? '#fff' : 'var(--ink-2)',
            fontSize: 14, fontWeight: 600, letterSpacing: '-0.01em',
            transition: 'color 280ms ease',
          }}>
            <span style={{
              width: 8, height: 8, borderRadius: 8,
              background: t.color,
              opacity: active ? 1 : 0.5,
              boxShadow: active ? `0 0 0 3px ${t.color === 'var(--you)' ? 'var(--you-glow)' : 'var(--pal-glow)'}` : 'none',
              transition: 'opacity 280ms ease, box-shadow 280ms ease',
            }}/>
            {t.label}
          </button>
        );
      })}
    </div>
  );
}

/* ---------- Identity card — grounded, name primary, inline progress ---------- */
function IdentityCard({ name, role, color, glow, done, max = 5, stateId, lastUpdate, interactive }) {
  const pct = max > 0 ? done / max : 0;

  return (
    <div className="fade-up" style={{
      position: 'relative',
      padding: '16px 18px',
      background: 'var(--card)',
      border: '1px solid var(--hairline)',
      borderRadius: 18,
      boxShadow: 'var(--shadow-card)',
    }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12 }}>
        {/* Left — identity */}
        <div style={{ minWidth: 0, flex: 1 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 7, marginBottom: 4 }}>
            <span style={{
              width: 6, height: 6, borderRadius: 6, background: color,
              boxShadow: `0 0 0 3px ${glow}`,
            }}/>
            <span className="tracked" style={{ color: 'var(--ink-3)', fontSize: 9 }}>{role}</span>
            {!interactive && (
              <span style={{
                display: 'inline-flex', alignItems: 'center', gap: 4,
                padding: '2px 7px', borderRadius: 100,
                background: 'var(--bg-2)',
                fontSize: 9, fontWeight: 600, color: 'var(--ink-2)',
                letterSpacing: '0.06em', textTransform: 'uppercase',
                marginLeft: 4,
              }}>
                <Ico.Lock s={8} c="var(--ink-3)"/> View only
              </span>
            )}
          </div>
          <div className="display" style={{
            fontSize: 22, fontWeight: 700, letterSpacing: '-0.03em',
            color: 'var(--ink-0)', lineHeight: 1.1,
          }}>{name}</div>
          {(stateId || lastUpdate) && (
            <div style={{
              display: 'flex', alignItems: 'center', gap: 8, marginTop: 6,
              color: 'var(--ink-2)', fontSize: 12,
            }}>
              {stateId && STATE_BY_ID[stateId] && (
                <span style={{
                  display: 'inline-flex', alignItems: 'center', gap: 5,
                  color: 'var(--ink-1)', fontWeight: 500,
                }}>
                  <span style={{ fontSize: 11, color: color }}>{STATE_BY_ID[stateId].glyph}</span>
                  {STATE_BY_ID[stateId].label}
                </span>
              )}
              {stateId && lastUpdate && <span style={{ opacity: 0.35 }}>·</span>}
              {lastUpdate && <span>{lastUpdate}</span>}
            </div>
          )}
        </div>

        {/* Right — small ring + count */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, flexShrink: 0 }}>
          <div style={{ textAlign: 'right' }}>
            <div className="display tnum" style={{
              fontSize: 22, fontWeight: 700, lineHeight: 1,
              color: 'var(--ink-1)', letterSpacing: '-0.025em',
            }}>
              <AnimatedNumber value={done}/>
              <span style={{ color: 'var(--ink-3)', fontWeight: 500 }}>/{max}</span>
            </div>
            <div className="tracked" style={{ color: 'var(--ink-3)', fontSize: 8.5, marginTop: 3 }}>
              complete
            </div>
          </div>
          <div style={{ position: 'relative', width: 38, height: 38 }}>
            <Ring size={38} stroke={3} value={done} max={max} color={color} track="var(--bg-3)"/>
          </div>
        </div>
      </div>

      {/* thin progress rail */}
      <div style={{ marginTop: 14, height: 2, background: 'var(--bg-2)', borderRadius: 2, overflow: 'hidden' }}>
        <div style={{
          height: '100%', width: `${pct * 100}%`,
          background: color, opacity: 0.6,
          borderRadius: 2,
          transition: 'width 800ms cubic-bezier(0.2, 0.8, 0.2, 1)',
        }}/>
      </div>
    </div>
  );
}

/* ---------- Task row — softer, dotted rhythm, category color dot ---------- */
const TaskRow = React.memo(function TaskRow({
  task, index, onChangeText, onChangeLabel, onToggle, color, interactive
}) {
  const [editingLabel, setEditingLabel] = useStateT(false);
  const [striking, setStriking] = useStateT(false);
  const labelRef = useRefT(null);

  useEffectT(() => {
    if (editingLabel && labelRef.current) {
      labelRef.current.focus(); labelRef.current.select();
    }
  }, [editingLabel]);

  const isEmpty = !task.text.trim();

  const handleToggle = () => {
    if (!interactive || isEmpty) return;
    haptic(task.done ? 'light' : 'success');
    if (!task.done) {
      setStriking(true);
      setTimeout(() => setStriking(false), 600);
    }
    onToggle(task.id);
  };

  return (
    <div
      className={striking ? 'row-strike' : ''}
      style={{
        display: 'flex', gap: 14,
        padding: '18px 4px',
        opacity: task.done ? 0.5 : 1,
        transition: 'opacity 360ms ease',
        alignItems: 'center',
        position: 'relative',
      }}>
      <div style={{ width: 24, display: 'flex', justifyContent: 'center', flexShrink: 0 }}>
        <Check
          checked={task.done}
          onClick={handleToggle}
          color={color}
          interactive={interactive && !isEmpty}
          size={24}
        />
      </div>

      <div style={{ flex: 1, minWidth: 0, display: 'flex', flexDirection: 'column', gap: 1 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          <span style={{
            width: 5, height: 5, borderRadius: 5,
            background: color, opacity: task.done ? 0.4 : 0.85,
            transition: 'opacity 320ms ease',
          }}/>
          {interactive && editingLabel ? (
            <input
              ref={labelRef}
              value={task.label}
              onChange={e => onChangeLabel(task.id, e.target.value.toUpperCase().slice(0, 14))}
              onBlur={() => setEditingLabel(false)}
              onKeyDown={e => { if (e.key === 'Enter' || e.key === 'Escape') setEditingLabel(false); }}
              style={{
                width: '100%', background: 'transparent', border: 'none', outline: 'none',
                fontSize: 9.5, fontWeight: 700, letterSpacing: '0.16em',
                color: 'var(--ink-1)', textTransform: 'uppercase',
                padding: 0,
              }}
            />
          ) : (
            <button
              onClick={() => interactive && setEditingLabel(true)}
              style={{
                fontSize: 9.5, fontWeight: 700, letterSpacing: '0.16em',
                color: 'var(--ink-2)', textTransform: 'uppercase',
                cursor: interactive ? 'pointer' : 'default',
                padding: 0, transition: 'color 200ms ease',
              }}
            >{task.label}</button>
          )}
        </div>
        {interactive ? (
          <input
            value={task.text}
            onChange={e => onChangeText(task.id, e.target.value)}
            placeholder="Define today's focus…"
            style={{
              width: '100%', background: 'transparent', border: 'none', outline: 'none',
              fontSize: 17, fontWeight: 500, letterSpacing: '-0.014em',
              color: task.done ? 'var(--ink-2)' : 'var(--ink-0)',
              textDecoration: task.done ? 'line-through' : 'none',
              textDecorationColor: 'var(--ink-3)',
              padding: 0, marginTop: 3,
              fontFamily: 'inherit',
              transition: 'color 320ms ease',
              lineHeight: 1.3,
            }}
          />
        ) : (
          <div style={{
            fontSize: 17, fontWeight: 500, letterSpacing: '-0.014em',
            color: isEmpty ? 'var(--ink-4)' : task.done ? 'var(--ink-2)' : 'var(--ink-0)',
            fontStyle: isEmpty ? 'italic' : 'normal',
            textDecoration: task.done ? 'line-through' : 'none',
            textDecorationColor: 'var(--ink-3)',
            marginTop: 3, minHeight: 22,
            transition: 'color 320ms ease',
            lineHeight: 1.3,
          }}>{task.text || '—'}</div>
        )}
      </div>
    </div>
  );
});

/* ---------- Task list block ---------- */
function TaskList({ tasks, onChangeText, onChangeLabel, onToggle, color, interactive }) {
  return (
    <div style={{
      background: 'var(--card)',
      border: '1px solid var(--hairline)',
      borderRadius: 20,
      boxShadow: 'var(--shadow-card)',
      padding: '6px 16px',
    }}>
      {tasks.map((t, i) => (
        <div key={t.id}>
          {i > 0 && (
            <div style={{
              height: 1,
              background: 'transparent',
              borderTop: '1px dashed var(--hairline)',
              marginLeft: 36,
            }}/>
          )}
          <TaskRow task={t} index={i}
            onChangeText={onChangeText} onChangeLabel={onChangeLabel}
            onToggle={onToggle} color={color} interactive={interactive}/>
        </div>
      ))}
    </div>
  );
}

/* ---------- Day navigation chevron button ---------- */
function NavArrow({ dir, onClick, disabled }) {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      style={{
        width: 32, height: 32, borderRadius: 32,
        background: disabled ? 'transparent' : 'var(--card)',
        border: `1px solid ${disabled ? 'transparent' : 'var(--hairline)'}`,
        boxShadow: disabled ? 'none' : 'var(--shadow-card)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        color: disabled ? 'var(--ink-4)' : 'var(--ink-1)',
        cursor: disabled ? 'default' : 'pointer',
        transition: 'all 200ms ease',
        flexShrink: 0,
      }}
    >
      <Ico.Chev s={14} c="currentColor" dir={dir}/>
    </button>
  );
}

/* ---------- Today screen ---------- */
function TodayScreen({
  view, onSetView,
  youTasks, palTasks,
  onChangeYouText, onChangeYouLabel, onToggleYou,
  youState, palState, onSetState,
  dayOffset, onDayChange,
  pastData,
}) {
  const isToday = dayOffset === 0;
  const isPast = dayOffset < 0;

  // Compute the date to display
  const displayDate = new Date();
  displayDate.setDate(displayDate.getDate() + dayOffset);
  const dateStr = displayDate.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' });
  const insight = getDailyInsight(displayDate);

  const isYou = view === 'you';

  // For past days: use pastData if available, otherwise fall back to today's data
  const activeTasks = isPast && pastData
    ? (isYou ? pastData.youTasks : pastData.palTasks)
    : (isYou ? youTasks : palTasks);

  const activeYouDone = isPast && pastData
    ? pastData.youTasks.filter(t => t.done).length
    : youTasks.filter(t => t.done).length;

  const activePalDone = isPast && pastData
    ? pastData.palTasks.filter(t => t.done).length
    : palTasks.filter(t => t.done).length;

  const activeDone = isYou ? activeYouDone : activePalDone;

  const activeYouState = isPast && pastData ? pastData.youState : youState;
  const activePalState = isPast && pastData ? pastData.palState : palState;
  const activeState = isYou ? activeYouState : activePalState;

  // Past days are always read-only
  const interactive = isToday && isYou;

  // Can only go forward to today (dayOffset 0 max), can go back up to 7 days
  const canGoBack = dayOffset > -7;
  const canGoForward = dayOffset < 0;

  return (
    <div className="no-scrollbar" style={{
      height: '100%', overflow: 'auto',
      padding: '60px 18px 130px',
    }}>
      {/* Title + day navigation */}
      <div style={{ marginBottom: 18 }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 8 }}>
          <div className="display" style={{
            fontSize: 30, fontWeight: 700, letterSpacing: '-0.035em',
            lineHeight: 1, color: 'var(--ink-0)', flex: 1,
          }}>
            {isToday ? 'Today' : displayDate.toLocaleDateString('en-US', { weekday: 'long' })}
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            <NavArrow dir="left" onClick={() => { haptic('light'); onDayChange(dayOffset - 1); }} disabled={!canGoBack}/>
            <NavArrow dir="right" onClick={() => { haptic('light'); onDayChange(dayOffset + 1); }} disabled={!canGoForward}/>
          </div>
        </div>
        <div style={{ fontSize: 12.5, color: 'var(--ink-2)', marginTop: 5, display: 'flex', alignItems: 'center', gap: 6 }}>
          <span>{dateStr}</span>
          {isToday && (
            <><span style={{ opacity: 0.4 }}>·</span><span>clean slate</span></>
          )}
          {isPast && (
            <><span style={{ opacity: 0.4 }}>·</span>
            <span style={{
              display: 'inline-flex', alignItems: 'center', gap: 4,
              padding: '1px 7px', borderRadius: 100,
              background: 'var(--bg-2)',
              fontSize: 10.5, fontWeight: 600, color: 'var(--ink-2)',
              letterSpacing: '0.04em',
            }}>
              <Ico.Lock s={8} c="var(--ink-3)"/> Past day
            </span></>
          )}
        </div>
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
        {/* Toggle */}
        <UserToggle value={view} onChange={onSetView}/>

        {/* Identity card */}
        <div key={`${view}-${dayOffset}`}>
          {isYou ? (
            <IdentityCard
              name="Alex" role="YOU"
              color="var(--you)" glow="var(--you-glow)"
              done={activeYouDone} max={5}
              stateId={activeYouState}
              interactive={interactive}
            />
          ) : (
            <IdentityCard
              name="Maya" role="PARTNER"
              color="var(--pal)" glow="var(--pal-glow)"
              done={activePalDone} max={5}
              stateId={activePalState}
              lastUpdate={isToday ? "updated 4m ago" : undefined}
              interactive={false}
            />
          )}
        </div>

        {/* Mood selector */}
        <StateSelector
          value={activeState}
          onChange={isToday && isYou ? onSetState : () => {}}
          readOnly={!isToday || !isYou}
          label={isYou ? (isToday ? "HOW ARE YOU TODAY?" : "HOW YOU FELT") : (isToday ? "MAYA IS FEELING…" : "MAYA FELT")}
        />

        {/* Tasks */}
        <div key={`tasks-${view}-${dayOffset}`} className="fade-up">
          <TaskList
            tasks={activeTasks}
            onChangeText={interactive ? onChangeYouText : () => {}}
            onChangeLabel={interactive ? onChangeYouLabel : () => {}}
            onToggle={interactive ? onToggleYou : () => {}}
            color={isYou ? 'var(--you)' : 'var(--pal)'}
            interactive={interactive}
          />
        </div>

        {/* Daily Signal */}
        <DailyInsightCard text={insight}/>

        {isToday && isYou && youTasks.every(t => !t.text.trim()) && (
          <div className="fade-up" style={{
            textAlign: 'center', padding: '4px 16px',
            color: 'var(--ink-3)', fontSize: 12,
            letterSpacing: '-0.005em', fontStyle: 'italic',
          }}>
            A new day. Five slots. Tap a category to rename it.
          </div>
        )}
      </div>
    </div>
  );
}

Object.assign(window, { TodayScreen, TaskRow, TaskList, IdentityCard, UserToggle, DailyInsightCard, StateSelector, NavArrow });
