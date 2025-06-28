import React, { useState } from 'react'
import { AuthProvider, useAuth } from './contexts/AuthContext'
import { SearchProvider } from './contexts/SearchContext'
import { AuthModal } from './components/auth/AuthModal'
import { Header } from './components/layout/Header'
import { SearchInterface } from './components/search/SearchInterface'
import { SearchResults } from './components/search/SearchResults'

function AppContent() {
  const { loading } = useAuth()
  const [isAuthModalOpen, setIsAuthModalOpen] = useState(false)
  const [authMode, setAuthMode] = useState<'signin' | 'signup'>('signin')

  const handleSignInClick = () => {
    setAuthMode('signin')
    setIsAuthModalOpen(true)
  }

  const handleCloseAuthModal = () => {
    setIsAuthModalOpen(false)
  }

  const handleToggleAuthMode = () => {
    setAuthMode(authMode === 'signin' ? 'signup' : 'signin')
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  return (
    <SearchProvider>
      <div className="min-h-screen bg-gray-50">
        <Header onSignInClick={handleSignInClick} />
        
        <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          {/* Hero Section */}
          <div className="text-center mb-12">
            <h1 className="text-5xl font-bold text-gray-900 mb-4">
              Find Any Product
            </h1>
            <p className="text-xl text-gray-600 mb-8 max-w-2xl mx-auto">
              Search millions of products from across the web. Get the best prices, 
              compare options, and find exactly what you're looking for.
            </p>
          </div>

          {/* Search Interface */}
          <SearchInterface />

          {/* Search Results */}
          <SearchResults />
        </main>

        {/* Authentication Modal */}
        <AuthModal
          isOpen={isAuthModalOpen}
          onClose={handleCloseAuthModal}
          mode={authMode}
          onToggleMode={handleToggleAuthMode}
        />
      </div>
    </SearchProvider>
  )
}

function App() {
  return (
    <AuthProvider>
      <AppContent />
    </AuthProvider>
  )
}

export default App