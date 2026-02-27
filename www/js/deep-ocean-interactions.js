/**
 * Deep Ocean Scientific Theme - Micro-Interactions
 * Environmental Bowtie Risk Analysis Application
 * Version: 1.1.0
 *
 * Provides smooth animations, hover effects, theme switching, and enhanced UX
 */

(function() {
  'use strict';

  // =============================================================================
  // CONFIGURATION
  // =============================================================================
  const CONFIG = {
    animationDuration: 300,
    staggerDelay: 50,
    particleCount: 30,
    enableParticles: true,
    enableRipple: true,
    enableCardAnimations: true,
    defaultTheme: 'dark',
    themeStorageKey: 'bowtie_theme_preference'
  };

  // =============================================================================
  // THEME MANAGEMENT
  // =============================================================================
  const ThemeManager = {
    currentTheme: 'dark',

    init: function() {
      // Load saved theme preference or use default
      const savedTheme = localStorage.getItem(CONFIG.themeStorageKey);
      this.currentTheme = savedTheme || CONFIG.defaultTheme;

      // Apply theme immediately (before DOM fully loads to prevent flash)
      this.applyTheme(this.currentTheme, false);

      console.log('[Theme Manager] Initialized with theme:', this.currentTheme);
    },

    applyTheme: function(theme, animate = true) {
      const html = document.documentElement;
      const body = document.body;

      if (animate) {
        // Add transition class for smooth theme change
        body.classList.add('theme-transitioning');
      }

      // Set theme attribute
      html.setAttribute('data-theme', theme);
      body.setAttribute('data-theme', theme);

      // Update any theme toggle buttons
      this.updateToggleButtons(theme);

      // Store preference
      localStorage.setItem(CONFIG.themeStorageKey, theme);
      this.currentTheme = theme;

      // Notify Shiny if available
      if (typeof Shiny !== 'undefined' && Shiny.setInputValue) {
        Shiny.setInputValue('current_color_theme', theme, {priority: 'event'});
      }

      if (animate) {
        // Remove transition class after animation
        setTimeout(() => {
          body.classList.remove('theme-transitioning');
        }, 500);
      }

      console.log('[Theme Manager] Applied theme:', theme);
    },

    toggle: function() {
      const newTheme = this.currentTheme === 'dark' ? 'light' : 'dark';
      this.applyTheme(newTheme, true);
      return newTheme;
    },

    updateToggleButtons: function(theme) {
      // Update all theme toggle buttons in the UI
      document.querySelectorAll('.theme-toggle-btn, [data-theme-toggle]').forEach(btn => {
        const icon = btn.querySelector('i, .fa, .fas, .far');
        const text = btn.querySelector('.theme-toggle-text');

        if (icon) {
          if (theme === 'dark') {
            icon.className = icon.className.replace(/fa-sun|fa-moon/, 'fa-sun');
          } else {
            icon.className = icon.className.replace(/fa-sun|fa-moon/, 'fa-moon');
          }
        }

        if (text) {
          text.textContent = theme === 'dark' ? 'Light Mode' : 'Dark Mode';
        }

        // Update aria-label for accessibility
        btn.setAttribute('aria-label', `Switch to ${theme === 'dark' ? 'light' : 'dark'} mode`);
      });
    },

    getTheme: function() {
      return this.currentTheme;
    }
  };

  // Initialize theme BEFORE DOMContentLoaded to prevent flash
  ThemeManager.init();

  // =============================================================================
  // INITIALIZATION
  // =============================================================================
  document.addEventListener('DOMContentLoaded', function() {
    console.log('[Deep Ocean Theme] Initializing micro-interactions...');

    // Initialize all interaction modules
    initThemeToggle();
    initPageTransitions();
    initCardAnimations();
    initButtonRipples();
    initSidebarEnhancements();
    initFormEnhancements();
    initScrollAnimations();
    initTooltipEnhancements();
    initNotificationEnhancements();

    // Shiny-specific initialization
    if (typeof Shiny !== 'undefined') {
      initShinyIntegration();
    }

    console.log('[Deep Ocean Theme] Micro-interactions initialized');
  });

  // =============================================================================
  // THEME TOGGLE INITIALIZATION
  // =============================================================================
  function initThemeToggle() {
    // Attach click handlers to any theme toggle buttons
    document.querySelectorAll('.theme-toggle-btn, [data-theme-toggle]').forEach(btn => {
      btn.addEventListener('click', function(e) {
        e.preventDefault();
        ThemeManager.toggle();
      });
    });

    // Listen for system preference changes
    if (window.matchMedia) {
      const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
      mediaQuery.addEventListener('change', (e) => {
        // Only auto-switch if user hasn't set a preference
        if (!localStorage.getItem(CONFIG.themeStorageKey)) {
          ThemeManager.applyTheme(e.matches ? 'dark' : 'light', true);
        }
      });
    }

    // Keyboard shortcut: Ctrl/Cmd + Shift + L to toggle theme
    document.addEventListener('keydown', function(e) {
      if ((e.ctrlKey || e.metaKey) && e.shiftKey && e.key === 'L') {
        e.preventDefault();
        ThemeManager.toggle();
      }
    });
  }

  // Expose ThemeManager globally for external access
  window.ThemeManager = ThemeManager;

  // =============================================================================
  // PAGE TRANSITIONS
  // =============================================================================
  function initPageTransitions() {
    // Staggered entrance animation for content on page load
    const content = document.querySelector('.content-wrapper');
    if (content) {
      content.classList.add('fade-in');
    }

    // Animate cards on initial load with stagger
    setTimeout(() => {
      const cards = document.querySelectorAll('.card, .box, .info-box');
      cards.forEach((card, index) => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(20px)';

        setTimeout(() => {
          card.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
          card.style.opacity = '1';
          card.style.transform = 'translateY(0)';
        }, index * CONFIG.staggerDelay);
      });
    }, 100);
  }

  // =============================================================================
  // CARD ANIMATIONS
  // =============================================================================
  function initCardAnimations() {
    if (!CONFIG.enableCardAnimations) return;

    // Add magnetic hover effect to cards
    document.querySelectorAll('.card, .box').forEach(card => {
      card.addEventListener('mousemove', function(e) {
        const rect = card.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;

        const centerX = rect.width / 2;
        const centerY = rect.height / 2;

        const rotateX = (y - centerY) / 30;
        const rotateY = (centerX - x) / 30;

        card.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) translateY(-2px)`;
      });

      card.addEventListener('mouseleave', function() {
        card.style.transform = 'perspective(1000px) rotateX(0) rotateY(0) translateY(0)';
        card.style.transition = 'transform 0.5s ease';
      });

      card.addEventListener('mouseenter', function() {
        card.style.transition = 'transform 0.1s ease';
      });
    });

    // Observe new cards added dynamically
    observeDynamicElements('.card, .box', initSingleCardAnimation);
  }

  function initSingleCardAnimation(card) {
    if (card.dataset.animationInitialized) return;
    card.dataset.animationInitialized = 'true';

    // Add entrance animation
    card.style.opacity = '0';
    card.style.transform = 'translateY(20px)';

    requestAnimationFrame(() => {
      card.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
      card.style.opacity = '1';
      card.style.transform = 'translateY(0)';
    });
  }

  // =============================================================================
  // BUTTON RIPPLE EFFECTS
  // =============================================================================
  function initButtonRipples() {
    if (!CONFIG.enableRipple) return;

    document.addEventListener('click', function(e) {
      const button = e.target.closest('.btn');
      if (!button) return;

      // Create ripple element
      const ripple = document.createElement('span');
      ripple.className = 'btn-ripple';

      const rect = button.getBoundingClientRect();
      const size = Math.max(rect.width, rect.height);
      const x = e.clientX - rect.left - size / 2;
      const y = e.clientY - rect.top - size / 2;

      ripple.style.cssText = `
        position: absolute;
        width: ${size}px;
        height: ${size}px;
        left: ${x}px;
        top: ${y}px;
        background: radial-gradient(circle, rgba(255,255,255,0.4) 0%, transparent 70%);
        border-radius: 50%;
        transform: scale(0);
        animation: rippleEffect 0.6s ease-out forwards;
        pointer-events: none;
      `;

      // Ensure button has relative positioning
      const computedStyle = window.getComputedStyle(button);
      if (computedStyle.position === 'static') {
        button.style.position = 'relative';
      }
      button.style.overflow = 'hidden';

      button.appendChild(ripple);

      // Remove ripple after animation
      setTimeout(() => ripple.remove(), 600);
    });

    // Add ripple animation keyframes if not exists
    if (!document.getElementById('ripple-styles')) {
      const style = document.createElement('style');
      style.id = 'ripple-styles';
      style.textContent = `
        @keyframes rippleEffect {
          to {
            transform: scale(2.5);
            opacity: 0;
          }
        }
      `;
      document.head.appendChild(style);
    }
  }

  // =============================================================================
  // SIDEBAR ENHANCEMENTS
  // =============================================================================
  function initSidebarEnhancements() {
    const sidebar = document.querySelector('.main-sidebar');
    if (!sidebar) return;

    // Add hover sound effect class (optional, could be enabled with actual sounds)
    const menuItems = sidebar.querySelectorAll('.nav-link');

    menuItems.forEach(item => {
      // Add subtle scale effect on hover
      item.addEventListener('mouseenter', function() {
        const icon = this.querySelector('.nav-icon');
        if (icon) {
          icon.style.transform = 'scale(1.2) rotate(5deg)';
          icon.style.transition = 'transform 0.2s ease';
        }
      });

      item.addEventListener('mouseleave', function() {
        const icon = this.querySelector('.nav-icon');
        if (icon) {
          icon.style.transform = 'scale(1) rotate(0deg)';
        }
      });
    });

    // Animate sidebar section headers
    const headers = sidebar.querySelectorAll('.sidebar-header');
    headers.forEach((header, index) => {
      header.style.opacity = '0';
      header.style.transform = 'translateX(-10px)';

      setTimeout(() => {
        header.style.transition = 'opacity 0.4s ease, transform 0.4s ease';
        header.style.opacity = '0.7';
        header.style.transform = 'translateX(0)';
      }, 500 + index * 100);
    });
  }

  // =============================================================================
  // FORM ENHANCEMENTS
  // =============================================================================
  function initFormEnhancements() {
    // Floating label effect for inputs
    document.querySelectorAll('.form-control').forEach(input => {
      // Add focus glow effect
      input.addEventListener('focus', function() {
        this.parentElement.classList.add('input-focused');

        // Add subtle glow
        this.style.boxShadow = '0 0 0 3px rgba(0, 212, 170, 0.2), 0 4px 20px rgba(0, 212, 170, 0.1)';
      });

      input.addEventListener('blur', function() {
        this.parentElement.classList.remove('input-focused');
        this.style.boxShadow = '';
      });
    });

    // Animate select dropdown arrows
    document.querySelectorAll('.form-select, select').forEach(select => {
      select.addEventListener('focus', function() {
        this.style.borderColor = '#00d4aa';
      });

      select.addEventListener('blur', function() {
        this.style.borderColor = '';
      });
    });

    // Checkbox animation enhancement
    document.querySelectorAll('.form-check-input').forEach(checkbox => {
      checkbox.addEventListener('change', function() {
        if (this.checked) {
          this.style.transform = 'scale(1.2)';
          setTimeout(() => {
            this.style.transform = 'scale(1)';
          }, 150);
        }
      });
    });
  }

  // =============================================================================
  // SCROLL ANIMATIONS
  // =============================================================================
  function initScrollAnimations() {
    const observerOptions = {
      root: null,
      rootMargin: '0px',
      threshold: 0.1
    };

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('animate-in');
          entry.target.style.opacity = '1';
          entry.target.style.transform = 'translateY(0)';
        }
      });
    }, observerOptions);

    // Observe elements that should animate on scroll
    document.querySelectorAll('.scroll-animate').forEach(el => {
      el.style.opacity = '0';
      el.style.transform = 'translateY(30px)';
      el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
      observer.observe(el);
    });
  }

  // =============================================================================
  // TOOLTIP ENHANCEMENTS
  // =============================================================================
  function initTooltipEnhancements() {
    // Enhanced tooltip positioning and animations
    document.querySelectorAll('[data-toggle="tooltip"], [data-bs-toggle="tooltip"]').forEach(el => {
      el.addEventListener('mouseenter', function() {
        this.style.transition = 'transform 0.2s ease';
      });
    });
  }

  // =============================================================================
  // NOTIFICATION ENHANCEMENTS
  // =============================================================================
  function initNotificationEnhancements() {
    // Observer for Shiny notifications
    const notificationContainer = document.querySelector('#shiny-notification-panel');
    if (notificationContainer) {
      const observer = new MutationObserver((mutations) => {
        mutations.forEach(mutation => {
          mutation.addedNodes.forEach(node => {
            if (node.classList && node.classList.contains('shiny-notification')) {
              // Add entrance animation
              node.style.opacity = '0';
              node.style.transform = 'translateX(100%)';

              requestAnimationFrame(() => {
                node.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
                node.style.opacity = '1';
                node.style.transform = 'translateX(0)';
              });
            }
          });
        });
      });

      observer.observe(notificationContainer, { childList: true });
    }
  }

  // =============================================================================
  // SHINY INTEGRATION
  // =============================================================================
  function initShinyIntegration() {
    // Listen for Shiny events
    $(document).on('shiny:value', function(event) {
      // Animate updated elements
      const target = document.getElementById(event.name);
      if (target) {
        target.classList.add('value-updated');
        setTimeout(() => target.classList.remove('value-updated'), 500);
      }
    });

    // Tab change animations
    $(document).on('shiny:inputchanged', function(event) {
      if (event.name === 'sidebar_menu' || event.name.includes('tab')) {
        // Animate tab content
        setTimeout(() => {
          const activePane = document.querySelector('.tab-pane.active');
          if (activePane) {
            activePane.style.opacity = '0';
            activePane.style.transform = 'translateY(10px)';

            requestAnimationFrame(() => {
              activePane.style.transition = 'opacity 0.4s ease, transform 0.4s ease';
              activePane.style.opacity = '1';
              activePane.style.transform = 'translateY(0)';
            });
          }
        }, 50);
      }
    });

    // Custom message handler for theme JavaScript
    Shiny.addCustomMessageHandler('eval', function(message) {
      try {
        eval(message.code);
      } catch (e) {
        console.error('[Deep Ocean Theme] Eval error:', e);
      }
    });

    // Add loading state animations
    $(document).on('shiny:busy', function() {
      document.body.classList.add('shiny-busy-state');
    });

    $(document).on('shiny:idle', function() {
      document.body.classList.remove('shiny-busy-state');
    });
  }

  // =============================================================================
  // DYNAMIC ELEMENT OBSERVER
  // =============================================================================
  function observeDynamicElements(selector, callback) {
    const observer = new MutationObserver((mutations) => {
      mutations.forEach(mutation => {
        mutation.addedNodes.forEach(node => {
          if (node.nodeType === 1) {
            if (node.matches && node.matches(selector)) {
              callback(node);
            }
            node.querySelectorAll && node.querySelectorAll(selector).forEach(callback);
          }
        });
      });
    });

    observer.observe(document.body, {
      childList: true,
      subtree: true
    });
  }

  // =============================================================================
  // COUNTER ANIMATION (for info boxes)
  // =============================================================================
  function animateCounter(element, start, end, duration) {
    const range = end - start;
    const startTime = performance.now();

    function updateCounter(currentTime) {
      const elapsed = currentTime - startTime;
      const progress = Math.min(elapsed / duration, 1);
      const easeProgress = 1 - Math.pow(1 - progress, 3); // Ease out cubic

      const currentValue = Math.round(start + range * easeProgress);
      element.textContent = currentValue.toLocaleString();

      if (progress < 1) {
        requestAnimationFrame(updateCounter);
      }
    }

    requestAnimationFrame(updateCounter);
  }

  // Expose counter animation for use by Shiny
  window.animateCounter = animateCounter;

  // =============================================================================
  // ADDITIONAL STYLES (injected dynamically)
  // =============================================================================
  const dynamicStyles = document.createElement('style');
  dynamicStyles.textContent = `
    /* =========================================
       THEME TRANSITION STYLES
       ========================================= */

    /* Smooth theme transition */
    .theme-transitioning,
    .theme-transitioning * {
      transition: background-color 0.4s ease,
                  color 0.4s ease,
                  border-color 0.4s ease,
                  box-shadow 0.4s ease !important;
    }

    /* Theme toggle button */
    .theme-toggle-btn {
      position: relative;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      padding: 8px 16px;
      border-radius: 25px;
      font-weight: 500;
      cursor: pointer;
      overflow: hidden;
      transition: all 0.3s ease;
    }

    .theme-toggle-btn i {
      font-size: 1.1em;
      transition: transform 0.4s ease;
    }

    .theme-toggle-btn:hover i {
      transform: rotate(180deg);
    }

    /* Dark mode toggle button style */
    [data-theme="dark"] .theme-toggle-btn {
      background: linear-gradient(135deg, rgba(255, 217, 61, 0.15), rgba(255, 217, 61, 0.05));
      border: 1px solid rgba(255, 217, 61, 0.3);
      color: #ffd93d;
    }

    [data-theme="dark"] .theme-toggle-btn:hover {
      background: linear-gradient(135deg, rgba(255, 217, 61, 0.25), rgba(255, 217, 61, 0.1));
      box-shadow: 0 4px 20px rgba(255, 217, 61, 0.2);
    }

    /* Light mode toggle button style */
    [data-theme="light"] .theme-toggle-btn {
      background: linear-gradient(135deg, rgba(99, 102, 241, 0.15), rgba(99, 102, 241, 0.05));
      border: 1px solid rgba(99, 102, 241, 0.3);
      color: #6366f1;
    }

    [data-theme="light"] .theme-toggle-btn:hover {
      background: linear-gradient(135deg, rgba(99, 102, 241, 0.25), rgba(99, 102, 241, 0.1));
      box-shadow: 0 4px 20px rgba(99, 102, 241, 0.2);
    }

    /* Compact toggle button (icon only) */
    .theme-toggle-compact {
      width: 40px;
      height: 40px;
      padding: 0;
      border-radius: 50%;
    }

    .theme-toggle-compact .theme-toggle-text {
      display: none;
    }

    /* =========================================
       VALUE UPDATE ANIMATION
       ========================================= */
    .value-updated {
      animation: valueFlash 0.5s ease;
    }

    @keyframes valueFlash {
      0% { background-color: transparent; }
      50% { background-color: rgba(0, 212, 170, 0.2); }
      100% { background-color: transparent; }
    }

    /* =========================================
       BUSY STATE INDICATOR
       ========================================= */
    .shiny-busy-state::after {
      content: '';
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      height: 3px;
      background: linear-gradient(90deg,
        transparent 0%,
        #00d4aa 50%,
        transparent 100%
      );
      background-size: 200% 100%;
      animation: loadingBar 1.5s ease-in-out infinite;
      z-index: 9999;
    }

    [data-theme="light"] .shiny-busy-state::after {
      background: linear-gradient(90deg,
        transparent 0%,
        #0d9488 50%,
        transparent 100%
      );
      background-size: 200% 100%;
    }

    @keyframes loadingBar {
      0% { background-position: 200% 0; }
      100% { background-position: -200% 0; }
    }

    /* =========================================
       INPUT FOCUSED STATE
       ========================================= */
    .input-focused label {
      color: #00d4aa !important;
      transform: translateY(-2px);
      transition: all 0.2s ease;
    }

    [data-theme="light"] .input-focused label {
      color: #0d9488 !important;
    }

    /* =========================================
       SMOOTH TRANSITIONS
       ========================================= */
    .btn, .nav-link, .form-control, .card, .box {
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }

    /* =========================================
       KEYBOARD SHORTCUT HINT
       ========================================= */
    .theme-toggle-btn::after {
      content: 'Ctrl+Shift+L';
      position: absolute;
      bottom: -25px;
      left: 50%;
      transform: translateX(-50%);
      font-size: 10px;
      opacity: 0;
      transition: opacity 0.2s ease;
      white-space: nowrap;
      pointer-events: none;
    }

    .theme-toggle-btn:hover::after {
      opacity: 0.6;
    }
  `;
  document.head.appendChild(dynamicStyles);

})();
