import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { MantineProvider } from '@mantine/core';
import { Notifications } from '@mantine/notifications';
import { AuthProvider } from './auth/auth.context';
import { AuthHashRedirect } from './components/auth_hash_redirect';
import { ProtectedRoute } from './components/protected_route';
import { DashboardLayout } from './layouts/dashboard_layout';
import { theme } from './core/theme';

import LoginPage from './pages/login';
import SignupPage from './pages/signup';
import ForgotPasswordPage from './pages/forgot_password';
import ResetPasswordPage from './pages/reset_password';
import AuthCallbackPage from './pages/auth_callback';
import OnboardingPage from './pages/onboarding';
import DashboardPage from './pages/dashboard';
import CompanyProfilePage from './pages/company_profile';
import ServicesAndPlansPage from './pages/services_and_plans';
import PlanDetailPage from './pages/plan_detail';
import OrdersPage from './pages/orders';
import OrderDetailPage from './pages/order_detail';
import StaffPage from './pages/staff';
import ProfilePage from './pages/profile';
import VehicleHistoryPage from './pages/vehicle_history';

import '@mantine/core/styles.css';
import '@mantine/dates/styles.css';
import '@mantine/notifications/styles.css';

function App() {
  return (
    <MantineProvider theme={theme} defaultColorScheme="light">
      <Notifications position="top-right" />
      <AuthProvider>
        <BrowserRouter>
          <AuthHashRedirect />
          <Routes>
            <Route path="/login" element={<LoginPage />} />
            <Route path="/signup" element={<SignupPage />} />
            <Route path="/forgot-password" element={<ForgotPasswordPage />} />
            <Route path="/reset-password" element={<ResetPasswordPage />} />
            <Route path="/auth/callback" element={<AuthCallbackPage />} />
            
            <Route
              path="/onboarding"
              element={
                <ProtectedRoute>
                  <OnboardingPage />
                </ProtectedRoute>
              }
            />

            <Route
              path="/"
              element={
                <ProtectedRoute requireCompany>
                  <DashboardLayout />
                </ProtectedRoute>
              }
            >
              <Route index element={<Navigate to="/dashboard" replace />} />
              <Route path="dashboard" element={<DashboardPage />} />
              <Route path="company-profile" element={<CompanyProfilePage />} />
              <Route path="services" element={<ServicesAndPlansPage />} />
              <Route path="plans/:planId" element={<PlanDetailPage />} />
              <Route path="orders" element={<OrdersPage />} />
              <Route path="orders/:orderId" element={<OrderDetailPage />} />
              <Route path="staff" element={<StaffPage />} />
              <Route path="vehicle-history" element={<VehicleHistoryPage />} />
              <Route path="profile" element={<ProfilePage />} />
            </Route>

            <Route path="*" element={<Navigate to="/login" replace />} />
          </Routes>
        </BrowserRouter>
      </AuthProvider>
    </MantineProvider>
  );
}

export default App;
