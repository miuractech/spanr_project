export interface UserDetailState {
  loading: boolean;
  user: { id: string; email: string; name: string } | null | undefined;
}

export interface DbUser {
  user_id: string;
  email: string;
  name: string;
  phone: string;
  created_at: string;
  updated_at: string;
}

