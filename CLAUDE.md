# Kitamo Design System Rules

> This document describes the design system, conventions, and patterns for the Kitamo codebase.
> Use it when integrating Figma designs via MCP or implementing new UI components.

---

## 1. Tech Stack Overview

| Category | Technology |
|----------|------------|
| **Framework** | Vue 3 (Composition API + `<script setup>`) |
| **Build** | Vite 7 + Laravel Vite Plugin |
| **Routing** | Inertia.js (`@inertiajs/vue3`) |
| **Styling** | Tailwind CSS 3 (utility-first) |
| **Language** | TypeScript (strict mode) |
| **Backend** | Laravel (PHP) |
| **Video** | Remotion (React) in `/Kitamo/` |

---

## 2. Design Tokens

### Location
`resources/css/app.css` (lines 5-55)

### CSS Custom Properties

```css
:root {
    /* Backgrounds */
    --bg-page: #F8FAFC;
    --bg-section: #F1F5F9;
    --bg-card: #FFFFFF;
    --bg-input: #FFFFFF;

    /* Text */
    --text-primary: #0F172A;
    --text-secondary: #334155;
    --text-tertiary: #64748B;
    --text-disabled: #94A3B8;

    /* Border */
    --border: #E2E8F0;

    /* Intent Colors */
    --primary-500: #14B8A6;      /* Teal - Brand Primary */
    --success-500: #10B981;      /* Emerald */
    --danger-500: #EF4444;       /* Red */
    --warning-500: #F59E0B;      /* Amber */

    /* RGB Variants (for alpha blending) */
    --kitamo-brand: 20 184 166;
    --kitamo-brand-dark: 15 118 110;
    --kitamo-brand-light: 153 246 228;
    --kitamo-success: 16 185 129;
    --kitamo-warning: 245 158 11;
    --kitamo-danger: 239 68 68;
    --kitamo-ink: 15 23 42;
    --kitamo-body: 71 85 105;
    --kitamo-surface: 255 255 255;
    --kitamo-bg: 248 250 252;

    /* Motion */
    --motion-fast: 180ms;
    --motion-base: 300ms;
    --motion-slow: 480ms;
    --motion-ease: cubic-bezier(0.2, 0.8, 0.2, 1);
}
```

### Dark Mode
Toggle via `data-theme="dark"` attribute on `<html>`:

```css
[data-theme='dark'] {
    --bg-page: #0F172A;
    --bg-section: #1E293B;
    --bg-card: #334155;
    --bg-input: #475569;
    --text-primary: #F8FAFC;
    --text-secondary: #CBD5E1;
    --text-tertiary: #94A3B8;
    --text-disabled: #64748B;
    --border: #475569;
}
```

### Using Tokens
Reference tokens in CSS/Tailwind:
```css
background-color: var(--bg-card);
border: 1px solid var(--border);
```

For alpha blending with RGB tokens:
```css
background-color: rgb(var(--kitamo-brand) / 0.2);
color-mix(in srgb, var(--bg-card), transparent 10%);
```

---

## 3. Typography

### Font Stack
**Primary:** Plus Jakarta Sans
**Fallback:** Figtree, system fonts

```js
// tailwind.config.js
fontFamily: {
    sans: ['"Plus Jakarta Sans"', 'Figtree', ...defaultTheme.fontFamily.sans],
}
```

### Text Scales (Tailwind)
- Headings: `text-4xl`, `text-3xl`, `text-2xl`, `text-xl`
- Body: `text-base`, `text-sm`, `text-xs`
- Font weights: `font-bold` (700), `font-semibold` (600), `font-medium` (500)

---

## 4. Color Palette

### Brand Colors
| Name | Hex | Usage |
|------|-----|-------|
| Teal 500 | `#14B8A6` | Primary brand, CTAs |
| Teal 700 | `#0F766E` | Hover states |
| Teal 50/100 | Light tints | Backgrounds |

### Status Colors
| Status | Color | Tailwind |
|--------|-------|----------|
| Success | `#10B981` | `emerald-500` |
| Warning | `#F59E0B` | `amber-500` |
| Danger | `#EF4444` | `red-500` |
| Info | `#14B8A6` | `teal-500` |

### Neutral Scale
Use Tailwind's `slate` palette:
- Text: `slate-900`, `slate-700`, `slate-500`, `slate-400`
- Backgrounds: `slate-50`, `slate-100`, `slate-200`
- Borders: `slate-200`, `slate-300`

---

## 5. Spacing & Layout

### Spacing Scale
Use Tailwind's default spacing (4px base):
- `gap-2` (8px), `gap-4` (16px), `gap-6` (24px), `gap-8` (32px)
- `p-4`, `p-6`, `px-6 py-3` for buttons
- `space-y-4`, `space-y-6` for vertical stacks

### Border Radius
| Usage | Value | Class |
|-------|-------|-------|
| Buttons | 16px | `rounded-2xl` |
| Cards | 32px | `rounded-[32px]` |
| Badges | Full | `rounded-full` |
| Inputs | 8px | `rounded-lg` |
| Phone mockup | 44px | `rounded-[44px]` |

### Container Widths
- Max content width: `max-w-7xl`
- Modal sizes: `sm:max-w-sm` to `sm:max-w-6xl`

---

## 6. Component Patterns

### Button Styles

**Primary Button**
```css
.btn-primary {
    @apply inline-flex items-center justify-center gap-2 rounded-2xl
           bg-teal-500 px-6 py-3 font-bold text-white
           shadow-[0_10px_15px_-3px_rgba(20,184,166,0.30)]
           transition active:scale-95 hover:bg-teal-700;
}
```

**Outline Button**
```css
.btn-outline {
    @apply inline-flex items-center justify-center gap-2 rounded-2xl
           border-2 border-slate-200 bg-white/70 px-6 py-3 font-bold
           text-slate-700 transition active:scale-95 hover:bg-white;
}
```

### Card Styles
```css
.card-kitamo {
    @apply rounded-[32px] shadow-sm transition;
    background-color: var(--bg-card);
    border: 1px solid var(--border);
}

.card-kitamo-hover {
    @apply hover:-translate-y-1 hover:border-teal-500
           hover:shadow-[0_20px_40px_-5px_rgba(0,0,0,0.10)];
}
```

### Status Badge Pattern
```vue
<!-- resources/js/Components/StatusBadge.vue -->
<span class="inline-flex items-center gap-2 rounded-full px-3 py-1 text-xs font-medium"
      :class="resolved.cls">
    <span class="h-2 w-2 rounded-full" :class="resolved.dot"></span>
    <span>{{ resolved.label }}</span>
</span>
```

Variants:
- `active`: `bg-emerald-100 text-emerald-700` + `bg-emerald-500` dot
- `pending`: `bg-amber-100 text-amber-700` + `bg-amber-500` dot
- `error`: `bg-red-100 text-red-700` + `bg-red-500` dot
- `inactive`: `bg-slate-100 text-slate-700` + `bg-slate-400` dot

### Modal Pattern
```vue
<!-- Uses native <dialog> element -->
<dialog class="z-50 m-0 min-h-full min-w-full overflow-y-auto bg-transparent">
    <div class="fixed inset-0 z-50 overflow-y-auto px-4 py-6 sm:px-0">
        <!-- Backdrop with transition -->
        <div class="absolute inset-0 bg-gray-500 opacity-75" />
        <!-- Content panel -->
        <div class="rounded-lg bg-white shadow-xl sm:mx-auto sm:w-full" :class="maxWidthClass">
            <slot />
        </div>
    </div>
</dialog>
```

### Glass Navigation
```css
.glass-nav {
    background-color: color-mix(in srgb, var(--bg-card), transparent 10%);
    border-bottom: 1px solid color-mix(in srgb, var(--border), transparent 40%);
    backdrop-filter: blur(10px);
}
```

---

## 7. Animation & Motion

### Motion Tokens
```css
--motion-fast: 180ms;
--motion-base: 300ms;
--motion-slow: 480ms;
--motion-ease: cubic-bezier(0.2, 0.8, 0.2, 1);
```

### Scroll-triggered Animations
Use `MotionSection` wrapper (`resources/js/Components/site/MotionSection.vue`):

```vue
<MotionSection class="py-24 bg-slate-50">
    <h2>Content fades in + slides up on scroll</h2>
</MotionSection>
```

Features:
- 15% intersection threshold
- Respects `prefers-reduced-motion`
- Skips animation for bots/test frameworks

### Standard Transitions
```css
/* Button press */
@apply transition active:scale-95;

/* Card hover lift */
@apply transition hover:-translate-y-1;

/* Fade in/out */
enter-active-class="ease-out duration-300"
enter-from-class="opacity-0"
enter-to-class="opacity-100"
```

### Custom Keyframes
```css
@keyframes kitamo-float {
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(-20px); }
}

@keyframes kitamo-marquee {
    from { transform: translateX(0); }
    to { transform: translateX(-50%); }
}
```

---

## 8. Responsive Design

### Breakpoints (Tailwind defaults)
| Prefix | Min-width |
|--------|-----------|
| `sm:` | 640px |
| `md:` | 768px |
| `lg:` | 1024px |
| `xl:` | 1280px |

### Mobile Detection Hook
```ts
// resources/js/composables/useIsMobile.ts
export const useIsMobile = () =>
    useMediaQuery(
        '(max-width: 767px), ((hover: none) and (pointer: coarse) and (orientation: portrait))'
    );
```

### Responsive Patterns
```vue
<!-- Hide on mobile, show on desktop -->
<nav class="hidden lg:flex">...</nav>

<!-- Show on mobile, hide on desktop -->
<button class="lg:hidden">Menu</button>

<!-- Responsive grid -->
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
```

---

## 9. Icon System

### Strategy
- **Primary:** Inline SVG paths (no icon library)
- **Videos:** Lucide React icons (Remotion project)

### SVG Icon Pattern
```vue
<svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
          d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
</svg>
```

### Category Icons
`resources/js/Components/CategoryIcon.vue` maps category keys to icons:
- `food`, `home`, `car`, `gym`, `cart`, `money`, `other`

### Bank Logos
`resources/js/lib/bankLogos.ts` provides:
```ts
getBankLogo(bankName)     // { svgFile, color }
getBankSvgPath(bankName)  // SVG path string
getBankColor(bankName)    // Brand color hex
```

---

## 10. Project Structure

```
/home/gabfelix/kitamo/
├── resources/
│   ├── css/
│   │   └── app.css              # Global styles, tokens, components
│   └── js/
│       ├── app.ts               # Entry point
│       ├── Components/          # 68 Vue components
│       │   ├── site/            # Public site components
│       │   ├── *Modal.vue       # Modal components
│       │   └── *Sheet.vue       # Mobile sheet components
│       ├── Layouts/             # Layout wrappers
│       ├── Pages/               # Inertia pages
│       │   ├── Site/            # Public pages (Home, Pricing, etc.)
│       │   ├── Auth/            # Authentication
│       │   ├── Accounts/        # Account management
│       │   ├── Goals/           # Financial goals
│       │   └── ...
│       ├── composables/         # Vue composition hooks
│       ├── lib/                 # Utilities (bankLogos, moneyInput, etc.)
│       ├── stores/              # Client-side state
│       └── types/               # TypeScript definitions
├── public/
│   ├── videos/                  # MP4 video assets
│   └── Bancos-em-SVG-main/      # Bank institution logos
├── Kitamo/                      # Remotion video project (React)
├── tailwind.config.js
├── vite.config.js
└── tsconfig.json
```

---

## 11. Component Architecture

### Vue SFC Pattern
```vue
<script setup lang="ts">
import { computed, ref } from 'vue';

const props = withDefaults(
    defineProps<{
        variant: 'primary' | 'secondary';
        disabled?: boolean;
    }>(),
    {
        disabled: false,
    }
);

const emit = defineEmits<{
    click: [event: MouseEvent];
}>();
</script>

<template>
    <button :class="[...]" :disabled="disabled" @click="emit('click', $event)">
        <slot />
    </button>
</template>
```

### Type Definitions
`resources/js/types/kitamo.ts`:
```ts
type Entry = {
    id: string;
    title: string;
    amount: number;
    kind: 'expense' | 'income';
    status: 'paid' | 'pending' | 'received';
    icon: 'gym' | 'home' | 'cart' | 'money' | 'car' | string;
    categoryKey: 'food' | 'home' | 'car' | 'other' | string;
    tags: string[];
    // ...
};

type Account = { id, name, type, current_balance, institution, ... };
type Goal = { id, title, target, current, status, deposits[], ... };
type Category = { id, name, type, color, icon, ... };
```

---

## 12. Tailwind Safelist

Dynamic classes that must be preserved:

```js
// tailwind.config.js
safelist: [
    ...['teal', 'emerald', 'amber', 'cyan'].flatMap(c => [
        `bg-${c}-50`, `bg-${c}-100`, `bg-${c}-400`, `bg-${c}-500`,
        `bg-${c}-500/10`, `bg-${c}-500/20`,
        `text-${c}-400`, `text-${c}-500`,
        `border-${c}-500/20`,
        `group-hover:bg-${c}-100`, `group-hover:bg-${c}-500/20`,
        `group-hover:text-${c}-300`,
    ]),
]
```

---

## 13. Accessibility

### Focus States
```css
:where(input, textarea, select, button, a):focus-visible {
    outline: 2px solid rgb(var(--kitamo-brand));
    outline-offset: 2px;
}
```

### Reduced Motion
```css
@media (prefers-reduced-motion: reduce) {
    .site-motion-inner {
        opacity: 1 !important;
        transform: none !important;
        transition: none !important;
    }
}
```

### Headless UI
Use `@headlessui/vue` for accessible dialogs/dropdowns:
- `Dialog`, `DialogPanel` for modals
- `TransitionRoot`, `TransitionChild` for animations

---

## 14. Figma Integration Guidelines

### When translating Figma designs:

1. **Map Figma colors to tokens:**
   - Brand teal → `--primary-500` / `bg-teal-500`
   - Text colors → `--text-primary`, `--text-secondary`, etc.
   - Backgrounds → `--bg-card`, `--bg-section`

2. **Use existing component classes:**
   - Buttons → `.btn-primary`, `.btn-outline`
   - Cards → `.card-kitamo`, `.card-kitamo-hover`
   - Badges → StatusBadge component

3. **Radius mapping:**
   - Small elements → `rounded-lg` (8px)
   - Buttons → `rounded-2xl` (16px)
   - Cards → `rounded-[32px]`

4. **Shadow mapping:**
   - Subtle → `shadow-sm`
   - Button glow → `shadow-[0_10px_15px_-3px_rgba(20,184,166,0.30)]`
   - Card hover → `shadow-[0_20px_40px_-5px_rgba(0,0,0,0.10)]`

5. **Prefer existing patterns:**
   - Check `resources/js/Components/` for similar components
   - Use composition hooks from `composables/`
   - Follow TypeScript patterns from `types/kitamo.ts`

---

## 15. Quick Reference

### Common Classes
```html
<!-- Primary button -->
<button class="btn-primary">Action</button>

<!-- Outline button -->
<button class="btn-outline">Secondary</button>

<!-- Card -->
<div class="card-kitamo card-kitamo-hover p-6">Content</div>

<!-- Glass nav -->
<nav class="glass-nav sticky top-0 z-50">...</nav>

<!-- Section with motion -->
<MotionSection class="py-24">Content</MotionSection>

<!-- Responsive hide/show -->
<div class="hidden lg:block">Desktop only</div>
<div class="lg:hidden">Mobile only</div>
```

### Import Aliases
```ts
import { useIsMobile } from '@/composables/useIsMobile';
import { getBankLogo } from '@/lib/bankLogos';
import type { Entry, Account, Goal } from '@/types/kitamo';
```

---

*Last updated: 2026-02-24*
