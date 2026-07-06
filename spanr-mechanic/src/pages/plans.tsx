import { useState, useEffect, useCallback } from 'react';
import {
  Box, Title, Text, Group, Button, Badge, Paper, Modal, Stack,
  TextInput, NumberInput, Select, Skeleton, ActionIcon, ScrollArea,
  Divider, Checkbox, SimpleGrid, Image, ThemeIcon, Tabs,
} from '@mantine/core';
import {
  IconPlus, IconEdit, IconTrash, IconClipboardList,
  IconCar, IconMotorbike, IconCheck, IconSearch,
} from '@tabler/icons-react';
import { useCompany } from '../company/company.hook';
import { plansService } from '../plans/plans.service';
import { jobCatalogService } from '../job-catalog/job_catalog.service';
import type { DbPlan } from '../types';
import type { JobCatalogItem } from '../job-catalog/job_catalog.types';
import { useNotification } from '../core/notification.hook';

const ORANGE = '#FC8019';
const HEADING = '#1C1C1C';
const BODY = '#696969';
const BG = '#F2F2F2';

type VehicleType = 'car' | 'bike';
type PlanType = 'package' | 'custom';
type PackageTier = 1 | 2 | 3 | 4;

const TIER_LABELS: Record<PackageTier, string> = {
  1: 'Plan 1',
  2: 'Plan 2',
  3: 'Plan 3',
  4: 'Plan 4',
};

const TIER_COLORS: Record<PackageTier, string> = {
  1: 'blue',
  2: 'teal',
  3: 'violet',
  4: 'orange',
};

interface PlanForm {
  name: string;
  vehicleType: VehicleType;
  planType: PlanType;
  packageTier: PackageTier;
  basePrice: number;
  duration: number;
  tax: number;
  warranty: string;
  guarantee: string;
  badge: string;
}

const emptyForm = (): PlanForm => ({
  name: '',
  vehicleType: 'car',
  planType: 'package',
  packageTier: 1,
  basePrice: 0,
  duration: 60,
  tax: 18,
  warranty: '',
  guarantee: '',
  badge: '',
});

function PlanSkeleton() {
  return (
    <SimpleGrid cols={{ base: 1, sm: 2, lg: 3 }} spacing="md">
      {[1, 2, 3].map((i) => <Skeleton key={i} height={160} radius="lg" />)}
    </SimpleGrid>
  );
}

export default function PlansPage() {
  const { company } = useCompany();
  const notification = useNotification();
  const [vehicleFilter, setVehicleFilter] = useState<VehicleType>('car');
  const [plans, setPlans] = useState<DbPlan[]>([]);
  const [allServices, setAllServices] = useState<JobCatalogItem[]>([]);
  const [includedIds, setIncludedIds] = useState<Set<string>>(new Set());
  const [serviceSearch, setServiceSearch] = useState('');
  const [loading, setLoading] = useState(false);
  const [modal, setModal] = useState(false);
  const [editingPlan, setEditingPlan] = useState<DbPlan | null>(null);
  const [form, setForm] = useState<PlanForm>(emptyForm());
  const [saving, setSaving] = useState(false);

  const set = (k: keyof PlanForm, v: any) => setForm((f) => ({ ...f, [k]: v }));

  const loadPlans = useCallback(async () => {
    if (!company) return;
    setLoading(true);
    try {
      const data = await plansService.getPlansByCompany(company.id);
      setPlans(data.filter((p) => p.vehicle_type === vehicleFilter));
    } catch (e: any) {
      notification.showError(e.message || 'Failed to load plans');
    } finally {
      setLoading(false);
    }
  }, [company, vehicleFilter]);

  const loadAllServices = useCallback(async () => {
    if (!company) return;
    try {
      // Fetch all job_catalog items for this company + vehicle type (both sections)
      const sections = await jobCatalogService.getSections(company.id, vehicleFilter);
      const jobs = await Promise.all(sections.map((s) => jobCatalogService.getJobs(company.id, s.id)));
      setAllServices(jobs.flat().filter((j) => j.isActive));
    } catch {
      // non-fatal
    }
  }, [company, vehicleFilter]);

  useEffect(() => { loadPlans(); loadAllServices(); }, [loadPlans, loadAllServices]);

  const openAdd = () => {
    setEditingPlan(null);
    setForm({ ...emptyForm(), vehicleType: vehicleFilter });
    setIncludedIds(new Set());
    setServiceSearch('');
    setModal(true);
  };

  const openEdit = async (plan: DbPlan) => {
    setEditingPlan(plan);
    setForm({
      name: plan.name,
      vehicleType: plan.vehicle_type as VehicleType,
      planType: ((plan as any).plan_type || 'package') as PlanType,
      packageTier: ((plan as any).package_tier || 1) as PackageTier,
      basePrice: Number(plan.base_price),
      duration: plan.duration,
      tax: Number(plan.tax),
      warranty: plan.warranty || '',
      guarantee: plan.guarantee || '',
      badge: plan.badge || '',
    });
    // Load included services
    try {
      const ids = await jobCatalogService.getIncludedJobs(plan.id);
      setIncludedIds(new Set(ids));
    } catch {
      setIncludedIds(new Set());
    }
    setServiceSearch('');
    setModal(true);
  };

  const handleSave = async () => {
    if (!company || !form.name.trim()) return;
    setSaving(true);
    try {
      const payload = {
        serviceId: undefined as any,
        name: form.name.trim(),
        vehicleType: form.vehicleType,
        locationType: 'in_premise' as const,
        duration: form.duration,
        basePrice: form.basePrice,
        tax: form.tax,
        warranty: form.warranty || undefined,
        guarantee: form.guarantee || undefined,
        badge: form.badge || undefined,
        planType: form.planType,
        packageTier: form.planType === 'package' ? form.packageTier : undefined,
        fuelTypes: [],
        features: [],
        faqs: [],
        serviceOutcomes: [],
        additionalServices: [],
        steps: [],
      };

      let planId: string;
      if (editingPlan) {
        await plansService.updatePlan(editingPlan.id, payload);
        planId = editingPlan.id;
        notification.showSuccess('Plan updated');
      } else {
        const created = await plansService.createPlan(company.id, payload);
        planId = created.id;
        notification.showSuccess('Plan created');
      }

      // Save included services for package plans
      if (form.planType === 'package') {
        await jobCatalogService.setIncludedJobs(planId, Array.from(includedIds));
      }

      setModal(false);
      await loadPlans();
    } catch (e: any) {
      notification.showError(e.message || 'Failed to save plan');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (planId: string) => {
    if (!confirm('Delete this plan?')) return;
    try {
      await plansService.deletePlan(planId);
      notification.showSuccess('Plan deleted');
      await loadPlans();
    } catch (e: any) {
      notification.showError(e.message || 'Failed to delete plan');
    }
  };

  const toggleService = (id: string) => {
    setIncludedIds((prev) => {
      const next = new Set(prev);
      next.has(id) ? next.delete(id) : next.add(id);
      return next;
    });
  };

  const filteredServices = allServices.filter((s) =>
    s.name.toLowerCase().includes(serviceSearch.toLowerCase())
  );

  const packagePlans = plans.filter((p) => (p as any).plan_type !== 'custom');
  const customPlans = plans.filter((p) => (p as any).plan_type === 'custom');

  if (!company) return null;

  return (
    <Box style={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      {/* Header */}
      <Box p="lg" style={{ backgroundColor: '#fff', borderBottom: '1px solid #E8E8E8' }}>
        <Group justify="space-between" wrap="nowrap">
          <Group gap="sm">
            <Box style={{
              width: 36, height: 36, borderRadius: 10,
              backgroundColor: '#F3F0FF',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <IconClipboardList size={20} color="#7950F2" />
            </Box>
            <div>
              <Title order={4} c={HEADING} lh={1.2}>Plans</Title>
              <Text size="xs" c={BODY}>Package plans and custom pricing</Text>
            </div>
          </Group>

          <Group gap="sm">
            {/* Vehicle toggle */}
            <Group gap={0} style={{ border: '1px solid #E8E8E8', borderRadius: 10, overflow: 'hidden', backgroundColor: BG }}>
              {(['car', 'bike'] as VehicleType[]).map((v) => {
                const active = vehicleFilter === v;
                return (
                  <Button
                    key={v}
                    size="sm"
                    variant="filled"
                    leftSection={v === 'car' ? <IconCar size={15} /> : <IconMotorbike size={15} />}
                    onClick={() => setVehicleFilter(v)}
                    style={{
                      borderRadius: 0, border: 'none',
                      backgroundColor: active ? ORANGE : 'transparent',
                      color: active ? '#fff' : BODY,
                      fontWeight: active ? 600 : 400,
                    }}
                  >
                    {v === 'car' ? 'Car' : 'Bike'}
                  </Button>
                );
              })}
            </Group>

            <Button leftSection={<IconPlus size={16} />} color="orange" onClick={openAdd} radius="md">
              Add Plan
            </Button>
          </Group>
        </Group>
      </Box>

      <ScrollArea style={{ flex: 1 }} p="lg">
        {loading ? (
          <PlanSkeleton />
        ) : plans.length === 0 ? (
          <Stack align="center" gap="sm" mt={80}>
            <ThemeIcon size={56} radius="xl" variant="light" color="orange">
              <IconClipboardList size={28} />
            </ThemeIcon>
            <Text fw={600} c={HEADING}>No plans yet</Text>
            <Text size="sm" c={BODY} ta="center">
              Create Plan 1–4 as fixed packages,<br />or add a Custom plan for à la carte booking.
            </Text>
            <Button leftSection={<IconPlus size={15} />} color="orange" onClick={openAdd} mt="xs">
              Create first plan
            </Button>
          </Stack>
        ) : (
          <Stack gap="xl">
            {/* Package plans */}
            {packagePlans.length > 0 && (
              <div>
                <Text size="sm" fw={700} c={BODY} tt="uppercase" mb="sm" style={{ letterSpacing: 1 }}>
                  Package Plans
                </Text>
                <SimpleGrid cols={{ base: 1, sm: 2, lg: 3 }} spacing="md">
                  {packagePlans.map((plan) => {
                    const tier = (plan as any).package_tier as PackageTier || 1;
                    return (
                      <Paper
                        key={plan.id}
                        radius="lg"
                        p="lg"
                        style={{
                          border: '1px solid #EFEFEF',
                          borderTop: `3px solid var(--mantine-color-${TIER_COLORS[tier]}-5)`,
                          position: 'relative',
                        }}
                      >
                        <Group justify="space-between" mb="xs">
                          <Badge color={TIER_COLORS[tier]} variant="light" size="sm">
                            {TIER_LABELS[tier]}
                          </Badge>
                          <Group gap={4}>
                            <ActionIcon size="sm" variant="subtle" color="gray" onClick={() => openEdit(plan)}>
                              <IconEdit size={14} />
                            </ActionIcon>
                            <ActionIcon size="sm" variant="subtle" color="red" onClick={() => handleDelete(plan.id)}>
                              <IconTrash size={14} />
                            </ActionIcon>
                          </Group>
                        </Group>
                        <Text fw={700} size="md" c={HEADING} mb={4}>{plan.name}</Text>
                        <Text size="xl" fw={800} c={ORANGE}>₹{Number(plan.base_price).toLocaleString('en-IN')}</Text>
                        <Text size="xs" c={BODY}>{plan.duration} min · {plan.tax}% tax</Text>
                        {plan.badge && (
                          <Badge size="xs" color="orange" variant="dot" mt="xs">{plan.badge}</Badge>
                        )}
                      </Paper>
                    );
                  })}
                </SimpleGrid>
              </div>
            )}

            {/* Custom plans */}
            {customPlans.length > 0 && (
              <div>
                <Text size="sm" fw={700} c={BODY} tt="uppercase" mb="sm" style={{ letterSpacing: 1 }}>
                  Custom Plans
                </Text>
                <SimpleGrid cols={{ base: 1, sm: 2, lg: 3 }} spacing="md">
                  {customPlans.map((plan) => (
                    <Paper
                      key={plan.id}
                      radius="lg"
                      p="lg"
                      style={{ border: '1px solid #EFEFEF', borderTop: `3px solid ${ORANGE}` }}
                    >
                      <Group justify="space-between" mb="xs">
                        <Badge color="orange" variant="light" size="sm">Custom</Badge>
                        <Group gap={4}>
                          <ActionIcon size="sm" variant="subtle" color="gray" onClick={() => openEdit(plan)}>
                            <IconEdit size={14} />
                          </ActionIcon>
                          <ActionIcon size="sm" variant="subtle" color="red" onClick={() => handleDelete(plan.id)}>
                            <IconTrash size={14} />
                          </ActionIcon>
                        </Group>
                      </Group>
                      <Text fw={700} size="md" c={HEADING} mb={4}>{plan.name}</Text>
                      <Text size="xs" c={BODY}>Customer picks services · pay per service</Text>
                      <Text size="xs" c={BODY} mt={2}>{plan.duration} min estimated · {plan.tax}% tax</Text>
                    </Paper>
                  ))}
                </SimpleGrid>
              </div>
            )}
          </Stack>
        )}
      </ScrollArea>

      {/* Add / Edit Modal */}
      <Modal
        opened={modal}
        onClose={() => setModal(false)}
        title={editingPlan ? 'Edit Plan' : 'Add Plan'}
        centered
        size="lg"
        radius="lg"
      >
        <Tabs defaultValue="details">
          <Tabs.List mb="md">
            <Tabs.Tab value="details">Details</Tabs.Tab>
            {form.planType === 'package' && (
              <Tabs.Tab value="services">
                Included Services {includedIds.size > 0 && `(${includedIds.size})`}
              </Tabs.Tab>
            )}
          </Tabs.List>

          <Tabs.Panel value="details">
            <Stack gap="md">
              <SimpleGrid cols={2}>
                <TextInput
                  label="Plan name"
                  placeholder="e.g. Basic Package"
                  required
                  value={form.name}
                  onChange={(e) => set('name', e.target.value)}
                  radius="md"
                />
                <Select
                  label="Vehicle type"
                  required
                  data={[{ value: 'car', label: 'Car' }, { value: 'bike', label: 'Bike' }]}
                  value={form.vehicleType}
                  onChange={(v) => set('vehicleType', v)}
                  radius="md"
                />
              </SimpleGrid>

              <SimpleGrid cols={2}>
                <Select
                  label="Plan type"
                  required
                  data={[
                    { value: 'package', label: 'Package (fixed services)' },
                    { value: 'custom', label: 'Custom (customer picks)' },
                  ]}
                  value={form.planType}
                  onChange={(v) => set('planType', v)}
                  radius="md"
                />
                {form.planType === 'package' && (
                  <Select
                    label="Package tier"
                    required
                    data={[
                      { value: '1', label: 'Plan 1' },
                      { value: '2', label: 'Plan 2' },
                      { value: '3', label: 'Plan 3' },
                      { value: '4', label: 'Plan 4' },
                    ]}
                    value={String(form.packageTier)}
                    onChange={(v) => set('packageTier', Number(v))}
                    radius="md"
                  />
                )}
              </SimpleGrid>

              <SimpleGrid cols={3}>
                <NumberInput
                  label="Base price (₹)"
                  prefix="₹"
                  min={0}
                  value={form.basePrice}
                  onChange={(v) => set('basePrice', Number(v) || 0)}
                  radius="md"
                />
                <NumberInput
                  label="Duration (min)"
                  min={0}
                  value={form.duration}
                  onChange={(v) => set('duration', Number(v) || 0)}
                  radius="md"
                />
                <NumberInput
                  label="Tax (%)"
                  min={0} max={100}
                  value={form.tax}
                  onChange={(v) => set('tax', Number(v) || 0)}
                  radius="md"
                />
              </SimpleGrid>

              <SimpleGrid cols={3}>
                <TextInput label="Warranty" placeholder="6 months" value={form.warranty} onChange={(e) => set('warranty', e.target.value)} radius="md" />
                <TextInput label="Guarantee" placeholder="100% satisfaction" value={form.guarantee} onChange={(e) => set('guarantee', e.target.value)} radius="md" />
                <TextInput label="Badge" placeholder="Best Seller" value={form.badge} onChange={(e) => set('badge', e.target.value)} radius="md" />
              </SimpleGrid>

              {form.planType === 'custom' && (
                <Paper p="sm" radius="md" style={{ backgroundColor: '#FFF8F0', border: '1px solid #FFE0B2' }}>
                  <Text size="sm" c={ORANGE} fw={500}>
                    Custom plan — customers browse all your active services and select what they need. No fixed service list required.
                  </Text>
                </Paper>
              )}
            </Stack>
          </Tabs.Panel>

          {form.planType === 'package' && (
            <Tabs.Panel value="services">
              <Stack gap="sm">
                <TextInput
                  placeholder="Search services..."
                  leftSection={<IconSearch size={15} />}
                  value={serviceSearch}
                  onChange={(e) => setServiceSearch(e.target.value)}
                  radius="md"
                />
                {allServices.length === 0 ? (
                  <Text size="sm" c={BODY} ta="center" py="xl">
                    No services found. Add services from the Services page first.
                  </Text>
                ) : filteredServices.length === 0 ? (
                  <Text size="sm" c={BODY} ta="center" py="md">No results</Text>
                ) : (
                  <ScrollArea h={280}>
                    <Stack gap={6}>
                      {filteredServices.map((svc) => {
                        const checked = includedIds.has(svc.id);
                        return (
                          <Box
                            key={svc.id}
                            onClick={() => toggleService(svc.id)}
                            style={{
                              display: 'flex', alignItems: 'center', gap: 12,
                              padding: '10px 12px', borderRadius: 10, cursor: 'pointer',
                              backgroundColor: checked ? '#FFF3E0' : '#F9F9F9',
                              border: `1px solid ${checked ? ORANGE : '#EFEFEF'}`,
                              transition: 'all 0.12s',
                            }}
                          >
                            <Checkbox
                              checked={checked}
                              onChange={() => toggleService(svc.id)}
                              color="orange"
                              size="sm"
                              onClick={(e) => e.stopPropagation()}
                            />
                            {svc.thumbnailUrl && (
                              <Image src={svc.thumbnailUrl} h={28} w={28} fit="cover" radius="sm" />
                            )}
                            <Text size="sm" fw={checked ? 600 : 400} c={checked ? ORANGE : HEADING} style={{ flex: 1 }}>
                              {svc.name}
                            </Text>
                            <Text size="xs" c={BODY}>₹{svc.basePrice.toLocaleString('en-IN')}</Text>
                            {checked && <IconCheck size={15} color={ORANGE} />}
                          </Box>
                        );
                      })}
                    </Stack>
                  </ScrollArea>
                )}
                <Text size="xs" c={BODY}>
                  {includedIds.size} service{includedIds.size !== 1 ? 's' : ''} selected
                </Text>
              </Stack>
            </Tabs.Panel>
          )}
        </Tabs>

        <Divider my="md" />
        <Group justify="flex-end">
          <Button variant="subtle" color="gray" onClick={() => setModal(false)}>Cancel</Button>
          <Button
            color="orange"
            onClick={handleSave}
            loading={saving}
            disabled={!form.name.trim()}
            radius="md"
          >
            {editingPlan ? 'Update' : 'Create'} Plan
          </Button>
        </Group>
      </Modal>
    </Box>
  );
}
