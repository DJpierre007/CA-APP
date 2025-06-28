/*
  # Create user_favorites table with RLS policies

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
    - Users can insert, read, and delete their own favorites

  3. Performance
    - Add indexes on user_id and product_id for better query performance
*/

-- Create the user_favorites table if it doesn't exist
CREATE TABLE IF NOT EXISTS user_favorites (
  favorite_id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
  product_id INTEGER REFERENCES products(product_id) ON DELETE CASCADE,
  saved_at TIMESTAMPTZ DEFAULT now()
);

-- Add unique constraint if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'user_favorites_user_id_product_id_key' 
    AND table_name = 'user_favorites'
  ) THEN
    ALTER TABLE user_favorites ADD CONSTRAINT user_favorites_user_id_product_id_key UNIQUE(user_id, product_id);
  END IF;
END $$;

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_favorites_user_id ON user_favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_user_favorites_product_id ON user_favorites(product_id);

-- Enable RLS
ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;

-- Create policies with proper existence checks
DO $$
BEGIN
  -- Insert policy
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'user_favorites' 
    AND policyname = 'Users can insert own favorites'
  ) THEN
    CREATE POLICY "Users can insert own favorites"
      ON user_favorites
      FOR INSERT
      TO authenticated
      WITH CHECK (user_id = (current_setting('app.current_user_id'::text))::integer);
  END IF;

  -- Select policy
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'user_favorites' 
    AND policyname = 'Users can read own favorites'
  ) THEN
    CREATE POLICY "Users can read own favorites"
      ON user_favorites
      FOR SELECT
      TO authenticated
      USING (user_id = (current_setting('app.current_user_id'::text))::integer);
  END IF;

  -- Delete policy
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'user_favorites' 
    AND policyname = 'Users can delete own favorites'
  ) THEN
    CREATE POLICY "Users can delete own favorites"
      ON user_favorites
      FOR DELETE
      TO authenticated
      USING (user_id = (current_setting('app.current_user_id'::text))::integer);
  END IF;
END $$;