/*
  # Fix user_id column type conversion from integer to UUID

  This migration converts the user_id columns from integer to UUID across all tables
  to properly integrate with Supabase Auth.

  ## Changes Made
  1. Drop all existing policies and constraints
  2. Clear existing data (required for primary key type change)
  3. Convert user_id columns to UUID type
  4. Recreate foreign key constraints
  5. Recreate RLS policies using auth.uid()

  ## Tables Modified
  - users: user_id column converted to UUID
  - search_history: user_id foreign key converted to UUID
  - user_favorites: user_id foreign key converted to UUID

  ## Security
  - All RLS policies recreated to use auth.uid()
  - Foreign key constraints maintained for data integrity
*/

-- Step 1: Drop ALL existing policies (including ones from schema)
DROP POLICY IF EXISTS "Users can insert their profile" ON users;
DROP POLICY IF EXISTS "Users can update their profile" ON users;
DROP POLICY IF EXISTS "Users can view their profile" ON users;
DROP POLICY IF EXISTS "Users can read own profile" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;
DROP POLICY IF EXISTS "Users can insert own profile during signup" ON users;
DROP POLICY IF EXISTS "Allow user creation during signup" ON users;

DROP POLICY IF EXISTS "Users can insert own search history" ON search_history;
DROP POLICY IF EXISTS "Users can read own search history" ON search_history;

DROP POLICY IF EXISTS "Users can insert own favorites" ON user_favorites;
DROP POLICY IF EXISTS "Users can read own favorites" ON user_favorites;
DROP POLICY IF EXISTS "Users can delete own favorites" ON user_favorites;

DROP POLICY IF EXISTS "Authenticated users can insert products" ON products;
DROP POLICY IF EXISTS "Authenticated users can read products" ON products;

-- Step 2: Drop existing foreign key constraints
ALTER TABLE search_history DROP CONSTRAINT IF EXISTS search_history_user_id_fkey;
ALTER TABLE user_favorites DROP CONSTRAINT IF EXISTS user_favorites_user_id_fkey;
ALTER TABLE user_favorites DROP CONSTRAINT IF EXISTS user_favorites_product_id_fkey;

-- Step 3: Clear existing data (required for primary key type change)
-- WARNING: This will delete all existing data
TRUNCATE TABLE user_favorites CASCADE;
TRUNCATE TABLE search_history CASCADE;
TRUNCATE TABLE users CASCADE;

-- Step 4: Modify the users table
-- Drop the existing primary key and sequence
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_pkey;
DROP SEQUENCE IF EXISTS users_user_id_seq CASCADE;

-- Change user_id column to UUID with proper default
ALTER TABLE users ALTER COLUMN user_id TYPE UUID USING gen_random_uuid();
ALTER TABLE users ALTER COLUMN user_id SET DEFAULT gen_random_uuid();

-- Re-add primary key constraint
ALTER TABLE users ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);

-- Step 5: Modify search_history table
ALTER TABLE search_history ALTER COLUMN user_id TYPE UUID;

-- Step 6: Modify user_favorites table  
ALTER TABLE user_favorites ALTER COLUMN user_id TYPE UUID;

-- Step 7: Re-add foreign key constraints
ALTER TABLE search_history 
  ADD CONSTRAINT search_history_user_id_fkey 
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;

ALTER TABLE user_favorites 
  ADD CONSTRAINT user_favorites_user_id_fkey 
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;

ALTER TABLE user_favorites 
  ADD CONSTRAINT user_favorites_product_id_fkey 
  FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE;

-- Step 8: Recreate RLS policies using proper auth functions

-- Users table policies
CREATE POLICY "Users can insert their profile"
  ON users
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their profile"
  ON users
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can view their profile"
  ON users
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Search history policies
CREATE POLICY "Users can insert own search history"
  ON search_history
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can read own search history"
  ON search_history
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- User favorites policies
CREATE POLICY "Users can insert own favorites"
  ON user_favorites
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can read own favorites"
  ON user_favorites
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can delete own favorites"
  ON user_favorites
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

-- Products table policies (recreate existing ones)
CREATE POLICY "Authenticated users can insert products"
  ON products
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can read products"
  ON products
  FOR SELECT
  TO authenticated
  USING (true);