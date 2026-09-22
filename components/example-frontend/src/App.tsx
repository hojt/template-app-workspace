import { useEffect, useState } from 'react'

type Greeting = {
  message: string
}

export function App() {
  const [greeting, setGreeting] = useState<string>()
  const [error, setError] = useState(false)

  useEffect(() => {
    let cancelled = false

    async function loadGreeting() {
      try {
        const response = await fetch('/api/greeting')

        if (!response.ok) {
          throw new Error('Greeting request failed')
        }

        const data = (await response.json()) as Greeting

        if (!cancelled) {
          setGreeting(data.message)
        }
      } catch {
        if (!cancelled) {
          setError(true)
        }
      }
    }

    void loadGreeting()

    return () => {
      cancelled = true
    }
  }, [])

  return (
    <main>
      <h1>Example App</h1>
      {error ? (
        <p role="alert">Unable to load greeting.</p>
      ) : greeting ? (
        <p>{greeting}</p>
      ) : (
        <p role="status">Loading greeting...</p>
      )}
    </main>
  )
}
