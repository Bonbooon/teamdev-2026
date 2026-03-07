# ADR 0007: Token-Only API Authentication (No CSRF/Session)

**Status:** Accepted  
**Date:** 2026/03/07  
**Deciders:** Development Team  
**Category:** Security / Authentication

---

## Context

Laravel Sanctum supports two authentication modes:

1. **SPA/Cookie-based (stateful):** Uses `EnsureFrontendRequestsAreStateful` middleware, which injects session and CSRF middleware for requests from "stateful" domains. Requires CSRF cookie exchange before every mutating request.

2. **Token-based (stateless):** Uses `Authorization: Bearer {token}` headers. No sessions, no CSRF cookies.

Our frontend (`localhost:3000`) was configured as a Sanctum stateful domain (`SANCTUM_STATEFUL_DOMAINS=localhost:3000`), which caused `EnsureFrontendRequestsAreStateful` to apply session + CSRF middleware to all API requests from the frontend. This resulted in **HTTP 419 (Page Expired)** errors on login because the frontend was not sending CSRF tokens (it was designed for token-based auth).

## Decision

**Remove `EnsureFrontendRequestsAreStateful` from the `api` middleware group** and use token-only (Bearer) authentication for all API routes.

### Before (Kernel.php)
```php
'api' => [
    \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
    'throttle:api',
    \Illuminate\Routing\Middleware\SubstituteBindings::class,
],
```

### After (Kernel.php)
```php
'api' => [
    // Token-based auth only (Bearer tokens via Sanctum).
    // EnsureFrontendRequestsAreStateful removed — it injects session/CSRF
    // middleware for stateful domains, which conflicts with our token flow.
    'throttle:api',
    \Illuminate\Routing\Middleware\SubstituteBindings::class,
],
```

## Rationale

| Factor | Cookie/Session (Stateful) | Bearer Token (Stateless) |
|--------|--------------------------|--------------------------|
| CSRF protection | Required (419 errors if missing) | Not needed (token in header) |
| Frontend complexity | Must call `/sanctum/csrf-cookie` before every session | Just include `Authorization` header |
| Cross-origin | Requires `withCredentials`, domain alignment | Works with any origin via CORS |
| Token storage | HttpOnly cookie (automatic) | `localStorage` (manual) |
| Mobile/API clients | Difficult | Easy |
| SSR compatibility | Cookie forwarding issues | Straightforward |

**Why token-based wins for our project:**
- Our frontend is a Next.js SPA using popup-based Google OAuth — no server-side cookie flow
- Token stored in `localStorage` and sent via `Authorization: Bearer` header
- Simpler mental model — no CSRF dance before API calls
- Future mobile clients can use the same token flow
- XSS risk from `localStorage` is mitigated by our CSP headers and sanitization

## Consequences

### Positive
- Eliminates 419 CSRF errors for API requests
- Simpler frontend code (no `/sanctum/csrf-cookie` preflight)
- Consistent auth model for web and future mobile clients
- Easier testing (just send Bearer header)

### Negative
- Tokens in `localStorage` are vulnerable to XSS (mitigated by CSP + input sanitization)
- No automatic cookie-based session refresh (tokens have fixed lifetime)

### Neutral
- `SANCTUM_STATEFUL_DOMAINS` and `SESSION_DOMAIN` in `.env` are now unused for API auth (kept for potential future admin panel)
- CSRF protection still active on `web` middleware group routes (Blade views, etc.)

## Related

- **ADR 0005:** Google OAuth with Guzzle + firebase/php-jwt
- **Spec:** `specs/business/authentication.md` (Notes section)
- **File changed:** `app/Http/Kernel.php`
