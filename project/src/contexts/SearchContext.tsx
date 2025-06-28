import React, { createContext, useContext, useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'
import { useAuth } from './AuthContext'

interface SearchContextType {
  searchQuery: string
  setSearchQuery: (query: string) => void
  searchHistory: string[]
  isSearching: boolean
  searchResults: any[]
  performSearch: (query: string) => Promise<void>
  clearSearch: () => void
}

const SearchContext = createContext<SearchContextType | undefined>(undefined)

export function SearchProvider({ children }: { children: React.ReactNode }) {
  const [searchQuery, setSearchQuery] = useState('')
  const [searchHistory, setSearchHistory] = useState<string[]>([])
  const [isSearching, setIsSearching] = useState(false)
  const [searchResults, setSearchResults] = useState<any[]>([])
  const { user } = useAuth()

  // Load search history when user logs in
  useEffect(() => {
    if (user) {
      loadSearchHistory()
    } else {
      // Clear search history when user logs out
      setSearchHistory([])
    }
  }, [user])

  const loadSearchHistory = async () => {
    if (!user) return

    try {
      const { data, error } = await supabase
        .from('search_history')
        .select('search_query')
        .eq('user_id', user.id)
        .order('search_date', { ascending: false })
        .limit(10)

      if (error) throw error

      const uniqueQueries = [...new Set(data.map(item => item.search_query))]
      setSearchHistory(uniqueQueries)
    } catch (error) {
      console.error('Error loading search history:', error)
    }
  }

  const saveSearchToHistory = async (query: string) => {
    // Only save to database if user is logged in
    if (!user || !query.trim()) return

    try {
      const { error } = await supabase
        .from('search_history')
        .insert([
          {
            user_id: user.id,
            search_query: query.trim(),
            country: 'UK' // Default country
          }
        ])

      if (error) throw error

      // Update local history
      setSearchHistory(prev => {
        const filtered = prev.filter(q => q !== query.trim())
        return [query.trim(), ...filtered].slice(0, 10)
      })
    } catch (error) {
      console.error('Error saving search history:', error)
    }
  }

  const searchWithSerpAPI = async (query: string) => {
    const apiKey = import.meta.env.VITE_SERPAPI_KEY
    
    if (!apiKey) {
      throw new Error('SerpAPI key not found in environment variables')
    }

    // Construct SerpAPI URL using the proxy path
    const serpApiUrl = new URL('/api/serpapi', window.location.origin)
    serpApiUrl.searchParams.append('engine', 'google_shopping')
    serpApiUrl.searchParams.append('q', query)
    serpApiUrl.searchParams.append('api_key', apiKey)
    serpApiUrl.searchParams.append('location', 'United Kingdom')
    serpApiUrl.searchParams.append('hl', 'en')
    serpApiUrl.searchParams.append('gl', 'uk')
    serpApiUrl.searchParams.append('num', '20') // Get up to 20 results

    const response = await fetch(serpApiUrl.toString())
    
    if (!response.ok) {
      throw new Error(`SerpAPI request failed: ${response.status} ${response.statusText}`)
    }

    const data = await response.json()
    
    if (data.error) {
      throw new Error(`SerpAPI error: ${data.error}`)
    }

    return data
  }

  const mapSerpAPIResults = (serpApiData: any) => {
    if (!serpApiData.shopping_results || !Array.isArray(serpApiData.shopping_results)) {
      return []
    }

    return serpApiData.shopping_results.map((item: any, index: number) => ({
      product_id: index + 1, // Generate a temporary ID
      product_name: item.title || 'Unknown Product',
      price: item.price || 'Price not available',
      image_url: item.thumbnail || 'https://images.pexels.com/photos/1464625/pexels-photo-1464625.jpeg',
      buy_link: item.link || '#',
      source: item.source || 'Google Shopping',
      rating: item.rating || null,
      reviews: item.reviews || null,
      delivery: item.delivery || null,
      merchant: item.merchant || null,
      product_id_serpapi: item.product_id || null,
      created_at: new Date().toISOString()
    }))
  }

  const saveProductsToDatabase = async (products: any[]) => {
    if (!products.length) return

    try {
      // Insert products into database
      const { error } = await supabase
        .from('products')
        .insert(
          products.map(product => ({
            product_name: product.product_name,
            price: product.price,
            image_url: product.image_url,
            buy_link: product.buy_link,
            source: product.source,
            region: 'UK'
          }))
        )

      if (error) {
        console.error('Error saving products to database:', error)
        // Don't throw error here - we still want to show results even if saving fails
      }
    } catch (error) {
      console.error('Error saving products to database:', error)
    }
  }

  const performSearch = async (query: string) => {
    if (!query.trim()) return

    setIsSearching(true)
    setSearchQuery(query)

    try {
      // Save to search history (only if user is logged in)
      if (user) {
        await saveSearchToHistory(query)
      }

      // Perform actual search with SerpAPI
      const serpApiData = await searchWithSerpAPI(query)
      
      // Map SerpAPI results to our product format
      const mappedResults = mapSerpAPIResults(serpApiData)
      
      // Save products to database (optional - for caching/analytics)
      if (mappedResults.length > 0) {
        await saveProductsToDatabase(mappedResults)
      }

      setSearchResults(mappedResults)
      
    } catch (error) {
      console.error('Search error:', error)
      
      // Fallback to mock results if API fails
      console.log('Falling back to mock results due to API error')
      const mockResults = [
        {
          product_id: 1,
          product_name: `${query} - Premium Quality`,
          price: '£29.99',
          image_url: 'https://images.pexels.com/photos/1464625/pexels-photo-1464625.jpeg',
          buy_link: '#',
          source: 'Google Shopping (Mock)',
          rating: 4.5,
          reviews: 128,
          created_at: new Date().toISOString()
        },
        {
          product_id: 2,
          product_name: `${query} - Best Seller`,
          price: '£45.99',
          image_url: 'https://images.pexels.com/photos/1598505/pexels-photo-1598505.jpeg',
          buy_link: '#',
          source: 'Google Shopping (Mock)',
          rating: 4.2,
          reviews: 89,
          created_at: new Date().toISOString()
        },
        {
          product_id: 3,
          product_name: `${query} - Top Rated`,
          price: '£19.99',
          image_url: 'https://images.pexels.com/photos/1598508/pexels-photo-1598508.jpeg',
          buy_link: '#',
          source: 'Google Shopping (Mock)',
          rating: 4.8,
          reviews: 256,
          created_at: new Date().toISOString()
        }
      ]

      setSearchResults(mockResults)
    } finally {
      setIsSearching(false)
    }
  }

  const clearSearch = () => {
    setSearchQuery('')
    setSearchResults([])
  }

  const value = {
    searchQuery,
    setSearchQuery,
    searchHistory,
    isSearching,
    searchResults,
    performSearch,
    clearSearch
  }

  return <SearchContext.Provider value={value}>{children}</SearchContext.Provider>
}

export function useSearch() {
  const context = useContext(SearchContext)
  if (context === undefined) {
    throw new Error('useSearch must be used within a SearchProvider')
  }
  return context
}