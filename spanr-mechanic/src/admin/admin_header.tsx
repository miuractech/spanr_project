import { Group, Text, Menu, Avatar, UnstyledButton, Modal, Button, Burger } from '@mantine/core';
import { useState } from 'react';
import { IconChevronDown, IconLogout, IconTool } from '@tabler/icons-react';
import { useAuth } from '../auth/auth.hook';
import { useNavigate } from 'react-router-dom';
import { adminService } from './admin.service';

interface AdminHeaderProps {
  burgerOpened: boolean;
  onBurgerToggle: () => void;
}

export const AdminHeader = ({ burgerOpened, onBurgerToggle }: AdminHeaderProps) => {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [logoutModalOpen, setLogoutModalOpen] = useState(false);
  const [isLoggingOut, setIsLoggingOut] = useState(false);

  const handleLogout = async () => {
    setIsLoggingOut(true);
    try {
      await adminService.signOut();
      navigate('/admin/login', { replace: true });
    } catch (error) {
      console.error('Logout failed:', error);
      setIsLoggingOut(false);
    }
  };

  const displayName = user?.name || user?.email || 'Admin';
  const initial = displayName[0]?.toUpperCase() || 'A';

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
          <IconTool size={22} color="#FC8019" />
          <div>
            <Text size="lg" fw={700} lh={1.2} c="#1C1C1C">
              SPANR
            </Text>
            <Text size="xs" c="#FC8019" fw={600}>
              Super Admin
            </Text>
          </div>
        </Group>

        <Menu shadow="md" width={220} radius="md">
          <Menu.Target>
            <UnstyledButton style={{ padding: '6px 12px', borderRadius: 12 }}>
              <Group gap="xs">
                <Avatar
                  color="orange"
                  radius="xl"
                  size="sm"
                  style={{ border: '2px solid #FFF3E0' }}
                >
                  {initial}
                </Avatar>
                <div>
                  <Text size="sm" fw={600} c="#1C1C1C">
                    {displayName}
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
          <Button color="red" onClick={handleLogout} loading={isLoggingOut}>
            Logout
          </Button>
        </Group>
      </Modal>
    </>
  );
};
