import { Alert, List } from '@mantine/core';
import { useEffect, useState } from 'react';
import { IconClock, IconAlertTriangle } from '@tabler/icons-react';
import type { CompanyProfile, DbCompanyDocument } from '../company/company.service';
import { companyService } from '../company/company.service';
import { documentLabel } from '../kyc/kyc.constants';

export const VerificationStatusBanner: React.FC<{ company: CompanyProfile }> = ({
  company,
}) => {
  const [rejectedDocs, setRejectedDocs] = useState<DbCompanyDocument[]>([]);

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

  if (company.verification_status === 'verified') return null;

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
          'Your shop was not approved. Re-upload the documents below from Shop Profile.'}
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
      title="Verification pending"
    >
      Your shop is hidden from customers until SPANR approves KYC. Upload all
      mandatory documents in Shop Profile. Re-uploads return the shop to this queue.
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
