import { NavLink } from 'react-router-dom';
import { Stack } from '@mantine/core';
import {
  IconDashboard,
  IconBuilding,
  IconTools,
  IconClipboardList,
  IconShoppingCart,
  IconUsers,
  IconUser,
} from '@tabler/icons-react';

const links = [
  { to: '/dashboard', label: 'Dashboard', icon: IconDashboard },
  { to: '/company-profile', label: 'Company Profile', icon: IconBuilding },
  { to: '/services', label: 'Services & Plans', icon: IconTools },
  { to: '/orders', label: 'Orders', icon: IconShoppingCart },
  { to: '/staff', label: 'Staff', icon: IconUsers },
  { to: '/profile', label: 'Profile', icon: IconUser },
];

export const Sidebar = () => {
  return (
    <Stack gap="xs" p="md">
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
              padding: '12px 16px',
              borderRadius: '8px',
              textDecoration: 'none',
              color: isActive ? '#FFFFFF' : '#495057',
              backgroundColor: isActive ? '#FF6B35' : 'transparent',
              fontWeight: isActive ? 600 : 400,
              transition: 'all 0.2s',
            })}
          >
            <Icon size={20} />
            <span>{link.label}</span>
          </NavLink>
        );
      })}
    </Stack>
  );
};

