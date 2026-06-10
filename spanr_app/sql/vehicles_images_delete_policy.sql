-- Allow users to delete images for their own vehicles
DROP POLICY IF EXISTS "Users can delete their vehicle images" ON images;
CREATE POLICY "Users can delete their vehicle images"
  ON images FOR DELETE
  TO authenticated
  USING (
    entity_type = 'vehicle'
    AND entity_id IN (
      SELECT id FROM vehicles WHERE user_id = auth.uid()
    )
  );
