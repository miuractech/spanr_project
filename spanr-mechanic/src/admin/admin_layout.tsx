import { AppShell } from '@mantine/core';
import { useDisclosure } from '@mantine/hooks';
import { Outlet } from 'react-router-dom';
import { AdminHeader } from './admin_header';
import { AdminSidebar } from './admin_sidebar';

export const AdminLayout = () => {
  const [opened, { toggle, close }] = useDisclosure(false);

  return (
    <AppShell
      header={{ height: 60 }}
      navbar={{ width: 250, breakpoint: 'sm', collapsed: { mobile: !opened } }}
      padding="md"
      styles={{
        main: {
          backgroundColor: '#F2F2F2',
        },
      }}
    >
      <AppShell.Header>
        <AdminHeader burgerOpened={opened} onBurgerToggle={toggle} />
      </AppShell.Header>
      <AppShell.Navbar onClick={close}>
        <AdminSidebar />
      </AppShell.Navbar>
      <AppShell.Main>
        <Outlet />
      </AppShell.Main>
    </AppShell>
  );
};
