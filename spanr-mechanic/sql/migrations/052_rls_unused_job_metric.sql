-- Security advisor: rls_disabled_in_public
-- public."Job" and public."Metric" are not used by SPANR (PascalCase leftovers).
-- Enable RLS and block PostgREST client roles. Service role still bypasses RLS.

DO $$
BEGIN
  IF to_regclass('public."Job"') IS NOT NULL THEN
    ALTER TABLE public."Job" ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public."Job" FORCE ROW LEVEL SECURITY;
    REVOKE ALL ON TABLE public."Job" FROM anon, authenticated;
    DROP POLICY IF EXISTS "No client access to Job" ON public."Job";
    CREATE POLICY "No client access to Job"
      ON public."Job"
      FOR ALL
      TO anon, authenticated
      USING (false)
      WITH CHECK (false);
  END IF;

  IF to_regclass('public."Metric"') IS NOT NULL THEN
    ALTER TABLE public."Metric" ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public."Metric" FORCE ROW LEVEL SECURITY;
    REVOKE ALL ON TABLE public."Metric" FROM anon, authenticated;
    DROP POLICY IF EXISTS "No client access to Metric" ON public."Metric";
    CREATE POLICY "No client access to Metric"
      ON public."Metric"
      FOR ALL
      TO anon, authenticated
      USING (false)
      WITH CHECK (false);
  END IF;
END $$;
