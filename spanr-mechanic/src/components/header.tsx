import { useState } from 'react';
import { Group, Text, Menu, Avatar, UnstyledButton, Modal, Button } from '@mantine/core';
import { IconChevronDown, IconLogout, IconUser } from '@tabler/icons-react';
import { useAuth } from '../auth/auth.hook';
import { useCompany } from '../company/company.hook';
import { useNavigate } from 'react-router-dom';

export const Header = () => {
  const { user, logout } = useAuth();
  const { company } = useCompany();
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
    <>
      <Group justify="space-between" h="100%" px="md" style={{ borderBottom: '1px solid #E0E0E0' }}>
        <Group>
          {company?.logo && (
            <img src={company.logo} alt={company.company_name} style={{ height: 40 }} />
          )}
          <Text size="xl" fw={700} c="#FF6B35">
            {company?.company_name || 'SPANR'}
          </Text>
        </Group>

        <Menu shadow="md" width={200}>
          <Menu.Target>
            <UnstyledButton>
              <Group gap="xs">
                <Avatar color="orange" radius="xl">
                  {user?.name?.[0]?.toUpperCase() || 'U'}
                </Avatar>
                <div>
                  <Text size="sm" fw={500}>
                    {user?.name}
                  </Text>
                  <Text size="xs" c="dimmed">
                    {user?.email}
                  </Text>
                </div>
                <IconChevronDown size={16} />
              </Group>
            </UnstyledButton>
          </Menu.Target>

          <Menu.Dropdown>
            <Menu.Item
              leftSection={<IconUser size={14} />}
              onClick={() => navigate('/profile')}
            >
              Profile
            </Menu.Item>
            <Menu.Item
              leftSection={<IconLogout size={14} />}
              onClick={() => setLogoutModalOpen(true)}
              color="red"
            >
              Logout
            </Menu.Item>
          </Menu.Dropdown>
        </Menu>
      </Group>

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
    </>
  );
};

