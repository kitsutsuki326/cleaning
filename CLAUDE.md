# CLAUDE.md

## Project Overview

Cleaning Schedule Management App (掃除スケジュール管理) — a single-file, client-side React application for tracking household cleaning schedules by room. The UI is entirely in Japanese.

## Architecture

**Single-file SPA**: The entire application lives in `index.html` (417 lines). There is no build system, no bundler, no package manager, and no backend.

- **React 18** loaded via CDN (UMD production build from unpkg)
- **Babel Standalone** for client-side JSX transformation
- **TailwindCSS** loaded via CDN (JIT mode)
- **localStorage** for data persistence (key: `cleaning-rooms`)

## File Structure

```
cleaning/
├── index.html    # Entire application (HTML + JSX + styles)
└── CLAUDE.md     # This file
```

## Code Organization (within index.html)

| Lines     | Section                                    |
|-----------|--------------------------------------------|
| 1-14      | HTML head, CDN script tags, `<div id="root">` |
| 15-98     | SVG icon components (Home, Droplets, Bath, Bed, Utensils, Coffee, Plus, Trash2, Check, AlertCircle) |
| 100-410   | `CleaningScheduleApp` — the single React component containing all state and UI |
| 412-413   | React root creation and render call         |

## Key Data Model

Room objects stored in state and localStorage:

```javascript
{
  id: number,           // Date.now() timestamp as ID
  name: string,         // Room name (Japanese)
  frequency: number,    // Cleaning frequency in days
  icon: string,         // Icon key: 'home' | 'droplets' | 'bath' | 'bed' | 'utensils' | 'coffee'
  lastCleaned: string | null,  // ISO 8601 date string
  history: string[]     // Last 10 cleaning timestamps (ISO strings)
}
```

## Urgency System

Rooms are color-coded by `daysSinceLastCleaned / frequency` ratio:

| Level    | Ratio     | Color  | Japanese Label          |
|----------|-----------|--------|-------------------------|
| never    | N/A       | Gray   | 未掃除                   |
| clean    | < 0.7     | Green  | まだ綺麗                 |
| soon     | 0.7 - 1.0 | Yellow | そろそろ                 |
| urgent   | 1.0 - 1.5 | Orange | 掃除が必要               |
| overdue  | > 1.5     | Red    | 至急！                   |

Rooms are sorted by urgency (most urgent first) in the UI.

## Development Workflow

### Running Locally

Open `index.html` directly in a browser. No server, build step, or installation required. All dependencies load from CDNs, so an internet connection is needed.

### Making Changes

1. Edit `index.html` directly
2. Refresh the browser to see changes
3. Babel compiles JSX client-side — look for `<script type="text/babel">` blocks

### No Build / Test / Lint Commands

There is no `package.json`, no test framework, no linter, and no CI/CD pipeline. Quality is verified manually in the browser.

## Conventions

- **All UI text is in Japanese** — maintain this when adding features or modifying labels
- **Inline SVG icons** — icons are defined as React components using Lucide-style SVGs, not imported from a library
- **Single component architecture** — all logic lives in `CleaningScheduleApp`; extract components only if complexity demands it
- **TailwindCSS utility classes** — no custom CSS; all styling uses Tailwind classes
- **No external state management** — React `useState` and `useEffect` hooks only
- **localStorage persistence** — data saves automatically on state change via `useEffect`

## Common Pitfalls

- The `<script type="text/babel">` tag is required for JSX transformation. Regular `<script>` tags won't work for JSX code.
- `localStorage` key is `'cleaning-rooms'` — changing it will cause users to lose existing data.
- Room IDs use `Date.now()`, which can collide if two rooms are added within the same millisecond.
- The localStorage save effect runs on every render where `rooms.length >= 0` (i.e., always), so an empty array will overwrite existing data on first load if the load effect hasn't run yet. The load effect runs first due to React's hook ordering, but be aware of this coupling.
