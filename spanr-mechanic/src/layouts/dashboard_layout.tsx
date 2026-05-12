import { AppShell } from '@mantine/core';
import { Outlet } from 'react-router-dom';
import { Sidebar } from '../components/sidebar';
import { Header } from '../components/header';
import { CompanyProvider, useCompany } from '../company/company.hook';
import { DashboardRouteSkeleton } from '../components/dashboard_page_loading';

const DashboardShell = () => {
  const { loading, company } = useCompany();

  return (
    <AppShell
      header={{ height: 60 }}
      navbar={{ width: 250, breakpoint: 'sm' }}
      padding="md"
      styles={{
        main: {
          backgroundColor: '#F2F2F2',
        },
      }}
    >
      <AppShell.Header>
        <Header />
      </AppShell.Header>

      <AppShell.Navbar>
        <Sidebar />
      </AppShell.Navbar>

      <AppShell.Main>
        {loading && !company ? <DashboardRouteSkeleton /> : <Outlet />}
      </AppShell.Main>
    </AppShell>
  );
};

export const DashboardLayout = () => (
  <CompanyProvider>
    <DashboardShell />
  </CompanyProvider>
);
