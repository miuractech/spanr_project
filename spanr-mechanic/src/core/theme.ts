import type { MantineThemeOverride } from '@mantine/core';
import { createTheme } from '@mantine/core';

export const theme: MantineThemeOverride = createTheme({
  primaryColor: 'orange',
  colors: {
    orange: [
      '#FFF3E0',
      '#FFE5C0',
      '#FFD7A0',
      '#FFC880',
      '#FFB960',
      '#FFAA40',
      '#FC8019',
      '#E06E0A',
      '#C05D00',
      '#9A4B00',
    ],
    green: [
      '#E8F5E9',
      '#C8E6C9',
      '#A5D6A7',
      '#81C784',
      '#66BB6A',
      '#4CAF50',
      '#267E3E',
      '#1B5E2F',
      '#134A23',
      '#0C3618',
    ],
  },
  defaultRadius: 'lg',
  fontFamily: 'Inter, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
  headings: {
    fontFamily: 'Inter, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
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
        radius: 'lg',
        shadow: 'xs',
      },
      styles: {
        root: {
          backgroundColor: '#FFFFFF',
        },
      },
    },
    Card: {
      defaultProps: {
        radius: 'lg',
        shadow: 'xs',
      },
      styles: {
        root: {
          backgroundColor: '#FFFFFF',
          transition: 'box-shadow 0.2s ease',
          '&:hover': {
            boxShadow: '0 4px 16px rgba(0, 0, 0, 0.08)',
          },
        },
      },
    },
    Button: {
      defaultProps: {
        radius: 'xl',
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
          backgroundColor: '#FFFFFF',
          border: '1.5px solid #E0E0E0',
          '&:focus': {
            borderColor: '#FC8019',
          },
        },
      },
    },
    PasswordInput: {
      defaultProps: {
        radius: 'md',
      },
      styles: {
        input: {
          backgroundColor: '#FFFFFF',
          border: '1.5px solid #E0E0E0',
          '&:focus': {
            borderColor: '#FC8019',
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
          backgroundColor: '#FFFFFF',
          border: '1.5px solid #E0E0E0',
          '&:focus': {
            borderColor: '#FC8019',
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
    Tabs: {
      styles: {
        tab: {
          fontWeight: 500,
          '&[data-active]': {
            borderColor: '#FC8019',
            color: '#FC8019',
          },
        },
      },
    },
    Modal: {
      defaultProps: {
        radius: 'lg',
      },
    },
    Stepper: {
      styles: {
        stepIcon: {
          '&[data-completed]': {
            backgroundColor: '#FC8019',
            borderColor: '#FC8019',
          },
          '&[data-progress]': {
            borderColor: '#FC8019',
          },
        },
      },
    },
  },
});
