// Pact — daily insights + mood states data

const INSIGHTS = [
  "Relationships are one of the strongest predictors of long-term happiness.",
  "A 25-minute walk can change the trajectory of your day.",
  "Consistency beats intensity when repeated long enough.",
  "Sleep is a performance multiplier, not a luxury.",
  "What you do daily compounds. What you do occasionally doesn't.",
  "The body keeps the score. Move it, fuel it, rest it.",
  "Discomfort is the price of admission to a meaningful life.",
  "You don't rise to the level of your goals; you fall to the level of your systems.",
  "Showing up on bad days is what separates the disciplined from the rest.",
  "The most underrated productivity tool is going to bed at the same time.",
  "Identity precedes outcome. Decide who you are, then act accordingly.",
  "Boredom is the doorway. Most people walk away from it.",
  "Your mornings set the tone. Protect the first 90 minutes.",
  "Hard things become easier. Easy things become habits.",
  "Compare yourself to who you were yesterday — not to who someone else is today.",
  "Energy is a renewable resource if you treat it like one.",
  "Discipline is choosing between what you want now and what you want most.",
  "The work you avoid is usually the work you most need to do.",
  "Small wins, repeated, become identity.",
  "Strong relationships need standards, not just affection.",
];

// pick deterministically by date — both partners see the same one
function getDailyInsight(date = new Date()) {
  const epoch = Math.floor(date.getTime() / (1000 * 60 * 60 * 24));
  return INSIGHTS[epoch % INSIGHTS.length];
}

const STATES = [
  { id: 'focused', label: 'Focused', glyph: '◆' },
  { id: 'driven', label: 'Driven', glyph: '▲' },
  { id: 'calm', label: 'Calm', glyph: '◯' },
  { id: 'low_energy', label: 'Low energy', glyph: '◌' },
  { id: 'strategic', label: 'Strategic', glyph: '◐' },
  { id: 'struggling', label: 'Struggling', glyph: '◇' },
];

const STATE_BY_ID = Object.fromEntries(STATES.map(s => [s.id, s]));

// Past day snapshots (keyed by negative offset: -1 = yesterday, -2 = 2 days ago, etc.)
const PAST_DAY_DATA = {
  '-1': {
    youState: 'focused',
    palState: 'driven',
    youTasks: [
      { id: 'y0', label: 'MAIN TASK', text: 'Finish Q2 strategy doc', done: true },
      { id: 'y1', label: 'WORK', text: 'Review team PRs', done: true },
      { id: 'y2', label: 'WORK', text: 'Client call with Lena', done: true },
      { id: 'y3', label: 'BODY', text: 'Gym · upper body', done: true },
      { id: 'y4', label: 'MIND', text: 'Read · 30 pages', done: false },
    ],
    palTasks: [
      { id: 'p0', label: 'MAIN TASK', text: 'Ship the Q2 plan', done: true },
      { id: 'p1', label: 'WORK', text: 'Review Eng candidates', done: true },
      { id: 'p2', label: 'STRATEGY', text: 'Outline next OKRs', done: true },
      { id: 'p3', label: 'BODY', text: 'Run · 6 km', done: true },
      { id: 'p4', label: 'MIND', text: 'Meditate · 15 min', done: false },
    ],
  },
  '-2': {
    youState: 'strategic',
    palState: 'calm',
    youTasks: [
      { id: 'y0', label: 'MAIN TASK', text: 'Competitor analysis', done: true },
      { id: 'y1', label: 'WORK', text: '1:1 with Sasha', done: true },
      { id: 'y2', label: 'WORK', text: 'Write weekly report', done: false },
      { id: 'y3', label: 'BODY', text: 'Morning run · 5 km', done: true },
      { id: 'y4', label: 'MIND', text: 'Journal · 10 min', done: true },
    ],
    palTasks: [
      { id: 'p0', label: 'MAIN TASK', text: 'Design sprint kick-off', done: true },
      { id: 'p1', label: 'WORK', text: 'Prototype review', done: true },
      { id: 'p2', label: 'STRATEGY', text: 'Roadmap revision', done: false },
      { id: 'p3', label: 'BODY', text: 'Yoga · 45 min', done: true },
      { id: 'p4', label: 'MIND', text: 'Read · 20 pages', done: true },
    ],
  },
  '-3': {
    youState: 'driven',
    palState: 'focused',
    youTasks: [
      { id: 'y0', label: 'MAIN TASK', text: 'Board deck v2', done: true },
      { id: 'y1', label: 'WORK', text: 'Hiring interviews x2', done: true },
      { id: 'y2', label: 'WORK', text: 'Async standup catchup', done: true },
      { id: 'y3', label: 'BODY', text: 'Walk · 40 min', done: true },
      { id: 'y4', label: 'MIND', text: 'Podcast · deep work', done: true },
    ],
    palTasks: [
      { id: 'p0', label: 'MAIN TASK', text: 'User research synthesis', done: true },
      { id: 'p1', label: 'WORK', text: 'Stakeholder update', done: true },
      { id: 'p2', label: 'STRATEGY', text: 'Feature prioritisation', done: true },
      { id: 'p3', label: 'BODY', text: 'Swim · 30 min', done: false },
      { id: 'p4', label: 'MIND', text: 'Meditation · 20 min', done: true },
    ],
  },
  '-4': {
    youState: 'low_energy',
    palState: 'struggling',
    youTasks: [
      { id: 'y0', label: 'MAIN TASK', text: 'Refine pitch narrative', done: false },
      { id: 'y1', label: 'WORK', text: 'Email triage', done: true },
      { id: 'y2', label: 'WORK', text: 'Team check-in', done: true },
      { id: 'y3', label: 'BODY', text: 'Stretch · 15 min', done: true },
      { id: 'y4', label: 'MIND', text: 'Rest — no screens', done: false },
    ],
    palTasks: [
      { id: 'p0', label: 'MAIN TASK', text: 'Fix prod regression', done: true },
      { id: 'p1', label: 'WORK', text: 'Incident debrief', done: true },
      { id: 'p2', label: 'STRATEGY', text: 'Process retrospective', done: false },
      { id: 'p3', label: 'BODY', text: 'Walk · 20 min', done: false },
      { id: 'p4', label: 'MIND', text: 'Read fiction', done: true },
    ],
  },
  '-5': {
    youState: 'calm',
    palState: 'driven',
    youTasks: [
      { id: 'y0', label: 'MAIN TASK', text: 'Weekly planning session', done: true },
      { id: 'y1', label: 'WORK', text: 'Backlog grooming', done: true },
      { id: 'y2', label: 'WORK', text: 'Partner sync', done: true },
      { id: 'y3', label: 'BODY', text: 'Gym · legs', done: true },
      { id: 'y4', label: 'MIND', text: 'Journaling · 15 min', done: true },
    ],
    palTasks: [
      { id: 'p0', label: 'MAIN TASK', text: 'Kick off new sprint', done: true },
      { id: 'p1', label: 'WORK', text: 'Pair programming session', done: true },
      { id: 'p2', label: 'STRATEGY', text: 'Set personal OKRs', done: true },
      { id: 'p3', label: 'BODY', text: 'Run · 8 km', done: true },
      { id: 'p4', label: 'MIND', text: 'Meditate · 20 min', done: true },
    ],
  },
  '-6': {
    youState: 'focused',
    palState: 'calm',
    youTasks: [
      { id: 'y0', label: 'MAIN TASK', text: 'Deep work block · 3h', done: true },
      { id: 'y1', label: 'WORK', text: 'Design feedback round', done: true },
      { id: 'y2', label: 'WORK', text: 'Async reviews', done: true },
      { id: 'y3', label: 'BODY', text: 'Bike ride · 45 min', done: false },
      { id: 'y4', label: 'MIND', text: 'Read · 40 pages', done: true },
    ],
    palTasks: [
      { id: 'p0', label: 'MAIN TASK', text: 'Content calendar setup', done: true },
      { id: 'p1', label: 'WORK', text: 'Analytics review', done: true },
      { id: 'p2', label: 'STRATEGY', text: 'Growth experiment plan', done: false },
      { id: 'p3', label: 'BODY', text: 'Hot yoga · 60 min', done: true },
      { id: 'p4', label: 'MIND', text: 'Gratitude journal', done: true },
    ],
  },
  '-7': {
    youState: 'strategic',
    palState: 'strategic',
    youTasks: [
      { id: 'y0', label: 'MAIN TASK', text: 'Monthly review', done: true },
      { id: 'y1', label: 'WORK', text: 'Roadmap Q3 draft', done: true },
      { id: 'y2', label: 'WORK', text: 'Team offsíte prep', done: false },
      { id: 'y3', label: 'BODY', text: 'Long walk · 1h', done: true },
      { id: 'y4', label: 'MIND', text: 'Planning reflection', done: true },
    ],
    palTasks: [
      { id: 'p0', label: 'MAIN TASK', text: 'Q2 retrospective', done: true },
      { id: 'p1', label: 'WORK', text: 'Budget review', done: true },
      { id: 'p2', label: 'STRATEGY', text: 'Team goals alignment', done: true },
      { id: 'p3', label: 'BODY', text: 'Rest day', done: true },
      { id: 'p4', label: 'MIND', text: 'Strategic reading', done: true },
    ],
  },
};

function getPastDayData(offset) {
  const key = String(offset);
  return PAST_DAY_DATA[key] || null;
}

Object.assign(window, { INSIGHTS, getDailyInsight, STATES, STATE_BY_ID, PAST_DAY_DATA, getPastDayData });
