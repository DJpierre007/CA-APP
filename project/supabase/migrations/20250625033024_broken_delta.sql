/*
  # Create products table

  1. New Tables
    - `products`
      - `product_id` (integer, primary key, auto-increment)
      - `product_name` (text, not null)
      - `price` (text)
      - `size` (text)
      - `colors` (text)
      - `region` (text, default 'UK')
      - `image_url` (text)
      - `buy_link` (text)
      - `source` (text, default 'Google Shopping')
      - `created_at` (timestamptz, default now())

  2. Security
    - Enable RLS on `products` table
    - Add policy for authenticated users to insert products
    - Add policy for authenticated users to read all products

  3. Indexes
    - Add index on created_at for chronological sorting
*/

CREATE TABLE IF NOT EXISTS products (
  product_id SERIAL PRIMARY KEY,
  product_name TEXT NOT NULL,
  price TEXT,
  size TEXT,
  colors TEXT,
  region TEXT DEFAULT 'UK',
  image_url TEXT,
  buy_link TEXT,
  source TEXT DEFAULT 'Google Shopping',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Add index for better performance
CREATE INDEX IF NOT EXISTS idx_products_created_at ON products(created_at DESC);

ALTER TABLE products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can insert products"
  ON products
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can read products"
  ON products
  FOR SELECT
  TO authenticated
  USING (true);