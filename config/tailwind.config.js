const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      colors: {
        "tp-sky-blue": "#2A8FE6",
        "tp-white": "#FFFFFF",
        "tp-deep-sky-blue": "#1F73B3",
        "tp-light-sea-blue": "#CAF4FA",
        "tp-deep-sea-blue": "#103E5B",
        "tp-gentle-teal": "#A7E6ED",
        "tp-midnight-teal": "#1B2D39",
        "tp-soft-gray": "#F8F9FA",
        "tp-super-light-aqua": "#EAF8FB",
        "tp-super-light-red": "#FDECEC",
        "tp-light-red": "#FFD6D6",
        "tp-red": "#D93F3F",
        "tp-deep-red": "#B71C1C",
        "tp-light-green": "#E8F5E9",
        "tp-deep-green": "#1B5E20"
      },
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}
