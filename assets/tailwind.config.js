// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration
module.exports = {
  content: [
    './js/**/*.{js,ts,tsx}',
    '../lib/*_web.ex',
    '../lib/*_web/**/*.*ex',
  ],
  theme: {
    container: {
      center: true,
      padding: '2rem',
    },
    extend: {
      animation: {
        wiggle: 'wiggle 1s ease-in-out infinite',
        jello: 'jello 1s linear',
        tada: 'tada 1s linear',
        bounce2: 'bounce2 1s linear infinite',
        rubberBand: 'rubberBand 1s linear infinite',
        flip: 'flip 1s linear infinite',
        hinge: 'hinge 2s linear',
        pulse2: 'pulse2 1s ease-in-out infinite',
        flash: 'flash 1s linear infinite',
      },
      keyframes: {
        wiggle: {
          '0%, 100%': { transform: 'rotate(-3deg)' },
          '50%': { transform: 'rotate(3deg)' },
        },
        jello: {
          '0%, 11.1%, 100%': { transform: 'translate3d(0, 0, 0)' },
          '22.2%': { transform: 'skewX(-12.5deg) skewY(-12.5deg)' },
          '33.3%': { transform: 'skewX(6.25deg) skewY(6.25deg)' },
          '44.4%': { transform: 'skewX(-3.125deg) skewY(-3.125deg)' },
          '55.5%': { transform: 'skewX(1.5625deg) skewY(1.5625deg)' },
          '66.6%': { transform: 'skewX(-0.78125deg) skewY(-0.78125deg)' },
          '77.7%': { transform: 'skewX(0.390625deg) skewY(0.390625deg)' },
          '88.8%': { transform: 'skewX(-0.1953125deg) skewY(-0.1953125deg)' },
        },
        tada: {
          '0%, 100%': { transform: 'scale3d(1, 1, 1)' },
          '10%, 20%': {
            transform: 'scale3d(0.9, 0.9, 0.9) rotate3d(0, 0, 1, -3deg)',
          },
          '30%, 50%, 70%, 90%': {
            transform: 'scale3d(1.1, 1.1, 1.1) rotate3d(0, 0, 1, 3deg)',
          },
          '40%, 60%, 80%': {
            transform: 'scale3d(1.1, 1.1, 1.1) rotate3d(0, 0, 1, -3deg)',
          },
        },
        bounce2: {
          '0%, 20%, 53%, 100%': {
            animationTimingFunction: 'cubic-bezier(0.215, 0.61, 0.355, 1)',
            transform: 'translate3d(0, 0, 0)',
          },
          '40%, 43%': {
            animationTimingFunction: 'cubic-bezier(0.755, 0.05, 0.855, 0.06)',
            transform: 'translate3d(0, -30px, 0) scaleY(1.1)',
          },
          '70%': {
            animationTimingFunction: 'cubic-bezier(0.755, 0.05, 0.855, 0.06)',
            transform: 'translate3d(0, -15px, 0) scaleY(1.05)',
          },
          '80%': {
            transitionTimingFunction: 'cubic-bezier(0.215, 0.61, 0.355, 1)',
            transform: 'translate3d(0, 0, 0) scaleY(0.95)',
          },
          '90%': {
            transform: 'translate3d(0, -4px, 0) scaleY(1.02)',
          },
        },
        rubberBand: {
          '0% 100%': {
            transform: 'scale3d(1, 1, 1)',
          },
          '30%': {
            transform: 'scale3d(1.25, 0.75, 1)',
          },
          '40%': {
            transform: 'scale3d(0.75, 1.25, 1)',
          },
          '50%': {
            transform: 'scale3d(1.15, 0.85, 1)',
          },
          '65%': {
            transform: 'scale3d(0.95, 1.05, 1)',
          },
          '75%': {
            transform: 'scale3d(1.05, 0.95, 1)',
          },
        },
        flip: {
          from: {
            transform:
              'perspective(400px) scale3d(1, 1, 1) translate3d(0, 0, 0) rotate3d(0, 1, 0, -360deg)',
            animationTimingFunction: 'ease-out',
          },
          '40%': {
            transform:
              'perspective(400px) scale3d(1, 1, 1) translate3d(0, 0, 150px) rotate3d(0, 1, 0, -190deg)',
            animationTimingFunction: 'ease-out',
          },
          '50%': {
            transform:
              'perspective(400px) scale3d(1, 1, 1) translate3d(0, 0, 150px) rotate3d(0, 1, 0, -170deg)',
            animationTimingFunction: 'ease-in',
          },
          '80%': {
            transform:
              'perspective(400px) scale3d(0.95, 0.95, 0.95) translate3d(0, 0, 0) rotate3d(0, 1, 0, 0deg)',
            animationTimingFunction: 'ease-in',
          },
          to: {
            transform:
              'perspective(400px) scale3d(1, 1, 1) translate3d(0, 0, 0) rotate3d(0, 1, 0, 0deg)',
            animationTimingFunction: 'ease-in',
          },
        },
        hinge: {
          '0%': {
            animationTimingFunction: 'ease-in-out',
          },
          '20%, 60%': {
            transform: 'rotate3d(0, 0, 1, 80deg)',
            animationTimingFunction: 'ease-in-out',
          },
          '40%, 80%': {
            transform: 'rotate3d(0, 0, 1, 60deg)',
            animationTimingFunction: 'ease-in-out',
            opacity: 1,
          },
          to: {
            transform: 'translate3d(0, 700px, 0)',
            opacity: 0,
          },
        },
        pulse2: {
          '0%, 100%': {
            transform: 'scale3d(1, 1, 1)',
          },
          '50%': {
            transform: 'scale3d(1.05, 1.05, 1.05)',
          },
        },
        flash: {
          '0%,50%,100%': {
            opacity: 1,
          },
          '25%,75%': {
            opacity: 0,
          },
        },
      },
    },
  },
  plugins: [require('@tailwindcss/forms')],
};
