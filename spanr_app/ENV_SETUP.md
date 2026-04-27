# Environment Setup

## Steps to Configure Environment Variables

1. **Copy the example file:**
   ```bash
   cp .env.example .env
   ```

2. **Fill in your Supabase credentials:**
   Open `.env` and replace the placeholder values:
   ```
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   ```

3. **Get your Supabase credentials:**
   - Go to your Supabase project dashboard
   - Navigate to Settings > API
   - Copy the Project URL and anon/public key

4. **Run the app:**
   ```bash
   flutter pub get
   flutter run
   ```

## Important Notes

- The `.env` file is gitignored and will not be committed to version control
- Never commit your actual Supabase credentials to git
- Each developer/environment should have their own `.env` file


