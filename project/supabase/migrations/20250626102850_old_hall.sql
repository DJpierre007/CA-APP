/*
  # Change user_id from integer to UUID for Supabase Auth compatibility

  1. Schema Changes
    - Change `users.user_id` from integer to UUID
    - Change `search_history.user_id` from integer to UUID  
    - Change `user_favorites.user_id` from integer to UUID
    - Update all foreign key constraints
    - Set default value for user_id to auth.uid()

  2. Security Updates
    - Update all RLS policies to use auth.uid() directly
    - Remove complex type casting from policies
    - Ensure policies work with UUID comparisons

  3. Data Migration
    - This migration assumes you're starting fresh or have minimal test data
    - For production data, you'd need a more complex migration strategy
*/

-- Step 1: Drop existing foreign key constraints and policies
ALTER TABLE search_history DROP CONSTRAINT IF EXISTS search_history_user_id_fkey;
ALTER TABLE user_favorites DROP CONSTRAINT IF EXISTS user_favorites_user_id_fkey;

-- Drop existing policies that reference the old integer user_id
DROP POLICY IF EXISTS "Users can read own profile" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;
DROP POLICY IF EXISTS "Users can insert own profile during signup" ON users;
DROP POLICY IF EXISTS "Allow user creation during signup" ON users;
DROP POLICY IF EXISTS "Users can insert own search history" ON search_history;
DROP POLICY IF EXISTS "Users can read own search history" ON search_history;
DROP POLICY IF EXISTS "Users can insert own favorites" ON user_favorites;
DROP POLICY IF EXISTS "Users can read own favorites" ON user_favorites;
DROP POLICY IF EXISTS "Users can delete own favorites" ON user_favorites;

-- Step 2: Clear existing data (since we're changing the primary key type)
-- WARNING: This will delete all existing data
TRUNCATE TABLE user_favorites CASCADE;
TRUNCATE TABLE search_history CASCADE;
TRUNCATE TABLE users CASCADE;

-- Step 3: Modify the users table
-- Drop the existing primary key and sequence
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_pkey;
DROP SEQUENCE IF EXISTS users_user_id_seq CASCADE;

-- Change user_id column to UUID
ALTER TABLE users ALTER COLUMN user_id TYPE UUID USING gen_random_uuid();
ALTER TABLE users ALTER COLUMN user_id SET DEFAULT auth.uid();

-- Re-add primary key constraint
ALTER TABLE users ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);

-- Step 4: Modify search_history table
ALTER TABLE search_history ALTER COLUMN user_id TYPE UUID;

-- Step 5: Modify user_favorites table  
ALTER TABLE user_favorites ALTER COLUMN user_id TYPE UUID;

-- Step 6: Re-add foreign key constraints
ALTER TABLE search_history 
  ADD CONSTRAINT search_history_user_id_fkey 
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;

ALTER TABLE user_favorites 
  ADD CONSTRAINT user_favorites_user_id_fkey 
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;

-- Step 7: Create new RLS policies using auth.uid() directly

-- Users table policies
CREATE POLICY "Users can read own profile"
  ON users
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can update own profile"
  ON users
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own profile during signup"
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