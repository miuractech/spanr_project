import { useState, useEffect } from 'react';
import { ordersService } from './orders.service';
import type { OrderDetails, OrderFilters, PaginatedOrders } from './orders.types';

export const useOrders = (
  companyId?: string,
  page: number = 1,
  pageSize: number = 10,
  filters?: OrderFilters
) => {
  const [paginatedOrders, setPaginatedOrders] = useState<PaginatedOrders>({
    data: [],
    total: 0,
    page: 1,
    pageSize: 10,
    totalPages: 0,
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchOrders = async () => {
    if (!companyId) {
      setLoading(false);
      return;
    }

    try {
      setLoading(true);
      const data = await ordersService.getOrdersByCompany(companyId, page, pageSize, filters);
      setPaginatedOrders(data);
      setError(null);
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchOrders();
  }, [companyId, page, pageSize, filters?.status, filters?.startDate, filters?.endDate, filters?.search]);

  const refreshOrders = () => {
    fetchOrders();
  };

  return {
    orders: paginatedOrders.data,
    total: paginatedOrders.total,
    page: paginatedOrders.page,
    pageSize: paginatedOrders.pageSize,
    totalPages: paginatedOrders.totalPages,
    loading,
    error,
    refreshOrders,
  };
};

export const useOrderStats = (companyId?: string) => {
  const [stats, setStats] = useState({
    total: 0,
    created: 0,
    accepted: 0,
    inProgress: 0,
    readyForDelivery: 0,
    completed: 0,
    dispute: 0,
    cancelled: 0,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!companyId) {
      setLoading(false);
      return;
    }

    ordersService.getOrderStats(companyId).then((data) => {
      setStats(data);
      setLoading(false);
    });
  }, [companyId]);

  return { stats, loading };
};

