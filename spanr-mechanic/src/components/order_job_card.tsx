import { useState, useEffect, useRef } from 'react';
import {
  Stack,
  Group,
  Button,
  TextInput,
  Textarea,
  Select,
  Checkbox,
  SimpleGrid,
  Text,
  Divider,
  Loader,
  SegmentedControl,
  Paper,
  Title,
  Badge,
} from '@mantine/core';
import { IconPrinter, IconDeviceFloppy } from '@tabler/icons-react';
import { ordersService } from '../orders/orders.service';
import type { OrderDetails } from '../orders/orders.types';
import bikeOutline from '../assets/bike-outline.jpg';
import carOutline from '../assets/car-outline.webp';

interface JobCardData {
  vehicle_tag_no: string;
  kms_run: string;
  fuel_level: string;
  key_no: string;
  color: string;
  vehicle_type: string;
  service_type: string;
  service_no: string;
  technician_name: string;
  supervisor_name: string;
  service_advisor_name: string;
  customer_requests: string[];
  vehicle_checklist: string[];
  accessories_checklist: string[];
  remarks: string;
  final_remarks: string;
  psf_done: string;
  payment_mode: string;
  invoice_no: string;
  delivery_date: string;
}

const defaultJobCard: JobCardData = {
  vehicle_tag_no: '',
  kms_run: '',
  fuel_level: '1/2',
  key_no: '',
  color: '',
  vehicle_type: '',
  service_type: '',
  service_no: '',
  technician_name: '',
  supervisor_name: '',
  service_advisor_name: '',
  customer_requests: [],
  vehicle_checklist: [],
  accessories_checklist: [],
  remarks: '',
  final_remarks: '',
  psf_done: 'No',
  payment_mode: '',
  invoice_no: '',
  delivery_date: '',
};

const CUSTOMER_REQUESTS = [
  'Mileage Problem', 'Vibration Problem', 'Chain/Belt Problem', 'Starting Trouble',
  'Engine Noise Problem', 'Handle Adjustment', 'Mirror Adjustment', 'Head Light Focus Problem',
  'One Side Pulling', 'Choke Problem', 'Self Not Working', 'Horn Not Working',
  'Light Problem', 'Battery Problem', 'Speedometer Problem', 'Engine Oil Change',
  'Brake Adjustment Fr & Rr', 'Clutch Adjustment', 'Oil Filter Replacement',
  'Air Filter Replacement', 'Spark Plug Replacement', 'All Fasteners Tighten',
];

const VEHICLE_CHECKLIST = [
  'Foot Rest', 'Inner Box', 'Side Stand', 'Tyre Bracket', 'Side Protector', 'Front Guard',
  'All Round Guard', 'Front Fender Guard', 'Front Crash Guard', 'Seat Cover',
  'Grip Cover', 'Mud Flap', 'Buzzer', 'Front Basket',
];

const ACCESSORIES_LIST = [
  'Rear Grip', 'Side Box', 'Luggage Net', 'Helmet Lock', 'Tyre Lock', 'Reg. No. Plate',
];

const SERVICE_TYPES = [
  'Free Service', 'Paid Service', 'General Repair', 'AMC', 'Extended Warranty', 'Accidental', 'Complaint',
];

interface OrderJobCardProps {
  orderId: string;
  order: OrderDetails;
}

const cell = (style?: React.CSSProperties): React.CSSProperties => ({
  border: '0.5px solid #999',
  padding: '3px 5px',
  ...style,
});

const sectionHeader = (style?: React.CSSProperties): React.CSSProperties => ({
  fontWeight: 700,
  fontSize: '8px',
  letterSpacing: '0.5px',
  textTransform: 'uppercase' as const,
  background: '#e8e8e8',
  padding: '2px 5px',
  borderBottom: '0.5px solid #999',
  ...style,
});

const checkRow = (checked: boolean, label: string) => (
  <div key={label} style={{ display: 'flex', alignItems: 'center', gap: '3px', marginBottom: '1px' }}>
    <span style={{
      flexShrink: 0,
      display: 'inline-block', width: '8px', height: '8px',
      border: '0.5px solid #555',
      background: checked ? '#222' : '#fff',
    }} />
    <span style={{ fontSize: '8px', lineHeight: '1.2' }}>{label}</span>
  </div>
);

export const OrderJobCard: React.FC<OrderJobCardProps> = ({ orderId, order }) => {
  const [data, setData] = useState<JobCardData>(defaultJobCard);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const printRef = useRef<HTMLDivElement>(null);

  const inferredVehicleType = 'Motorbike';

  useEffect(() => {
    loadJobCardData();
  }, [orderId]);

  const loadJobCardData = async () => {
    try {
      setLoading(true);
      const saved = await ordersService.getJobCardData(orderId);
      setData(prev => ({
        ...prev,
        ...(saved as Partial<JobCardData>),
        vehicle_type: (saved as Partial<JobCardData>)?.vehicle_type || inferredVehicleType,
      }));
    } catch (err) {
      console.error('Failed to load job card data:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async () => {
    try {
      setSaving(true);
      await ordersService.saveJobCardData(orderId, data as unknown as Record<string, unknown>);
    } catch (err) {
      console.error('Failed to save job card data:', err);
    } finally {
      setSaving(false);
    }
  };

  const toggleCheck = (field: 'customer_requests' | 'vehicle_checklist' | 'accessories_checklist', value: string) => {
    setData(prev => ({
      ...prev,
      [field]: prev[field].includes(value)
        ? prev[field].filter(v => v !== value)
        : [...prev[field], value],
    }));
  };

  const scheduledDate = new Date(order.scheduled_service_date);
  const totalAmount = Number(order.plan.base_price) * (1 + Number(order.plan.tax) / 100);

  if (loading) return <Loader />;

  return (
    <>
      <style>{`
        @page { size: A4 portrait; margin: 8mm; }
        @media print {
          html, body { margin: 0 !important; padding: 0 !important; }
          body * { visibility: hidden !important; }
          #job-card-print, #job-card-print * { visibility: visible !important; }
          #job-card-print {
            position: fixed !important;
            left: 0 !important; top: 0 !important;
            width: 100% !important;
            transform: none !important;
          }
          #job-card-print .jc-page {
            width: 194mm !important;
            height: 281mm !important;
            overflow: hidden !important;
            box-shadow: none !important;
          }
          .no-print { display: none !important; }
        }
      `}</style>

      {/* Action buttons */}
      <Group mb="md" className="no-print">
        <Button leftSection={<IconDeviceFloppy size={16} />} onClick={handleSave} loading={saving}>
          Save Job Card
        </Button>
        <Button leftSection={<IconPrinter size={16} />} variant="outline" onClick={() => window.print()}>
          Print / Download PDF
        </Button>
      </Group>

      {/* Edit form */}
      <Paper withBorder p="md" mb="xl" className="no-print">
        <Stack gap="md">
          <Title order={4}>Mechanic Details</Title>
          <SimpleGrid cols={{ base: 1, sm: 2, md: 3 }}>
            <TextInput label="Vehicle Tag No." value={data.vehicle_tag_no} onChange={e => setData({ ...data, vehicle_tag_no: e.target.value })} />
            <TextInput label="KMs Run / Odometer" value={data.kms_run} onChange={e => setData({ ...data, kms_run: e.target.value })} />
            <Select label="Fuel Level" data={['E', '1/4', '1/2', '3/4', 'F']} value={data.fuel_level} onChange={v => setData({ ...data, fuel_level: v ?? '1/2' })} />
            <TextInput label="Key No." value={data.key_no} onChange={e => setData({ ...data, key_no: e.target.value })} />
            <TextInput label="Color" value={data.color} onChange={e => setData({ ...data, color: e.target.value })} />
            <Select label="Vehicle Type" data={['Car', 'Motorbike']} value={data.vehicle_type} onChange={v => setData({ ...data, vehicle_type: v ?? '' })} clearable />
            <Select label="Type of Service" data={SERVICE_TYPES} value={data.service_type} onChange={v => setData({ ...data, service_type: v ?? '' })} clearable />
            <TextInput label="Service No." value={data.service_no} onChange={e => setData({ ...data, service_no: e.target.value })} />
            <TextInput label="Service Advisor" value={data.service_advisor_name} onChange={e => setData({ ...data, service_advisor_name: e.target.value })} />
            <TextInput label="Technician Name" value={data.technician_name} onChange={e => setData({ ...data, technician_name: e.target.value })} />
            <TextInput label="Supervisor Name" value={data.supervisor_name} onChange={e => setData({ ...data, supervisor_name: e.target.value })} />
            <TextInput label="Expected Delivery Date" placeholder="e.g. 31-08-2025" value={data.delivery_date} onChange={e => setData({ ...data, delivery_date: e.target.value })} />
            <TextInput label="Invoice No." value={data.invoice_no} onChange={e => setData({ ...data, invoice_no: e.target.value })} />
          </SimpleGrid>

          <Divider label="Customer Requests" labelPosition="center" />
          <SimpleGrid cols={{ base: 2, sm: 3, md: 4 }}>
            {CUSTOMER_REQUESTS.map(item => (
              <Checkbox key={item} label={item} checked={data.customer_requests.includes(item)} onChange={() => toggleCheck('customer_requests', item)} />
            ))}
          </SimpleGrid>

          <Divider label="Vehicle Checklist" labelPosition="center" />
          <SimpleGrid cols={{ base: 2, sm: 3, md: 4 }}>
            {VEHICLE_CHECKLIST.map(item => (
              <Checkbox key={item} label={item} checked={data.vehicle_checklist.includes(item)} onChange={() => toggleCheck('vehicle_checklist', item)} />
            ))}
          </SimpleGrid>

          <Divider label="Accessories" labelPosition="center" />
          <SimpleGrid cols={{ base: 2, sm: 3 }}>
            {ACCESSORIES_LIST.map(item => (
              <Checkbox key={item} label={item} checked={data.accessories_checklist.includes(item)} onChange={() => toggleCheck('accessories_checklist', item)} />
            ))}
          </SimpleGrid>

          <Divider label="Remarks & Payment" labelPosition="center" />
          <Textarea label="Remarks" value={data.remarks} onChange={e => setData({ ...data, remarks: e.target.value })} minRows={2} />
          <Textarea label="Final Service Remarks" value={data.final_remarks} onChange={e => setData({ ...data, final_remarks: e.target.value })} minRows={2} />
          <SimpleGrid cols={{ base: 1, sm: 2 }}>
            <div>
              <Text size="sm" fw={500} mb={4}>PSF Done</Text>
              <SegmentedControl data={['Yes', 'No']} value={data.psf_done} onChange={v => setData({ ...data, psf_done: v })} />
            </div>
            <Select label="Payment Mode" data={['Cash', 'Credit', 'Card', 'Warranty']} value={data.payment_mode} onChange={v => setData({ ...data, payment_mode: v ?? '' })} clearable />
          </SimpleGrid>
        </Stack>
      </Paper>

      {/* A4 Print Preview */}
      <div id="job-card-print" ref={printRef}>
        {/* Screen: show scaled preview */}
        <div style={{ overflowX: 'auto', background: '#ccc', padding: '16px', borderRadius: '4px' }}>
          <div
            className="jc-page"
            style={{
              width: '794px',
              height: '1123px',
              background: '#fff',
              boxShadow: '0 2px 8px rgba(0,0,0,0.3)',
              margin: '0 auto',
              fontFamily: 'Arial, Helvetica, sans-serif',
              fontSize: '9px',
              color: '#111',
              display: 'flex',
              flexDirection: 'column',
              boxSizing: 'border-box',
              border: '1px solid #aaa',
              overflow: 'hidden',
            }}
          >
            {/* ── ROW 1: Header ── */}
            <div style={{ display: 'flex', borderBottom: '1px solid #888', flexShrink: 0 }}>
              {/* Company */}
              <div style={{ ...cell(), flex: '0 0 200px', display: 'flex', flexDirection: 'column', justifyContent: 'center' }}>
                <div style={{ fontWeight: 900, fontSize: '13px', letterSpacing: '-0.3px' }}>SPANR</div>
                <div style={{ fontSize: '8px', color: '#555', marginTop: '1px' }}>Mechanic Services Platform</div>
              </div>
              {/* Job card meta */}
              <div style={{ ...cell({ borderLeft: 'none' }), flex: 1, display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '0' }}>
                <div style={{ borderRight: '0.5px solid #999', padding: '3px 5px' }}>
                  <div style={{ fontSize: '7px', color: '#666' }}>JOB CARD No.</div>
                  <div style={{ fontWeight: 700, fontSize: '10px' }}>{order.id.slice(0, 8).toUpperCase()}</div>
                </div>
                <div style={{ borderRight: '0.5px solid #999', padding: '3px 5px' }}>
                  <div style={{ fontSize: '7px', color: '#666' }}>In Date / Time</div>
                  <div style={{ fontWeight: 600 }}>{new Date(order.order_date || order.created_at).toLocaleDateString('en-IN')}</div>
                  <div style={{ fontSize: '7px', color: '#666', marginTop: '3px' }}>Vehicle Tag No.</div>
                  <div style={{ fontWeight: 600 }}>{data.vehicle_tag_no || '___________'}</div>
                </div>
                <div style={{ padding: '3px 5px' }}>
                  <div style={{ fontSize: '7px', color: '#666' }}>Exp. Delivery Date</div>
                  <div style={{ fontWeight: 600 }}>{data.delivery_date || scheduledDate.toLocaleDateString('en-IN')}</div>
                  <div style={{ fontSize: '7px', color: '#666', marginTop: '3px' }}>Status</div>
                  <div style={{ fontWeight: 700, fontSize: '8px', textTransform: 'uppercase' }}>{order.status.replace(/_/g, ' ')}</div>
                </div>
              </div>
            </div>

            {/* ── ROW 2: Customer + Vehicle ── */}
            <div style={{ display: 'flex', borderBottom: '1px solid #888', flexShrink: 0 }}>
              {/* Customer */}
              <div style={{ flex: 1, borderRight: '1px solid #888' }}>
                <div style={sectionHeader()}>Customer's Details</div>
                <div style={{ padding: '3px 5px' }}>
                  <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '9px' }}>
                    <tbody>
                      <tr>
                        <td style={{ fontWeight: 700, paddingRight: '6px', whiteSpace: 'nowrap', width: '50px' }}>Name</td>
                        <td>{order.contact_name || order.user.name}</td>
                      </tr>
                      <tr>
                        <td style={{ fontWeight: 700 }}>Address</td>
                        <td style={{ fontSize: '8px' }}>{order.service_address || order.contact_address}</td>
                      </tr>
                      <tr>
                        <td style={{ fontWeight: 700 }}>Phone</td>
                        <td>{order.contact_phone || order.user.phone}</td>
                      </tr>
                      <tr>
                        <td style={{ fontWeight: 700 }}>Email</td>
                        <td style={{ fontSize: '8px' }}>{order.contact_email || order.user.email}</td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
              {/* Vehicle */}
              <div style={{ flex: 1, borderRight: '1px solid #888' }}>
                <div style={sectionHeader()}>Vehicle Details</div>
                <div style={{ padding: '3px 5px' }}>
                  <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '9px' }}>
                    <tbody>
                      <tr><td style={{ fontWeight: 700, paddingRight: '6px', whiteSpace: 'nowrap', width: '60px' }}>Make/Model</td><td>{order.vehicle.make} {order.vehicle.model}</td></tr>
                      <tr><td style={{ fontWeight: 700 }}>Year</td><td>{order.vehicle.year}</td></tr>
                      <tr><td style={{ fontWeight: 700 }}>Reg. No.</td><td style={{ fontWeight: 600 }}>{order.vehicle.license_plate}</td></tr>
                      <tr><td style={{ fontWeight: 700 }}>Color</td><td>{data.color || '___________'}</td></tr>
                      <tr><td style={{ fontWeight: 700 }}>KMs Run</td><td>{data.kms_run || '___________'}</td></tr>
                      <tr><td style={{ fontWeight: 700 }}>Key No.</td><td>{data.key_no || '___________'}</td></tr>
                    </tbody>
                  </table>
                </div>
              </div>
              {/* Fuel + Service type */}
              <div style={{ flex: 1 }}>
                <div style={sectionHeader()}>Fuel Level</div>
                <div style={{ padding: '4px 5px', display: 'flex', gap: '3px', flexWrap: 'wrap' }}>
                  {['E', '1/4', '1/2', '3/4', 'F'].map(level => (
                    <span key={level} style={{
                      border: '0.5px solid #555', padding: '1px 5px',
                      background: data.fuel_level === level ? '#222' : '#fff',
                      color: data.fuel_level === level ? '#fff' : '#111',
                      fontWeight: data.fuel_level === level ? 700 : 400,
                      fontSize: '9px',
                    }}>{level}</span>
                  ))}
                </div>
                <div style={sectionHeader({ marginTop: '2px' })}>Type of Service</div>
                <div style={{ padding: '3px 5px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1px 8px' }}>
                  {SERVICE_TYPES.map(type => (
                    <div key={type} style={{ display: 'flex', alignItems: 'center', gap: '3px' }}>
                      <span style={{
                        flexShrink: 0, display: 'inline-block', width: '8px', height: '8px',
                        border: '0.5px solid #555',
                        background: data.service_type === type ? '#222' : '#fff',
                      }} />
                      <span style={{ fontSize: '8px' }}>{type}</span>
                    </div>
                  ))}
                </div>
                {(data.service_type === 'Free Service' || data.service_type === 'Paid Service') && (
                  <div style={{ padding: '0 5px 3px', fontSize: '8px' }}>
                    Service No.: <strong>{data.service_no || '___'}</strong>
                  </div>
                )}
              </div>
            </div>

            {/* ── ROW 3: Service info ── */}
            <div style={{ display: 'flex', borderBottom: '1px solid #888', flexShrink: 0 }}>
              <div style={{ flex: 1 }}>
                <div style={sectionHeader()}>Service Information</div>
                <div style={{ padding: '3px 5px', display: 'flex', gap: '16px', flexWrap: 'wrap' }}>
                  <span><strong>Service:</strong> {order.service.name}</span>
                  <span><strong>Plan:</strong> {order.plan.name}</span>
                  <span><strong>Scheduled:</strong> {scheduledDate.toLocaleDateString('en-IN')}</span>
                  {order.special_instructions && <span><strong>Note:</strong> {order.special_instructions}</span>}
                </div>
              </div>
            </div>

            {/* ── ROW 4: Checklists (main body) ── */}
            <div style={{ display: 'flex', borderBottom: '1px solid #888', flex: 1, minHeight: 0 }}>
              {/* Vehicle Checklist + Accessories */}
              <div style={{ flex: '0 0 170px', borderRight: '1px solid #888', display: 'flex', flexDirection: 'column' }}>
                <div style={sectionHeader()}>Vehicle Checklist</div>
                <div style={{ padding: '3px 5px', display: 'grid', gridTemplateColumns: '1fr 1fr', columnGap: '4px' }}>
                  {VEHICLE_CHECKLIST.map(item => checkRow(data.vehicle_checklist.includes(item), item))}
                </div>
                <div style={sectionHeader({ marginTop: '2px' })}>Accessories</div>
                <div style={{ padding: '3px 5px', display: 'grid', gridTemplateColumns: '1fr 1fr', columnGap: '4px' }}>
                  {ACCESSORIES_LIST.map(item => checkRow(data.accessories_checklist.includes(item), item))}
                </div>
              </div>

              {/* Customer Requests */}
              <div style={{ flex: '0 0 200px', borderRight: '1px solid #888', display: 'flex', flexDirection: 'column' }}>
                <div style={sectionHeader()}>Customer Request</div>
                <div style={{ padding: '3px 5px', display: 'grid', gridTemplateColumns: '1fr 1fr', columnGap: '4px' }}>
                  {CUSTOMER_REQUESTS.map(item => checkRow(data.customer_requests.includes(item), item))}
                </div>
              </div>

              {/* Vehicle diagram + Remarks + PSF */}
              <div style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
                {/* Vehicle diagram */}
                {data.vehicle_type && (
                  <div style={{
                    borderBottom: '0.5px solid #999',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    padding: '8px 6px',
                    background: '#fafafa',
                    flex: '0 0 auto',
                  }}>
                    {data.vehicle_type === 'Car' ? (
                      <img
                        src={carOutline}
                        alt="car outline"
                        style={{ height: '330px', width: 'auto', maxWidth: '100%', objectFit: 'contain', display: 'block' }}
                      />
                    ) : (
                      <div style={{ display: 'flex', alignItems: 'center' }}>
                        <img
                          src={bikeOutline}
                          alt="bike left"
                          style={{ height: '200px', width: 'auto', objectFit: 'contain', display: 'block' }}
                        />
                        <img
                          src={bikeOutline}
                          alt="bike right"
                          style={{ height: '200px', width: 'auto', objectFit: 'contain', display: 'block', transform: 'scaleX(-1)' }}
                        />
                      </div>
                    )}
                  </div>
                )}
                <div style={sectionHeader()}>Remarks</div>
                <div style={{ padding: '3px 5px', height: '178px', borderBottom: '0.5px solid #999', fontSize: '8px', whiteSpace: 'pre-wrap', overflow: 'hidden' }}>
                  {data.remarks || ''}
                </div>
                <div style={sectionHeader()}>Final Service Remarks</div>
                <div style={{ padding: '3px 5px', height: '178px', borderBottom: '0.5px solid #999', fontSize: '8px', whiteSpace: 'pre-wrap', overflow: 'hidden' }}>
                  {data.final_remarks || ''}
                </div>
                <div style={{ padding: '4px 5px', display: 'flex', alignItems: 'center', gap: '6px', borderBottom: '0.5px solid #999' }}>
                  <span style={{ fontSize: '8px', fontWeight: 700 }}>PSF Done:</span>
                  {['Yes', 'No'].map(v => (
                    <span key={v} style={{ display: 'inline-flex', alignItems: 'center', gap: '3px', fontSize: '8px' }}>
                      <span style={{
                        display: 'inline-block', width: '8px', height: '8px',
                        border: '0.5px solid #555',
                        background: data.psf_done === v ? '#222' : '#fff',
                      }} />
                      {v}
                    </span>
                  ))}
                </div>
              </div>
            </div>

            {/* ── ROW 5: Staff + Payment ── */}
            <div style={{ display: 'flex', borderBottom: '1px solid #888', flexShrink: 0 }}>
              <div style={{ flex: 1, borderRight: '1px solid #888' }}>
                <div style={sectionHeader()}>Staff</div>
                <div style={{ padding: '3px 5px', fontSize: '9px' }}>
                  <div><strong>Service Advisor:</strong> {data.service_advisor_name || '_____________________'}</div>
                  <div><strong>Technician:</strong> {data.technician_name || '_____________________'}</div>
                  <div><strong>Supervisor:</strong> {data.supervisor_name || '_____________________'}</div>
                </div>
              </div>
              <div style={{ flex: 2 }}>
                <div style={sectionHeader()}>Payment Details</div>
                <div style={{ padding: '3px 5px', display: 'flex', gap: '8px', alignItems: 'flex-start' }}>
                  <div style={{ flex: 1 }}>
                    <div style={{ display: 'flex', gap: '8px', marginBottom: '3px' }}>
                      {['Cash', 'Credit', 'Card', 'Warranty'].map(mode => (
                        <span key={mode} style={{ display: 'inline-flex', alignItems: 'center', gap: '3px', fontSize: '8px' }}>
                          <span style={{
                            display: 'inline-block', width: '8px', height: '8px',
                            border: '0.5px solid #555',
                            background: data.payment_mode === mode ? '#222' : '#fff',
                          }} />
                          {mode}
                        </span>
                      ))}
                    </div>
                    <div style={{ fontSize: '9px' }}>
                      <div><strong>Invoice No.:</strong> {data.invoice_no || '_______________'}</div>
                    </div>
                  </div>
                  <div style={{ borderLeft: '0.5px solid #ccc', paddingLeft: '8px', fontSize: '9px' }}>
                    <div><strong>Estimated Cost:</strong> ₹{totalAmount.toFixed(2)}</div>
                    {order.payment && (
                      <>
                        <div><strong>Paid:</strong> ₹{order.payment.amount} ({order.payment.status})</div>
                        <div><strong>Method:</strong> {order.payment.method}</div>
                      </>
                    )}
                  </div>
                </div>
              </div>
            </div>

            {/* ── ROW 6: Signatures ── */}
            <div style={{ display: 'flex', borderBottom: '1px solid #888', flexShrink: 0 }}>
              {['Customer Signature', 'Service Advisor', 'Floor Supervisor', 'Cashier Signature'].map((label, i) => (
                <div key={label} style={{
                  flex: 1,
                  borderRight: i < 3 ? '0.5px solid #888' : 'none',
                  padding: '5px',
                }}>
                  <div style={{ height: '30px' }} />
                  <div style={{ borderTop: '0.5px solid #444', paddingTop: '2px', fontSize: '8px', color: '#444' }}>{label}</div>
                </div>
              ))}
            </div>

            {/* ── Footer ── */}
            <div style={{ background: '#f2f2f2', padding: '3px 8px', flexShrink: 0, fontSize: '8px', color: '#666', borderTop: '0.5px solid #ccc' }}>
              <strong>Note:</strong> Vehicle will be charged ₹50/day parking after completion if not collected within 24 hours. | SPANR — {new Date().getFullYear()}
            </div>
          </div>
        </div>

        <div className="no-print" style={{ textAlign: 'center', marginTop: '8px' }}>
          <Badge color="gray" variant="outline" size="sm">A4 Preview — Save first, then Print / Download PDF</Badge>
        </div>
      </div>
    </>
  );
};
