import React from 'react'
import { X } from 'lucide-react'
import { AuthForm } from './AuthForm'

interface AuthModalProps {
  isOpen: boolean
  onClose: () => void
  mode: 'signin' | 'signup'
  onToggleMode: () => void
}

export function AuthModal({ isOpen, onClose, mode, onToggleMode }: AuthModalProps) {
  if (!isOpen) return null

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto">
      {/* Backdrop */}
      <div 
        className="fixed inset-0 bg-black bg-opacity-50 transition-opacity"
        onClick={onClose}
      />
      
      {/* Modal */}
      <div className="flex min-h-full items-center justify-center p-4">
        <div className="relative bg-white rounded-2xl shadow-xl max-w-md w-full">
          {/* Close button */}
          <button
            onClick={onClose}
            className="absolute top-4 right-4 p-2 text-gray-400 hover:text-gray-600 transition-colors z-10"
          >
            <X className="w-5 h-5" />
          </button>
          
          {/* Auth form */}
          <div className="p-8">
            <AuthForm mode={mode} onToggleMode={onToggleMode} />
          </div>
        </div>
      </div>
    </div>
  )
}