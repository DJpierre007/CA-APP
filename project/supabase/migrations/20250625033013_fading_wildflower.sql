/*
  # Create users table

  1. New Tables
    - `users`
      - `user_id` (integer, primary key, auto-increment)
      - `email` (text, unique, not null)
      - `password_hash` (text, not null) 
      - `name` (text, not null)
      - `created_at` (timestamptz, default now())

  2. Security
    - Enable RLS on `users` table
    - Add policy for authenticated users to read their own profile data
    - Add policy for authenticated users to update their own profile data
*/

CREATE TABLE IF NOT EXISTS users (
  user_id SERIAL PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own profile"
  ON users
  FOR SELECT
  TO authenticated
  USING (user_id = (current_setting('app.current_user_id'::text))::integer);

CREATE POLICY "Users can update own profile"
  ON users
  FOR UPDATE
  TO authenticated
  USING (user_id = (current_setting('app.current_user_id'::text))::integer);