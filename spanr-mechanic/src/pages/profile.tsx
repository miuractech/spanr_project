import { useState } from 'react';
import {
  Container,
  Title,
  Paper,
  Stack,
  Group,
  Avatar,
  Text,
  Button,
  Divider,
  Modal,
  Box,
} from '@mantine/core';
import { IconLogout, IconUser, IconMail } from '@tabler/icons-react';
import { useAuth } from '../auth/auth.hook';
import { useNavigate } from 'react-router-dom';

export default function ProfilePage() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const [logoutModalOpen, setLogoutModalOpen] = useState(false);
  const [isLoggingOut, setIsLoggingOut] = useState(false);

  const handleLogout = async () => {
    setIsLoggingOut(true);
    try {
      await logout();
      navigate('/login');
    } catch (error) {
      console.error('Logout failed:', error);
      setIsLoggingOut(false);
    }
  };

  return (
    <Container size="md" py={60}>
      <Title mb={48} size={32} c="#1C1C1C">
        Profile
      </Title>

      <Paper shadow="sm" p={32} radius="lg" style={{ border: '1px solid #E0E0E0' }}>
        <Stack gap={32}>
          <Group>
            <Avatar size={80} radius="xl" color="orange">
              {user?.name?.[0]?.toUpperCase() || 'U'}
            </Avatar>
            <Box>
              <Text size="xl" fw={600}>
                {user?.name}
              </Text>
              <Text size="sm" c="dimmed">
                User Profile
              </Text>
            </Box>
          </Group>

          <Divider />

          <Stack gap={16}>
            <Group gap={12}>
              <IconUser size={20} color="gray" />
              <Box>
                <Text size="xs" c="dimmed" mb={4}>
                  Name
                </Text>
                <Text size="sm" fw={500}>
                  {user?.name}
                </Text>
              </Box>
            </Group>

            <Group gap={12}>
              <IconMail size={20} color="gray" />
              <Box>
                <Text size="xs" c="dimmed" mb={4}>
                  Email
                </Text>
                <Text size="sm" fw={500}>
                  {user?.email}
                </Text>
              </Box>
            </Group>
          </Stack>

          <Divider />

          <Box>
            <Button
              leftSection={<IconLogout size={18} />}
              color="red"
              variant="light"
              onClick={() => setLogoutModalOpen(true)}
              fullWidth
            >
              Logout
            </Button>
          </Box>
        </Stack>
      </Paper>

      <Modal
        opened={logoutModalOpen}
        onClose={() => !isLoggingOut && setLogoutModalOpen(false)}
        title="Confirm Logout"
        centered
        closeOnClickOutside={!isLoggingOut}
        closeOnEscape={!isLoggingOut}
      >
        <Text size="sm" mb={24}>
          Are you sure you want to logout?
        </Text>
        <Group justify="flex-end" gap={12}>
          <Button
            variant="subtle"
            onClick={() => setLogoutModalOpen(false)}
            disabled={isLoggingOut}
          >
            Cancel
          </Button>
          <Button
            color="red"
            onClick={handleLogout}
            loading={isLoggingOut}
          >
            Logout
          </Button>
        </Group>
      </Modal>
    </Container>
  );
}

