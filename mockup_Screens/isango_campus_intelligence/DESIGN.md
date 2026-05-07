---
name: Isango Campus Intelligence
colors:
  surface: '#f8f9fa'
  surface-dim: '#d9dadb'
  surface-bright: '#f8f9fa'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f4f5'
  surface-container: '#edeeef'
  surface-container-high: '#e7e8e9'
  surface-container-highest: '#e1e3e4'
  on-surface: '#191c1d'
  on-surface-variant: '#444650'
  inverse-surface: '#2e3132'
  inverse-on-surface: '#f0f1f2'
  outline: '#757682'
  outline-variant: '#c5c6d2'
  surface-tint: '#435b9f'
  primary: '#00113a'
  on-primary: '#ffffff'
  primary-container: '#002366'
  on-primary-container: '#758dd5'
  inverse-primary: '#b3c5ff'
  secondary: '#0060ac'
  on-secondary: '#ffffff'
  secondary-container: '#68abff'
  on-secondary-container: '#003e73'
  tertiary: '#2d0700'
  on-tertiary: '#ffffff'
  tertiary-container: '#501300'
  on-tertiary-container: '#d37758'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dbe1ff'
  primary-fixed-dim: '#b3c5ff'
  on-primary-fixed: '#00174a'
  on-primary-fixed-variant: '#2a4386'
  secondary-fixed: '#d4e3ff'
  secondary-fixed-dim: '#a4c9ff'
  on-secondary-fixed: '#001c39'
  on-secondary-fixed-variant: '#004883'
  tertiary-fixed: '#ffdbd0'
  tertiary-fixed-dim: '#ffb59e'
  on-tertiary-fixed: '#390b00'
  on-tertiary-fixed-variant: '#783018'
  background: '#f8f9fa'
  on-background: '#191c1d'
  surface-variant: '#e1e3e4'
typography:
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  button:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 20px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  margin-mobile: 20px
  gutter-mobile: 12px
---

## Brand & Style

This design system is built to facilitate the vibrant, fast-paced nature of campus life while maintaining a level of academic professionalism. The aesthetic is **Corporate Modern**, prioritizing clarity, structure, and reliability. It targets university students and faculty who require a trustworthy platform to manage their extracurricular schedules. 

The visual language relies on high-contrast primary actions set against a soft, breathable background. The goal is to evoke a sense of organized energy—encouraging participation in events through a UI that feels both stable and effortless.

## Colors

The color palette is anchored by a deep navy blue, used exclusively for primary actions and brand-heavy elements to establish authority. 

- **Primary (#002366):** Used for buttons, active navigation states, and key headings.
- **Secondary (#4A90E2):** A lighter blue for accents, links, and illustrative icons to prevent the UI from feeling too heavy.
- **Background (#F8F9FA):** A subtle light gray to reduce eye strain and provide contrast for white cards.
- **Surface (#FFFFFF):** Pure white used for content containers and cards.
- **Validation:** High-visibility red is used for error states and destructive actions, ensuring student safety and clarity during form entry.

## Typography

This design system utilizes **Plus Jakarta Sans** for its modern, friendly, yet geometric proportions. It strikes a balance between professional academic tool and social discovery app.

Headlines should use a tighter letter-spacing and bold weights to create a strong visual anchor. Body copy is optimized for readability with generous line heights. Labels use semi-bold weights and slight tracking to ensure they are legible even at small sizes on mobile screens.

## Layout & Spacing

The layout follows a **fluid grid** model optimized for mobile devices. It utilizes a 4-column system for standard phone widths. 

- **Safe Zones:** Standardized 20px horizontal margins ensure content does not hug the edge of the screen.
- **Rhythm:** An 8px linear scale (4, 8, 16, 24, 32) governs all padding and margins to maintain vertical rhythm. 
- **Card Spacing:** Grouped content within cards should use 16px internal padding, while separate cards should be stacked with 12px or 16px vertical gaps.

## Elevation & Depth

This design system employs **Ambient Shadows** to create a sense of hierarchy without overwhelming the user. 

- **Primary Cards:** Use a soft, diffused shadow with a 12px blur and 4% opacity (Color: #000000). This lifts the white cards off the light gray background.
- **Buttons:** Active buttons have a slightly deeper shadow to invite interaction, conveying a tactile "pressable" feel.
- **Inputs:** No shadows; instead, they use a subtle 1px border (#E0E4EC) to define the interactive area, transitioning to the primary navy blue on focus.

## Shapes

The shape language is consistently **Rounded**, reflecting an approachable and modern campus vibe. 

- **Standard Elements:** 8px (0.5rem) radius for cards and input fields.
- **Buttons:** 16px (1rem) or fully pill-shaped (rounded-full) to maximize their prominence as action drivers.
- **Icons:** Enclosed in circles or squares with a 4px-8px radius to match the component containers.

## Components

- **Buttons:** High-contrast primary buttons with white text on navy blue. Secondary buttons use a transparent background with a navy border or subtle gray fill.
- **Cards:** White surfaces with 16px internal padding and 8px corner radii. Used for event listings, profile summaries, and news updates.
- **Input Fields:** Clear labels placed above the field. Use a 1px #E0E4EC border. For error states, change the border and the help text to #D32F2F.
- **Chips:** Small, rounded pills (12px radius) used for event categories (e.g., "Workshop", "Social").
- **Navigation:** A bottom tab bar with clean line icons and navy blue active states.
- **Validation:** Icons (like an exclamation mark) should accompany error text to ensure accessibility for colorblind users.