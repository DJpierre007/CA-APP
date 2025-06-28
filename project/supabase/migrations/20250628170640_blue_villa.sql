/*
  # Fix user_id column type and RLS policies

  1. Database Changes
    - Drop all existing RLS policies that depend on user_id
    - Change user_id from integer to UUID in all tables
    - Update foreign key constraints
    - Recreate RLS policies with proper auth.uid() references

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users to manage their own data
    - Use auth.uid() for proper Supabase Auth integration

  Note: This migration will clear existing user data due to primary key type change
*/

-- Step 1: Drop ALL existing policies that might reference user_id
DROP POLICY IF EXISTS "Users can read own profile" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;
DROP POLICY IF EXISTS "Users can insert own profile during signup" ON users;
DROP POLICY IF EXISTS "Allow user creation during signup" ON users;
DROP POLICY IF EXISTS "Users can insert their profile" ON users;
DROP POLICY IF EXISTS "Users can update their profile" ON users;
DROP POLICY IF EXISTS "Users can view their profile" ON users;
DROP POLICY IF EXISTS "Users can insert own search history" ON search_history;
DROP POLICY IF EXISTS "Users can read own search history" ON search_history;
DROP POLICY IF EXISTS "Users can insert own favorites" ON user_favorites;
DROP POLICY IF EXISTS "Users can read own favorites" ON user_favorites;
DROP POLICY IF EXISTS "Users can delete own favorites" ON user_favorites;

-- Step 2: Drop existing foreign key constraints
ALTER TABLE search_history DROP CONSTRAINT IF EXISTS search_history_user_id_fkey;
ALTER TABLE user_favorites DROP CONSTRAINT IF EXISTS user_favorites_user_id_fkey;

-- Step 3: Clear existing data (required for primary key type change)
TRUNCATE TABLE user_favorites CASCADE;
TRUNCATE TABLE search_history CASCADE;
TRUNCATE TABLE users CASCADE;

-- Step 4: Modify the users table structure
-- Drop the existing primary key and sequence
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_pkey;
DROP SEQUENCE IF EXISTS users_user_id_seq CASCADE;

-- Change user_id column to UUID with proper default
ALTER TABLE users ALTER COLUMN user_id TYPE UUID USING gen_random_uuid();
ALTER TABLE users ALTER COLUMN user_id SET DEFAULT gen_random_uuid();

-- Re-add primary key constraint
ALTER TABLE users ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);

-- Step 5: Update related tables to use UUID
ALTER TABLE search_history ALTER COLUMN user_id TYPE UUID;
ALTER TABLE user_favorites ALTER COLUMN user_id TYPE UUID;

-- Step 6: Re-add foreign key constraints
ALTER TABLE search_history 
  ADD CONSTRAINT search_history_user_id_fkey 
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;

ALTER TABLE user_favorites 
  ADD CONSTRAINT user_favorites_user_id_fkey 
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;

-- Step 7: Ensure RLS is enabled on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE search_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Step 8: Create comprehensive RLS policies

-- Users table policies
CREATE POLICY "Users can view their profile"
  ON users
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can update their profile"
  ON users
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can insert their profile"
  ON users
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

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

-- Products table policies (fix for the original RLS error)
CREATE POLICY "Authenticated users can read products"
  ON products
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Allow product inserts for search results"
  ON products
  FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);