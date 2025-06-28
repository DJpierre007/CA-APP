import React from 'react'
import { useSearch } from '../../contexts/SearchContext'
import { Heart, ExternalLink, Star, Truck, Store } from 'lucide-react'

export function SearchResults() {
  const { searchResults, searchQuery } = useSearch()

  if (searchResults.length === 0) {
    return null
  }

  return (
    <div className="w-full max-w-6xl mx-auto mt-12">
      {/* Results Header */}
      <div className="mb-8">
        <h2 className="text-2xl font-bold text-gray-900 mb-2">
          Search Results for "{searchQuery}"
        </h2>
        <p className="text-gray-600">
          Found {searchResults.length} products
        </p>
      </div>

      {/* Results Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {searchResults.map((product) => (
          <div
            key={product.product_id}
            className="bg-white rounded-2xl shadow-lg border border-gray-200 overflow-hidden hover:shadow-xl transition-all duration-300 group"
          >
            {/* Product Image */}
            <div className="relative aspect-square overflow-hidden bg-gray-100">
              <img
                src={product.image_url}
                alt={product.product_name}
                className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                onError={(e) => {
                  // Fallback image if the original fails to load
                  const target = e.target as HTMLImageElement
                  target.src = 'https://images.pexels.com/photos/1464625/pexels-photo-1464625.jpeg'
                }}
              />
              
              {/* Favorite Button */}
              <button className="absolute top-4 right-4 p-2 bg-white/90 hover:bg-white rounded-full shadow-md transition-all duration-200 group/heart">
                <Heart className="w-5 h-5 text-gray-600 group-hover/heart:text-red-500 transition-colors" />
              </button>

              {/* Source Badge */}
              <div className="absolute bottom-4 left-4">
                <span className="px-3 py-1 bg-black/70 text-white text-xs font-medium rounded-full">
                  {product.source}
                </span>
              </div>
            </div>

            {/* Product Info */}
            <div className="p-6">
              <h3 className="font-semibold text-gray-900 mb-2 line-clamp-2 leading-tight">
                {product.product_name}
              </h3>
              
              <div className="flex items-center justify-between mb-3">
                <span className="text-2xl font-bold text-blue-600">
                  {product.price}
                </span>
                
                {product.rating && (
                  <div className="flex items-center gap-1">
                    <Star className="w-4 h-4 text-yellow-400 fill-current" />
                    <span className="text-sm text-gray-600">{product.rating}</span>
                    {product.reviews && (
                      <span className="text-xs text-gray-500">({product.reviews})</span>
                    )}
                  </div>
                )}
              </div>

              {/* Additional Info */}
              <div className="space-y-2 mb-4">
                {product.merchant && (
                  <div className="flex items-center gap-2 text-sm text-gray-600">
                    <Store className="w-4 h-4" />
                    <span>{product.merchant}</span>
                  </div>
                )}
                
                {product.delivery && (
                  <div className="flex items-center gap-2 text-sm text-gray-600">
                    <Truck className="w-4 h-4" />
                    <span>{product.delivery}</span>
                  </div>
                )}
              </div>

              {/* Action Button */}
              <a
                href={product.buy_link}
                target="_blank"
                rel="noopener noreferrer"
                className="w-full bg-gray-900 hover:bg-gray-800 text-white font-semibold py-3 px-4 rounded-xl transition-colors flex items-center justify-center gap-2 group/button"
              >
                <span>View Product</span>
                <ExternalLink className="w-4 h-4 group-hover/button:translate-x-0.5 transition-transform" />
              </a>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}