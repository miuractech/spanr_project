import { NavLink } from 'react-router-dom';
import { Stack, Text } from '@mantine/core';
import { IconClipboardCheck } from '@tabler/icons-react';

const links = [
  { to: '/admin', label: 'Shop approval', icon: IconClipboardCheck },
];

export const AdminSidebar = () => {
  return (
    <Stack
      gap={4}
      p="md"
      style={{
        height: '100%',
        backgroundColor: '#FFFFFF',
        borderRight: '1px solid #E0E0E0',
      }}
    >
      <Text size="xs" fw={700} c="#696969" tt="uppercase" px="sm" mb={8} mt={4}>
        SPANR Admin
      </Text>
      {links.map((link) => {
        const Icon = link.icon;
        return (
          <NavLink
            key={link.to}
            to={link.to}
            style={({ isActive }) => ({
              display: 'flex',
              alignItems: 'center',
              gap: '12px',
              padding: '10px 14px',
              borderRadius: '12px',
              textDecoration: 'none',
              color: isActive ? '#FC8019' : '#696969',
              backgroundColor: isActive ? '#FFF3E0' : 'transparent',
              fontWeight: isActive ? 600 : 500,
              fontSize: '14px',
              transition: 'all 0.15s ease',
            })}
          >
            <Icon size={20} stroke={1.8} />
            <Text size="sm" fw="inherit" style={{ color: 'inherit' }}>
              {link.label}
            </Text>
          </NavLink>
        );
      })}
    </Stack>
  );
};
