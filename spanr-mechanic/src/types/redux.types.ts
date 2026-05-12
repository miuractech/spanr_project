/**
 * Redux state-related type definitions
 */

import type { MechanicCompanyProfile } from './company.types';
import type { MasterPlanType } from './plan.types';

export interface CompanyDetailState {
  companyProfile: MechanicCompanyProfile | null | undefined;
}

export type MasterPlanState = {
  plans: MasterPlanType[];
};

// Note: RootState and AppDispatch types are typically generated from store.getState()
// and store.dispatch, so they should remain in their respective store.ts files
// export type RootState = ReturnType<typeof store.getState>
// export type AppDispatch = typeof store.dispatch

