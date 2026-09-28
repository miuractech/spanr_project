import { useEffect, useState } from 'react';
import {
  Container,
  Box,
  Title,
  Alert,
} from '@mantine/core';
import { IconAlertCircle } from '@tabler/icons-react';
import { useCompany } from '../company/company.hook';
import { companyService, toExistingDocuments } from '../company/company.service';
import { CompanyProfileStepper } from '../components/company_profile_stepper';
import type { ExistingDocuments } from '../components/company_documents_form';
import type { CompanyFormData } from '../company/company.service';
import type { DocumentFiles } from '../components/company_documents_form';
import { useNotification } from '../core/notification.hook';

export default function CompanyProfilePage() {
  const { company, error, refreshCompany } = useCompany();
  const [updateError, setUpdateError] = useState('');
  const [existingDocuments, setExistingDocuments] = useState<ExistingDocuments>({});
  const { showSuccess } = useNotification();

  useEffect(() => {
    if (!company) return;
    companyService
      .getDocuments(company.id)
      .then((docs) => setExistingDocuments(toExistingDocuments(docs)))
      .catch((err) => console.error('Failed to load existing documents:', err));
  }, [company]);

  const handleUpdate = async (
    data: CompanyFormData,
    logoFile?: File,
    imageFiles?: File[],
    certifications?: string[],
    specializations?: string[],
    documents?: DocumentFiles
  ) => {
    if (!company) {
      console.error('No company found');
      return;
    }

    try {
      setUpdateError('');
      console.log('Starting update with data:', { data, certifications, specializations });

      let logoUrl = data.logo;

      if (logoFile) {
        console.log('Uploading logo...');
        logoUrl = await companyService.uploadLogo(logoFile, company.id);
      }

      // Upload new images
      let allImages: string[];
      if (imageFiles && imageFiles.length > 0) {
        console.log('Uploading images...', imageFiles.length);
        const uploadedImageUrls = await Promise.all(
          imageFiles.map((file) =>
            companyService.uploadCompanyImage(file, company.id)
          )
        );
        allImages = [...(data.images || []), ...uploadedImageUrls];
      } else {
        allImages = data.images || [];
      }

      console.log('Updating company data...');
      await companyService.updateCompany(company.id, {
        ...data,
        phone: data.phone || company.phone,
        email: data.email || company.email,
        logo: logoUrl,
        images: allImages,
      });
      console.log('Company data updated successfully');
      // Update certifications
      if (certifications) {
        console.log('Updating certifications...');
        const toRemove = company.certifications.filter(c => !certifications.includes(c));
        const toAdd = certifications.filter(c => !company.certifications.includes(c));
        
        const certOps = [
          ...toRemove.map(cert => companyService.removeCertification(company.id, cert)),
          ...toAdd.map(cert => companyService.addCertification(company.id, cert)),
        ];
        
        if (certOps.length > 0) {
          await Promise.all(certOps);
        }
      }

      // Update specializations
      if (specializations) {
        console.log('Updating specializations...');
        const toRemove = company.specializations.filter(s => !specializations.includes(s));
        const toAdd = specializations.filter(s => !company.specializations.includes(s));
        
        const specOps = [
          ...toRemove.map(spec => companyService.removeSpecialization(company.id, spec)),
          ...toAdd.map(spec => companyService.addSpecialization(company.id, spec)),
        ];
        
        if (specOps.length > 0) {
          await Promise.all(specOps);
        }
      }

      const hasNewDocs = Boolean(
        documents && Object.values(documents).some((file) => Boolean(file))
      );
      if (hasNewDocs && documents) {
        await companyService.uploadAndSaveDocuments(company.id, documents);
        const docs = await companyService.getDocuments(company.id);
        setExistingDocuments(toExistingDocuments(docs));
      }

      await companyService.submitKycForReview();
      await refreshCompany();
      showSuccess('Shop profile updated successfully');
    } catch (err) {
      console.error('Update error:', err);
      const errorMessage = err instanceof Error ? err.message : 'Failed to update company profile';
      setUpdateError(errorMessage);
      throw err;
    }
  };

  if (error) return <Alert color="red">{error}</Alert>;
  if (!company) return <Alert color="yellow">No company profile found</Alert>;

  return (
    <Container size="lg" py={{ base: 32, md: 48 }} maw={960}>
      <Title order={2} mb="xl" fz={28} fw={700} c="#1C1C1C">
        Shop profile
      </Title>

      {updateError && (
        <Alert icon={<IconAlertCircle size={16} />} color="red" mb={32}>
          {updateError}
        </Alert>
      )}

      <Box>
        <CompanyProfileStepper
          initialData={{
            companyName: company.company_name,
            addressLine1: company.address_line_1,
            addressLine2: company.address_line_2 || '',
            landmark: company.landmark || '',
            city: company.city,
            state: company.state,
            phoneNumber: company.phone_number,
            pincode: company.pincode,
            phone: company.phone,
            email: company.email,
            logo: company.logo || '',
            latitude: company.latitude || undefined,
            longitude: company.longitude || undefined,
            images: company.images || [],
          }}
          initialCertifications={company.certifications}
          initialSpecializations={company.specializations}
          existingDocuments={existingDocuments}
          userPhone={company.phone}
          onSubmit={handleUpdate}
          submitLabel="Update Profile"
        />
      </Box>
    </Container>
  );
}

