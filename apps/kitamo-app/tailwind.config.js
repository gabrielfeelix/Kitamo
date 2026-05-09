/** @type {import('tailwindcss').Config} */
module.exports = {
    content: ['./app/**/*.{js,jsx,ts,tsx}', './src/**/*.{js,jsx,ts,tsx}'],
    presets: [require('nativewind/preset')],
    theme: {
        extend: {
            colors: {
                bg: {
                    page: '#F8FAFC',
                    section: '#F1F5F9',
                    card: '#FFFFFF',
                    input: '#FFFFFF',
                },
                ink: {
                    primary: '#0F172A',
                    secondary: '#334155',
                    tertiary: '#64748B',
                    disabled: '#94A3B8',
                },
                border: {
                    DEFAULT: '#E2E8F0',
                },
                brand: {
                    50: '#F1FBF9',
                    100: '#E0F9F5',
                    200: '#B6F0E8',
                    300: '#7CE3D6',
                    400: '#52DCCC',
                    500: '#33D6C5',
                    600: '#28BFAF',
                    700: '#1FB5A4',
                    800: '#0F766E',
                    900: '#0B544D',
                },
                success: {
                    50: '#ECFDF5',
                    500: '#10B981',
                    700: '#047857',
                },
                warning: {
                    50: '#FFFBEB',
                    500: '#F59E0B',
                    700: '#B45309',
                },
                danger: {
                    50: '#FEF2F2',
                    500: '#EF4444',
                    700: '#B91C1C',
                },
            },
            fontFamily: {
                sans: ['System'],
            },
            borderRadius: {
                xl: '12px',
                '2xl': '16px',
                '3xl': '24px',
                card: '12px',
            },
        },
    },
    plugins: [],
};
