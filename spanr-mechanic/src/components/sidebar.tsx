import { NavLink } from 'react-router-dom';
import { Stack, Text } from '@mantine/core';
import {
  IconDashboard,
  IconBuilding,
  IconClipboardList,
  IconShoppingCart,
  IconUsers,
  IconUser,
  IconHistory,
  IconListDetails,
} from '@tabler/icons-react';

const links = [
  { to: '/dashboard', label: 'Dashboard', icon: IconDashboard },
  { to: '/company-profile', label: 'Shop Profile', icon: IconBuilding },
  { to: '/services', label: 'Services', icon: IconListDetails },
  { to: '/plans', label: 'Plans', icon: IconClipboardList },
  { to: '/orders', label: 'Orders', icon: IconShoppingCart },
  { to: '/staff', label: 'Staff', icon: IconUsers },
  { to: '/vehicle-history', label: 'Vehicle History', icon: IconHistory },
  { to: '/profile', label: 'Profile', icon: IconUser },
];

export const Sidebar = () => {
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
