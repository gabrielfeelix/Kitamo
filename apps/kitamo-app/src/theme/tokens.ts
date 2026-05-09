export const KITAMO = {
    brand: '#33D6C5',
    brandDark: '#1FB5A4',
    brandSoft: '#E0F9F5',
    brandTint: '#F1FBF9',
    success: '#10B981',
    successSoft: '#D1FAE5',
    danger: '#EF4444',
    dangerSoft: '#FEE2E2',
    warn: '#F59E0B',
    warnSoft: '#FEF3C7',
    info: '#3B82F6',
    infoSoft: '#DBEAFE',
    ink: '#0F172A',
    ink2: '#475569',
    muted: '#64748B',
    line: '#E2E8F0',
    line2: '#EEF2F6',
    bg: '#F8FAFC',
    white: '#FFFFFF',
} as const;

export const RADIUS = {
    sm: 8,
    md: 12,
    lg: 14,
    xl: 18,
    pill: 999,
} as const;

export const MOTION = {
    fast: 180,
    base: 300,
    slow: 480,
} as const;

export const SHADOW = {
    soft: {
        shadowColor: '#0F172A',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.04,
        shadowRadius: 8,
        elevation: 1,
    },
    card: {
        shadowColor: '#0F172A',
        shadowOffset: { width: 0, height: 8 },
        shadowOpacity: 0.08,
        shadowRadius: 24,
        elevation: 4,
    },
    cta: {
        shadowColor: '#33D6C5',
        shadowOffset: { width: 0, height: 6 },
        shadowOpacity: 0.4,
        shadowRadius: 16,
        elevation: 6,
    },
} as const;
