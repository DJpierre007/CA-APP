/*
  # Fix products table RLS policy

  1. Security Changes
    - Drop existing restrictive INSERT policy for products table
    - Create new INSERT policy that allows both authenticated and anonymous users
    - This enables the search functionality to save products regardless of login status

  2. Reasoning
    - Product data from search results is not user-specific
    - Both logged-in and guest users should be able to trigger product saves
    - The products table serves as a cache for search results from external APIs
*/

-- Drop the existing restrictive INSERT policy
DROP POLICY IF EXISTS "Authenticated users can insert products" ON products;

-- Create a new policy that allows both authenticated and anonymous users to insert products
CREATE POLICY "Allow product inserts for search results"
  ON products
  FOR INSERT
  TO authenticated, anon
  WITH CHECK (true);