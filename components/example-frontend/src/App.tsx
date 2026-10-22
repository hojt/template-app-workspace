import { useEffect, useRef, useState } from 'react'

type Greeting = {
  message: string
}

export function App() {
  const [greeting, setGreeting] = useState<string>()
  const [error, setError] = useState(false)
  const mounted = useRef(true)
  const latestRequest = useRef(0)

  async function loadGreeting() {
    const request = ++latestRequest.current

    if (mounted.current && request === latestRequest.current) {
      setError(false)
    }

    try {
      const response = await fetch('/api/greeting')

      if (!response.ok) {
        throw new Error('Greeting request failed')
      }

      const data = (await response.json()) as Greeting
      if (mounted.current && request === latestRequest.current) {
        setGreeting(data.message)
      }
    } catch {
      if (mounted.current && request === latestRequest.current) {
        setError(true)
      }
    }
  }

  useEffect(() => {
    mounted.current = true
    void loadGreeting()

    return () => {
      mounted.current = false
    }
  }, [])

  return (
    <main>
      <h1>Example App</h1>
      {error ? (
        <>
          <p role="alert">Unable to load greeting. Please try again later.</p>
          <button type="button" onClick={() => void loadGreeting()}>
            Retry
          </button>
        </>
      ) : greeting ? (
        <p>{greeting}</p>
      ) : (
        <p role="status">Loading greeting...</p>
      )}
    </main>
  )
}
