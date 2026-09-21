import { useCallback, useEffect, useMemo, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  Badge,
  Button,
  Container,
  Group,
  Image,
  Paper,
  Stack,
  Text,
  Textarea,
  Title,
  UnstyledButton,
} from '@mantine/core';
import { IconArrowLeft, IconExternalLink } from '@tabler/icons-react';
import { adminService } from './admin.service';
import type { DbCompanyDocument } from '../company/company.service';
import type { DbMechanicCompany } from '../types';
import { documentLabel, MANDATORY_DOCUMENT_TYPES } from '../kyc/kyc.constants';
import { useNotification } from '../core/notification.hook';
import { DashboardRouteSkeleton } from '../components/dashboard_page_loading';
import { AdminDocumentViewer, getDocumentKind } from './admin_document_viewer';

const STATUS_COLOR = {
  pending: 'orange',
  verified: 'green',
  rejected: 'red',
} as const;

export default function AdminReviewPage() {
  const { companyId } = useParams<{ companyId: string }>();
  const navigate = useNavigate();
  const { showSuccess, showError } = useNotification();
  const [shop, setShop] = useState<DbMechanicCompany | null>(null);
  const [documents, setDocuments] = useState<DbCompanyDocument[]>([]);
  const [loading, setLoading] = useState(true);
  const [notes, setNotes] = useState('');
  const [docReasons, setDocReasons] = useState<Record<string, string>>({});
  const [busy, setBusy] = useState(false);
  const [selectedId, setSelectedId] = useState<string | null>(null);

  const load = useCallback(async () => {
    if (!companyId) return;
    setLoading(true);
    try {
      const [company, docs] = await Promise.all([
        adminService.getCompany(companyId),
        adminService.getCompanyDocuments(companyId),
      ]);
      setShop(company);
      setDocuments(docs);
      setNotes(company.verification_notes ?? '');
      setSelectedId((current) => {
        if (current && docs.some((d) => d.id === current)) return current;
        const pending = docs.find((d) => d.verified === 'pending');
        return pending?.id ?? docs[0]?.id ?? null;
      });
    } catch (err) {
      showError(err instanceof Error ? err.message : 'Failed to load shop');
    } finally {
      setLoading(false);
    }
  }, [companyId, showError]);

  useEffect(() => {
    void load();
  }, [load]);

  const selected = useMemo(
    () => documents.find((d) => d.id === selectedId) ?? null,
    [documents, selectedId]
  );

  const mandatoryReady = useMemo(() => {
    return MANDATORY_DOCUMENT_TYPES.every((type) =>
      documents.some((d) => d.document_type === type && d.verified === 'verified')
    );
  }, [documents]);

  const setDocStatus = async (doc: DbCompanyDocument, status: 'verified' | 'rejected') => {
    const reason = docReasons[doc.id]?.trim();
    if (status === 'rejected' && !reason) {
      showError('Add a reason before rejecting this document');
      return;
    }
    setBusy(true);
    try {
      await adminService.setDocumentVerification(doc.id, status, reason);
      showSuccess(`Document ${status}`);
      await load();
    } catch (err) {
      showError(err instanceof Error ? err.message : 'Failed to update document');
    } finally {
      setBusy(false);
    }
  };

  const setShopStatus = async (status: 'verified' | 'rejected') => {
    if (status === 'rejected' && !notes.trim()) {
      showError('Add a rejection reason for the shop');
      return;
    }
    if (status === 'verified' && !mandatoryReady) {
      showError('Approve every mandatory document before verifying the shop');
      return;
    }
    setBusy(true);
    try {
      await adminService.setCompanyVerification(shop!.id, status, notes.trim() || undefined);
      showSuccess(`Shop marked ${status}`);
      navigate('/admin');
    } catch (err) {
      showError(err instanceof Error ? err.message : 'Failed to update shop');
    } finally {
      setBusy(false);
    }
  };

  if (loading) {
    return (
      <Container size="xl" my={40}>
        <DashboardRouteSkeleton />
      </Container>
    );
  }

  if (!shop) {
    return (
      <Container size="xl" my={40}>
        <Text c="#696969">Shop not found.</Text>
        <Button variant="subtle" color="orange" mt="md" onClick={() => navigate('/admin')}>
          Back to queue
        </Button>
      </Container>
    );
  }

  return (
    <Container size="xl" my={40} pb={80}>
      <Button
        variant="subtle"
        color="gray"
        leftSection={<IconArrowLeft size={16} />}
        onClick={() => navigate('/admin')}
        mb="md"
        px={0}
      >
        Shop approval
      </Button>

      <Paper p="lg" radius="lg" mb="xl" style={{ border: '1px solid #E0E0E0' }}>
        <Group gap="sm" mb={6}>
          <Title order={2} c="#1C1C1C">
            {shop.company_name}
          </Title>
          <Badge color={STATUS_COLOR[shop.verification_status]} size="lg">
            {shop.verification_status}
          </Badge>
        </Group>
        <Text size="sm" c="#696969">
          {shop.address_line_1}, {shop.city}, {shop.state} {shop.pincode}
        </Text>
        <Text size="sm" c="#696969">
          {shop.phone}
        </Text>
        {shop.images?.[0] && (
          <Image src={shop.images[0]} h={180} radius="md" mt="md" fit="cover" alt="Shop" />
        )}
      </Paper>

      <Title order={3} mb="xs" c="#1C1C1C">
        KYC documents
      </Title>
      <Text size="sm" c="#696969" mb="md">
        Open each file in the viewer, then approve or reject. Verify shop stays locked until all required files are approved.
      </Text>

      {documents.length === 0 ? (
        <Paper p="lg" radius="lg" style={{ border: '1px solid #E0E0E0' }}>
          <Text size="sm" c="#696969">
            No documents uploaded yet.
          </Text>
        </Paper>
      ) : (
        <Group align="flex-start" gap="lg" wrap="wrap">
          <Stack gap={8} w={{ base: '100%', sm: 280 }} style={{ flexShrink: 0 }}>
            {documents.map((doc) => {
              const active = doc.id === selectedId;
              const kind = getDocumentKind(doc.file_name, doc.file_url);
              return (
                <UnstyledButton
                  key={doc.id}
                  onClick={() => setSelectedId(doc.id)}
                  style={{
                    width: '100%',
                    textAlign: 'left',
                    padding: '12px 14px',
                    borderRadius: 12,
                    border: active ? '1.5px solid #FC8019' : '1px solid #E0E0E0',
                    backgroundColor: active ? '#FFF3E0' : '#FFFFFF',
                  }}
                >
                  <Group justify="space-between" wrap="nowrap" gap="xs">
                    <div>
                      <Text size="sm" fw={600} c="#1C1C1C">
                        {documentLabel(doc.document_type)}
                      </Text>
                      <Text size="xs" c="#696969">
                        {kind === 'pdf' ? 'PDF' : kind === 'image' ? 'Image / receipt' : 'File'}
                      </Text>
                    </div>
                    <Badge size="sm" color={STATUS_COLOR[doc.verified]}>
                      {doc.verified}
                    </Badge>
                  </Group>
                </UnstyledButton>
              );
            })}
          </Stack>

          {selected && (
            <Paper p="lg" radius="lg" style={{ border: '1px solid #E0E0E0', flex: 1, minWidth: 280 }}>
              <Group justify="space-between" mb="md" wrap="wrap">
                <div>
                  <Group gap="xs">
                    <Text fw={700} c="#1C1C1C">
                      {documentLabel(selected.document_type)}
                    </Text>
                    {(MANDATORY_DOCUMENT_TYPES as string[]).includes(selected.document_type) && (
                      <Badge size="sm" variant="light" color="orange">
                        Required
                      </Badge>
                    )}
                  </Group>
                  <Text size="xs" c="#696969">
                    {selected.file_name}
                  </Text>
                </div>
                <Button
                  component="a"
                  href={selected.file_url}
                  target="_blank"
                  rel="noreferrer"
                  variant="subtle"
                  color="orange"
                  size="xs"
                  leftSection={<IconExternalLink size={14} />}
                >
                  Open tab
                </Button>
              </Group>

              {selected.rejection_reason && (
                <Text size="sm" c="red" mb="sm">
                  {selected.rejection_reason}
                </Text>
              )}

              <AdminDocumentViewer
                src={selected.file_url}
                fileName={selected.file_name}
                title={documentLabel(selected.document_type)}
              />

              <Textarea
                mt="md"
                label="Rejection reason"
                placeholder="Required if you reject this document"
                value={docReasons[selected.id] ?? ''}
                onChange={(e) =>
                  setDocReasons((prev) => ({
                    ...prev,
                    [selected.id]: e.currentTarget.value,
                  }))
                }
                minRows={2}
              />
              <Group justify="flex-end" mt="md">
                <Button
                  color="red"
                  variant="light"
                  disabled={busy || selected.verified === 'rejected'}
                  onClick={() => void setDocStatus(selected, 'rejected')}
                >
                  Reject document
                </Button>
                <Button
                  color="green"
                  disabled={busy || selected.verified === 'verified'}
                  onClick={() => void setDocStatus(selected, 'verified')}
                >
                  Approve document
                </Button>
              </Group>
            </Paper>
          )}
        </Group>
      )}

      <Paper p="lg" radius="lg" mt="xl" style={{ border: '1px solid #E0E0E0' }}>
        <Textarea
          label="Shop notes / rejection reason"
          placeholder="Shown to the shop owner if you reject the whole shop"
          value={notes}
          onChange={(e) => setNotes(e.currentTarget.value)}
          mb="md"
          minRows={3}
        />
        <Group justify="flex-end">
          <Button color="red" variant="light" loading={busy} onClick={() => void setShopStatus('rejected')}>
            Reject shop
          </Button>
          <Button
            color="orange"
            loading={busy}
            disabled={!mandatoryReady}
            onClick={() => void setShopStatus('verified')}
          >
            Verify shop
          </Button>
        </Group>
        {!mandatoryReady && (
          <Text size="xs" c="#696969" ta="right" mt="xs">
            Approve all mandatory documents to enable Verify shop.
          </Text>
        )}
      </Paper>
    </Container>
  );
}
