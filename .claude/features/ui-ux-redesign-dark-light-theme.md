# PRD: UI/UX Redesign with Dark/Light Theme Support

## 1. Overview

The current UI is unstyled vanilla Bootstrap 5 with no custom CSS, flat typography, and no visual identity suited for a medieval strategy game. This PRD covers a full visual redesign scoped exclusively to `app/views/` and `app/assets/` — no backend changes, no new tables.

**Goals:**
- Establish a design system using CSS custom properties (variables) that supports both dark and light themes
- Give the game a medieval/strategy aesthetic with improved visual hierarchy, spacing, and typography
- Persist the user's theme preference in `localStorage` (no server-side storage needed)
- Improve the game dashboard's information density without sacrificing clarity
- Ensure mobile responsiveness across all views

---

## 2. Actors

| Actor | Role |
|---|---|
| **User (player)** | Browses home, auth pages, game lobby, and gameplay — experiences the redesigned UI |
| **System (browser)** | Reads `prefers-color-scheme` media query on first visit; stores/retrieves theme from `localStorage` |

No admin-specific views are in scope.

---

## 3. Data Model

**No new tables or columns.** Theme preference is a client-side concern stored in `localStorage` under the key `empires_theme` with values `"light"` or `"dark"`.

If server-side persistence becomes a requirement in the future, a `theme_preference` column can be added to `users`, but that is explicitly out of scope here.

---

## 4. Command Objects

**None.** This feature touches only views and assets — no business logic, no commands.

---

## 5. Asset & View Changes

### 5.1 `app/assets/stylesheets/application.css`

Replace the empty file with a full custom stylesheet. Key sections:

#### CSS Custom Properties (Theme Variables)
```css
:root[data-theme="light"] {
  --bg-primary: #f5f0e8;        /* parchment */
  --bg-secondary: #ede8dc;
  --bg-card: #ffffff;
  --bg-card-header: #e8e0cc;
  --text-primary: #2c2416;
  --text-secondary: #5a4e3a;
  --text-muted: #8a7d6a;
  --border-color: #c8b99a;
  --accent-gold: #c9952a;
  --accent-green: #4a7c59;
  --accent-red: #8b3a3a;
  --accent-blue: #2d5a8e;
  --nav-bg: #2c2416;
  --nav-text: #e8d9bb;
  --btn-primary-bg: #c9952a;
  --btn-primary-text: #1a0f00;
  --tab-active-bg: #c9952a;
  --tab-active-text: #1a0f00;
  --summary-bar-bg: #e8e0cc;
  --table-stripe: #f0ebe0;
  --badge-bg: #c9952a;
}

:root[data-theme="dark"] {
  --bg-primary: #1a1510;
  --bg-secondary: #221d16;
  --bg-card: #2a2318;
  --bg-card-header: #332c1f;
  --text-primary: #e8d9bb;
  --text-secondary: #c4b08a;
  --text-muted: #7a6e5a;
  --border-color: #4a3e2e;
  --accent-gold: #d4a83a;
  --accent-green: #5a9468;
  --accent-red: #c05050;
  --accent-blue: #4a80c0;
  --nav-bg: #0e0b07;
  --nav-text: #e8d9bb;
  --btn-primary-bg: #d4a83a;
  --btn-primary-text: #0e0b07;
  --tab-active-bg: #d4a83a;
  --tab-active-text: #0e0b07;
  --summary-bar-bg: #332c1f;
  --table-stripe: #231e15;
  --badge-bg: #d4a83a;
}
```

#### Global Resets & Base
- `body` uses `--bg-primary`, `--text-primary`, serif font stack (`Georgia, 'Times New Roman', serif` for headings, system-ui for body text)
- Smooth transition on `background-color` and `color` for theme switching (`transition: background-color 0.2s ease, color 0.2s ease`)

#### Navbar
- Override Bootstrap navbar: `background-color: var(--nav-bg)`, text `var(--nav-text)`
- Brand name styled with `--accent-gold`, small-caps, slightly larger font
- Theme toggle button: sun/moon icon button floated right in the nav, no label

#### Cards
- `background-color: var(--bg-card)`, `border: 1px solid var(--border-color)`
- Card headers use `--bg-card-header`
- Subtle `box-shadow` in light mode; remove shadow in dark mode

#### Buttons
- `.btn-primary` overridden to use `--btn-primary-bg` / `--btn-primary-text`
- `.btn-outline-primary` uses `--accent-gold` border and text
- `.btn-danger` uses `--accent-red`

#### Tab Navigation (game sidebar)
- Vertical nav pills: active tab gets `--tab-active-bg` background
- Hover state uses `--bg-card-header`
- Tab labels get a small icon prefix (Unicode symbols) to improve scanability — no extra assets needed:
  - Builders 🏗 → `⚒`  Wall → `🏰`  Explore → `🗺`  Local Trade → `⚖`  Global Trade → `🌍`  Research → `📜`  Army → `⚔`  Attack → `🗡`  Management → `📋`  Aid → `🤝`  Scores → `🏆`
  - Icons are optional and can be toggled off; use Unicode to avoid new image assets

#### Summary Bar (Score / Population / Gold strip)
- Use `--summary-bar-bg`, increase font size, add `--accent-gold` color to values
- Separate with `border-right: 1px solid var(--border-color)` dividers

#### Resource / Land Tables
- Replace `bg-light` / `bg-white` inline classes with CSS variables on the component stylesheet
- Add `--table-stripe` alternating rows
- Resource GIF images: add `filter: drop-shadow(0 1px 2px rgba(0,0,0,0.3))` in dark mode

#### Flash Alerts
- Override Bootstrap `.alert-success` / `.alert-danger` to use theme variables

#### Forms (Devise)
- Inputs: `background: var(--bg-card)`, `border-color: var(--border-color)`, `color: var(--text-primary)`
- Labels use `--text-secondary`
- Focus ring uses `--accent-gold`

#### Typography
- H1–H2: `font-family: Georgia, serif`, `color: var(--accent-gold)`, letter-spacing
- H3–H6: semi-bold, `var(--text-primary)`
- `.text-muted` mapped to `var(--text-muted)`

### 5.2 `app/assets/javascript/application.js`

Add theme management logic:

```javascript
// Theme management
const THEME_KEY = 'empires_theme';

function getPreferredTheme() {
  const stored = localStorage.getItem(THEME_KEY);
  if (stored) return stored;
  return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
}

function applyTheme(theme) {
  document.documentElement.setAttribute('data-theme', theme);
  const btn = document.getElementById('theme-toggle');
  if (btn) btn.textContent = theme === 'dark' ? '☀' : '🌙';
}

function toggleTheme() {
  const current = document.documentElement.getAttribute('data-theme');
  const next = current === 'dark' ? 'light' : 'dark';
  localStorage.setItem(THEME_KEY, next);
  applyTheme(next);
}

// Apply theme before first paint to prevent flash
(function() {
  applyTheme(getPreferredTheme());
})();

document.addEventListener('DOMContentLoaded', function() {
  applyTheme(getPreferredTheme());

  const themeBtn = document.getElementById('theme-toggle');
  if (themeBtn) themeBtn.addEventListener('click', toggleTheme);

  // Existing scroll-to-top logic
  if (localStorage.getItem('scrollToTop') === 'true') {
    window.scrollTo({ top: 0, behavior: 'smooth' });
    localStorage.removeItem('scrollToTop');
  }
});
```

### 5.3 `app/views/layouts/application.html.erb`

- Add `data-theme` attribute to `<html>` tag (set via inline script before `<body>` to prevent FOUC):
  ```html
  <script>
    document.documentElement.setAttribute('data-theme',
      localStorage.getItem('empires_theme') ||
      (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light')
    );
  </script>
  ```
- Add theme toggle button to the navbar (before sign-out link):
  ```erb
  <li class="nav-item">
    <button id="theme-toggle" class="nav-link btn btn-link theme-toggle-btn" aria-label="Toggle theme">🌙</button>
  </li>
  ```
- Upgrade Bootstrap CSS CDN from 5.3.3 → keep 5.3.3 but load the **dark mode compatible** variant (same CDN, Bootstrap 5 supports `data-bs-theme` — leverage this alongside our custom variables)
- Add `data-bs-theme` attribute sync: when `data-theme` is set to `dark`, also set `data-bs-theme="dark"` on `<html>` so Bootstrap's own components (modals, dropdowns) pick up dark styles automatically

### 5.4 `app/views/home/index.html.erb`

- Hero section: add a styled hero banner with parchment texture via CSS gradient (`radial-gradient` over `--bg-primary`)
- Game cards: add a `card-header` with "Game #N" in `--accent-gold` style
- "Continue Game" / "Join Game" buttons use the themed `.btn-primary`
- Empty state (no games): styled `.alert` using theme variables

### 5.5 `app/views/games/show.html.erb`

- Top info bar (Game # / Civilization / Turns) — promote to a styled header card with `--bg-card-header` background and `--accent-gold` civilization name
- Last Turn Events card — add a left border stripe colored by event severity (green = positive, red = combat, neutral = info)
- Summary row (Score / Population / Gold) — larger numbers, icon prefixes, dividers
- Left sidebar tab list — increase spacing, add hover highlight, bold active tab
- Resource/land tables — standardize padding, remove inline `bg-light`/`bg-white`, use CSS variables

### 5.6 `app/views/games/select_civilization.html.erb`

- Civilization cards: add a colored top border (`--accent-gold`) on hover
- Bonus list items: use color-coded badges (`text-success` → custom `--accent-green`)
- "Choose Civilization" button: full-width, themed `.btn-primary`

### 5.7 `app/views/devise/**`

- Wrap all forms in a centered max-width container (`max-width: 420px`)
- Add a styled page title with `--accent-gold`
- Input fields use themed variables
- Error messages use `--accent-red`

---

## 6. API / Controller Changes

**None.** Theme is fully client-side. No new routes, no new endpoints.

---

## 7. Acceptance Criteria

### Theme Switching
- [ ] On first visit with no stored preference, theme matches `prefers-color-scheme` media query
- [ ] Clicking the theme toggle button switches between dark and light themes instantly (no full reload)
- [ ] Theme preference persists across page reloads (stored in `localStorage` under key `empires_theme`)
- [ ] Theme preference persists after navigating between pages (home → game → back)
- [ ] No flash of wrong theme (FOUC) on page load — the `<html>` element has `data-theme` set before body renders
- [ ] Theme toggle button shows sun icon in dark mode, moon icon in light mode
- [ ] Bootstrap components (dropdowns, modals, alerts) respect the active theme via `data-bs-theme`

### Light Theme
- [ ] Background uses parchment tones (`#f5f0e8` range), not pure white
- [ ] Headings use serif font in gold/amber color
- [ ] Navbar is dark (`#2c2416`) with light text, contrasting the light body
- [ ] All interactive elements (buttons, tabs, links) meet WCAG AA contrast ratio (4.5:1 minimum)

### Dark Theme
- [ ] Background uses deep charcoal tones (`#1a1510` range), not pure black
- [ ] All text remains readable (light text on dark backgrounds)
- [ ] Resource GIFs have subtle drop-shadow to remain visible
- [ ] No pure white used anywhere in dark theme

### Game Show Page
- [ ] Tab navigation shows active tab with gold highlight in both themes
- [ ] Summary bar (Score / Population / Gold) is visually prominent
- [ ] Last Turn Events card shows color-coded messages
- [ ] Land and Resource tables are readable in both themes (no inline `bg-light`/`bg-white` classes remaining)

### Auth Pages (Devise)
- [ ] All form inputs are readable and correctly styled in both themes
- [ ] Error messages are visible in both themes
- [ ] Forms are centered and max-width constrained on desktop

### Home Page
- [ ] Game cards are visually distinct and show join/continue state clearly
- [ ] Empty state alert is visible in both themes

### General
- [ ] No existing functionality is broken (all buttons, forms, tabs still work)
- [ ] No new Rails views or controllers are created
- [ ] No changes to `app/commands/`, `app/models/`, `app/controllers/`, or DB schema
- [ ] Page loads without JavaScript errors in both themes

---

## 8. Non-Goals

- **No server-side theme persistence** — `localStorage` is sufficient; no `users` table changes
- **No new image assets** — reuse existing GIFs; use Unicode characters for tab icons
- **No JavaScript framework** — vanilla JS only, no React/Vue/Stimulus for theming
- **No responsive breakpoint redesign** — improve mobile readability but do not redesign the layout to be mobile-first
- **No animation overhaul** — subtle transitions only (`0.2s ease`); no complex animations
- **No new game features** — strictly visual changes; game logic is untouched
- **No admin views** — not in scope
- **No email template redesign** — `app/views/layouts/mailer.html.erb` and Devise mailer views are out of scope
- **No PWA manifest changes** — `app/views/pwa/` is out of scope
- **No icon library** — do not add Font Awesome or similar; use Unicode symbols where icons are needed
