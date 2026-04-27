import { notifications } from '@mantine/notifications';

export const useNotification = () => {
  const showSuccess = (message: string, title = 'Success') => {
    notifications.show({
      title,
      message,
      color: 'green',
      autoClose: 3000,
    });
  };

  const showError = (message: string, title = 'Error') => {
    notifications.show({
      title,
      message,
      color: 'red',
      autoClose: 5000,
    });
  };

  const showInfo = (message: string, title = 'Info') => {
    notifications.show({
      title,
      message,
      color: 'blue',
      autoClose: 3000,
    });
  };

  const showWarning = (message: string, title = 'Warning') => {
    notifications.show({
      title,
      message,
      color: 'yellow',
      autoClose: 4000,
    });
  };

  return {
    showSuccess,
    showError,
    showInfo,
    showWarning,
  };
};

