/**
 * Image and media-related type definitions
 */

import { ReactNode } from 'react';

// UI component types (not database tables)
export type EditConfigType = {
  aspect_x: number;
  aspect_y: number;
};

export interface MiuracImageProps {
  image?: string;
  auth_component?: React.ReactElement;
  update_firestore: boolean;
  edit_config: EditConfigType | null;
  set_url_func: (url: string | string[]) => unknown | void;
  button_component?: ReactNode;
  min_height?: number;
  min_width?: number;
  allow_multiple?: boolean;
  count?: (current: number, total: number) => void;
}

export type StateUrl = { 
  url: string; 
  file_name: string 
};

// Database table type for stored images
export interface DbImage {
  id: string;
  entity_type: 'company' | 'plan' | 'service' | 'order';
  entity_id: string;
  url: string;
  file_name: string;
  created_at: string;
}

