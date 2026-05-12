-- company_ratings INSERT is blocked for JWT users when no INSERT policy exists or policies fail.
-- Create default ratings row server-side (bypasses RLS) when a mechanic company is created.

CREATE OR REPLACE FUNCTION public.ensure_company_ratings_row()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.company_ratings (company_id, count, professionalism, timeliness, quality, rating)
  VALUES (NEW.id, 0, 0, 0, 0, 0)
  ON CONFLICT (company_id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS mechanic_companies_ensure_company_ratings ON public.mechanic_companies;

CREATE TRIGGER mechanic_companies_ensure_company_ratings
  AFTER INSERT ON public.mechanic_companies
  FOR EACH ROW
  EXECUTE FUNCTION public.ensure_company_ratings_row();

-- Backfill companies missing a ratings row (e.g. failed onboarding before this migration)
INSERT INTO public.company_ratings (company_id, count, professionalism, timeliness, quality, rating)
SELECT mc.id, 0, 0, 0, 0, 0
FROM public.mechanic_companies mc
WHERE NOT EXISTS (
  SELECT 1 FROM public.company_ratings cr WHERE cr.company_id = mc.id
)
ON CONFLICT (company_id) DO NOTHING;
