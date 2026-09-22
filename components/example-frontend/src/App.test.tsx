import { cleanup, render, screen } from '@testing-library/react'
import { afterEach, expect, test, vi } from 'vitest'
import { App } from './App'

afterEach(() => {
  cleanup()
  vi.unstubAllGlobals()
})

test('loads and displays the greeting', async () => {
  const fetchGreeting = vi.fn().mockResolvedValue({
    ok: true,
    json: () => Promise.resolve({ message: 'Hello from Quarkus' }),
  })
  vi.stubGlobal('fetch', fetchGreeting)

  render(<App />)

  expect(screen.getByRole('heading', { name: 'Example App' })).toBeInTheDocument()
  expect(screen.getByRole('status')).toHaveTextContent('Loading greeting...')
  expect(await screen.findByText('Hello from Quarkus')).toBeInTheDocument()
  expect(fetchGreeting).toHaveBeenCalledWith('/api/greeting')
})

test('shows an error when the greeting request fails', async () => {
  vi.stubGlobal('fetch', vi.fn().mockResolvedValue({ ok: false }))

  render(<App />)

  expect(await screen.findByRole('alert')).toHaveTextContent('Unable to load greeting.')
})
