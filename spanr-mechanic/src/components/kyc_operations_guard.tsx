import { Navigate, useLocation } from 'react-router-dom';
import { useCompany } from '../company/company.hook';
import { isKycAllowedPath } from '../kyc/kyc.constants';

export const KycOperationsGuard: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const { operationsLocked } = useCompany();
  const { pathname } = useLocation();

  if (operationsLocked && !isKycAllowedPath(pathname)) {
    return <Navigate to="/company-profile" replace />;
  }

  return <>{children}</>;
};
