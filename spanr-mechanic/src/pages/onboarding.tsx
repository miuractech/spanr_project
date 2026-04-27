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
    <Box style={{ minHeight: '100vh', backgroundColor: '#f8f9fa' }}>
      {/* Header */}
      <Box
        style={{
          backgroundColor: '#fff',
          borderBottom: '1px solid #e9ecef',
          position: 'sticky',
          top: 0,
          zIndex: 100,
        }}
      >
        <Container size="lg" py="sm">
          <Group justify="space-between" align="center">
            <Group gap="xs">
              <IconTool size={22} color="#FF6B35" />
              <Text fw={700} size="lg" c="#FF6B35">
                SPANR
              </Text>
            </Group>

            <Group gap="sm">
              <Avatar size="sm" color="orange" radius="xl">
                <IconUser size={14} />
              </Avatar>
              <Text size="sm" c="dimmed">
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

      {/* Content */}
      <Container size={780} py={48}>
        <Stack gap="xs" mb={32} align="center">
          <Title order={2} ta="center">
            Set up your business profile
          </Title>
          <Text c="dimmed" size="sm" ta="center" maw={480}>
            Fill in your company details to get started. You can update everything
            later from your dashboard.
          </Text>
        </Stack>

        <Paper withBorder shadow="sm" p={40} radius="md" bg="white">
          {error && (
            <Alert
              icon={<IconAlertCircle size={16} />}
              color="red"
              mb="xl"
              variant="light"
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
