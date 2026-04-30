// Pact — History (light)
function HistoryScreen() {
  const days = [
    { label: 'Mon', date: '21', you: 5, total: 5, pal: 4, palTotal: 5 },
    { label: 'Tue', date: '22', you: 4, total: 5, pal: 5, palTotal: 5 },
    { label: 'Wed', date: '23', you: 5, total: 5, pal: 5, palTotal: 5 },
    { label: 'Thu', date: '24', you: 3, total: 4, pal: 4, palTotal: 4 },
    { label: 'Fri', date: '25', you: 5, total: 5, pal: 3, palTotal: 5 },
    { label: 'Sat', date: '26', you: 2, total: 4, pal: 4, palTotal: 4 },
    { label: 'Sun', date: '27', you: 4, total: 5, pal: 5, palTotal: 5 },
  ];
  const youAvg = days.reduce((a, d) => a + d.you / d.total, 0) / days.length;
  const palAvg = days.reduce((a, d) => a + d.pal / d.palTotal, 0) / days.length;
  const sealedDays = days.filter(d => d.you === d.total && d.pal === d.palTotal).length;

  return (
    <div className="no-scrollbar" style={{ height: '100%', overflow: 'auto', padding: '60px 18px 130px' }}>
      <div className="display" style={{ fontSize: 34, fontWeight: 700, letterSpacing: '-0.035em', lineHeight: 1, color: 'var(--ink-0)' }}>
        History
      </div>
      <div style={{ fontSize: 13, color: 'var(--ink-2)', marginTop: 6 }}>Apr 21 — Apr 27 · the last seven days</div>

      <Card style={{ padding: 22, marginTop: 22, position: 'relative', overflow: 'hidden' }}>
        <div style={{
          position: 'absolute', top: -60, right: -60, width: 220, height: 220,
          background: 'radial-gradient(closest-side, var(--you-soft), transparent)',
          pointerEvents: 'none',
        }}/>
        <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between' }}>
          <div>
            <div className="tracked" style={{ color: 'var(--you)' }}>Joint streak</div>
            <div className="display tnum" style={{ fontSize: 56, fontWeight: 800, letterSpacing: '-0.04em', lineHeight: 1, marginTop: 8, color: 'var(--ink-0)' }}>
              <AnimatedNumber value={23} duration={1100}/>
            </div>
            <div style={{ fontSize: 13, color: 'var(--ink-2)', marginTop: 4 }}>days both above 50%</div>
          </div>
          <div style={{
            width: 52, height: 52, borderRadius: 52,
            background: 'var(--you-soft)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <Ico.Flame s={24} c="var(--you)"/>
          </div>
        </div>
        <div style={{ marginTop: 22, display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 1, background: 'var(--hairline)', borderRadius: 12, overflow: 'hidden' }}>
          {[
            { label: 'Sealed', val: sealedDays, suffix: '/7', col: 'var(--ink-0)' },
            { label: 'You avg', val: Math.round(youAvg * 100), suffix: '%', col: 'var(--you)' },
            { label: 'Maya avg', val: Math.round(palAvg * 100), suffix: '%', col: 'var(--pal)' },
          ].map((s, i) => (
            <div key={i} style={{ background: 'var(--card)', padding: '14px 4px', textAlign: 'center' }}>
              <div className="display tnum" style={{ fontSize: 22, fontWeight: 700, color: s.col }}>
                {s.val}<span style={{ fontSize: 13, color: 'var(--ink-3)', fontWeight: 500 }}>{s.suffix}</span>
              </div>
              <div className="tracked" style={{ color: 'var(--ink-3)', marginTop: 2, fontSize: 9 }}>{s.label}</div>
            </div>
          ))}
        </div>
      </Card>

      <Card style={{ padding: '20px 18px', marginTop: 14 }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 18 }}>
          <div style={{ fontSize: 14, fontWeight: 600, color: 'var(--ink-0)' }}>This week</div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, fontSize: 11, color: 'var(--ink-2)' }}>
            <span style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
              <span style={{ width: 8, height: 8, borderRadius: 8, background: 'var(--you)' }}/> You
            </span>
            <span style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
              <span style={{ width: 8, height: 8, borderRadius: 8, background: 'var(--pal)' }}/> Maya
            </span>
          </div>
        </div>
        <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', gap: 8 }}>
          {days.map((d, i) => {
            const yp = d.you / d.total;
            const pp = d.pal / d.palTotal;
            const sealed = d.you === d.total && d.pal === d.palTotal;
            const isToday = i === days.length - 1;
            const BAR_MAX = 110;
            return (
              <div key={i} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
                <div style={{ height: BAR_MAX, width: '100%', display: 'flex', alignItems: 'flex-end', justifyContent: 'center', gap: 3 }}>
                  <div style={{
                    width: '42%', height: Math.max(4, yp * BAR_MAX),
                    background: 'linear-gradient(180deg, var(--you-dim), var(--you))',
                    borderRadius: 4,
                    boxShadow: sealed ? '0 2px 8px var(--you-glow)' : 'none',
                    transition: 'height 1100ms cubic-bezier(0.2, 0.8, 0.2, 1)',
                    transitionDelay: `${i * 50}ms`,
                  }}/>
                  <div style={{
                    width: '42%', height: Math.max(4, pp * BAR_MAX),
                    background: 'linear-gradient(180deg, var(--pal-dim), var(--pal))',
                    borderRadius: 4,
                    boxShadow: sealed ? '0 2px 8px var(--pal-glow)' : 'none',
                    transition: 'height 1100ms cubic-bezier(0.2, 0.8, 0.2, 1)',
                    transitionDelay: `${i * 50 + 30}ms`,
                  }}/>
                </div>
                <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 1 }}>
                  <div className="tnum display" style={{ fontSize: 13, fontWeight: 600, color: isToday ? 'var(--ink-0)' : 'var(--ink-1)' }}>
                    {d.date}
                  </div>
                  <div className="tracked" style={{ fontSize: 9, color: isToday ? 'var(--you)' : 'var(--ink-3)' }}>
                    {isToday ? 'TODAY' : d.label.toUpperCase()}
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </Card>

      <div className="tracked" style={{ color: 'var(--ink-3)', marginTop: 28, marginBottom: 12, paddingLeft: 4 }}>
        Last 7 days · completion
      </div>
      <Card style={{ padding: 0, overflow: 'hidden' }}>
        {days.slice().reverse().map((d, i) => {
          const yp = d.you / d.total;
          const pp = d.pal / d.palTotal;
          return (
            <div key={i} style={{
              padding: '14px 18px',
              borderTop: i > 0 ? '1px solid var(--hairline)' : 'none',
              display: 'flex', alignItems: 'center', gap: 16,
            }}>
              <div style={{ width: 44 }}>
                <div className="display tnum" style={{ fontSize: 16, fontWeight: 600, color: 'var(--ink-0)' }}>{d.date}</div>
                <div className="tracked" style={{ fontSize: 9, color: 'var(--ink-3)', marginTop: 2 }}>{d.label.toUpperCase()}</div>
              </div>
              <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 6 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                  <div style={{ flex: 1 }}><Bar value={yp} max={1} color="var(--you)" track="var(--bg-2)" height={5}/></div>
                  <div className="tnum" style={{ fontSize: 11, color: 'var(--ink-2)', width: 36, textAlign: 'right', fontWeight: 600 }}>{Math.round(yp*100)}%</div>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                  <div style={{ flex: 1 }}><Bar value={pp} max={1} color="var(--pal)" track="var(--bg-2)" height={5}/></div>
                  <div className="tnum" style={{ fontSize: 11, color: 'var(--ink-2)', width: 36, textAlign: 'right', fontWeight: 600 }}>{Math.round(pp*100)}%</div>
                </div>
              </div>
            </div>
          );
        })}
      </Card>
    </div>
  );
}

function SettingsScreen() {
  const Section = ({ title, children }) => (
    <div style={{ marginTop: 22 }}>
      <div className="tracked" style={{ color: 'var(--ink-3)', marginBottom: 10, paddingLeft: 4 }}>{title}</div>
      <Card style={{ overflow: 'hidden', padding: 0 }}>{children}</Card>
    </div>
  );
  const Row = ({ icon, label, value, last }) => (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 14,
      padding: '14px 18px',
      borderBottom: last ? 'none' : '1px solid var(--hairline)',
    }}>
      <div style={{
        width: 32, height: 32, borderRadius: 10,
        background: 'var(--bg-2)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        color: 'var(--ink-1)',
      }}>{icon}</div>
      <div style={{ flex: 1, fontSize: 14, fontWeight: 500, color: 'var(--ink-0)' }}>{label}</div>
      {value && <div style={{ fontSize: 13, color: 'var(--ink-2)' }}>{value}</div>}
      <Ico.Chev s={14} c="var(--ink-3)"/>
    </div>
  );

  return (
    <div className="no-scrollbar" style={{ height: '100%', overflow: 'auto', padding: '60px 18px 130px' }}>
      <div className="display" style={{ fontSize: 34, fontWeight: 700, letterSpacing: '-0.035em', lineHeight: 1, color: 'var(--ink-0)' }}>
        Settings
      </div>

      <Card style={{ padding: 18, marginTop: 22, display: 'flex', alignItems: 'center', gap: 14 }}>
        <div style={{
          width: 52, height: 52, borderRadius: 52,
          background: 'linear-gradient(135deg, var(--you-soft), var(--pal-soft))',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontFamily: 'var(--display)', fontWeight: 700, fontSize: 18, color: 'var(--ink-0)',
        }}>A · M</div>
        <div style={{ flex: 1 }}>
          <div className="display" style={{ fontSize: 17, fontWeight: 600, letterSpacing: '-0.02em', color: 'var(--ink-0)' }}>
            Alex & Maya
          </div>
          <div style={{ fontSize: 12, color: 'var(--ink-2)', marginTop: 2 }}>Pact since Apr 5 · 23-day streak</div>
        </div>
      </Card>

      <Section title="Pact">
        <Row icon={<Ico.User s={16}/>} label="Your profile" value="Alex"/>
        <Row icon={<Ico.Heart s={16}/>} label="Partner" value="Maya"/>
        <Row icon={<Ico.Bell s={16}/>} label="Daily reminder" value="7:00 AM"/>
        <Row icon={<Ico.Lock s={16}/>} label="Privacy" last/>
      </Section>

      <Section title="App">
        <Row icon={<Ico.Settings s={16}/>} label="Appearance" value="Light"/>
        <Row icon={<Ico.Quote s={14}/>} label="Daily signals" value="On" last/>
      </Section>

      <div style={{
        textAlign: 'center', marginTop: 32,
        fontSize: 11, color: 'var(--ink-3)', letterSpacing: '0.04em',
      }}>
        Pact · v1.0
      </div>
    </div>
  );
}

Object.assign(window, { HistoryScreen, SettingsScreen });
