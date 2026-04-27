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
import { IconPlus, IconEdit, IconTrash, IconAlertCircle } from '@tabler/icons-react';
import { useCompany } from '../company/company.hook';
import { useStaff } from '../staff/staff.hook';
import { staffService, type StaffFormData } from '../staff/staff.service';
import { StaffForm } from '../components/staff_form';
import type { StaffWithAccess } from '../staff/staff.service';

export default function StaffPage() {
  const { company } = useCompany();
  const { staff, loading, error, refreshStaff } = useStaff(company?.id);
  const [formOpened, setFormOpened] = useState(false);
  const [editingStaff, setEditingStaff] = useState<StaffWithAccess | undefined>();

  const handleCreate = async (data: StaffFormData, permissions: string[]) => {
    if (!company) return;

    try {
      const newStaff = await staffService.createStaff(company.id, data);
      if (permissions.length > 0) {
        await staffService.updatePermissions(newStaff.id, permissions);
      }
      refreshStaff();
    } catch (err: any) {
      console.error('Failed to create staff:', err);
    }
  };

  const handleUpdate = async (data: StaffFormData, permissions: string[]) => {
    if (!editingStaff) return;

    try {
      await staffService.updateStaff(editingStaff.id, data);
      await staffService.updatePermissions(editingStaff.id, permissions);
      refreshStaff();
      setEditingStaff(undefined);
    } catch (err: any) {
      console.error('Failed to update staff:', err);
    }
  };

  const handleDelete = async (staffId: string) => {
    if (!confirm('Are you sure you want to delete this staff member?')) return;

    try {
      await staffService.deleteStaff(staffId);
      refreshStaff();
    } catch (err: any) {
      console.error('Failed to delete staff:', err);
    }
  };

  const handleEdit = (staff: StaffWithAccess) => {
    setEditingStaff(staff);
    setFormOpened(true);
  };

  const handleCloseForm = () => {
    setFormOpened(false);
    setEditingStaff(undefined);
  };

  if (loading) return <div>Loading...</div>;
  if (error) return <Alert color="red">{error}</Alert>;
  if (!company) return <Alert color="yellow">No company profile found</Alert>;

  return (
    <Container size="xl" my={40}>
      <Group justify="space-between" mb="xl">
        <Title>Staff Members</Title>
        <Button leftSection={<IconPlus size={16} />} onClick={() => setFormOpened(true)} color="orange">
          Add Staff
        </Button>
      </Group>

      {staff.length === 0 ? (
        <Alert icon={<IconAlertCircle size={16} />} color="blue">
          <Text>No staff members found. Add your first staff member to get started.</Text>
        </Alert>
      ) : (
        <Table>
          <Table.Thead>
            <Table.Tr>
              <Table.Th>Name</Table.Th>
              <Table.Th>Email</Table.Th>
              <Table.Th>Status</Table.Th>
              <Table.Th>Permissions</Table.Th>
              <Table.Th>Actions</Table.Th>
            </Table.Tr>
          </Table.Thead>
          <Table.Tbody>
            {staff.map((member) => (
              <Table.Tr key={member.id}>
                <Table.Td>{member.name}</Table.Td>
                <Table.Td>{member.email}</Table.Td>
                <Table.Td>
                  <Badge color={member.enabled ? 'green' : 'red'} radius="sm">
                    {member.enabled ? 'Active' : 'Disabled'}
                  </Badge>
                </Table.Td>
                <Table.Td>
                  <Group gap="xs">
                    {member.permissions.slice(0, 2).map((perm) => (
                      <Badge key={perm} size="sm" variant="light" color="orange">
                        {perm.replace('_', ' ')}
                      </Badge>
                    ))}
                    {member.permissions.length > 2 && (
                      <Badge size="sm" variant="light" color="orange">
                        +{member.permissions.length - 2}
                      </Badge>
                    )}
                  </Group>
                </Table.Td>
                <Table.Td>
                  <Group gap="xs">
                    <ActionIcon variant="light" color="orange" onClick={() => handleEdit(member)}>
                      <IconEdit size={16} />
                    </ActionIcon>
                    <ActionIcon variant="light" color="red" onClick={() => handleDelete(member.id)}>
                      <IconTrash size={16} />
                    </ActionIcon>
                  </Group>
                </Table.Td>
              </Table.Tr>
            ))}
          </Table.Tbody>
        </Table>
      )}

      <StaffForm
        opened={formOpened}
        onClose={handleCloseForm}
        onSubmit={editingStaff ? handleUpdate : handleCreate}
        initialData={editingStaff}
      />
    </Container>
  );
}

