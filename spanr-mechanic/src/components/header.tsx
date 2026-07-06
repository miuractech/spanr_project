import { useState } from 'react';
import { Group, Text, Menu, Avatar, UnstyledButton, Modal, Button, Burger } from '@mantine/core';
import { IconChevronDown, IconLogout, IconUser } from '@tabler/icons-react';
import { useAuth } from '../auth/auth.hook';
import { useCompany } from '../company/company.hook';
import { useNavigate } from 'react-router-dom';

interface HeaderProps {
  burgerOpened: boolean;
  onBurgerToggle: () => void;
}

export const Header = ({ burgerOpened, onBurgerToggle }: HeaderProps) => {
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
      <Group
        justify="space-between"
        h="100%"
        px="lg"
        style={{
          backgroundColor: '#FFFFFF',
          borderBottom: '1px solid #E0E0E0',
        }}
      >
        <Group gap="sm">
          <Burger
            opened={burgerOpened}
            onClick={onBurgerToggle}
            hiddenFrom="sm"
            size="sm"
            color="#1C1C1C"
          />
          {company?.logo && (
            <img
              src={company.logo}
              alt={company.company_name}
              style={{ height: 36, borderRadius: 8 }}
            />
          )}
          <Text size="lg" fw={700} c="#1C1C1C">
            {company?.company_name || 'SPANR'}
          </Text>
        </Group>

        <Menu shadow="md" width={200} radius="md">
          <Menu.Target>
            <UnstyledButton
              style={{
                padding: '6px 12px',
                borderRadius: 12,
                transition: 'background-color 0.15s',
              }}
            >
              <Group gap="xs">
                <Avatar
                  color="orange"
                  radius="xl"
                  size="sm"
                  style={{ border: '2px solid #FFF3E0' }}
                >
                  {user?.name?.[0]?.toUpperCase() || 'U'}
                </Avatar>
                <div>
                  <Text size="sm" fw={600} c="#1C1C1C">
                    {user?.name}
                  </Text>
                  <Text size="xs" c="#696969">
                    {user?.email}
                  </Text>
                </div>
                <IconChevronDown size={14} color="#696969" />
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
        <Text size="sm" mb={24} c="#696969">
          Are you sure you want to logout?
        </Text>
        <Group justify="flex-end" gap={12}>
          <Button
            variant="subtle"
            color="gray"
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
