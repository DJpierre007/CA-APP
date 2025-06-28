/*
  # Create user_favorites table

  1. New Tables
    - `user_favorites`
      - `favorite_id` (serial, primary key)
      - `user_id` (integer, foreign key to users)
      - `product_id` (integer, foreign key to products)
      - `saved_at` (timestamptz, default now())
      - Unique constraint on (user_id, product_id)

  2. Security
    - Enable RLS on `user_favorites` table
    - Add policies for authenticated users to manage their own favorites

  3. Performance
    - Add indexes on user_id and product_id for better query performance
*/

CREATE TABLE IF NOT EXISTS user_favorites (
  favorite_id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
  product_id INTEGER REFERENCES products(product_id) ON DELETE CASCADE,
  saved_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, product_id)
);

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_favorites_user_id ON user_favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_user_favorites_product_id ON user_favorites(product_id);

ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist, then recreate them
DO $$
BEGIN
  -- Drop policies if they exist
  DROP POLICY IF EXISTS "Users can insert own favorites" ON user_favorites;
  DROP POLICY IF EXISTS "Users can read own favorites" ON user_favorites;
  DROP POLICY IF EXISTS "Users can delete own favorites" ON user_favorites;
  
  -- Create the policies
  CREATE POLICY "Users can insert own favorites"
    ON user_favorites
    FOR INSERT
    TO authenticated
    WITH CHECK (user_id = (current_setting('app.current_user_id'::text))::integer);

  CREATE POLICY "Users can read own favorites"
    ON user_favorites
    FOR SELECT
    TO authenticated
    USING (user_id = (current_setting('app.current_user_id'::text))::integer);

  CREATE POLICY "Users can delete own favorites"
    ON user_favorites
    FOR DELETE
    TO authenticated
    USING (user_id = (current_setting('app.current_user_id'::text))::integer);
END $$;