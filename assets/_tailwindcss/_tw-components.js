const plugin = require('tailwindcss/plugin');
/**
 * .btn: border-radius, padding, font-weight, font-size, transition
 * .btn-outline: border
 * ## Colors
 * .btn-indigo: text color, bg color, border color, hover:forall
 * .btn-outline-indigo
 */
const components = plugin(function ({ addComponents, matchComponents, theme }) {
  addComponents({
    '.btn': {
      'border-radius': '.25rem',
      padding: '.5rem 3rem',
      'font-weight': 500,
      'font-size': '.875rem',
      'line-height': '1.25rem',
      'transition-property':
        'color, background-color, border-color, text-decoration-color',
      'transition-timing-function': 'cubic-bezier(0.4, 0, 0.2, 1)',
      'transition-duration': '150ms',
    },
    '.btn-outline': {
      '@apply ring-1 ring-inset': {},
    },
    '.divider-text': {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      position: 'relative',
      '&::before': {
        content: '""',
        border: 'lightgray solid 0.5px',
        position: 'absolute',
        width: '100%',
        zIndex: -10,
      },
    },
    '.btn-group': {
      '.btn': {
        padding: '.5rem 1rem',
      },
      ':not(:first-child)': {
        borderTopLeftRadius: 0,
        borderBottomLeftRadius: 0,
      },
      ':not(:last-child)': {
        borderTopRightRadius: 0,
        borderBottomRightRadius: 0,
        borderRightWidth: 0,
      },
    },
  });
  matchComponents(
    {
      btn: (color) => ({
        color: 'white',
        'background-color': color[500],
        '&:hover': {
          'background-color': color[700],
        },
      }),
      'btn-outline': (color) => ({
        '@apply ring-1 ring-inset': {},
        '--tw-ring-opacity': 1,
        '--tw-ring-color': color[500],
        color: color[500],
        '&:hover': {
          color: 'white',
          'background-color': color[500],
        },
      }),
    },
    { values: theme('colors') }
  );
});

module.exports = components;
