/*
  # Fix RLS Policy for Users Table

  1. Policy Updates
    - Drop any existing problematic INSERT policies on the users table
    - Create a new INSERT policy that correctly uses auth.uid() for authenticated users
    - Ensure RLS is properly enabled on the users table

  2. Security
    - The new policy allows authenticated users to insert their own profile data
    - Uses auth.uid() which correctly identifies the authenticated user's ID
    - Prevents users from inserting data for other users

  This migration resolves the "new row violates row-level security policy" error
  that occurs during user sign-up.
*/

-- Step 1: Enable RLS (if not already enabled)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Step 2: Drop the existing INSERT policy if it exists
DROP POLICY IF EXISTS "Users can insert their profile" ON users;
DROP POLICY IF EXISTS "Allow users to insert own profile" ON users;
DROP POLICY IF EXISTS "Users can insert own profile during signup" ON users;
DROP POLICY IF EXISTS "Allow user creation during signup" ON users;

-- Step 3: Create a corrected INSERT policy using auth.uid()
CREATE POLICY "Users can insert their profile"
ON users
FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());