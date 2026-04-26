---
name: i18n Setup
description: EN/RU internationalization with cookie-based locale persistence; locale switcher in navbar
type: project
---

Added full i18n support (EN default, RU) in April 2026.

**Architecture:**
- `ApplicationController#set_locale` reads `cookies[:locale]` and sets `I18n.locale`
- `LocalesController#update` sets `cookies.permanent[:locale]` and redirects back
- Route: `GET /locale/:locale` → `switch_locale_path(:en)` / `switch_locale_path(:ru)`
- `config/application.rb`: `config.i18n.default_locale = :en`, `available_locales = [:en, :ru]`

**Locale files:**
- `config/locales/en.yml` — full English translations
- `config/locales/ru.yml` — full Russian translations

**UI:** EN/RU buttons in navbar (`.navbar-lang-btn` CSS class, active state highlights current locale)

**Views translated:** all game views, home, select_civilization, layout nav

**Why:** `%%` in YAML i18n only collapses to `%` when adjacent to `%{variable}` interpolation; standalone `%%` renders as `%%`. Use single `%` for literal percent in standalone positions.
