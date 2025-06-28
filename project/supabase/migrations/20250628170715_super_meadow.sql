/*
  # Fix User ID Type and RLS Policies

  1. Schema Changes
    - Convert user_id from integer to UUID in users table
    - Update foreign key references in search_history and user_favorites
    - Clear existing data due to primary key type change

  2. Security Updates
    - Drop and recreate all RLS policies to use auth.uid()
    - Ensure RLS is enabled on all tables
    - Fix products table policies to allow proper access

  3. Important Notes
    - This migration will clear all existing user data
    - All policies are recreated to use proper UUID references
    - Products table policies are updated to fix RLS errors
*/

-- Step 1: Drop ALL existing policies from all tables
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

-- Drop existing products table policies
DROP POLICY IF EXISTS "Authenticated users can read products" ON products;
DROP POLICY IF EXISTS "Allow product inserts for search results" ON products;

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