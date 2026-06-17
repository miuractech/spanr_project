import supabase from '../supabaseconfig';
import type { DbMechanicCompany } from '../types';
import type { DocumentFiles } from '../components/company_documents_form';

export type DocumentType = 'gst_certificate' | 'pan_card' | 'utility_bill';
export type VerificationStatus = 'pending' | 'verified' | 'rejected';

export interface DbCompanyDocument {
  id: string;
  company_id: string;
  document_type: DocumentType;
  file_url: string;
  file_name: string;
  verified: VerificationStatus;
  rejection_reason: string | null;
  created_at: string;
  updated_at: string;
}

export interface CompanyFormData {
  companyName: string;
  addressLine1: string;
  addressLine2?: string;
  landmark?: string;
  city: string;
  state: string;
  phoneNumber: string;
  pincode: string;
  phone: string;
  email: string;
  logo?: string;
  latitude?: number;
  longitude?: number;
  images?: string[];
}

export interface CompanyProfile extends DbMechanicCompany {
  certifications: string[];
  specializations: string[];
}

const DOCUMENTS_BUCKET = 'company-documents';

function documentStoragePath(fileUrlOrPath: string): string {
  const marker = `/${DOCUMENTS_BUCKET}/`;
  if (fileUrlOrPath.includes(marker)) {
    return fileUrlOrPath.split(marker)[1]?.split('?')[0] ?? fileUrlOrPath;
  }
  return fileUrlOrPath;
}

export const companyService = {
  async createCompany(data: CompanyFormData, userEmail: string, userName: string) {
    // Create company
    const { data: company, error: companyError } = await supabase
      .from('mechanic_companies')
      .insert({
        company_name: data.companyName,
        address_line_1: data.addressLine1,
        address_line_2: data.addressLine2,
        landmark: data.landmark,
        city: data.city,
        state: data.state,
        phone_number: data.phoneNumber,
        pincode: data.pincode,
        phone: data.phone,
        email: data.email,
        logo: data.logo,
        latitude: data.latitude,
        longitude: data.longitude,
        images: data.images || [],
      })
      .select()
      .single();

    if (companyError) throw companyError;

    // Create staff record for owner
    const { error: staffError } = await supabase
      .from('staff')
      .insert({
        company_id: company.id,
        email: userEmail,
        name: userName,
        enabled: true,
      });

    if (staffError) throw staffError;

    return company;
  },

  async getCompanyByStaffEmail(email: string): Promise<CompanyProfile | null> {
    const { data, error } = await supabase
      .from('staff')
      .select(`
        company_id,
        mechanic_companies (
          *,
          company_certifications (certification_name),
          company_specializations (specialization_name)
        )
      `)
      .eq('email', email)
      .eq('enabled', true)
      .order('created_at', { ascending: false })
      .limit(1)
      .maybeSingle();

    if (error) throw error;
    if (!data?.mechanic_companies) return null;

    const nested = data.mechanic_companies as DbMechanicCompany & {
      company_certifications?: { certification_name: string }[];
      company_specializations?: { specialization_name: string }[];
    };

    const {
      company_certifications,
      company_specializations,
      ...company
    } = nested;

    return {
      ...company,
      certifications:
        company_certifications?.map((c) => c.certification_name) ?? [],
      specializations:
        company_specializations?.map((s) => s.specialization_name) ?? [],
    };
  },

  async updateCompany(companyId: string, data: Partial<CompanyFormData>) {
    const { data: company, error } = await supabase
      .from('mechanic_companies')
      .update({
        company_name: data.companyName,
        address_line_1: data.addressLine1,
        address_line_2: data.addressLine2,
        landmark: data.landmark,
        city: data.city,
        state: data.state,
        phone_number: data.phoneNumber,
        pincode: data.pincode,
        phone: data.phone,
        email: data.email,
        logo: data.logo,
        latitude: data.latitude,
        longitude: data.longitude,
        images: data.images,
      })
      .eq('id', companyId)
      .select()
      .single();

    if (error) throw error;
    return company;
  },

  async uploadLogo(file: File, companyId: string): Promise<string> {
    const fileExt = file.name.split('.').pop();
    const fileName = `${companyId}-${Date.now()}.${fileExt}`;
    const filePath = `${fileName}`;

    const { error: uploadError } = await supabase.storage
      .from('company-logos')
      .upload(filePath, file, { upsert: true });

    if (uploadError) throw uploadError;

    const { data } = supabase.storage
      .from('company-logos')
      .getPublicUrl(filePath);

    return data.publicUrl;
  },

  async addCertification(companyId: string, certificationName: string) {
    const { error } = await supabase
      .from('company_certifications')
      .insert({
        company_id: companyId,
        certification_name: certificationName,
      });

    if (error) throw error;
  },

  async removeCertification(companyId: string, certificationName: string) {
    const { error } = await supabase
      .from('company_certifications')
      .delete()
      .eq('company_id', companyId)
      .eq('certification_name', certificationName);

    if (error) throw error;
  },

  async addSpecialization(companyId: string, specializationName: string) {
    const { error } = await supabase
      .from('company_specializations')
      .insert({
        company_id: companyId,
        specialization_name: specializationName,
      });

    if (error) throw error;
  },

  async removeSpecialization(companyId: string, specializationName: string) {
    const { error } = await supabase
      .from('company_specializations')
      .delete()
      .eq('company_id', companyId)
      .eq('specialization_name', specializationName);

    if (error) throw error;
  },

  async uploadCompanyImage(file: File, companyId: string): Promise<string> {
    const fileExt = file.name.split('.').pop();
    const fileName = `${companyId}-${Date.now()}.${fileExt}`;

    const { error: uploadError } = await supabase.storage
      .from('company-images')
      .upload(fileName, file, { upsert: true });

    if (uploadError) throw uploadError;

    const { data } = supabase.storage
      .from('company-images')
      .getPublicUrl(fileName);

    return data.publicUrl;
  },

  async uploadDocument(
    file: File,
    companyId: string,
    docType: DocumentType
  ): Promise<string> {
    const fileExt = file.name.split('.').pop();
    const fileName = `${companyId}/${docType}-${Date.now()}.${fileExt}`;

    const { error } = await supabase.storage
      .from(DOCUMENTS_BUCKET)
      .upload(fileName, file, { upsert: true });

    if (error) throw error;

    return fileName;
  },

  async getDocumentSignedUrl(fileUrlOrPath: string): Promise<string> {
    const path = documentStoragePath(fileUrlOrPath);
    const { data, error } = await supabase.storage
      .from(DOCUMENTS_BUCKET)
      .createSignedUrl(path, 3600);

    if (error) throw error;
    return data.signedUrl;
  },

  async saveDocument(
    companyId: string,
    docType: DocumentType,
    storagePath: string,
    fileName: string
  ): Promise<void> {
    const { error } = await supabase
      .from('company_documents')
      .upsert(
        {
          company_id: companyId,
          document_type: docType,
          file_url: storagePath,
          file_name: fileName,
          verified: 'pending',
        },
        { onConflict: 'company_id,document_type' }
      );

    if (error) throw error;
  },

  async uploadAndSaveDocuments(
    companyId: string,
    documents: DocumentFiles
  ): Promise<void> {
    const uploads: Promise<void>[] = [];

    const handle = async (file: File, type: DocumentType) => {
      const path = await this.uploadDocument(file, companyId, type);
      await this.saveDocument(companyId, type, path, file.name);
    };

    if (documents.gst) uploads.push(handle(documents.gst, 'gst_certificate'));
    if (documents.pan) uploads.push(handle(documents.pan, 'pan_card'));
    if (documents.utilityBill) uploads.push(handle(documents.utilityBill, 'utility_bill'));

    await Promise.all(uploads);
  },

  async getDocuments(companyId: string): Promise<DbCompanyDocument[]> {
    const { data, error } = await supabase
      .from('company_documents')
      .select('*')
      .eq('company_id', companyId);

    if (error) throw error;
    if (!data?.length) return [];

    return Promise.all(
      data.map(async (doc) => {
        try {
          const signedUrl = await this.getDocumentSignedUrl(doc.file_url);
          return { ...doc, file_url: signedUrl };
        } catch {
          return doc;
        }
      })
    );
  },

  async deleteDocument(companyId: string, docType: DocumentType): Promise<void> {
    const { error } = await supabase
      .from('company_documents')
      .delete()
      .eq('company_id', companyId)
      .eq('document_type', docType);

    if (error) throw error;
  },
};

