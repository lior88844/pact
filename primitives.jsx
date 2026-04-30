// Pact — shared primitives & icons (light-first)
const { useState, useEffect, useRef, useMemo, useCallback, Fragment } = React;

const haptic = (kind = 'light') => {
  if (navigator.vibrate) {
    if (kind === 'light') navigator.vibrate(8);
    else if (kind === 'success') navigator.vibrate([10, 30, 18]);
    else navigator.vibrate(12);
  }
};

const Ico = {
  Plus: ({ s = 18, c = 'currentColor' }) => (<svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2" strokeLinecap="round"><path d="M12 5v14M5 12h14"/></svg>),
  X: ({ s = 16, c = 'currentColor' }) => (<svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2" strokeLinecap="round"><path d="M6 6l12 12M18 6l-6 6-6 6"/></svg>),
  Today: ({ s = 22, c = 'currentColor', fill = false }) => (<svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="9" fill={fill ? c : 'none'} opacity={fill ? 0.12 : 1}/><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg>),
  History: ({ s = 22, c = 'currentColor', fill = false }) => (<svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round"><rect x="3.5" y="4" width="17" height="17" rx="3" fill={fill ? c : 'none'} opacity={fill ? 0.12 : 1}/><rect x="3.5" y="4" width="17" height="17" rx="3"/><path d="M3.5 9h17M8 2.5v3M16 2.5v3"/></svg>),
  Settings: ({ s = 22, c = 'currentColor', fill = false }) => (<svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="2.6" fill={fill ? c : 'none'} opacity={fill ? 0.12 : 1}/><circle cx="12" cy="12" r="2.6"/><path d="M12 2v3M12 19v3M22 12h-3M5 12H2M18.4 5.6l-2.1 2.1M7.7 16.3l-2.1 2.1M18.4 18.4l-2.1-2.1M7.7 7.7L5.6 5.6"/></svg>),
  Chev: ({ s = 18, c = 'currentColor', dir = 'right' }) => { const r = dir === 'right' ? 0 : dir === 'left' ? 180 : dir === 'down' ? 90 : -90; return <svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ transform: `rotate(${r}deg)` }}><path d="M9 6l6 6-6 6"/></svg>; },
  Flame: ({ s = 18, c = 'currentColor' }) => (<svg width={s} height={s} viewBox="0 0 24 24" fill={c}><path d="M12 2c0 4-5 5-5 10a5 5 0 0010 0c0-2-1-3-1-5 0 1-1 2-2 2 0-3 2-4 2-7-1 0-2 0-4 0z"/></svg>),
  Bolt: ({ s = 16, c = 'currentColor' }) => (<svg width={s} height={s} viewBox="0 0 24 24" fill={c}><path d="M13 2L4 14h6l-1 8 9-12h-6l1-8z"/></svg>),
  Quote: ({ s = 22, c = 'currentColor' }) => (<svg width={s} height={s} viewBox="0 0 24 24" fill={c}><path d="M9 7C5.5 7 4 10 4 13v4h6v-6H7c0-2 1-3 2-3V7zm10 0c-3.5 0-5 3-5 6v4h6v-6h-3c0-2 1-3 2-3V7z" opacity="0.85"/></svg>),
  Bell: ({ s = 18, c = 'currentColor' }) => (<svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round"><path d="M6 8a6 6 0 0112 0c0 7 3 7 3 9H3c0-2 3-2 3-9z"/><path d="M10 21a2 2 0 004 0"/></svg>),
  Lock: ({ s = 18, c = 'currentColor' }) => (<svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round"><rect x="4" y="11" width="16" height="10" rx="2"/><path d="M8 11V7a4 4 0 018 0v4"/></svg>),
  User: ({ s = 18, c = 'currentColor' }) => (<svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="9" r="3.5"/><path d="M5.5 20c1.4-3.4 4-5 6.5-5s5.1 1.6 6.5 5"/></svg>),
  Heart: ({ s = 18, c = 'currentColor' }) => (<svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round"><path d="M12 21s-7-4.5-9-9a5 5 0 019-3 5 5 0 019 3c-2 4.5-9 9-9 9z"/></svg>),
};

function AnimatedNumber({ value, duration = 700, format = (n) => Math.round(n) }) {
  const [n, setN] = useState(value);
  const startRef = useRef(value);
  const tStartRef = useRef(0);
  const rafRef = useRef(0);
  useEffect(() => {
    cancelAnimationFrame(rafRef.current);
    startRef.current = n;
    tStartRef.current = performance.now();
    const target = value;
    const tick = (t) => {
      const p = Math.min(1, (t - tStartRef.current) / duration);
      const eased = 1 - Math.pow(1 - p, 3);
      const v = startRef.current + (target - startRef.current) * eased;
      setN(v);
      if (p < 1) rafRef.current = requestAnimationFrame(tick);
    };
    rafRef.current = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(rafRef.current);
  }, [value]);
  return <>{format(n)}</>;
}

function Ring({ size = 96, stroke = 7, value = 0, max = 1, color = 'var(--you)', track = 'var(--bg-3)' }) {
  const r = (size - stroke) / 2;
  const c = 2 * Math.PI * r;
  const pct = Math.max(0, Math.min(1, value / max));
  const targetOffset = c * (1 - pct);
  const [offset, setOffset] = useState(c);
  useEffect(() => { requestAnimationFrame(() => setOffset(targetOffset)); }, [targetOffset]);
  const id = `g-${color.replace(/[^a-z]/gi,'')}-${size}`;
  return (
    <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`} style={{ transform: 'rotate(-90deg)' }}>
      <defs>
        <linearGradient id={id} x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stopColor={color} stopOpacity="0.95"/>
          <stop offset="100%" stopColor={color} stopOpacity="0.7"/>
        </linearGradient>
      </defs>
      <circle cx={size/2} cy={size/2} r={r} fill="none" stroke={track} strokeWidth={stroke}/>
      <circle cx={size/2} cy={size/2} r={r} fill="none"
        stroke={`url(#${id})`}
        strokeWidth={stroke} strokeLinecap="round"
        strokeDasharray={c} strokeDashoffset={offset}
        style={{ transition: 'stroke-dashoffset 1000ms cubic-bezier(0.2, 0.8, 0.2, 1)' }}
      />
    </svg>
  );
}

function Bar({ value = 0, max = 1, color = 'var(--you)', track = 'var(--bg-3)', height = 6 }) {
  const pct = Math.max(0, Math.min(1, value / max));
  return (
    <div style={{ height, borderRadius: height, background: track, overflow: 'hidden' }}>
      <div style={{
        height: '100%', width: `${pct * 100}%`,
        background: `linear-gradient(90deg, ${color === 'var(--you)' ? 'var(--you-dim)' : 'var(--pal-dim)'}, ${color})`,
        borderRadius: height,
        transition: 'width 900ms cubic-bezier(0.2, 0.8, 0.2, 1)',
      }}/>
    </div>
  );
}

function Check({ checked, onClick, color = 'var(--you)', size = 24, interactive = true }) {
  return (
    <button
      onClick={interactive ? onClick : undefined}
      style={{
        width: size, height: size, borderRadius: size,
        background: checked ? color : 'transparent',
        border: checked ? `1.5px solid ${color}` : `1.5px solid var(--ink-4)`,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        transition: 'background 240ms ease, border-color 240ms ease, transform 200ms ease',
        transform: checked ? 'scale(1.04)' : 'scale(1)',
        flexShrink: 0,
        cursor: interactive ? 'pointer' : 'default',
      }}
    >
      {checked && (
        <svg width={size * 0.55} height={size * 0.55} viewBox="0 0 16 16" fill="none">
          <path d="M3 8.5l3.5 3.5L13 5" stroke="#fff" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round" className="check-stroke"/>
        </svg>
      )}
    </button>
  );
}

function Card({ children, style, ...rest }) {
  return (
    <div {...rest} style={{
      background: 'var(--card)',
      border: '1px solid var(--hairline)',
      borderRadius: 20,
      boxShadow: 'var(--shadow-card)',
      ...style,
    }}>{children}</div>
  );
}

Object.assign(window, { Ico, AnimatedNumber, Ring, Bar, Check, Card, haptic });
