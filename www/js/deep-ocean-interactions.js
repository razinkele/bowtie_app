/**
 * Deep Ocean Scientific Theme - Micro-Interactions
 * Environmental Bowtie Risk Analysis Application
 * Version: 1.0.0
 *
 * Provides smooth animations, hover effects, and enhanced UX interactions
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
    enableCardAnimations: true
  };

  // =============================================================================
  // INITIALIZATION
  // =============================================================================
  document.addEventListener('DOMContentLoaded', function() {
    console.log('[Deep Ocean Theme] Initializing micro-interactions...');

    // Initialize all interaction modules
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
    /* Value update animation */
    .value-updated {
      animation: valueFlash 0.5s ease;
    }

    @keyframes valueFlash {
      0% { background-color: transparent; }
      50% { background-color: rgba(0, 212, 170, 0.2); }
      100% { background-color: transparent; }
    }

    /* Busy state indicator */
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

    @keyframes loadingBar {
      0% { background-position: 200% 0; }
      100% { background-position: -200% 0; }
    }

    /* Input focused state */
    .input-focused label {
      color: #00d4aa !important;
      transform: translateY(-2px);
      transition: all 0.2s ease;
    }

    /* Smooth transitions for all interactive elements */
    .btn, .nav-link, .form-control, .card, .box {
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }
  `;
  document.head.appendChild(dynamicStyles);

})();
