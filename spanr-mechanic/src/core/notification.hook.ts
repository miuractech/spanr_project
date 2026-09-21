import { notifications } from '@mantine/notifications';
import { useMemo } from 'react';

export const useNotification = () => {
  return useMemo(
    () => ({
      showSuccess: (message: string, title = 'Success') => {
        notifications.show({
          title,
          message,
          color: 'green',
          autoClose: 3000,
        });
      },
      showError: (message: string, title = 'Error') => {
        notifications.show({
          title,
          message,
          color: 'red',
          autoClose: 5000,
        });
      },
      showInfo: (message: string, title = 'Info') => {
        notifications.show({
          title,
          message,
          color: 'blue',
          autoClose: 3000,
        });
      },
      showWarning: (message: string, title = 'Warning') => {
        notifications.show({
          title,
          message,
          color: 'yellow',
          autoClose: 4000,
        });
      },
    }),
    []
  );
};
