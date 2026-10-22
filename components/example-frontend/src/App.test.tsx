import { cleanup, fireEvent, render, screen } from '@testing-library/react'
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

  expect(await screen.findByRole('alert')).toHaveTextContent(
    'Unable to load greeting. Please try again later.',
  )
})

test('shows an error when the greeting request cannot be sent', async () => {
  vi.stubGlobal('fetch', vi.fn().mockRejectedValue(new TypeError('Network error')))

  render(<App />)

  expect(await screen.findByRole('alert')).toHaveTextContent(
    'Unable to load greeting. Please try again later.',
  )
  expect(screen.queryByRole('status')).not.toBeInTheDocument()
})

test('retries loading the greeting after a failed request', async () => {
  const fetchGreeting = vi
    .fn()
    .mockRejectedValueOnce(new TypeError('Network error'))
    .mockResolvedValueOnce({
      ok: true,
      json: () => Promise.resolve({ message: 'Hello from Quarkus' }),
    })
  vi.stubGlobal('fetch', fetchGreeting)

  render(<App />)

  expect(await screen.findByRole('alert')).toBeInTheDocument()
  fireEvent.click(screen.getByRole('button', { name: 'Retry' }))

  expect(await screen.findByText('Hello from Quarkus')).toBeInTheDocument()
  expect(fetchGreeting).toHaveBeenCalledTimes(2)
})
