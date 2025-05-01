/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{astro,html,js,jsx,ts,tsx}', './public/**/*.html'],
  theme: {
    extend: {
      colors: {
        background: '#fbf3e4',
        surface: '#ffffff',
        text: '#1f2937',
        primary: '#0f766e',
        secondary: '#6b7280'
      }
    }
  },
  plugins: []
};
