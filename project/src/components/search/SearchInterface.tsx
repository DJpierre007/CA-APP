import React, { useState, useRef, useEffect } from 'react'
import { Search, Send, Clock, Sparkles, ArrowRight } from 'lucide-react'
import { useSearch } from '../../contexts/SearchContext'

export function SearchInterface() {
  const [inputValue, setInputValue] = useState('')
  const [showSuggestions, setShowSuggestions] = useState(false)
  const inputRef = useRef<HTMLInputElement>(null)
  const { searchHistory, performSearch, isSearching } = useSearch()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!inputValue.trim() || isSearching) return

    await performSearch(inputValue)
    setInputValue('')
    setShowSuggestions(false)
  }

  const handleSuggestionClick = (suggestion: string) => {
    setInputValue(suggestion)
    setShowSuggestions(false)
    performSearch(suggestion)
  }

  const popularSuggestions = [
    'Nike Air Max sneakers',
    'Wireless headphones',
    'Gaming laptop',
    'Smartphone cases',
    'Winter jackets',
    'Running shoes'
  ]

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (inputRef.current && !inputRef.current.contains(event.target as Node)) {
        setShowSuggestions(false)
      }
    }

    document.addEventListener('mousedown', handleClickOutside)
    return () => document.removeEventListener('mousedown', handleClickOutside)
  }, [])

  return (
    <div className="w-full max-w-4xl mx-auto">
      {/* Main Search Interface */}
      <div className="relative">
        <form onSubmit={handleSubmit} className="relative">
          <div className="relative bg-white rounded-2xl shadow-lg border border-gray-200 overflow-hidden transition-all duration-200 hover:shadow-xl focus-within:shadow-xl focus-within:border-blue-300">
            <div className="flex items-center">
              <div className="pl-6 pr-4 py-4">
                <Search className="w-6 h-6 text-gray-400" />
              </div>
              
              <input
                ref={inputRef}
                type="text"
                value={inputValue}
                onChange={(e) => setInputValue(e.target.value)}
                onFocus={() => setShowSuggestions(true)}
                placeholder="Search for any product... (e.g., 'Nike Air Max', 'iPhone case', 'winter jacket')"
                className="flex-1 py-4 text-lg text-gray-900 placeholder-gray-500 bg-transparent border-none outline-none"
                disabled={isSearching}
              />

              <button
                type="submit"
                disabled={!inputValue.trim() || isSearching}
                className="mr-4 p-3 bg-blue-600 hover:bg-blue-700 disabled:bg-gray-300 text-white rounded-xl transition-all duration-200 disabled:cursor-not-allowed group"
              >
                {isSearching ? (
                  <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
                ) : (
                  <Send className="w-5 h-5 group-hover:translate-x-0.5 transition-transform" />
                )}
              </button>
            </div>
          </div>
        </form>

        {/* Suggestions Dropdown */}
        {showSuggestions && (
          <div className="absolute top-full left-0 right-0 mt-2 bg-white rounded-2xl shadow-xl border border-gray-200 z-50 overflow-hidden">
            {/* Search History */}
            {searchHistory.length > 0 && (
              <div className="p-4 border-b border-gray-100">
                <div className="flex items-center gap-2 mb-3">
                  <Clock className="w-4 h-4 text-gray-400" />
                  <span className="text-sm font-medium text-gray-600">Recent searches</span>
                </div>
                <div className="space-y-1">
                  {searchHistory.slice(0, 5).map((query, index) => (
                    <button
                      key={index}
                      onClick={() => handleSuggestionClick(query)}
                      className="w-full text-left px-3 py-2 text-gray-700 hover:bg-gray-50 rounded-lg transition-colors flex items-center justify-between group"
                    >
                      <span>{query}</span>
                      <ArrowRight className="w-4 h-4 text-gray-400 opacity-0 group-hover:opacity-100 transition-opacity" />
                    </button>
                  ))}
                </div>
              </div>
            )}

            {/* Popular Suggestions */}
            <div className="p-4">
              <div className="flex items-center gap-2 mb-3">
                <Sparkles className="w-4 h-4 text-blue-500" />
                <span className="text-sm font-medium text-gray-600">Popular searches</span>
              </div>
              <div className="space-y-1">
                {popularSuggestions.map((suggestion, index) => (
                  <button
                    key={index}
                    onClick={() => handleSuggestionClick(suggestion)}
                    className="w-full text-left px-3 py-2 text-gray-700 hover:bg-blue-50 hover:text-blue-700 rounded-lg transition-colors flex items-center justify-between group"
                  >
                    <span>{suggestion}</span>
                    <ArrowRight className="w-4 h-4 text-gray-400 opacity-0 group-hover:opacity-100 group-hover:text-blue-500 transition-all" />
                  </button>
                ))}
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Search Status */}
      {isSearching && (
        <div className="mt-8 text-center">
          <div className="inline-flex items-center gap-3 px-6 py-3 bg-blue-50 text-blue-700 rounded-full">
            <div className="w-5 h-5 border-2 border-blue-600 border-t-transparent rounded-full animate-spin" />
            <span className="font-medium">Searching for products...</span>
          </div>
        </div>
      )}
    </div>
  )
}