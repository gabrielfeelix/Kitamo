import defaultTheme from 'tailwindcss/defaultTheme';
import forms from '@tailwindcss/forms';

/** @type {import('tailwindcss').Config} */
export default {
    content: [
        './vendor/laravel/framework/src/Illuminate/Pagination/resources/views/*.blade.php',
        './storage/framework/views/*.php',
        './resources/views/**/*.blade.php',
        './resources/js/**/*.vue',
    ],

    safelist: [
        // Dynamic accent colors used in Company, Product, Pricing pages
        ...['teal', 'emerald', 'amber', 'cyan'].flatMap(c => [
            `bg-${c}-50`, `bg-${c}-100`, `bg-${c}-400`, `bg-${c}-500`,
            `bg-${c}-500/10`, `bg-${c}-500/20`,
            `text-${c}-400`, `text-${c}-500`,
            `border-${c}-500/20`,
            `group-hover:bg-${c}-100`, `group-hover:bg-${c}-500/20`,
            `group-hover:text-${c}-300`,
        ]),
    ],

    theme: {
        extend: {
            fontFamily: {
                sans: [
                    '"Plus Jakarta Sans"',
                    'Figtree',
                    ...defaultTheme.fontFamily.sans,
                ],
            },
        },
    },

    plugins: [forms],
};
