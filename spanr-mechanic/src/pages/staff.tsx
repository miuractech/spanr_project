import { useState } from 'react';
import {
  Container,
  Title,
  Button,
  Alert,
  Table,
  Group,
  Badge,
  ActionIcon,
  Text,
} from '@mantine/core';
import { IconPlus, IconEdit, IconTrash, IconAlertCircle, IconKey } from '@tabler/icons-react';
import { useCompany } from '../company/company.hook';
import { StaffTableSkeleton } from '../components/dashboard_page_loading';
import { useStaff } from '../staff/staff.hook';
import { useStaffWorkload } from '../assignments/assignments.hook';
import { staffService, type StaffFormData, type StaffCredentials } from '../staff/staff.service';
import { StaffForm } from '../components/staff_form';
import { StaffCredentialsModal } from '../components/staff_credentials_modal';
import { isStaffAuthEmail, formatPhoneDisplay } from '../core/phone.util';
import type { StaffWithAccess } from '../staff/staff.service';

export default function StaffPage() {
  const { company } = useCompany();
  const { staff, loading, error, refreshStaff } = useStaff(company?.id);
  const { workload } = useStaffWorkload(company?.id);
  const [formOpened, setFormOpened] = useState(false);
  const [editingStaff, setEditingStaff] = useState<StaffWithAccess | undefined>();
  const [credentials, setCredentials] = useState<StaffCredentials | null>(null);
  const [credentialsName, setCredentialsName] = useState('');
  const [credentialsModalOpen, setCredentialsModalOpen] = useState(false);
  const [isResetCredentials, setIsResetCredentials] = useState(false);
  const [actionError, setActionError] = useState('');

  const getWorkload = (staffId: string) =>
    workload.find((w) => w.staff_id === staffId);

  const showCredentials = (name: string, creds: StaffCredentials, isReset = false) => {
    setCredentialsName(name);
    setCredentials(creds);
    setIsResetCredentials(isReset);
    setCredentialsModalOpen(true);
  };

  const handleCreate = async (data: StaffFormData, permissions: string[]) => {
    if (!company) return;
    setActionError('');
    try {
      const { staff: newStaff, credentials: creds } = await staffService.createStaff(company.id, data);
      if (permissions.length > 0) {
        await staffService.updatePermissions(newStaff.id, permissions);
      }
      refreshStaff();
      showCredentials(data.name, creds);
    } catch (err: unknown) {
      setActionError(err instanceof Error ? err.message : 'Failed to create staff');
    }
  };

  const handleUpdate = async (data: StaffFormData, permissions: string[]) => {
    if (!editingStaff) return;
    setActionError('');
    try {
      await staffService.updateStaff(editingStaff.id, data);
      await staffService.updatePermissions(editingStaff.id, permissions);
      refreshStaff();
      setEditingStaff(undefined);
    } catch (err: unknown) {
      setActionError(err instanceof Error ? err.message : 'Failed to update staff');
    }
  };

  const handleResetPassword = async (member: StaffWithAccess) => {
    if (!member.phone && !member.profile?.phone) return;
    setActionError('');
    try {
      const creds = await staffService.resetPassword(member.id);
      showCredentials(member.name, creds, true);
    } catch (err: unknown) {
      setActionError(err instanceof Error ? err.message : 'Failed to reset password');
    }
  };

  const handleDelete = async (staffId: string) => {
    if (!confirm('Are you sure you want to delete this staff member?')) return;
    try {
      await staffService.deleteStaff(staffId);
      refreshStaff();
    } catch (err: unknown) {
      setActionError(err instanceof Error ? err.message : 'Failed to delete staff');
    }
  };

  const handleEdit = (member: StaffWithAccess) => {
    setEditingStaff(member);
    setFormOpened(true);
  };

  const handleCloseForm = () => {
    setFormOpened(false);
    setEditingStaff(undefined);
  };

  if (error) return <Alert color="red">{error}</Alert>;
  if (!company) return <Alert color="yellow">No company profile found</Alert>;

  return (
    <Container size="xl" my={40}>
      <Group justify="space-between" mb="xl">
        <Title c="#1C1C1C">Staff Members</Title>
        <Button leftSection={<IconPlus size={16} />} onClick={() => setFormOpened(true)} color="orange">
          Add Mechanic
        </Button>
      </Group>

      {actionError && (
        <Alert color="red" mb="md" onClose={() => setActionError('')} withCloseButton>
          {actionError}
        </Alert>
      )}

      {loading ? (
        <StaffTableSkeleton />
      ) : staff.length === 0 ? (
        <Alert icon={<IconAlertCircle size={16} />} color="blue">
          <Text>No staff members found. Add your first mechanic to get started.</Text>
        </Alert>
      ) : (
        <Table>
          <Table.Thead>
            <Table.Tr>
              <Table.Th>Name</Table.Th>
              <Table.Th>Mobile</Table.Th>
              <Table.Th>Status</Table.Th>
              <Table.Th>Availability</Table.Th>
              <Table.Th>Workload</Table.Th>
              <Table.Th>Skills</Table.Th>
              <Table.Th>Actions</Table.Th>
            </Table.Tr>
          </Table.Thead>
          <Table.Tbody>
            {staff.map((member) => {
              const wl = getWorkload(member.id);
              const phone = member.phone ?? member.profile?.phone;
              const isMechanic = isStaffAuthEmail(member.email);
              return (
                <Table.Tr key={member.id}>
                  <Table.Td>{member.name}</Table.Td>
                  <Table.Td>{phone ? formatPhoneDisplay(phone) : '—'}</Table.Td>
                  <Table.Td>
                    <Badge color={member.enabled ? 'green' : 'red'} radius="sm">
                      {member.enabled ? 'Active' : 'Disabled'}
                    </Badge>
                  </Table.Td>
                  <Table.Td>
                    <Badge color={wl?.availability === 'available' ? 'green' : 'orange'} variant="light" size="sm">
                      {wl?.availability ?? member.profile?.availability ?? 'available'}
                    </Badge>
                  </Table.Td>
                  <Table.Td>
                    <Badge color="blue" variant="outline" size="sm">
                      {wl?.active_jobs ?? 0} jobs
                    </Badge>
                  </Table.Td>
                  <Table.Td>
                    <Group gap={4}>
                      {(member.skills ?? []).slice(0, 2).map((skill) => (
                        <Badge key={skill} size="xs" color="orange" variant="light">{skill}</Badge>
                      ))}
                    </Group>
                  </Table.Td>
                  <Table.Td>
                    <Group gap="xs">
                      {isMechanic && phone && (
                        <ActionIcon
                          variant="light"
                          color="blue"
                          title="Reset password"
                          onClick={() => handleResetPassword(member)}
                        >
                          <IconKey size={16} />
                        </ActionIcon>
                      )}
                      <ActionIcon variant="light" color="orange" onClick={() => handleEdit(member)}>
                        <IconEdit size={16} />
                      </ActionIcon>
                      <ActionIcon variant="light" color="red" onClick={() => handleDelete(member.id)}>
                        <IconTrash size={16} />
                      </ActionIcon>
                    </Group>
                  </Table.Td>
                </Table.Tr>
              );
            })}
          </Table.Tbody>
        </Table>
      )}
      <StaffForm
        opened={formOpened}
        onClose={handleCloseForm}
        onSubmit={editingStaff ? handleUpdate : handleCreate}
        initialData={editingStaff}
      />
      <StaffCredentialsModal
        opened={credentialsModalOpen}
        onClose={() => setCredentialsModalOpen(false)}
        staffName={credentialsName}
        credentials={credentials}
        isReset={isResetCredentials}
      />
    </Container>
  );
}
