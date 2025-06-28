/*
  # Fix Users Table RLS Policy for Registration

  1. Changes
    - Update the INSERT policy for users table to allow proper user registration
    - The current policy prevents new user insertion during sign-up process
    - New policy allows authenticated users to insert their own profile data

  2. Security
    - Maintains security by ensuring users can only insert data for their own user_id
    - Uses auth.uid() to verify the authenticated user matches the user_id being inserted
*/

-- Drop the existing INSERT policy
DROP POLICY IF EXISTS "Allow users to insert own profile" ON users;

-- Create a new INSERT policy that properly handles user registration
CREATE POLICY "Allow users to insert own profile"
  ON users
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- Ensure the users table has RLS enabled (should already be enabled)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;