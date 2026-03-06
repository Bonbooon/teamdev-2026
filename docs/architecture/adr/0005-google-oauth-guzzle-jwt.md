# ADR 0005: Use Guzzle + firebase/php-jwt for Google OAuth

- Status: Accepted
- Date: 2026-03-06

## Context

The authentication spec (S-01-01) requires Google OAuth (OIDC) login with:
- Frontend-initiated flow: frontend redirects user to Google, receives authorization code, POSTs code to `POST /api/login`
- Server-side code exchange for tokens
- **ID token claim validation** (`iss`, `aud`, `exp`) — explicitly required by the spec
- Extraction of user info from OIDC claims (`email`, `given_name`, `family_name`, `picture`, `sub`)

We evaluated two approaches:

### Option A: Laravel Socialite + Google Driver

- Official Laravel package, well-maintained, community-standard
- Handles token exchange and user info retrieval in ~3 lines
- **However**: designed for server-side redirect flow (`Socialite::driver()->redirect()` / `->user()`), not frontend-initiated code exchange
- **Critical gap**: Socialite does NOT validate OIDC ID token claims (`iss`, `aud`, `exp`) — it calls the Google UserInfo endpoint with the access token instead
- To use with code-from-frontend, requires `stateless()->userFromToken()` or manual `getAccessTokenResponse()` — fighting the abstraction
- Adds a dependency for functionality achievable in ~50-80 lines

### Option B: Guzzle (already installed) + firebase/php-jwt

- Guzzle is already a project dependency — zero new HTTP client dependencies
- `firebase/php-jwt` is a lightweight, widely-used JWT library for decoding and validating tokens
- Full control over the exact flow defined in the spec
- Directly validates ID token claims (`iss`, `aud`, `exp`) against Google's JWKS public keys
- Fits the API-only architecture (no server-side redirects)
- Easier to mock in tests (mock one Guzzle client)
- Clear placement as an Infrastructure concern in clean architecture

## Decision

We adopt **Option B: Guzzle + firebase/php-jwt**.

Implementation:
1. `GoogleOAuthClient` in `app/Infrastructure/External/Google/` exchanges authorization code via Guzzle
2. ID token decoded and validated using `firebase/php-jwt` with Google's JWKS public keys (RS256)
3. Claims validated: `iss` = `https://accounts.google.com`, `aud` = configured client ID, `exp` = not expired
4. Google JWKS keys cached via Laravel Cache to avoid repeated fetches

## Consequences

### Positive

- Spec-compliant ID token validation (Socialite would not satisfy this requirement)
- No new heavy dependencies (Guzzle already present; firebase/php-jwt is ~50KB)
- Clean separation: `GoogleOAuthClient` is a pure Infrastructure adapter
- Straightforward to test: mock the Guzzle client, assert claim validation logic
- Full control over error handling and response mapping

### Trade-offs

- We own the implementation (~80 lines) — must handle error cases ourselves
- Must keep up with any Google OIDC endpoint changes (rare, well-documented)
- Team members unfamiliar with raw OIDC flow may need onboarding (mitigated by clear code + this ADR)

## References

- Authentication spec: `specs/business/authentication.md`
- Google OIDC discovery: `https://accounts.google.com/.well-known/openid-configuration`
- Google JWKS endpoint: `https://www.googleapis.com/oauth2/v3/certs`
- firebase/php-jwt: `https://github.com/firebase/php-jwt`
