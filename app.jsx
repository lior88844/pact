// Pact — App shell: clean-slate model + You/Partner toggle + day navigation
const { useState: useStateA } = React;

const TAB_TODAY = 'today';
const TAB_HISTORY = 'history';
const TAB_SETTINGS = 'settings';

const DEFAULT_LABELS = ['MAIN TASK', 'WORK', 'WORK', 'BODY', 'MIND'];

function makeFreshDay() {
  return DEFAULT_LABELS.map((label, i) => ({
    id: `t${i}`, label, text: '', done: false,
  }));
}

// Partner has tasks already set today (for demo)
const PARTNER_TASKS = [
  { id: 'p0', label: 'MAIN TASK', text: 'Ship the Q2 plan', done: true },
  { id: 'p1', label: 'WORK', text: 'Review Eng candidates', done: true },
  { id: 'p2', label: 'STRATEGY', text: 'Outline next OKRs', done: false },
  { id: 'p3', label: 'BODY', text: 'Run · 6 km', done: true },
  { id: 'p4', label: 'MIND', text: 'Meditate · 15 min', done: false },
];

function TabBar({ tab, onChange }) {
  const tabs = [
    { id: TAB_TODAY, label: 'Today', Icon: Ico.Today },
    { id: TAB_HISTORY, label: 'History', Icon: Ico.History },
    { id: TAB_SETTINGS, label: 'Settings', Icon: Ico.Settings },
  ];
  return (
    <div style={{
      position: 'absolute', bottom: 22, left: '50%', transform: 'translateX(-50%)',
      zIndex: 30,
      display: 'flex', gap: 2, alignItems: 'center',
      padding: 5, borderRadius: 100,
      background: 'rgba(255,255,255,0.86)',
      border: '1px solid var(--hairline)',
      backdropFilter: 'blur(24px) saturate(160%)',
      WebkitBackdropFilter: 'blur(24px) saturate(160%)',
      boxShadow: '0 12px 32px -8px rgba(20,18,12,0.18), 0 1px 2px rgba(20,18,12,0.04)',
    }}>
      {tabs.map(t => {
        const active = tab === t.id;
        return (
          <button key={t.id} onClick={() => { haptic('light'); onChange(t.id); }} style={{
            display: 'flex', alignItems: 'center', gap: 7,
            padding: '9px 16px', borderRadius: 100,
            background: active ? 'var(--ink-0)' : 'transparent',
            color: active ? '#fff' : 'var(--ink-2)',
            fontSize: 13, fontWeight: 600,
            transition: 'background 220ms ease, color 220ms ease',
          }}>
            <t.Icon s={16} c="currentColor"/>
            {t.label}
          </button>
        );
      })}
    </div>
  );
}

function PactApp() {
  const [tab, setTab] = useStateA(TAB_TODAY);
  const [view, setView] = useStateA('you');
  const [youTasks, setYouTasks] = useStateA(makeFreshDay);
  const [palTasks] = useStateA(PARTNER_TASKS);
  const [youState, setYouState] = useStateA(null);
  const [palState] = useStateA('driven');
  const [dayOffset, setDayOffset] = useStateA(0);

  const updateYouText = (id, text) => setYouTasks(ts => ts.map(t => t.id === id ? { ...t, text } : t));
  const updateYouLabel = (id, label) => setYouTasks(ts => ts.map(t => t.id === id ? { ...t, label } : t));
  const toggleYou = (id) => setYouTasks(ts => ts.map(t => t.id === id ? { ...t, done: !t.done } : t));

  const handleDayChange = (offset) => {
    // Clamp: max 7 days back, no future days
    const clamped = Math.max(-7, Math.min(0, offset));
    setDayOffset(clamped);
  };

  const pastData = dayOffset < 0 ? getPastDayData(dayOffset) : null;

  return (
    <div style={{ position: 'absolute', inset: 0 }}>
      <div className="pact-stage"/>
      <div style={{ position: 'absolute', inset: 0, zIndex: 1, display: tab === TAB_TODAY ? 'block' : 'none' }}>
        <TodayScreen
          view={view} onSetView={setView}
          youTasks={youTasks} palTasks={palTasks}
          onChangeYouText={updateYouText}
          onChangeYouLabel={updateYouLabel}
          onToggleYou={toggleYou}
          youState={youState} palState={palState}
          onSetState={setYouState}
          dayOffset={dayOffset}
          onDayChange={handleDayChange}
          pastData={pastData}
        />
      </div>
      <div style={{ position: 'absolute', inset: 0, zIndex: 1, display: tab === TAB_HISTORY ? 'block' : 'none' }}>
        <HistoryScreen/>
      </div>
      <div style={{ position: 'absolute', inset: 0, zIndex: 1, display: tab === TAB_SETTINGS ? 'block' : 'none' }}>
        <SettingsScreen/>
      </div>
      <TabBar tab={tab} onChange={setTab}/>
    </div>
  );
}

Object.assign(window, { PactApp, TabBar });
