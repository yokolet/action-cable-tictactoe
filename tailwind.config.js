/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./app/views/layouts/application.html.erb",
    "./app/frontend/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        darkBlue: 'rgb(67,82,114)',
        veryDarkBlue: 'rgb(17,66,83)',
        cornYellow: 'rgb(251,201,108)',
        deepBeige: 'rgb(253,213,156)',
        beige: 'rgb(249,233,209)',
        lightGreen: 'rgb(230,212,111)',
        mediumGreen: 'rgb(33,164,143)',
        teaGreen: 'rgb(174,160,69)',
        lightBlue: 'rgb(147,204,190)',
        veryLightBlue: 'rgb(241,246,249)',
        deepOrange: 'rgb(243,152,103)',
      },
      fontFamily: {
        josefin: ['Josefin Sans', 'sans-serif'],
        josefinSlab: ['Josefin Slab', 'monospace'],
        raleway: ['Raleway', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
