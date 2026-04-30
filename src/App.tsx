import React, { useState } from 'react'
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import Login from './pages/Login'
import Bible from './pages/Bible'
import DailyVerse from './pages/DailyVerse'
import Prayers from './pages/Prayers'

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false)
  const [user, setUser] = useState<{ username: string } | null>(null)

  return (
    <Router>
      <Routes>
        <Route 
          path="/login" 
          element={
            isAuthenticated ? (
              <Navigate to="/biblia" />
            ) : (
              <Login onLogin={(userData) => {
                setUser(userData)
                setIsAuthenticated(true)
              }} />
            )
          } 
        />
        <Route 
          path="/biblia" 
          element={
            isAuthenticated ? (
              <Bible user={user!} onLogout={() => {
                setUser(null)
                setIsAuthenticated(false)
              }} />
            ) : (
              <Navigate to="/login" />
            )
          } 
        />
        <Route 
          path="/verso-diario" 
          element={
            isAuthenticated ? (
              <DailyVerse user={user!} onLogout={() => {
                setUser(null)
                setIsAuthenticated(false)
              }} />
            ) : (
              <Navigate to="/login" />
            )
          } 
        />
        <Route 
          path="/oracoes" 
          element={
            isAuthenticated ? (
              <Prayers user={user!} onLogout={() => {
                setUser(null)
                setIsAuthenticated(false)
              }} />
            ) : (
              <Navigate to="/login" />
            )
          } 
        />
        <Route 
          path="/" 
          element={<Navigate to={isAuthenticated ? "/biblia" : "/login"} />} 
        />
      </Routes>
    </Router>
  )
}

export default App
