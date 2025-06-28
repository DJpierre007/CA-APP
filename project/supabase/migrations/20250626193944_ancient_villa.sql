/*
  # Add SELECT and UPDATE policies for users table

  1. Security Policies
    - Add policy for authenticated users to view their own profile
    - Add policy for authenticated users to update their own profile
    - Both policies use auth.uid() to ensure users can only access their own data

  2. Policy Details
    - SELECT policy: Users can read rows where user_id matches their auth.uid()
    - UPDATE policy: Users can modify rows where user_id matches their auth.uid()
    - WITH CHECK clause ensures user_id cannot be changed during updates
*/

-- Drop existing SELECT and UPDATE policies if they exist
DROP POLICY IF EXISTS "Users can view their profile" ON users;
DROP POLICY IF EXISTS "Users can read own profile" ON users;
DROP POLICY IF EXISTS "Users can update their profile" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;

-- Allow users to view their own profile
CREATE POLICY "Users can view their profile"
ON users
FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- Allow users to update their own profile
CREATE POLICY "Users can update their profile"
ON users
FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());