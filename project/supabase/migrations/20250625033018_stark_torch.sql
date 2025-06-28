/*
  # Create search history table

  1. New Tables
    - `search_history`
      - `search_id` (integer, primary key, auto-increment)
      - `user_id` (integer, foreign key to users)
      - `search_query` (text, not null)
      - `search_date` (timestamptz, default now())
      - `country` (text, default 'UK')

  2. Security
    - Enable RLS on `search_history` table
    - Add policy for authenticated users to insert their own search history
    - Add policy for authenticated users to read their own search history

  3. Indexes
    - Add index on user_id for faster queries
    - Add index on search_date for chronological sorting
*/

CREATE TABLE IF NOT EXISTS search_history (
  search_id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
  search_query TEXT NOT NULL,
  search_date TIMESTAMPTZ DEFAULT now(),
  country TEXT DEFAULT 'UK'
);

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_search_history_user_id ON search_history(user_id);
CREATE INDEX IF NOT EXISTS idx_search_history_date ON search_history(search_date DESC);

ALTER TABLE search_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert own search history"
  ON search_history
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = (current_setting('app.current_user_id'::text))::integer);

CREATE POLICY "Users can read own search history"
  ON search_history
  FOR SELECT
  TO authenticated
  USING (user_id = (current_setting('app.current_user_id'::text))::integer);