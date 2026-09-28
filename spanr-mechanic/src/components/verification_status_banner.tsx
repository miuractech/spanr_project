import { Alert, List, Text } from '@mantine/core';
import { useEffect, useState } from 'react';
import { IconClock, IconAlertTriangle, IconCircleCheck } from '@tabler/icons-react';
import type { CompanyProfile, DbCompanyDocument } from '../company/company.service';
import { companyService } from '../company/company.service';
import { documentLabel } from '../kyc/kyc.constants';
import { useCompany } from '../company/company.hook';

function approvedDismissKey(companyId: string, verifiedAt: string | null) {
  return `spanr_kyc_approved_${companyId}_${verifiedAt ?? 'verified'}`;
}

export const VerificationStatusBanner: React.FC<{ company: CompanyProfile }> = ({
  company,
}) => {
  const { hasMandatoryDocs } = useCompany();
  const [rejectedDocs, setRejectedDocs] = useState<DbCompanyDocument[]>([]);
  const [approvedDismissed, setApprovedDismissed] = useState(() => {
    if (company.verification_status !== 'verified') return true;
    try {
      return localStorage.getItem(approvedDismissKey(company.id, company.verified_at)) === '1';
    } catch {
      return false;
    }
  });

  useEffect(() => {
    if (company.verification_status !== 'verified') {
      setApprovedDismissed(true);
      return;
    }
    try {
      setApprovedDismissed(
        localStorage.getItem(approvedDismissKey(company.id, company.verified_at)) === '1'
      );
    } catch {
      setApprovedDismissed(false);
    }
  }, [company.id, company.verification_status, company.verified_at]);

  useEffect(() => {
    if (company.verification_status === 'verified') {
      setRejectedDocs([]);
      return;
    }
    companyService
      .getDocuments(company.id)
      .then((docs) => setRejectedDocs(docs.filter((d) => d.verified === 'rejected')))
      .catch(() => setRejectedDocs([]));
  }, [company.id, company.verification_status, company.updated_at]);

  const dismissApproved = () => {
    try {
      localStorage.setItem(approvedDismissKey(company.id, company.verified_at), '1');
    } catch {
      /* ignore */
    }
    setApprovedDismissed(true);
  };

  if (company.verification_status === 'verified') {
    if (approvedDismissed) return null;
    return (
      <Alert
        icon={<IconCircleCheck size={16} />}
        color="green"
        variant="light"
        mb="md"
        title="Shop approved"
        withCloseButton
        onClose={dismissApproved}
      >
        SPANR approved your KYC. Customers can now find and book your shop.
      </Alert>
    );
  }

  if (company.verification_status === 'rejected') {
    return (
      <Alert
        icon={<IconAlertTriangle size={16} />}
        color="red"
        variant="light"
        mb="md"
        title="Verification rejected"
      >
        {company.verification_notes ||
          'Your shop was not approved. Re-upload the missing documents from Shop Profile. Other dashboard actions stay locked until SPANR approves them.'}
        {rejectedDocs.length > 0 && (
          <List size="sm" mt="xs">
            {rejectedDocs.map((doc) => (
              <List.Item key={doc.id}>
                {documentLabel(doc.document_type)}
                {doc.rejection_reason ? ` — ${doc.rejection_reason}` : ''}
              </List.Item>
            ))}
          </List>
        )}
      </Alert>
    );
  }

  return (
    <Alert
      icon={<IconClock size={16} />}
      color="orange"
      variant="light"
      mb="md"
      title="Under approval process"
    >
      <Text size="sm">
        {hasMandatoryDocs
          ? 'Your documents are with SPANR. You can still set up services, plans, and staff. Customers cannot see or book your shop until approval.'
          : 'Upload all mandatory documents in Shop Profile. Services, plans, orders, and staff stay locked until those files are submitted.'}
      </Text>
      {rejectedDocs.length > 0 && (
        <List size="sm" mt="xs">
          {rejectedDocs.map((doc) => (
            <List.Item key={doc.id}>
              {documentLabel(doc.document_type)}
              {doc.rejection_reason ? ` — ${doc.rejection_reason}` : ''}
            </List.Item>
          ))}
        </List>
      )}
    </Alert>
  );
};
