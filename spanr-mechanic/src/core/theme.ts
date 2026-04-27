import type { MantineThemeOverride } from '@mantine/core';
import { createTheme } from '@mantine/core';

export const theme: MantineThemeOverride = createTheme({
  primaryColor: 'orange',
  colors: {
    orange: [
      '#FFF5EC',
      '#FFE8D6',
      '#FFD4BA',
      '#FFC09E',
      '#FFAC82',
      '#FF6B35',
      '#E65A2B',
      '#CC4922',
      '#B33818',
      '#99270F',
    ],
    cream: [
      '#FFFBF7',
      '#FFF5EC',
      '#FFEFD9',
      '#FFE9C6',
      '#FFE3B3',
      '#FFDDA0',
      '#E6C690',
      '#CCAF80',
      '#B39870',
      '#998160',
    ],
  },
  defaultRadius: 'md',
  fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
  headings: {
    fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
    fontWeight: '700',
  },
  components: {
    Container: {
      defaultProps: {
        sizes: {
          xs: 540,
          sm: 720,
          md: 960,
          lg: 1140,
          xl: 1320,
        },
      },
    },
    Paper: {
      defaultProps: {
        radius: 'md',
        shadow: 'sm',
      },
      styles: {
        root: {
          backgroundColor: '#FFFFFF',
        },
      },
    },
    Card: {
      defaultProps: {
        radius: 'md',
        shadow: 'sm',
      },
      styles: {
        root: {
          backgroundColor: '#FFFFFF',
          transition: 'transform 0.2s ease, box-shadow 0.2s ease',
          '&:hover': {
            transform: 'translateY(-2px)',
            boxShadow: '0 4px 12px rgba(0, 0, 0, 0.1)',
          },
        },
      },
    },
    Button: {
      defaultProps: {
        radius: 'md',
      },
      styles: {
        root: {
          fontWeight: 600,
        },
      },
    },
    TextInput: {
      defaultProps: {
        radius: 'md',
      },
      styles: {
        input: {
          backgroundColor: '#F8F8F8',
          border: '1px solid #E0E0E0',
          '&:focus': {
            borderColor: '#FF6B35',
          },
        },
      },
    },
    Select: {
      defaultProps: {
        radius: 'md',
      },
      styles: {
        input: {
          backgroundColor: '#F8F8F8',
          border: '1px solid #E0E0E0',
          '&:focus': {
            borderColor: '#FF6B35',
          },
        },
      },
    },
    Badge: {
      defaultProps: {
        radius: 'sm',
      },
      styles: {
        root: {
          fontWeight: 600,
          textTransform: 'capitalize',
        },
      },
    },
    ActionIcon: {
      defaultProps: {
        radius: 'md',
      },
    },
  },
});

