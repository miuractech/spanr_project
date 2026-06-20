import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Container,
  Title,
  Button,
  Alert,
  SimpleGrid,
  Group,
  LoadingOverlay,
  Text,
  Stack,
  Box,
  Divider,
  ThemeIcon,
} from '@mantine/core';
import {
  IconPlus,
  IconAlertCircle,
  IconTools,
  IconClipboardList,
} from '@tabler/icons-react';
import { useCompany } from '../company/company.hook';
import { useServices } from '../services/services.hook';
import { usePlans } from '../plans/plans.hook';
import { servicesService, type ServiceFormData } from '../services/services.service';
import { plansService, type PlanFormData, type PlanDetails } from '../plans/plans.service';
import { ordersService } from '../orders/orders.service';
import { ServiceForm } from '../components/service_form';
import { ServiceCard } from '../components/service_card';
import { PlanCard } from '../components/plan_card';
import { PlanForm } from '../components/plan_form';
import { ServicesPlansSkeleton } from '../components/dashboard_page_loading';
import { useNotification } from '../core/notification.hook';
import type { DbService, DbPlan } from '../types';

const GRID_COLS = { base: 1, sm: 2, md: 3, lg: 4 } as const;

function bookingLabel(count: number): string {
  return count === 1 ? '1 customer booking' : `${count} customer bookings`;
}

function isOrderLinkedDeleteError(err: unknown): boolean {
  const message = err instanceof Error ? err.message : String(err);
  return message.includes('orders_plan_id_fkey');
}

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
  const [planDetailsLoading, setPlanDetailsLoading] = useState(false);

  useEffect(() => {
    if (services.length > 0 && !activeServiceId) {
      setActiveServiceId(services[0].id);
    }
    if (services.length > 0 && activeServiceId && !services.some((s) => s.id === activeServiceId)) {
      setActiveServiceId(services[0].id);
    }
    if (services.length === 0) {
      setActiveServiceId(null);
    }
  }, [services, activeServiceId]);

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
    const service = services.find((s) => s.id === serviceId);
    const planCount = plans.filter((p) => p.service_id === serviceId).length;

    try {
      setActionLoading(true);
      const orderCount = await ordersService.countOrdersByServiceId(serviceId);
      if (orderCount > 0) {
        notification.showWarning(
          `"${service?.name ?? 'This service'}" cannot be deleted because ${bookingLabel(orderCount)} use its plans. ` +
            'Customer order history must stay on file. You can edit the service or its plans instead.',
          "Can't delete service"
        );
        return;
      }

      if (
        !confirm(
          `Are you sure you want to delete "${service?.name}"?\n` +
            `This will also delete ${planCount} plan(s) under this service.`
        )
      )
        return;

      await servicesService.deleteService(serviceId);

      if (activeServiceId === serviceId) {
        const remainingServices = services.filter((s) => s.id !== serviceId);
        setActiveServiceId(remainingServices.length > 0 ? remainingServices[0].id : null);
      }

      await refreshServices();
      await refreshPlans();
      notification.showSuccess('Service deleted successfully');
    } catch (err: unknown) {
      if (isOrderLinkedDeleteError(err)) {
        notification.showWarning(
          `"${service?.name ?? 'This service'}" cannot be deleted because customer bookings are linked to its plans. ` +
            'Keep it for your order records, or edit it instead of removing it.',
          "Can't delete service"
        );
        return;
      }
      notification.showError(err instanceof Error ? err.message : 'Failed to delete service');
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

  const handleCreatePlan = async (data: PlanFormData) => {
    if (!company) return;

    try {
      await plansService.createPlan(company.id, data);
      await refreshPlans();
      notification.showSuccess('Plan created successfully');
      setPlanFormOpened(false);
    } catch (err: any) {
      notification.showError(err.message || 'Failed to create plan');
      throw err;
    }
  };

  const handleUpdatePlan = async (data: PlanFormData) => {
    if (!editingPlan) return;

    try {
      await plansService.updatePlan(editingPlan.id, data);
      await refreshPlans();
      notification.showSuccess('Plan updated successfully');
      setEditingPlan(undefined);
      setPlanFormOpened(false);
    } catch (err: any) {
      notification.showError(err.message || 'Failed to update plan');
      throw err;
    }
  };

  const handleDeletePlan = async (planId: string) => {
    const plan = plans.find((p) => p.id === planId);

    try {
      setActionLoading(true);
      const orderCount = await ordersService.countOrdersByPlanId(planId);
      if (orderCount > 0) {
        notification.showWarning(
          `"${plan?.name ?? 'This plan'}" cannot be deleted because ${bookingLabel(orderCount)} use it. ` +
            'Customer order history must stay on file. You can edit the plan details instead.',
          "Can't delete plan"
        );
        return;
      }

      if (!confirm(`Are you sure you want to delete "${plan?.name ?? 'this plan'}"?`)) return;

      await plansService.deletePlan(planId);
      await refreshPlans();
      notification.showSuccess('Plan deleted successfully');
    } catch (err: unknown) {
      if (isOrderLinkedDeleteError(err)) {
        notification.showWarning(
          `"${plan?.name ?? 'This plan'}" cannot be deleted because customer bookings are linked to it. ` +
            'Keep it for your order records, or edit it instead of removing it.',
          "Can't delete plan"
        );
        return;
      }
      notification.showError(err instanceof Error ? err.message : 'Failed to delete plan');
    } finally {
      setActionLoading(false);
    }
  };

  const handleEditPlan = async (plan: DbPlan) => {
    setEditingPlan(undefined);
    setPlanFormOpened(true);
    setPlanDetailsLoading(true);
    try {
      const details = await plansService.getPlanDetails(plan.id);
      setEditingPlan(details || undefined);
    } catch (err: any) {
      notification.showError(err.message || 'Failed to load plan details');
      setPlanFormOpened(false);
    } finally {
      setPlanDetailsLoading(false);
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

  const activePlans = plans.filter((p) => p.service_id === activeServiceId);
  const activeService = services.find((s) => s.id === activeServiceId);

  if (!company) return <Alert color="yellow">No company profile found</Alert>;

  const isLoading = servicesLoading || plansLoading;

  return (
    <Container size="xl" my={40} pos="relative">
      <LoadingOverlay visible={actionLoading && !planFormOpened && !serviceFormOpened} />

      <Title order={2} c="#1C1C1C" mb="xl">
        Services & Plans
      </Title>

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
        <ServicesPlansSkeleton />
      ) : (
        <Stack gap="lg">
          {/* Services section */}
          <Box>
            <Group justify="space-between" align="center" mb="md" wrap="wrap">
              <Group gap="sm">
                <ThemeIcon size={36} radius="md" variant="light" color="blue">
                  <IconTools size={20} />
                </ThemeIcon>
                <Title order={3} c="#1C1C1C" fw={600}>
                  Services ({services.length})
                </Title>
              </Group>
              <Button
                leftSection={<IconPlus size={16} />}
                onClick={() => setServiceFormOpened(true)}
                variant="light"
                color="blue"
              >
                Add Service
              </Button>
            </Group>

            {services.length === 0 ? (
              <Alert icon={<IconAlertCircle size={16} />} color="blue">
                <Stack gap="sm">
                  <Text>No services found. Create your first service to get started.</Text>
                  <Button
                    size="sm"
                    color="blue"
                    onClick={() => setServiceFormOpened(true)}
                    style={{ width: 'fit-content' }}
                  >
                    Create First Service
                  </Button>
                </Stack>
              </Alert>
            ) : (
              <SimpleGrid cols={GRID_COLS}>
                {services.map((service) => (
                  <ServiceCard
                    key={service.id}
                    service={service}
                    planCount={plans.filter((p) => p.service_id === service.id).length}
                    selected={service.id === activeServiceId}
                    onSelect={setActiveServiceId}
                    onEdit={handleEditService}
                    onDelete={handleDeleteService}
                  />
                ))}
              </SimpleGrid>
            )}
          </Box>

          {services.length > 0 && (
            <>
              <Divider color="#E8E8E8" />

              {/* Plans section */}
              <Box>
                <Group justify="space-between" align="center" mb="md" wrap="wrap">
                  <Group gap="sm">
                    <ThemeIcon size={36} radius="md" variant="light" color="orange">
                      <IconClipboardList size={20} />
                    </ThemeIcon>
                    <Stack gap={2}>
                      <Title order={3} c="#1C1C1C" fw={600}>
                        Plans ({activePlans.length})
                      </Title>
                      {activeService && services.length > 1 && (
                        <Text size="xs" c="#696969">
                          Showing plans for {activeService.name}
                        </Text>
                      )}
                    </Stack>
                  </Group>
                  <Button
                    leftSection={<IconPlus size={16} />}
                    onClick={handleAddPlan}
                    color="orange"
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
                        color="orange"
                        onClick={handleAddPlan}
                        style={{ width: 'fit-content' }}
                      >
                        Create First Plan
                      </Button>
                    </Stack>
                  </Alert>
                ) : (
                  <SimpleGrid cols={GRID_COLS}>
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
              </Box>
            </>
          )}
        </Stack>
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
        services={services.map((s) => ({ id: s.id, name: s.name }))}
        initialData={editingPlan}
        defaultServiceId={activeServiceId || undefined}
        detailsLoading={planDetailsLoading}
      />
    </Container>
  );
}
