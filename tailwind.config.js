/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./app/views/layouts/application.html.erb",
    "./app/frontend/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
