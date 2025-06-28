// Database type definitions based on your schema
export interface User {
  user_id: string  // Changed from number to string (UUID)
  email: string
  password_hash: string
  name: string
  created_at?: string
}

export interface SearchHistory {
  search_id: number
  user_id?: string  // Changed from number to string (UUID)
  search_query: string
  search_date?: string
  country?: string
}

export interface Product {
  product_id: number
  product_name: string
  price?: string
  size?: string
  colors?: string
  region?: string
  image_url?: string
  buy_link?: string
  source?: string
  created_at?: string
  // Additional fields from SerpAPI
  rating?: number
  reviews?: number
  delivery?: string
  merchant?: string
  product_id_serpapi?: string
}

export interface UserFavorite {
  favorite_id: number
  user_id?: string  // Changed from number to string (UUID)
  product_id?: number
  saved_at?: string
}

// Auth types
export interface AuthUser {
  id: string
  email?: string
  user_metadata?: {
    name?: string
  }
}

// SerpAPI response types
export interface SerpAPIShoppingResult {
  title: string
  price?: string
  thumbnail?: string
  link?: string
  source?: string
  rating?: number
  reviews?: number
  delivery?: string
  merchant?: string
  product_id?: string
}

export interface SerpAPIResponse {
  shopping_results?: SerpAPIShoppingResult[]
  error?: string
}