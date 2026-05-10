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
import { companyService, type CompanyFormData } from '../company/company.service';
import { CompanyProfileStepper } from '../components/company_profile_stepper';
import type { DocumentFiles } from '../components/company_documents_form';

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

      const company = await companyService.createCompany(data, user.email, user.name);

      await Promise.all([
        logoFile
          ? companyService.uploadLogo(logoFile, company.id).then((url) =>
              companyService.updateCompany(company.id, { logo: url })
            )
          : Promise.resolve(),
        ...(certifications || []).map((c) =>
          companyService.addCertification(company.id, c)
        ),
        ...(specializations || []).map((s) =>
          companyService.addSpecialization(company.id, s)
        ),
        documents && Object.keys(documents).length > 0
          ? companyService.uploadAndSaveDocuments(company.id, documents)
          : Promise.resolve(),
      ]);

      await refreshUser();
      navigate('/dashboard');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to create company profile');
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
              color="red"
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
