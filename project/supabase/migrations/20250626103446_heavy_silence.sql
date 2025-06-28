/*
  # Fix User Signup RLS Policies

  1. Security Updates
    - Add proper INSERT policy for users table to allow signup
    - Ensure users can insert their own profile during registration
    - Fix RLS policy that was preventing new user creation

  2. Changes Made
    - Drop existing restrictive INSERT policy
    - Create new INSERT policy that allows authenticated users to insert their own data
    - Maintain security by ensuring users can only insert data with their own user_id
*/

-- Drop the existing INSERT policy that's too restrictive
DROP POLICY IF EXISTS "Users can insert own profile during signup" ON users;

-- Create a new INSERT policy that allows users to insert their own profile
-- This policy allows authenticated users to insert rows where the user_id matches their auth.uid()
CREATE POLICY "Allow users to insert own profile"
  ON users
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- Also ensure we have a proper SELECT policy (this should already exist but let's make sure)
DROP POLICY IF EXISTS "Users can read own profile" ON users;
CREATE POLICY "Users can read own profile"
  ON users
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Ensure UPDATE policy exists for completeness
DROP POLICY IF EXISTS "Users can update own profile" ON users;
CREATE POLICY "Users can update own profile"
  ON users
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());