import { useParams, useNavigate } from 'react-router-dom';
import {
  Container,
  Title,
  Paper,
  Stack,
  Group,
  Text,
  Badge,
  Button,
  SimpleGrid,
  Image,
  Accordion,
  List,
  Alert,
} from '@mantine/core';
import { IconArrowLeft, IconClock, IconCoin } from '@tabler/icons-react';
import { usePlanDetails } from '../plans/plans.hook';

export default function PlanDetailPage() {
  const { planId } = useParams<{ planId: string }>();
  const navigate = useNavigate();
  const { planDetails, loading, error } = usePlanDetails(planId);

  if (loading) return <div>Loading...</div>;
  if (error) return <Alert color="red">{error}</Alert>;
  if (!planDetails) return <Alert color="yellow">Plan not found</Alert>;

  const totalPrice = Number(planDetails.base_price) * (1 + Number(planDetails.tax) / 100);

  return (
    <Container size="lg" my={40}>
      <Button
        leftSection={<IconArrowLeft size={16} />}
        variant="subtle"
        color="orange"
        onClick={() => navigate('/plans')}
        mb="xl"
      >
        Back to Plans
      </Button>

      <Paper withBorder shadow="sm" p="xl" radius="md" style={{ backgroundColor: '#FFFFFF' }}>
        <Stack gap="xl">
          <div>
            <Title mb="xs">{planDetails.name}</Title>
            <Group gap="xs">
              <Badge color="orange">{planDetails.vehicle_type}</Badge>
              <Badge color="orange">{planDetails.location_type}</Badge>
              {planDetails.badge && <Badge color="green">{planDetails.badge}</Badge>}
              {planDetails.fuelTypes.map(ft => (
                <Badge key={ft} variant="light" color="orange">{ft}</Badge>
              ))}
            </Group>
          </div>

          <SimpleGrid cols={2}>
            <div>
              <Group gap={5} mb="xs">
                <IconClock size={18} />
                <Text fw={500}>Duration</Text>
              </Group>
              <Text>{planDetails.duration} minutes</Text>
            </div>

            <div>
              <Group gap={5} mb="xs">
                <IconCoin size={18} />
                <Text fw={500}>Pricing</Text>
              </Group>
              <Text>Base: ₹{planDetails.base_price}</Text>
              <Text size="sm" c="dimmed">Tax: {planDetails.tax}%</Text>
              <Text fw={500}>Total: ₹{totalPrice.toFixed(2)}</Text>
            </div>
          </SimpleGrid>

          {planDetails.warranty && (
            <div>
              <Text fw={500} mb="xs">Warranty</Text>
              <Text>{planDetails.warranty}</Text>
            </div>
          )}

          {planDetails.guarantee && (
            <div>
              <Text fw={500} mb="xs">Guarantee</Text>
              <Text>{planDetails.guarantee}</Text>
            </div>
          )}

          {planDetails.features.length > 0 && (
            <div>
              <Text fw={500} mb="xs">Features</Text>
              <List>
                {planDetails.features.map((f) => (
                  <List.Item key={f.id}>{f.feature}</List.Item>
                ))}
              </List>
            </div>
          )}

          {planDetails.steps.length > 0 && (
            <div>
              <Text fw={500} mb="xs">Process Steps</Text>
              <List type="ordered">
                {planDetails.steps.map((s) => (
                  <List.Item key={s.id}>{s.step_description}</List.Item>
                ))}
              </List>
            </div>
          )}

          {planDetails.additionalServices.length > 0 && (
            <div>
              <Text fw={500} mb="xs">Additional Services Available</Text>
              <List>
                {planDetails.additionalServices.map((a) => (
                  <List.Item key={a.id}>{a.service_name}</List.Item>
                ))}
              </List>
            </div>
          )}

          {planDetails.serviceOutcomes.length > 0 && (
            <div>
              <Text fw={500} mb="md">Service Outcomes</Text>
              <SimpleGrid cols={2}>
                {planDetails.serviceOutcomes.map((outcome) => (
                  <Paper key={outcome.id} withBorder p="md">
                    {outcome.image_url && (
                      <Image
                        src={outcome.image_url}
                        alt={outcome.title}
                        h={150}
                        mb="md"
                        fit="cover"
                      />
                    )}
                    <Text fw={500} mb="xs">{outcome.title}</Text>
                    <Text size="sm">{outcome.description}</Text>
                  </Paper>
                ))}
              </SimpleGrid>
            </div>
          )}

          {planDetails.faqs.length > 0 && (
            <div>
              <Text fw={500} mb="md">Frequently Asked Questions</Text>
              <Accordion>
                {planDetails.faqs.map((faq) => (
                  <Accordion.Item key={faq.id} value={faq.id}>
                    <Accordion.Control>{faq.question}</Accordion.Control>
                    <Accordion.Panel>{faq.answer}</Accordion.Panel>
                  </Accordion.Item>
                ))}
              </Accordion>
            </div>
          )}
        </Stack>
      </Paper>
    </Container>
  );
}

