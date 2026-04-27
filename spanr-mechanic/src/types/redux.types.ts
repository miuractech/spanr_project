/**
 * Redux state-related type definitions
 */

import { mechanicCompanyProfile } from './company.types';
import { masterPlanType } from './plan.types';

export interface CompanyDetailState {
  companyProfile: mechanicCompanyProfile | null | undefined;
}

export type MasterPlanState = {
  plans: masterPlanType[];
};

// Note: RootState and AppDispatch types are typically generated from store.getState()
// and store.dispatch, so they should remain in their respective store.ts files
// export type RootState = ReturnType<typeof store.getState>
// export type AppDispatch = typeof store.dispatch

