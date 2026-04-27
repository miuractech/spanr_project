/**
 * Supabase Client Initialization Example
 * 
 * Copy this file to your src/lib/supabase.ts and adjust as needed.
 */

import { createSupabaseClient } from '@spanr/types';

// Get environment variables
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

// For Next.js, use:
// const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
// const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error(
    'Missing Supabase environment variables. ' +
    'Please check your .env file has VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY'
  );
}

// Create typed Supabase client
export const supabase = createSupabaseClient(supabaseUrl, supabaseAnonKey);

// Export types for convenience
export type { Database } from '@spanr/types';

/**
 * Helper function to handle Supabase errors
 */
export function handleSupabaseError(error: any): never {
  console.error('Supabase error:', error);
  throw new Error(error.message || 'An error occurred with the database');
}

/**
 * Helper function for safe queries (returns data or throws)
 */
export async function queryOrThrow<T>(
  queryPromise: Promise<{ data: T | null; error: any }>
): Promise<T> {
  const { data, error } = await queryPromise;
  if (error) handleSupabaseError(error);
  if (!data) throw new Error('No data returned from query');
  return data;
}

/**
 * Example: Get current authenticated user's ID from Supabase
 */
export async function getCurrentUserId(): Promise<string | null> {
  const { data: { user } } = await supabase.auth.getUser();
  return user?.id || null;
}

/**
 * Example: Get user by Firebase UID
 */
export async function getUserByFirebaseUid(firebaseUid: string) {
  return queryOrThrow(
    supabase
      .from('users')
      .select('*')
      .eq('user_id', firebaseUid)
      .single()
  );
}

/**
 * Example: Create or update user
 */
export async function upsertUser(userData: {
  user_id: string;
  email: string;
  name: string;
  phone: string;
}) {
  return queryOrThrow(
    supabase
      .from('users')
      .upsert(userData, { onConflict: 'user_id' })
      .select()
      .single()
  );
}

// ===========================================
// Real-time Helpers
// ===========================================

/**
 * Subscribe to table changes
 */
export function subscribeToTable<T = any>(
  table: string,
  callback: (payload: {
    eventType: 'INSERT' | 'UPDATE' | 'DELETE';
    new: T | null;
    old: T | null;
  }) => void,
  filter?: string
) {
  const channel = supabase.channel(`${table}-changes`);
  
  channel.on(
    'postgres_changes',
    {
      event: '*',
      schema: 'public',
      table,
      ...(filter && { filter }),
    },
    callback as any
  );

  channel.subscribe();

  // Return unsubscribe function
  return () => {
    channel.unsubscribe();
  };
}

/**
 * Example: Subscribe to company's orders
 */
export function subscribeToCompanyOrders(
  companyId: string,
  callback: (order: any) => void
) {
  return subscribeToTable(
    'orders',
    async (payload) => {
      // Fetch full order details
      const { data } = await supabase
        .from('order_details')
        .select('*')
        .eq('id', payload.new?.id || payload.old?.id)
        .single();
      
      if (data) callback(data);
    },
    `company_id=eq.${companyId}`
  );
}

// ===========================================
// Auth Helpers (if using Supabase Auth)
// ===========================================

/**
 * Sign in with email and password
 */
export async function signInWithEmail(email: string, password: string) {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });
  
  if (error) handleSupabaseError(error);
  return data;
}

/**
 * Sign up with email and password
 */
export async function signUpWithEmail(
  email: string,
  password: string,
  metadata?: { name?: string; phone?: string }
) {
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: metadata,
    },
  });
  
  if (error) handleSupabaseError(error);
  return data;
}

/**
 * Sign out
 */
export async function signOut() {
  const { error } = await supabase.auth.signOut();
  if (error) handleSupabaseError(error);
}

/**
 * Get current session
 */
export async function getSession() {
  const { data: { session }, error } = await supabase.auth.getSession();
  if (error) handleSupabaseError(error);
  return session;
}

/**
 * Listen to auth state changes
 */
export function onAuthStateChange(
  callback: (event: string, session: any) => void
) {
  const { data: { subscription } } = supabase.auth.onAuthStateChange(callback);
  return () => subscription.unsubscribe();
}

// ===========================================
// Storage Helpers
// ===========================================

/**
 * Upload file to storage
 */
export async function uploadFile(
  bucket: string,
  path: string,
  file: File
): Promise<string> {
  const { data, error } = await supabase.storage
    .from(bucket)
    .upload(path, file, {
      cacheControl: '3600',
      upsert: false,
    });

  if (error) handleSupabaseError(error);

  // Get public URL
  const { data: { publicUrl } } = supabase.storage
    .from(bucket)
    .getPublicUrl(data.path);

  return publicUrl;
}

/**
 * Delete file from storage
 */
export async function deleteFile(bucket: string, path: string) {
  const { error } = await supabase.storage.from(bucket).remove([path]);
  if (error) handleSupabaseError(error);
}

/**
 * Get signed URL for private file
 */
export async function getSignedUrl(
  bucket: string,
  path: string,
  expiresIn = 3600
): Promise<string> {
  const { data, error } = await supabase.storage
    .from(bucket)
    .createSignedUrl(path, expiresIn);

  if (error) handleSupabaseError(error);
  return data.signedUrl;
}

// ===========================================
// Batch Operations
// ===========================================

/**
 * Batch insert with transaction safety
 */
export async function batchInsert<T>(table: string, records: Partial<T>[]) {
  return queryOrThrow(
    supabase.from(table).insert(records).select()
  );
}

/**
 * Batch update
 */
export async function batchUpdate<T>(
  table: string,
  records: Array<{ id: string } & Partial<T>>
) {
  const promises = records.map(record =>
    supabase
      .from(table)
      .update(record)
      .eq('id', record.id)
      .select()
      .single()
  );

  const results = await Promise.all(promises);
  
  const errors = results.filter(r => r.error);
  if (errors.length > 0) {
    throw new Error(`Batch update failed: ${errors.map(e => e.error.message).join(', ')}`);
  }

  return results.map(r => r.data);
}

// ===========================================
// Pagination Helper
// ===========================================

export interface PaginationParams {
  page: number;
  pageSize: number;
}

export interface PaginatedResult<T> {
  data: T[];
  page: number;
  pageSize: number;
  totalCount: number;
  totalPages: number;
}

/**
 * Paginated query helper
 */
export async function paginatedQuery<T>(
  queryBuilder: any,
  { page, pageSize }: PaginationParams
): Promise<PaginatedResult<T>> {
  const from = (page - 1) * pageSize;
  const to = from + pageSize - 1;

  const { data, error, count } = await queryBuilder
    .range(from, to)
    .select('*', { count: 'exact' });

  if (error) handleSupabaseError(error);

  return {
    data: data || [],
    page,
    pageSize,
    totalCount: count || 0,
    totalPages: Math.ceil((count || 0) / pageSize),
  };
}

// Example usage:
// const result = await paginatedQuery<DbMechanicCompany>(
//   supabase.from('mechanic_companies').select('*').eq('city', 'Mumbai'),
//   { page: 1, pageSize: 10 }
// );

