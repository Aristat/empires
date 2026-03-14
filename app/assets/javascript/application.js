// Theme management
const THEME_KEY = "empires_theme";

function getPreferredTheme() {
  const stored = localStorage.getItem(THEME_KEY);
  if (stored) return stored;
  return "dark";
}

function applyTheme(theme) {
  document.documentElement.setAttribute("data-theme", theme);
  document.documentElement.setAttribute("data-bs-theme", theme);
  const btn = document.getElementById("theme-toggle");
  if (btn) btn.textContent = theme === "dark" ? "☀" : "🌙";
}

function toggleTheme() {
  const current = document.documentElement.getAttribute("data-theme");
  const next = current === "dark" ? "light" : "dark";
  localStorage.setItem(THEME_KEY, next);
  applyTheme(next);
}

document.addEventListener("DOMContentLoaded", function () {
  // Sync button icon — data-theme is already set on <html> by the inline head script
  applyTheme(getPreferredTheme());

  const themeBtn = document.getElementById("theme-toggle");
  if (themeBtn) themeBtn.addEventListener("click", toggleTheme);

  if (localStorage.getItem("scrollToTop") === "true") {
    window.scrollTo({ top: 0, behavior: "smooth" });
    localStorage.removeItem("scrollToTop");
  }
});
