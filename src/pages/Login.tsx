import React, { useState } from 'react'

interface LoginProps {
  onLogin: (userData: { username: string }) => void
}

const Login: React.FC<LoginProps> = ({ onLogin }) => {
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    setLoading(true)

    // Simulated authentication (replace with real backend later)
    setTimeout(() => {
      if (username.trim() && password.trim()) {
        onLogin({ username: username.trim() })
      } else {
        setError('Por favor, preencha todos os campos')
      }
      setLoading(false)
    }, 500)
  }

  return (
    <div className="min-h-screen flex items-center justify-center p-4">
      <div className="w-full max-w-md">
        {/* Logo and Title */}
        <div className="text-center mb-8">
          <div className="text-6xl mb-4 cross-glow">✝</div>
          <h1 className="text-4xl font-cinzel font-bold text-gold mb-2">
            Lumen Sacra
          </h1>
          <p className="text-gray-300 text-lg">
            Entre para acessar a sua Bíblia
          </p>
        </div>

        {/* Login Form */}
        <div className="bg-secondary/50 backdrop-blur-sm rounded-2xl p-8 border border-gold/20 shadow-2xl">
          <form onSubmit={handleSubmit} className="space-y-6">
            {/* Username Field */}
            <div>
              <label 
                htmlFor="username" 
                className="block text-sm font-medium text-gray-300 mb-2"
              >
                Usuário
              </label>
              <input
                type="text"
                id="username"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                className="w-full px-4 py-3 bg-primary/50 border border-gold/30 rounded-lg text-white placeholder-gray-400 focus:outline-none focus:border-gold focus:ring-2 focus:ring-gold/20 transition-all"
                placeholder="Digite seu usuário"
                disabled={loading}
              />
            </div>

            {/* Password Field */}
            <div>
              <label 
                htmlFor="password" 
                className="block text-sm font-medium text-gray-300 mb-2"
              >
                Senha
              </label>
              <input
                type="password"
                id="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full px-4 py-3 bg-primary/50 border border-gold/30 rounded-lg text-white placeholder-gray-400 focus:outline-none focus:border-gold focus:ring-2 focus:ring-gold/20 transition-all"
                placeholder="Digite sua senha"
                disabled={loading}
              />
            </div>

            {/* Error Message */}
            {error && (
              <div className="text-accent text-sm text-center bg-accent/10 py-2 rounded-lg">
                {error}
              </div>
            )}

            {/* Submit Button */}
            <button
              type="submit"
              disabled={loading}
              className="w-full py-3 px-4 bg-gradient-to-r from-gold to-gold-light text-primary font-semibold rounded-lg hover:from-gold-light hover:to-gold transition-all disabled:opacity-50 disabled:cursor-not-allowed shadow-lg hover:shadow-gold/20"
            >
              {loading ? (
                <span className="flex items-center justify-center gap-2">
                  <svg className="animate-spin h-5 w-5" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none" />
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
                  </svg>
                  Entrando...
                </span>
              ) : (
                'Entrar'
              )}
            </button>
          </form>

          {/* Demo Credentials Hint */}
          <div className="mt-6 text-center text-sm text-gray-400">
            <p>Dica: Use qualquer usuário e senha para testar</p>
          </div>
        </div>

        {/* Footer */}
        <div className="text-center mt-8 text-gray-400 text-sm">
          <p>Bíblia Católica Versão Ave Maria</p>
        </div>
      </div>
    </div>
  )
}

export default Login
