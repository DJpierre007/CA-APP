import React from 'react'
import { useAuth } from '../../contexts/AuthContext'
import { LogOut, User, Search, LogIn } from 'lucide-react'

interface HeaderProps {
  onSignInClick?: () => void
}

export function Header({ onSignInClick }: HeaderProps) {
  const { user, signOut } = useAuth()

  return (
    <header className="bg-white shadow-sm border-b border-gray-200">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          {/* Logo */}
          <div className="flex items-center">
            <Search className="w-8 h-8 text-blue-600" />
            <span className="ml-2 text-xl font-bold text-gray-900">ProductSearch</span>
          </div>

          {/* User menu */}
          <div className="flex items-center space-x-4">
            {user ? (
              <>
                <div className="flex items-center space-x-2">
                  <User className="w-5 h-5 text-gray-500" />
                  <span className="text-sm text-gray-700">{user.email}</span>
                </div>
                <button
                  onClick={signOut}
                  className="flex items-center space-x-1 text-gray-500 hover:text-gray-700 transition-colors"
                >
                  <LogOut className="w-4 h-4" />
                  <span className="text-sm">Sign out</span>
                </button>
              </>
            ) : (
              <button
                onClick={onSignInClick}
                className="flex items-center space-x-2 bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition-colors font-medium"
              >
                <LogIn className="w-4 h-4" />
                <span>Sign In</span>
              </button>
            )}
          </div>
        </div>
      </div>
    </header>
  )
}