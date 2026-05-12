import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Container,
  Paper,
  Title,
  Text,
  Alert,
  Group,
  Button,
  Avatar,
  Box,
  Divider,
  Stack,
} from '@mantine/core';
import { IconAlertCircle, IconTool, IconLogout, IconUser } from '@tabler/icons-react';
import { useAuth } from '../auth/auth.hook';
import { authService } from '../auth/auth.service';
import { companyService, type CompanyFormData } from '../company/company.service';
import { CompanyProfileStepper } from '../components/company_profile_stepper';
import type { DocumentFiles } from '../components/company_documents_form';

function submitErrorMessage(err: unknown): string {
  if (err instanceof Error) return err.message;
  if (typeof err === 'object' && err !== null && 'message' in err) {
    const m = (err as { message: unknown }).message;
    if (typeof m === 'string' && m.trim()) return m;
  }
  return 'Failed to create company profile';
}

export default function OnboardingPage() {
  const [error, setError] = useState('');
  const { user, logout, refreshUser, hasCompany } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    if (hasCompany) {
      navigate('/dashboard', { replace: true });
    }
  }, [hasCompany, navigate]);

  const handleSubmit = async (
    data: CompanyFormData,
    logoFile?: File,
    _imageFiles?: File[],
    certifications?: string[],
    specializations?: string[],
    documents?: DocumentFiles
  ) => {
    if (!user) return;

    try {
      setError('');

      const existing = await companyService.getCompanyByStaffEmail(user.email);
      const company = existing
        ? await companyService.updateCompany(existing.id, {
            companyName: data.companyName,
            addressLine1: data.addressLine1,
            addressLine2: data.addressLine2,
            landmark: data.landmark,
            city: data.city,
            state: data.state,
            phoneNumber: data.phoneNumber,
            pincode: data.pincode,
            phone: data.phone,
            email: data.email,
            logo: data.logo,
            latitude: data.latitude,
            longitude: data.longitude,
            images: data.images,
          })
        : await companyService.createCompany(data, user.email, user.name);

      const certList = [...new Set(certifications || [])];
      const specList = [...new Set(specializations || [])];
      const certPromises = existing
        ? certList
            .filter((c) => !existing.certifications.includes(c))
            .map((c) => companyService.addCertification(company.id, c))
        : certList.map((c) => companyService.addCertification(company.id, c));
      const specPromises = existing
        ? specList
            .filter((s) => !existing.specializations.includes(s))
            .map((s) => companyService.addSpecialization(company.id, s))
        : specList.map((s) => companyService.addSpecialization(company.id, s));

      await Promise.all([
        logoFile
          ? companyService.uploadLogo(logoFile, company.id).then((url) =>
              companyService.updateCompany(company.id, { logo: url })
            )
          : Promise.resolve(),
        ...certPromises,
        ...specPromises,
        documents && Object.keys(documents).length > 0
          ? companyService.uploadAndSaveDocuments(company.id, documents)
          : Promise.resolve(),
      ]);

      await refreshUser();

      let resolved = await authService.getCurrentUser();
      for (let i = 0; i < 10 && resolved && !resolved.companyId; i++) {
        await new Promise((r) => setTimeout(r, 300));
        resolved = await authService.getCurrentUser();
      }

      if (!resolved?.companyId) {
        await refreshUser();
        const again = await authService.getCurrentUser();
        if (again?.companyId) {
          navigate('/dashboard', { replace: true });
          return;
        }
        setError(
          'Your company profile was saved. Open the dashboard from the menu or refresh this page.'
        );
        return;
      }

      navigate('/dashboard', { replace: true });
    } catch (err) {
      setError(submitErrorMessage(err));
    }
  };

  const handleLogout = async () => {
    await logout();
    navigate('/login', { replace: true });
  };

  return (
    <Box style={{ minHeight: '100vh', backgroundColor: '#F2F2F2' }}>
      <Box
        style={{
          backgroundColor: '#FFFFFF',
          borderBottom: '1px solid #E0E0E0',
          position: 'sticky',
          top: 0,
          zIndex: 100,
        }}
      >
        <Container size="lg" py="sm">
          <Group justify="space-between" align="center">
            <Group gap="xs">
              <IconTool size={22} color="#FC8019" />
              <Text fw={700} size="lg" c="#1C1C1C">
                SPANR
              </Text>
            </Group>

            <Group gap="sm">
              <Avatar size="sm" color="orange" radius="xl">
                <IconUser size={14} />
              </Avatar>
              <Text size="sm" c="#696969">
                {user?.email}
              </Text>
              <Divider orientation="vertical" />
              <Button
                variant="subtle"
                color="gray"
                size="xs"
                leftSection={<IconLogout size={14} />}
                onClick={handleLogout}
              >
                Logout
              </Button>
            </Group>
          </Group>
        </Container>
      </Box>

      <Container size={780} py={48}>
        <Stack gap="xs" mb={32} align="center">
          <Title order={2} ta="center" c="#1C1C1C">
            Set up your business profile
          </Title>
          <Text c="#696969" size="sm" ta="center" maw={480}>
            Fill in your company details to get started. You can update everything
            later from your dashboard.
          </Text>
        </Stack>

        <Paper shadow="sm" p={40} radius="lg" style={{ border: '1px solid #E0E0E0' }}>
          {error && (
            <Alert
              icon={<IconAlertCircle size={16} />}
              color={error.includes('profile was saved') ? 'blue' : 'red'}
              mb="xl"
              variant="light"
              radius="md"
            >
              {error}
            </Alert>
          )}
          <CompanyProfileStepper
            onSubmit={handleSubmit}
            submitLabel="Complete Setup"
            userEmail={user?.email}
            allowFreeNavigation={false}
          />
        </Paper>
      </Container>
    </Box>
  );
}
