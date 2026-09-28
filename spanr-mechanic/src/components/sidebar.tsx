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
import { useCompany } from '../company/company.hook';
import { isKycAllowedPath } from '../kyc/kyc.constants';

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
  const { operationsLocked } = useCompany();

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
        const locked = operationsLocked && !isKycAllowedPath(link.to);
        return (
          <NavLink
            key={link.to}
            to={link.to}
            onClick={(e) => {
              if (locked) e.preventDefault();
            }}
            title={
              locked
                ? 'Upload required documents in Shop Profile before using this'
                : undefined
            }
            style={({ isActive }) => ({
              display: 'flex',
              alignItems: 'center',
              gap: '12px',
              padding: '10px 14px',
              borderRadius: '12px',
              textDecoration: 'none',
              color: locked ? '#B0B0B0' : isActive ? '#FC8019' : '#696969',
              backgroundColor: !locked && isActive ? '#FFF3E0' : 'transparent',
              fontWeight: isActive ? 600 : 500,
              fontSize: '14px',
              pointerEvents: locked ? 'none' : 'auto',
              opacity: locked ? 0.55 : 1,
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
