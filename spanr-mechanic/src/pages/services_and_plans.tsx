import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Container,
  Title,
  Button,
  Alert,
  SimpleGrid,
  Group,
  Tabs,
  LoadingOverlay,
  Text,
  Menu,
  ActionIcon,
  Card,
  Badge,
  Stack,
} from '@mantine/core';
import { IconPlus, IconAlertCircle, IconDots, IconEdit, IconTrash } from '@tabler/icons-react';
import { useCompany } from '../company/company.hook';
import { useServices } from '../services/services.hook';
import { usePlans } from '../plans/plans.hook';
import { servicesService, type ServiceFormData } from '../services/services.service';
import { plansService, type PlanFormData, type PlanDetails } from '../plans/plans.service';
import { ServiceForm } from '../components/service_form';
import { PlanCard } from '../components/plan_card';
import { PlanForm } from '../components/plan_form';
import { useNotification } from '../core/notification.hook';
import type { DbService, DbPlan } from '../types';

export default function ServicesAndPlansPage() {
  const navigate = useNavigate();
  const { company } = useCompany();
  const { services, loading: servicesLoading, error: servicesError, refreshServices } = useServices(company?.id);
  const { plans, loading: plansLoading, error: plansError, refreshPlans } = usePlans(company?.id);
  const notification = useNotification();

  const [activeServiceId, setActiveServiceId] = useState<string | null>(null);
  const [serviceFormOpened, setServiceFormOpened] = useState(false);
  const [planFormOpened, setPlanFormOpened] = useState(false);
  const [editingService, setEditingService] = useState<DbService | undefined>();
  const [editingPlan, setEditingPlan] = useState<PlanDetails | undefined>();
  const [actionLoading, setActionLoading] = useState(false);

  // Set first service as active when services load
  useEffect(() => {
    if (services.length > 0 && !activeServiceId) {
      setActiveServiceId(services[0].id);
    }
  }, [services, activeServiceId]);

  // Service handlers
  const handleCreateService = async (data: ServiceFormData, iconFile?: File) => {
    if (!company) return;

    try {
      setActionLoading(true);
      let iconUrl = data.iconUrl;
      const service = await servicesService.createService(company.id, data);

      if (iconFile) {
        iconUrl = await servicesService.uploadIcon(iconFile, service.id);
        await servicesService.updateService(service.id, { iconUrl });
      }

      await refreshServices();
      notification.showSuccess('Service created successfully');
      setServiceFormOpened(false);
      setActiveServiceId(service.id);
    } catch (err: any) {
      notification.showError(err.message || 'Failed to create service');
    } finally {
      setActionLoading(false);
    }
  };

  const handleUpdateService = async (data: ServiceFormData, iconFile?: File) => {
    if (!editingService) return;

    try {
      setActionLoading(true);
      let iconUrl = data.iconUrl;

      if (iconFile) {
        iconUrl = await servicesService.uploadIcon(iconFile, editingService.id);
      }

      await servicesService.updateService(editingService.id, { ...data, iconUrl });
      await refreshServices();
      notification.showSuccess('Service updated successfully');
      setEditingService(undefined);
      setServiceFormOpened(false);
    } catch (err: any) {
      notification.showError(err.message || 'Failed to update service');
    } finally {
      setActionLoading(false);
    }
  };

  const handleDeleteService = async (serviceId: string) => {
    const service = services.find(s => s.id === serviceId);
    const planCount = plans.filter(p => p.service_id === serviceId).length;
    
    if (!confirm(
      `Are you sure you want to delete "${service?.name}"?\n` +
      `This will also delete ${planCount} plan(s) under this service.`
    )) return;

    try {
      setActionLoading(true);
      await servicesService.deleteService(serviceId);
      
      // Switch to another service tab if deleting active one
      if (activeServiceId === serviceId) {
        const remainingServices = services.filter(s => s.id !== serviceId);
        setActiveServiceId(remainingServices.length > 0 ? remainingServices[0].id : null);
      }
      
      await refreshServices();
      await refreshPlans();
      notification.showSuccess('Service deleted successfully');
    } catch (err: any) {
      notification.showError(err.message || 'Failed to delete service');
    } finally {
      setActionLoading(false);
    }
  };

  const handleEditService = (service: DbService) => {
    setEditingService(service);
    setServiceFormOpened(true);
  };

  const handleCloseServiceForm = () => {
    setServiceFormOpened(false);
    setEditingService(undefined);
  };

  // Plan handlers
  const handleCreatePlan = async (data: PlanFormData) => {
    if (!company) return;

    try {
      setActionLoading(true);
      await plansService.createPlan(company.id, data);
      await refreshPlans();
      notification.showSuccess('Plan created successfully');
      setPlanFormOpened(false);
    } catch (err: any) {
      notification.showError(err.message || 'Failed to create plan');
    } finally {
      setActionLoading(false);
    }
  };

  const handleUpdatePlan = async (data: PlanFormData) => {
    if (!editingPlan) return;

    try {
      setActionLoading(true);
      await plansService.updatePlan(editingPlan.id, data);
      await refreshPlans();
      notification.showSuccess('Plan updated successfully');
      setEditingPlan(undefined);
      setPlanFormOpened(false);
    } catch (err: any) {
      notification.showError(err.message || 'Failed to update plan');
    } finally {
      setActionLoading(false);
    }
  };

  const handleDeletePlan = async (planId: string) => {
    if (!confirm('Are you sure you want to delete this plan?')) return;

    try {
      setActionLoading(true);
      await plansService.deletePlan(planId);
      await refreshPlans();
      notification.showSuccess('Plan deleted successfully');
    } catch (err: any) {
      notification.showError(err.message || 'Failed to delete plan');
    } finally {
      setActionLoading(false);
    }
  };

  const handleEditPlan = async (plan: DbPlan) => {
    try {
      setActionLoading(true);
      const details = await plansService.getPlanDetails(plan.id);
      setEditingPlan(details || undefined);
      setPlanFormOpened(true);
    } catch (err: any) {
      notification.showError(err.message || 'Failed to load plan details');
    } finally {
      setActionLoading(false);
    }
  };

  const handleViewPlan = (planId: string) => {
    navigate(`/plans/${planId}`);
  };

  const handleClosePlanForm = () => {
    setPlanFormOpened(false);
    setEditingPlan(undefined);
  };

  const handleAddPlan = () => {
    if (activeServiceId) {
      setPlanFormOpened(true);
    } else {
      notification.showWarning('Please create a service first');
    }
  };

  // Get plans for active service
  const activePlans = plans.filter(p => p.service_id === activeServiceId);
  const activeService = services.find(s => s.id === activeServiceId);

  if (!company) return <Alert color="yellow">No company profile found</Alert>;

  const isLoading = servicesLoading || plansLoading;

  return (
    <Container size="xl" my={40} pos="relative">
      <LoadingOverlay visible={actionLoading} />

      <Group justify="space-between" mb="xl">
        <Title>Services & Plans</Title>
        <Button 
          leftSection={<IconPlus size={16} />} 
          onClick={() => setServiceFormOpened(true)}
          variant="light"
        >
          Add Service
        </Button>
      </Group>

      {servicesError && (
        <Alert color="red" icon={<IconAlertCircle size={16} />} mb="md">
          {servicesError}
        </Alert>
      )}

      {plansError && (
        <Alert color="red" icon={<IconAlertCircle size={16} />} mb="md">
          {plansError}
        </Alert>
      )}

      {isLoading ? (
        <LoadingOverlay visible />
      ) : services.length === 0 ? (
        <Alert icon={<IconAlertCircle size={16} />} color="blue">
          <Stack gap="sm">
            <Text>No services found. Create your first service to get started.</Text>
            <Button 
              size="sm" 
              onClick={() => setServiceFormOpened(true)}
              style={{ width: 'fit-content' }}
            >
              Create First Service
            </Button>
          </Stack>
        </Alert>
      ) : (
        <Tabs value={activeServiceId} onChange={(value) => setActiveServiceId(value)}>
          <Tabs.List>
            {services.map((service) => {
              const planCount = plans.filter(p => p.service_id === service.id).length;
              return (
                <Tabs.Tab 
                  key={service.id} 
                  value={service.id}
                  rightSection={
                    <Group gap={4}>
                      <Badge size="xs" variant="light" circle>
                        {planCount}
                      </Badge>
                      <Menu position="bottom-end" withinPortal>
                        <Menu.Target>
                          <ActionIcon 
                            size="xs" 
                            variant="subtle" 
                            color="gray"
                            onClick={(e) => e.stopPropagation()}
                          >
                            <IconDots size={14} />
                          </ActionIcon>
                        </Menu.Target>
                        <Menu.Dropdown>
                          <Menu.Item 
                            leftSection={<IconEdit size={14} />}
                            onClick={(e) => {
                              e.stopPropagation();
                              handleEditService(service);
                            }}
                          >
                            Edit Service
                          </Menu.Item>
                          <Menu.Item 
                            leftSection={<IconTrash size={14} />}
                            color="red"
                            onClick={(e) => {
                              e.stopPropagation();
                              handleDeleteService(service.id);
                            }}
                          >
                            Delete Service
                          </Menu.Item>
                        </Menu.Dropdown>
                      </Menu>
                    </Group>
                  }
                >
                  {service.name}
                </Tabs.Tab>
              );
            })}
          </Tabs.List>

          {services.map((service) => (
            <Tabs.Panel key={service.id} value={service.id} pt="xl">
              <Stack gap="md">
                {/* Service Info Card */}
                {service.description && (
                  <Card withBorder padding="md" radius="md">
                    <Group justify="space-between" mb="xs">
                      <Text size="sm" fw={500}>About this service</Text>
                      <Badge color={service.category === 'car' ? 'blue' : 'green'}>
                        {service.category}
                      </Badge>
                    </Group>
                    <Text size="sm" c="dimmed">{service.description}</Text>
                  </Card>
                )}

                {/* Plans Section */}
                <Group justify="space-between">
                  <Text size="lg" fw={500}>
                    Plans ({activePlans.length})
                  </Text>
                  <Button 
                    leftSection={<IconPlus size={16} />} 
                    onClick={handleAddPlan}
                    size="sm"
                  >
                    Add Plan
                  </Button>
                </Group>

                {activePlans.length === 0 ? (
                  <Alert icon={<IconAlertCircle size={16} />} color="blue">
                    <Stack gap="sm">
                      <Text>No plans found for this service. Create your first plan.</Text>
                      <Button 
                        size="sm" 
                        onClick={handleAddPlan}
                        style={{ width: 'fit-content' }}
                      >
                        Create First Plan
                      </Button>
                    </Stack>
                  </Alert>
                ) : (
                  <SimpleGrid cols={{ base: 1, sm: 2, md: 3 }}>
                    {activePlans.map((plan) => (
                      <PlanCard
                        key={plan.id}
                        plan={plan}
                        onEdit={handleEditPlan}
                        onDelete={handleDeletePlan}
                        onView={handleViewPlan}
                      />
                    ))}
                  </SimpleGrid>
                )}
              </Stack>
            </Tabs.Panel>
          ))}
        </Tabs>
      )}

      <ServiceForm
        opened={serviceFormOpened}
        onClose={handleCloseServiceForm}
        onSubmit={editingService ? handleUpdateService : handleCreateService}
        initialData={editingService}
      />

      <PlanForm
        opened={planFormOpened}
        onClose={handleClosePlanForm}
        onSubmit={editingPlan ? handleUpdatePlan : handleCreatePlan}
        services={services.map(s => ({ id: s.id, name: s.name }))}
        initialData={editingPlan}
        defaultServiceId={activeServiceId || undefined}
      />
    </Container>
  );
}
