// Theme management
const THEME_KEY = "empires_theme";

function getPreferredTheme() {
  const stored = localStorage.getItem(THEME_KEY);
  if (stored) return stored;
  return "dark";
}

function applyTheme(theme) {
  document.documentElement.setAttribute("data-theme", theme);
  const btn = document.getElementById("theme-toggle");
  if (btn) btn.textContent = theme === "dark" ? "☀ Theme" : "🌙 Theme";
}

function toggleTheme() {
  const current = document.documentElement.getAttribute("data-theme");
  const next = current === "dark" ? "light" : "dark";
  localStorage.setItem(THEME_KEY, next);
  applyTheme(next);
}

// Bootstrap compatibility shims (no Bootstrap JS loaded)
document.addEventListener("DOMContentLoaded", function () {
  applyTheme(getPreferredTheme());

  const themeBtn = document.getElementById("theme-toggle");
  if (themeBtn) themeBtn.addEventListener("click", toggleTheme);

  // Navbar dropdown menu
  const menuBtn = document.getElementById("navbar-menu-btn");
  const menuDropdown = document.getElementById("navbar-dropdown");
  if (menuBtn && menuDropdown) {
    menuBtn.addEventListener("click", function (e) {
      e.stopPropagation();
      const isOpen = !menuDropdown.hidden;
      menuDropdown.hidden = isOpen;
      menuBtn.setAttribute("aria-expanded", String(!isOpen));
    });
    document.addEventListener("click", function () {
      if (!menuDropdown.hidden) {
        menuDropdown.hidden = true;
        menuBtn.setAttribute("aria-expanded", "false");
      }
    });
    menuDropdown.addEventListener("click", function (e) {
      e.stopPropagation();
    });
  }

  // Tab system: handles data-bs-toggle="tab"
  document.querySelectorAll('[data-bs-toggle="tab"]').forEach(function (tab) {
    tab.addEventListener("click", function (e) {
      e.preventDefault();
      const targetId = this.getAttribute("data-bs-target");
      const target = document.querySelector(targetId);
      if (!target) return;

      // Deactivate sibling tabs
      const tabList = this.closest('[role="tablist"]') || this.closest(".nav");
      if (tabList) {
        tabList.querySelectorAll(".nav-link").forEach(function (t) {
          t.classList.remove("active");
          t.setAttribute("aria-selected", "false");
        });
      }

      // Hide sibling panes
      const tabContent = target.parentElement;
      if (tabContent) {
        tabContent.querySelectorAll(".tab-pane").forEach(function (p) {
          p.classList.remove("show", "active");
        });
      }

      // Activate
      this.classList.add("active");
      this.setAttribute("aria-selected", "true");
      target.classList.add("show", "active");

      // Fire Bootstrap-compatible event for existing listeners
      this.dispatchEvent(new CustomEvent("shown.bs.tab", { bubbles: true, detail: { target: this } }));
    });
  });

  // Modal system: data-bs-toggle="modal"
  document.querySelectorAll('[data-bs-toggle="modal"]').forEach(function (trigger) {
    trigger.addEventListener("click", function (e) {
      e.preventDefault();
      const targetId = this.getAttribute("data-bs-target") || this.dataset.bsTarget;
      const modal = document.querySelector(targetId);
      if (modal) modal.classList.add("show");
    });
  });

  // Modal dismiss: data-bs-dismiss="modal"
  document.querySelectorAll('[data-bs-dismiss="modal"]').forEach(function (btn) {
    btn.addEventListener("click", function () {
      const modal = this.closest(".modal");
      if (modal) modal.classList.remove("show");
    });
  });

  // Close modal on backdrop click
  document.querySelectorAll(".modal").forEach(function (modal) {
    modal.addEventListener("click", function (e) {
      if (e.target === this) this.classList.remove("show");
    });
  });

  // Alert dismiss: data-bs-dismiss="alert"
  document.querySelectorAll('[data-bs-dismiss="alert"]').forEach(function (btn) {
    btn.addEventListener("click", function () {
      const alert = this.closest(".alert");
      if (alert) {
        alert.style.transition = "opacity 0.15s ease";
        alert.style.opacity = "0";
        setTimeout(function () { alert.remove(); }, 150);
      }
    });
  });

  // Scroll restore
  if (localStorage.getItem("scrollToTop") === "true") {
    window.scrollTo({ top: 0, behavior: "smooth" });
    localStorage.removeItem("scrollToTop");
  }
});

// Bootstrap.Modal shim for inline JS usage (e.g. new bootstrap.Modal(...))
window.bootstrap = {
  Modal: function (element) {
    return {
      show: function () { if (element) element.classList.add("show"); },
      hide: function () { if (element) element.classList.remove("show"); },
      toggle: function () { if (element) element.classList.toggle("show"); }
    };
  }
};
