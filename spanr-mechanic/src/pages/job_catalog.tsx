import { useState, useEffect } from 'react';
import {
  Title,
  Group,
  Stack,
  Button,
  Text,
  Paper,
  TextInput,
  NumberInput,
  Modal,
  ActionIcon,
  Alert,
  Switch,
  Box,
  FileInput,
  Image,
  Skeleton,
  Divider,
  ScrollArea,
} from '@mantine/core';
import {
  IconPlus,
  IconEdit,
  IconTrash,
  IconUpload,
  IconCar,
  IconMotorbike,
  IconChevronRight,
  IconListDetails,
} from '@tabler/icons-react';
import { useCompany } from '../company/company.hook';
import { jobCatalogService } from '../job-catalog/job_catalog.service';
import type { JobSection, JobCatalogItem, VehicleType } from '../job-catalog/job_catalog.types';
import { useNotification } from '../core/notification.hook';

const ORANGE = '#FC8019';
const BG = '#F2F2F2';
const HEADING = '#1C1C1C';
const BODY = '#696969';

function SectionSkeleton() {
  return (
    <Stack gap="sm">
      {[1, 2, 3].map((i) => (
        <Skeleton key={i} height={62} radius="md" />
      ))}
    </Stack>
  );
}

function JobSkeleton() {
  return (
    <Stack gap="sm">
      {[1, 2, 3, 4].map((i) => (
        <Skeleton key={i} height={58} radius="md" />
      ))}
    </Stack>
  );
}

export default function JobCatalogPage() {
  const { company } = useCompany();
  const notification = useNotification();
  const [vehicleFilter, setVehicleFilter] = useState<VehicleType>('car');
  const [sections, setSections] = useState<JobSection[]>([]);
  const [jobs, setJobs] = useState<JobCatalogItem[]>([]);
  const [activeSectionId, setActiveSectionId] = useState<string | null>(null);
  const [sectionsLoading, setSectionsLoading] = useState(false);
  const [jobsLoading, setJobsLoading] = useState(false);
  const [actionLoading, setActionLoading] = useState(false);

  // Section modal
  const [sectionModal, setSectionModal] = useState(false);
  const [editingSection, setEditingSection] = useState<JobSection | null>(null);
  const [sectionName, setSectionName] = useState('');
  const [sectionImageFile, setSectionImageFile] = useState<File | null>(null);

  // Job modal
  const [jobModal, setJobModal] = useState(false);
  const [editingJob, setEditingJob] = useState<JobCatalogItem | null>(null);
  const [jobName, setJobName] = useState('');
  const [jobPrice, setJobPrice] = useState<number>(0);
  const [jobThumbnailFile, setJobThumbnailFile] = useState<File | null>(null);

  const loadSections = async () => {
    if (!company) return;
    setSectionsLoading(true);
    setJobs([]); // clear jobs immediately on any section reload
    try {
      const s = await jobCatalogService.getSections(company.id, vehicleFilter);
      setSections(s);
      // pick first section, or clear if none
      const next = s.length > 0 ? (s.find((x) => x.id === activeSectionId) ? activeSectionId : s[0].id) : null;
      setActiveSectionId(next);
    } catch (err) {
      notification.showError(err instanceof Error ? err.message : 'Failed to load sections');
    } finally {
      setSectionsLoading(false);
    }
  };

  const loadJobs = async () => {
    if (!activeSectionId) { setJobs([]); return; }
    setJobsLoading(true);
    try {
      setJobs(await jobCatalogService.getJobs(company!.id, activeSectionId));
    } catch (err) {
      notification.showError(err instanceof Error ? err.message : 'Failed to load jobs');
    } finally {
      setJobsLoading(false);
    }
  };

  useEffect(() => { loadSections(); }, [company, vehicleFilter]);
  useEffect(() => { loadJobs(); }, [activeSectionId]);

  // Section handlers
  const openAddSection = () => { setEditingSection(null); setSectionName(''); setSectionImageFile(null); setSectionModal(true); };
  const openEditSection = (s: JobSection) => { setEditingSection(s); setSectionName(s.name); setSectionImageFile(null); setSectionModal(true); };

  const handleSaveSection = async () => {
    if (!company || !sectionName.trim()) return;
    setActionLoading(true);
    try {
      if (editingSection) {
        let imageUrl: string | undefined;
        if (sectionImageFile) imageUrl = await jobCatalogService.uploadSectionImage(sectionImageFile, editingSection.id);
        await jobCatalogService.updateSection(editingSection.id, { name: sectionName.trim(), imageUrl });
        notification.showSuccess('Section updated');
      } else {
        const created = await jobCatalogService.createSection(company.id, { name: sectionName.trim(), vehicleType: vehicleFilter });
        if (sectionImageFile) {
          const imageUrl = await jobCatalogService.uploadSectionImage(sectionImageFile, created.id);
          await jobCatalogService.updateSection(created.id, { imageUrl });
        }
        setActiveSectionId(created.id);
        notification.showSuccess('Section created');
      }
      setSectionModal(false);
      await loadSections();
    } catch (err) {
      notification.showError(err instanceof Error ? err.message : 'Failed to save section');
    } finally {
      setActionLoading(false);
    }
  };

  const handleDeleteSection = async (id: string) => {
    if (!confirm('Delete this section and all its jobs?')) return;
    setActionLoading(true);
    try {
      await jobCatalogService.deleteSection(id);
      if (activeSectionId === id) setActiveSectionId(null);
      notification.showSuccess('Section deleted');
      await loadSections();
    } catch (err) {
      notification.showError(err instanceof Error ? err.message : 'Failed to delete section');
    } finally {
      setActionLoading(false);
    }
  };

  // Job handlers
  const openAddJob = () => { setEditingJob(null); setJobName(''); setJobPrice(0); setJobThumbnailFile(null); setJobModal(true); };
  const openEditJob = (j: JobCatalogItem) => { setEditingJob(j); setJobName(j.name); setJobPrice(j.basePrice); setJobThumbnailFile(null); setJobModal(true); };

  const handleSaveJob = async () => {
    if (!company || !activeSectionId || !jobName.trim()) return;
    setActionLoading(true);
    try {
      if (editingJob) {
        let thumbnailUrl: string | undefined;
        if (jobThumbnailFile) thumbnailUrl = await jobCatalogService.uploadJobThumbnail(jobThumbnailFile, editingJob.id);
        await jobCatalogService.updateJob(editingJob.id, { name: jobName.trim(), basePrice: jobPrice, thumbnailUrl });
        notification.showSuccess('Job updated');
      } else {
        const created = await jobCatalogService.createJob({ companyId: company.id, sectionId: activeSectionId, name: jobName.trim(), basePrice: jobPrice });
        if (jobThumbnailFile) {
          const thumbnailUrl = await jobCatalogService.uploadJobThumbnail(jobThumbnailFile, created.id);
          await jobCatalogService.updateJob(created.id, { thumbnailUrl });
        }
        notification.showSuccess('Job added');
      }
      setJobModal(false);
      await loadJobs();
    } catch (err) {
      notification.showError(err instanceof Error ? err.message : 'Failed to save job');
    } finally {
      setActionLoading(false);
    }
  };

  const handleDeleteJob = async (id: string) => {
    if (!confirm('Delete this job?')) return;
    setActionLoading(true);
    try {
      await jobCatalogService.deleteJob(id);
      notification.showSuccess('Job deleted');
      await loadJobs();
    } catch (err) {
      notification.showError(err instanceof Error ? err.message : 'Failed to delete job');
    } finally {
      setActionLoading(false);
    }
  };

  const handleToggleJobActive = async (job: JobCatalogItem) => {
    try {
      await jobCatalogService.updateJob(job.id, { isActive: !job.isActive });
      setJobs((prev) => prev.map((j) => j.id === job.id ? { ...j, isActive: !j.isActive } : j));
    } catch (err) {
      notification.showError(err instanceof Error ? err.message : 'Failed to update job');
    }
  };

  if (!company) return <Alert color="yellow">No shop profile found</Alert>;

  const activeSection = sections.find((s) => s.id === activeSectionId);

  return (
    <Box style={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      {/* Header */}
      <Box
        p="lg"
        style={{ backgroundColor: '#fff', borderBottom: '1px solid #E8E8E8' }}
      >
        <Group justify="space-between" wrap="nowrap">
          <Group gap="sm">
            <Box
              style={{
                width: 36, height: 36, borderRadius: 10,
                backgroundColor: '#FFF3E0',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}
            >
              <IconListDetails size={20} color={ORANGE} />
            </Box>
            <div>
              <Title order={4} c={HEADING} lh={1.2}>Services</Title>
              <Text size="xs" c={BODY}>Manage individual services by section</Text>
            </div>
          </Group>

          {/* Vehicle toggle */}
          <Group
            gap={0}
            style={{
              border: '1px solid #E8E8E8',
              borderRadius: 10,
              overflow: 'hidden',
              backgroundColor: BG,
            }}
          >
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
                    borderRadius: 0,
                    backgroundColor: active ? ORANGE : 'transparent',
                    color: active ? '#fff' : BODY,
                    fontWeight: active ? 600 : 400,
                    border: 'none',
                    transition: 'all 0.15s',
                  }}
                >
                  {v === 'car' ? 'Car' : 'Bike'}
                </Button>
              );
            })}
          </Group>
        </Group>
      </Box>

      {/* Body — two-pane */}
      <Box style={{ flex: 1, display: 'flex', overflow: 'hidden', minHeight: 0 }}>
        {/* Left: Sections */}
        <Box
          style={{
            width: 280,
            flexShrink: 0,
            borderRight: '1px solid #E8E8E8',
            backgroundColor: '#fff',
            display: 'flex',
            flexDirection: 'column',
          }}
        >
          <Group justify="space-between" px="md" py="sm" style={{ borderBottom: '1px solid #F0F0F0' }}>
            <Text size="sm" fw={600} c={HEADING}>
              Sections
              {!sectionsLoading && (
                <Text span size="xs" c={BODY} fw={400} ml={4}>({sections.length})</Text>
              )}
            </Text>
            <Button
              size="xs"
              variant="light"
              color="orange"
              leftSection={<IconPlus size={13} />}
              onClick={openAddSection}
              style={{ borderRadius: 8 }}
            >
              Add
            </Button>
          </Group>

          <ScrollArea style={{ flex: 1 }} p="sm">
            {sectionsLoading ? (
              <SectionSkeleton />
            ) : sections.length === 0 ? (
              <Stack align="center" gap="xs" mt="xl" px="md">
                <Text size="sm" c={BODY} ta="center">
                  No sections yet.{'\n'}Add your first section.
                </Text>
              </Stack>
            ) : (
              <Stack gap={6}>
                {sections.map((section) => {
                  const isActive = section.id === activeSectionId;
                  return (
                    <Box
                      key={section.id}
                      onClick={() => setActiveSectionId(section.id)}
                      style={{
                        display: 'flex',
                        alignItems: 'center',
                        gap: 10,
                        padding: '10px 12px',
                        borderRadius: 10,
                        cursor: 'pointer',
                        backgroundColor: isActive ? '#FFF3E0' : 'transparent',
                        border: `1px solid ${isActive ? ORANGE : 'transparent'}`,
                        transition: 'all 0.15s',
                      }}
                      onMouseEnter={(e) => {
                        if (!isActive) e.currentTarget.style.backgroundColor = '#F9F9F9';
                      }}
                      onMouseLeave={(e) => {
                        if (!isActive) e.currentTarget.style.backgroundColor = 'transparent';
                      }}
                    >
                      {section.imageUrl ? (
                        <Image src={section.imageUrl} h={32} w={32} fit="contain" radius="sm" />
                      ) : (
                        <Box style={{
                          width: 32, height: 32, borderRadius: 8,
                          backgroundColor: isActive ? '#FFE0B2' : '#F2F2F2',
                          display: 'flex', alignItems: 'center', justifyContent: 'center',
                          flexShrink: 0,
                        }}>
                          <IconListDetails size={15} color={isActive ? ORANGE : BODY} />
                        </Box>
                      )}

                      <Text size="sm" fw={isActive ? 600 : 400} c={isActive ? ORANGE : HEADING} style={{ flex: 1, minWidth: 0 }} truncate>
                        {section.name}
                      </Text>

                      <Group gap={2} onClick={(e) => e.stopPropagation()}>
                        <ActionIcon size="xs" variant="subtle" color="gray" onClick={() => openEditSection(section)}>
                          <IconEdit size={12} />
                        </ActionIcon>
                        <ActionIcon size="xs" variant="subtle" color="red" onClick={() => handleDeleteSection(section.id)}>
                          <IconTrash size={12} />
                        </ActionIcon>
                      </Group>
                      {isActive && <IconChevronRight size={14} color={ORANGE} style={{ flexShrink: 0 }} />}
                    </Box>
                  );
                })}
              </Stack>
            )}
          </ScrollArea>
        </Box>

        {/* Right: Jobs */}
        <Box style={{ flex: 1, display: 'flex', flexDirection: 'column', backgroundColor: BG, minWidth: 0 }}>
          {/* Jobs header */}
          <Box
            px="lg"
            py="sm"
            style={{ backgroundColor: '#fff', borderBottom: '1px solid #E8E8E8' }}
          >
            <Group justify="space-between">
              <Text size="sm" fw={600} c={HEADING}>
                {activeSection ? activeSection.name : 'Select a section'}
                {activeSection && !jobsLoading && (
                  <Text span size="xs" c={BODY} fw={400} ml={4}>({jobs.length} jobs)</Text>
                )}
              </Text>
              {activeSectionId && (
                <Button
                  size="xs"
                  color="orange"
                  leftSection={<IconPlus size={13} />}
                  onClick={openAddJob}
                  style={{ borderRadius: 8 }}
                >
                  Add Job
                </Button>
              )}
            </Group>
          </Box>

          <ScrollArea style={{ flex: 1 }} p="lg">
            {!activeSectionId ? (
              <Stack align="center" gap="sm" mt={60}>
                <Box style={{
                  width: 56, height: 56, borderRadius: 16,
                  backgroundColor: '#fff',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  boxShadow: '0 2px 8px rgba(0,0,0,0.06)',
                }}>
                  <IconListDetails size={26} color="#CCC" />
                </Box>
                <Text size="sm" c={BODY} ta="center">
                  Select a section on the left<br />to manage its jobs
                </Text>
              </Stack>
            ) : jobsLoading ? (
              <JobSkeleton />
            ) : jobs.length === 0 ? (
              <Stack align="center" gap="sm" mt={60}>
                <Box style={{
                  width: 56, height: 56, borderRadius: 16,
                  backgroundColor: '#fff',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  boxShadow: '0 2px 8px rgba(0,0,0,0.06)',
                }}>
                  <IconPlus size={26} color="#CCC" />
                </Box>
                <Text size="sm" c={BODY} ta="center">No jobs yet in this section</Text>
                <Button size="xs" color="orange" variant="light" onClick={openAddJob} leftSection={<IconPlus size={13} />}>
                  Add first job
                </Button>
              </Stack>
            ) : (
              <Stack gap="sm">
                {jobs.map((job) => (
                  <Paper key={job.id} radius="md" p="sm" style={{ backgroundColor: '#fff', border: '1px solid #EFEFEF' }}>
                    <Group justify="space-between" wrap="nowrap">
                      <Group gap="sm" style={{ flex: 1, minWidth: 0 }}>
                        {job.thumbnailUrl ? (
                          <Image src={job.thumbnailUrl} h={40} w={40} fit="cover" radius="md" style={{ flexShrink: 0 }} />
                        ) : (
                          <Box style={{
                            width: 40, height: 40, borderRadius: 10, flexShrink: 0,
                            backgroundColor: '#F9F9F9', border: '1px solid #EFEFEF',
                            display: 'flex', alignItems: 'center', justifyContent: 'center',
                          }}>
                            <IconListDetails size={16} color="#CCC" />
                          </Box>
                        )}
                        <div style={{ minWidth: 0 }}>
                          <Text size="sm" fw={500} c={HEADING} truncate>{job.name}</Text>
                          <Text size="xs" c={ORANGE} fw={600}>₹{job.basePrice.toLocaleString('en-IN')}</Text>
                        </div>
                      </Group>

                      <Group gap={8} style={{ flexShrink: 0 }}>
                        <Group gap={4}>
                          <Switch
                            size="xs"
                            checked={job.isActive}
                            onChange={() => handleToggleJobActive(job)}
                            color="orange"
                          />
                          <Text size="xs" c={job.isActive ? ORANGE : BODY}>
                            {job.isActive ? 'Active' : 'Off'}
                          </Text>
                        </Group>
                        <Divider orientation="vertical" />
                        <ActionIcon size="sm" variant="subtle" color="gray" onClick={() => openEditJob(job)}>
                          <IconEdit size={14} />
                        </ActionIcon>
                        <ActionIcon size="sm" variant="subtle" color="red" onClick={() => handleDeleteJob(job.id)}>
                          <IconTrash size={14} />
                        </ActionIcon>
                      </Group>
                    </Group>
                  </Paper>
                ))}
              </Stack>
            )}
          </ScrollArea>
        </Box>
      </Box>

      {/* Section Modal */}
      <Modal opened={sectionModal} onClose={() => setSectionModal(false)} title={editingSection ? 'Edit Section' : 'Add Section'} centered radius="lg">
        <Stack gap="md">
          <TextInput
            label="Section name"
            placeholder="e.g. Engine, Wheel, Suspension"
            value={sectionName}
            onChange={(e) => setSectionName(e.target.value)}
            required
            radius="md"
          />
          <FileInput
            label="Section image (optional)"
            placeholder="Choose image"
            accept="image/*"
            leftSection={<IconUpload size={16} />}
            value={sectionImageFile}
            onChange={setSectionImageFile}
            clearable
            radius="md"
          />
          <Group justify="flex-end" mt="xs">
            <Button variant="subtle" color="gray" onClick={() => setSectionModal(false)}>Cancel</Button>
            <Button color="orange" onClick={handleSaveSection} loading={actionLoading} disabled={!sectionName.trim()} radius="md">
              Save
            </Button>
          </Group>
        </Stack>
      </Modal>

      {/* Job Modal */}
      <Modal opened={jobModal} onClose={() => setJobModal(false)} title={editingJob ? 'Edit Job' : 'Add Job'} centered radius="lg">
        <Stack gap="md">
          <TextInput
            label="Job name"
            placeholder="e.g. Oil Filter Replacement"
            value={jobName}
            onChange={(e) => setJobName(e.target.value)}
            required
            radius="md"
          />
          <NumberInput
            label="Base price"
            placeholder="0"
            min={0}
            prefix="₹"
            value={jobPrice}
            onChange={(v) => setJobPrice(Number(v) || 0)}
            radius="md"
          />
          <FileInput
            label="Thumbnail (optional)"
            placeholder="Choose image"
            accept="image/*"
            leftSection={<IconUpload size={16} />}
            value={jobThumbnailFile}
            onChange={setJobThumbnailFile}
            clearable
            radius="md"
          />
          <Group justify="flex-end" mt="xs">
            <Button variant="subtle" color="gray" onClick={() => setJobModal(false)}>Cancel</Button>
            <Button color="orange" onClick={handleSaveJob} loading={actionLoading} disabled={!jobName.trim()} radius="md">
              Save
            </Button>
          </Group>
        </Stack>
      </Modal>
    </Box>
  );
}
