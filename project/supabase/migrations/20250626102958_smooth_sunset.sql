/*
  # Change user_id from integer to UUID for Supabase Auth compatibility

  1. Database Schema Changes
    - Convert users.user_id from integer to UUID
    - Update search_history.user_id to UUID
    - Update user_favorites.user_id to UUID
    - Set default value for user_id to auth.uid()

  2. Security Updates
    - Drop and recreate all RLS policies to use auth.uid() directly
    - Remove complex type casting from policies
    - Ensure proper authentication flow

  3. Data Handling
    - Clear existing data due to primary key type change
    - Recreate foreign key constraints
    - Maintain referential integrity
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

-- Drop and recreate the user_id column as UUID
ALTER TABLE users DROP COLUMN user_id;
ALTER TABLE users ADD COLUMN user_id UUID PRIMARY KEY DEFAULT auth.uid();

-- Step 4: Modify search_history table
-- Drop and recreate user_id column as UUID
ALTER TABLE search_history DROP COLUMN IF EXISTS user_id;
ALTER TABLE search_history ADD COLUMN user_id UUID;

-- Step 5: Modify user_favorites table
-- Drop and recreate user_id column as UUID
ALTER TABLE user_favorites DROP COLUMN IF EXISTS user_id;
ALTER TABLE user_favorites ADD COLUMN user_id UUID;

-- Step 6: Re-add foreign key constraints
ALTER TABLE search_history 
  ADD CONSTRAINT search_history_user_id_fkey 
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;

ALTER TABLE user_favorites 
  ADD CONSTRAINT user_favorites_user_id_fkey 
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;

-- Step 7: Recreate unique constraint for user_favorites
ALTER TABLE user_favorites 
  ADD CONSTRAINT user_favorites_user_id_product_id_key 
  UNIQUE (user_id, product_id);

-- Step 8: Create new RLS policies using auth.uid() directly

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