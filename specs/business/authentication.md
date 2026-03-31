# Authentication & Authorization Specification

**Version:** 1.2  
**Last Updated:** 2026/03/08  
**Domain Model:** `docs/diagrams/domain-models/user-aggregate.puml`  
**Related ADR:** `docs/architecture/adr/0008-profile-upsert-for-aspida-response-constraints.md`

---

## Purpose

Define the complete authentication and authorization flows for all user types (Project Managers, Team Members). This spec covers:
- Google OAuth login (OIDC)
- Profile registration and completion
- Session management (login/logout)

## Implementation Status (2026/03/08)

- Implemented in the current codebase:
  - Google OAuth login/logout
  - `GET /api/auth/me`
  - Google avatar persistence on `users.google_avatar_url`
  - Profile registration and edit through `POST /api/users/me/profile`
  - Login response `googleProfile` hints used to prefill the profile setup form
- Planned but not implemented yet:
  - OAuth account linking and unlinking beyond the current Google login flow
  - Role-specific dashboard routing
  - Custom avatar upload and selection
- Architectural note:
  - Profile creation and edit currently share one upsert endpoint. This was chosen to keep the generated client contract simple; see the related ADR.

---

## Scope

**MUST Features (Phase 1):**
- S-01-01: Google OAuth Login
- S-01-02: Profile Registration
- S-01-03: Login (recurring)
- S-01-04: Logout

**Out of Scope (Phase 2+):**
- Multi-provider OAuth (only Google initially)
- Account recovery/password reset
- Two-factor authentication
- Team-based access control (handled in team-management.md)
- Custom avatar upload/delete (see Avatar Strategy section below)

---

## Avatar Strategy

### Phase 1: Google Avatar Only

**Scope:** Persist the Google `picture` OIDC claim on the `users` table and display it as the user's avatar everywhere. No custom upload.

**Data model:**
- `users.google_avatar_url: String?` — persisted from Google `picture` claim on every login
- `profiles.avatar_url: String?` — exists in schema but **unused in Phase 1** (reserved for Phase 2 custom upload)

**Behavior:**
- On every Google login, `google_avatar_url` is saved/updated on the user record
- If Google returns a different picture URL than what is stored, it is overwritten
- If Google returns no picture (null), `google_avatar_url` is set to null
- `/auth/me` returns `user.googleAvatarUrl` alongside other user fields
- Frontend avatar display chain: `user.google_avatar_url` → `/user-default.svg`
- Profile setup page shows the Google avatar as a read-only preview (no editing UI)
- `avatarUrl` is no longer sent in the profile upsert POST body

**Phase 1 Test Plan:**

| ID | Layer | Scenario | Expected |
|----|-------|----------|----------|
| B1 | Backend | First login saves `google_avatar_url` on user record | `users.google_avatar_url` matches Google `picture` claim |
| B2 | Backend | Returning login refreshes `google_avatar_url` when Google returns a different picture | Column is updated to new URL |
| B3 | Backend | Returning login does NOT write when avatar is unchanged | No unnecessary DB update |
| B4 | Backend | Google account has no picture (null) | `google_avatar_url` stored as null, no error |
| B5 | Backend | `/auth/me` response includes `user.google_avatar_url` | Field present in JSON response |
| F1 | Frontend | `google_avatar_url` is set | Avatar image displays it |
| F2 | Frontend | `google_avatar_url` is null | Falls back to `/user-default.svg` |

### Phase 2: Custom Avatar Upload (Deferred)

**Scope:** Allow users to upload their own profile picture. The custom avatar takes priority over the Google avatar.

**Planned data flow:**
- `profiles.avatar_url` stores the user-uploaded image URL (S3/local storage)
- Avatar display chain becomes: `profile.avatar_url` → `user.google_avatar_url` → `/user-default.svg`
- Profile page gains upload/remove UI
- Removing custom avatar falls back to Google avatar (not directly to default)

**Phase 2 Test Plan:**

| ID | Layer | Scenario | Expected |
|----|-------|----------|----------|
| B6 | Backend | Profile upsert with `avatarUrl` saves to `profiles.avatar_url` | URL persisted in DB |
| B7 | Backend | Profile upsert with null `avatarUrl` does NOT clear existing | Existing custom avatar preserved |
| B8 | Backend | Profile upsert with explicit empty string clears avatar | `profiles.avatar_url` set to null |
| F3 | Frontend | Both custom and Google avatars present | Shows custom avatar |
| F4 | Frontend | Custom avatar present, no Google avatar | Shows custom avatar |
| F5 | Frontend | Profile page "remove picture" clicked | Preview switches to Google avatar fallback |
| F6 | Frontend | Avatar URL is broken/stale (returns 404) | `onError` fallback to next in chain |
| E1 | E2E | User uploads custom avatar → saves → sidebar updates | Custom image shown everywhere |
| E2 | E2E | User removes custom avatar → saves → falls back to Google | Google avatar shown, not default SVG |
| E3 | E2E | No Google picture, no custom picture | Shows `/user-default.svg` |

---

## Domain Entities

### User (Aggregate Root)
- `id: UUID` - Unique identifier
- `email: String` - Unique, normalized email
- `emailVerifiedAt: DateTime?` - Null until verified via Google
- `googleAvatarUrl: String?` - Persisted from Google `picture` claim on every login (Phase 1)
- `createdAt: DateTime`
- `updatedAt: DateTime`

**Relationships:**
- `1` User → `0..1` Profile (optional during onboarding)
- `1` User → `0..*` OAuthAccount (Google)
- `1` User → `0..*` ProfileExternalLink

### Profile (Entity)
- `userId: UUID`
- `firstName: String`
- `lastName: String`
- `firstNameKana: String?`
- `lastNameKana: String?`
- `avatarUrl: String?` (Phase 2: custom upload; unused in Phase 1)
- `aboutMe: String?`
- `hobby: String?`
- `jobTitle: String?`
- `expertise: String?`
- `joinedCompanyAt: Date?`
- `workHistory: String?`

### OAuthAccount (Entity)
- `id: UUID`
- `userId: UUID`
- `provider: String` (e.g., "google")
- `providerUserId: String` (Google's user ID)
- `createdAt: DateTime`

---

## Requirements

### S-01-01: Google OAuth Login

**Requirement ID:** S-01-01  
**Type:** MUST (Phase 1)  
**Actor:** New or returning user  
**Precondition:** User has valid Google account  

**Main Flow:**
1. User visits app login page
2. User clicks "Sign in with Google"
3. Redirected to Google OAuth consent/login
4. User enters Google credentials (or uses existing session)
5. Google returns authorization code to callback URL
6. App exchanges the authorization code for tokens
7. App validates ID token claims (`iss`, `aud`, `exp`) and `state`
7. **If user exists:** Create Sanctum token, redirect to appropriate dashboard
8. **If user is new:** Create User + OAuthAccount, redirect to profile registration

**Data from Google OIDC Claims:**
- `email` → User.email
- `given_name` (first name) → temporary storage for Profile registration
- `family_name` (last name) → temporary storage
- `picture` (avatar URL) → User.googleAvatarUrl (Phase 1), Profile.avatarUrl (Phase 2 custom upload)
- `sub` (Google user ID) → OAuthAccount.providerUserId

**Business Rules:**
- Email must be unique across system (prevents duplicate user accounts)
- Email is automatically verified on first Google login
- `emailVerifiedAt` set to login timestamp
- OAuthAccount `(provider, providerUserId)` must be globally unique
- OAuth `state` validation is mandatory (CSRF protection)

**Error Cases:**
- Invalid/expired OAuth code or invalid ID token → 401 Unauthorized
- Google OAuth endpoint unavailable → 503 Service Unavailable
- Email already exists but no linked OAuth account → Show message: "Email exists, but not linked to Google. Contact support."

**Acceptance Criteria:**
- ✅ User redirected to Google login page
- ✅ Valid OAuth authorization code/token processed
- ✅ User.email set to Google email
- ✅ User.emailVerifiedAt set to login time
- ✅ OAuthAccount created with provider="google"
- ✅ New user redirected to profile registration
- ✅ Returning user redirected to dashboard
- ✅ Sanctum token issued and returned

**Test Cases:**
- TC-01-01-01: New user logs in → redirected to profile registration
- TC-01-01-02: Existing user logs in → redirected to dashboard
- TC-01-01-03: Invalid OAuth code / ID token → 401 error
- TC-01-01-04: Email collision (email exists but not OAuth linked) → error message

**API Endpoint:**
```
POST /api/auth/google/login
Content-Type: application/json

Request:
{
  "authorizationCode": "string", // Google OAuth authorization code
  "redirectUri": "string" // Popup flow page origin (for example, http://localhost:3000). Legacy "postmessage" is also accepted.
}

Response (201 Created):
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "profile": null // null if first login, else Profile object
  },
  "token": "sanctum_token_string",
  "requiresProfileCompletion": true|false // true if new user
}
```

---

### S-01-02: Profile Registration

**Requirement ID:** S-01-02  
**Type:** MUST (Phase 1)  
**Actor:** User who just completed Google OAuth login  
**Precondition:** User exists, has email verified, but no Profile yet  

**Main Flow:**
1. User sees profile registration form (post-Google login)
2. Required fields are pre-filled from Google where available (firstName, lastName)
3. User fills required fields:
   - hobby (required)
   - jobTitle (required)
   - expertise (required)
   - joinedCompanyAt (required)
4. User optionally fills:
   - firstNameKana, lastNameKana
   - aboutMe
   - workHistory
5. User can add external links (LinkedIn, GitHub, etc.) via ProfileExternalLink
6. User clicks "Complete Registration"
7. Profile created, user redirected to dashboard

**Business Rules:**
- Profile cannot be created without valid User
- All required fields must be present before save
- `hobby`, `jobTitle`, `expertise` are free-form text (no dropdown)
- `joinedCompanyAt` must be a valid date in past
- External links are optional, but if provided, must have valid URL
- Profile is updated in place if the user edits later
- Current API behavior is upsert: if a profile already exists, the same endpoint updates it instead of returning `409`

**Validation Rules:**
- `firstName`, `lastName`: max 100 chars, non-empty
- `hobby`: max 500 chars
- `jobTitle`: max 100 chars
- `expertise`: max 500 chars
- `aboutMe`: max 1000 chars
- `workHistory`: max 2000 chars
- External link URLs: must be valid HTTP/HTTPS URL
- `joinedCompanyAt`: date type, must be ≤ today

**Error Cases:**
- Missing required field → 422 Unprocessable Entity with field-level errors
- Invalid date format → 422 with specific field error

**Implementation Note:**
- The current API returns `200 OK` for both first-time completion and subsequent edits through the same upsert endpoint
- The original create-only `409 Conflict` behavior was replaced for client-generation simplicity; see ADR 0008

**Acceptance Criteria:**
- ✅ Form prefills with Google data
- ✅ All required fields enforced
- ✅ Profile object created with all data
- ✅ External links saved correctly
- ✅ User redirected to dashboard after completion
- ✅ Validation errors shown inline

**Test Cases:**
- TC-01-02-01: Complete all required fields → Profile created
- TC-01-02-02: Missing `hobby` → validation error
- TC-01-02-03: Invalid `joinedCompanyAt` date → validation error
- TC-01-02-04: Add LinkedIn link → external link saved
- TC-01-02-05: User already has Profile → existing profile is updated

**API Endpoint:**
```
POST /api/users/me/profile
Content-Type: application/json
Authorization: Bearer {sanctum_token}

Request:
{
  "firstName": "string",
  "lastName": "string",
  "firstNameKana": "string?",
  "lastNameKana": "string?",
  "hobby": "string",
  "jobTitle": "string",
  "expertise": "string",
  "aboutMe": "string?",
  "workHistory": "string?",
  "joinedCompanyAt": "date (YYYY-MM-DD)",
  "externalLinks": [
    { "platform": "linkedin", "url": "https://..." },
    { "platform": "github", "url": "https://..." }
  ]
}

Response (200 OK):
{
  "profile": { ...Profile object... }
}
```

---

### S-01-03: Login

**Requirement ID:** S-01-03  
**Type:** MUST (Phase 1)  
**Actor:** Returning user (already has User + Profile)  
**Precondition:** User has completed Google OAuth login previously  

**Main Flow:**
1. User visits login page
2. User clicks "Sign in with Google"
3. If already logged into Google browser session:
  - OAuth consent/login can complete seamlessly
4. If not logged into Google:
   - User redirected to Google login
   - Credentials entered
  - Authorization code returned
5. App validates OAuth tokens and claims
6. User found in database (email match)
7. Sanctum token issued
8. User redirected to dashboard (appropriate view for their role)

**Business Rules:**
- Email is the unique identifier
- OAuth ID token claims must be valid (`aud`, `iss`, `exp`)
- User.emailVerifiedAt is used to determine if email was verified via Google
- Sanctum token lifespan: configurable, recommend 30 days

**Error Cases:**
- OAuth validation fails → 401 Unauthorized
- User not found (email not in system) → 401 Unauthorized (do not reveal user existence)
- Google OAuth service unavailable → 503 Service Unavailable

**Acceptance Criteria:**
- ✅ Sanctum token issued to valid user
- ✅ Token valid for subsequent API calls (Authorization: Bearer {token})
- ✅ User redirected to the next application route after login
- ✅ Invalid token rejected with 401

**Test Cases:**
- TC-01-03-01: Returning user logs in → token issued
- TC-01-03-02: Token used in subsequent request → request succeeds
- TC-01-03-03: Invalid email → 401 error
- TC-01-03-04: ID token invalid/expired → 401 error

**API Endpoint:** Same as S-01-01

---

### S-01-04: Logout

**Requirement ID:** S-01-04  
**Type:** MUST (Phase 1)  
**Actor:** Any authenticated user  
**Precondition:** User has valid Sanctum token  

**Main Flow:**
1. User clicks "Logout" button on any page
2. POST request sent to `/api/logout` with valid token
3. Server revokes Sanctum token
4. Frontend clears token from local storage
5. User redirected to login page

**Business Rules:**
- Token must be valid (not expired, not already revoked)
- Logout is idempotent (logging out twice should not error)
- Token revocation is immediate
- Frontend should also clear all cached user data

**Error Cases:**
- No token provided → 401 Unauthorized
- Token already revoked → 401 Unauthorized (or 200 if idempotent)
- Server error during revocation → 500 Internal Server Error

**Acceptance Criteria:**
- ✅ Sanctum token revoked
- ✅ Subsequent requests with revoked token rejected (401)
- ✅ User redirected to login page
- ✅ Cannot use old token for API calls

**Test Cases:**
- TC-01-04-01: User logs out → token revoked
- TC-01-04-02: Attempt API call with revoked token → 401 error
- TC-01-04-03: Log out without token → 401 error
- TC-01-04-04: Log out twice → second logout succeeds (idempotent)

**API Endpoint:**
```
POST /api/auth/logout
Authorization: Bearer {sanctum_token}

Response (200 OK):
{
  "message": "Logged out successfully"
}
```

---

## API Summary

| Endpoint | Method | Auth | Purpose |
|----------|--------|------|---------|
| `/api/auth/google/login` | POST | None | Google OAuth login |
| `/api/users/me/profile` | POST | Sanctum | Create or update profile (post-login upsert) |
| `/api/auth/logout` | POST | Sanctum | Revoke session token |
| `/api/auth/me` | GET | Sanctum | Get authenticated user |

---

## OpenAPI Annotations

All endpoints decorated with Laravel OpenAPI annotations:
- Request/response schemas
- Error codes (401, 422, 500, 503)
- Authentication type (sanctum)

See `specs/api/openapi-contracts.md` for detailed schema definitions.

---

## Prerequisites & Setup

**Environment Variables Required:**
- `GOOGLE_OAUTH_CLIENT_ID` - Google OAuth client ID
- `GOOGLE_OAUTH_CLIENT_SECRET` - Google OAuth client secret
- `GOOGLE_OAUTH_REDIRECT_URI` - OAuth callback URL
- `GOOGLE_OAUTH_SCOPES` - Optional, default `openid profile email`
- `SANCTUM_EXPIRATION_HOURS` - Token lifetime (default: 720 = 30 days)

**External Dependencies:**
- Laravel Sanctum (token-based API authentication — Bearer tokens, **no CSRF/session**; see ADR 0007)
- Guzzle HTTP Client + firebase/php-jwt (Google OAuth code exchange & ID token validation; see ADR 0005)

**Database:**
- Migration `2026_03_05_000001_create_users_table.php` - Users table
- Migration `2026_03_05_000002_create_profiles_table.php` - Profiles table
- Migration `2026_03_05_000004_create_oauth_accounts_table.php` - OAuth accounts
- Migration `2026_03_07_000001_fix_personal_access_tokens_tokenable_id_to_uuid.php` - Fix Sanctum `tokenable_id` from bigint to varchar(36) for UUID support

---

## Dependencies & Ordering

**Must complete before:**
- Any other feature (all require authentication)

**Must be completed:**
- None (can proceed in parallel with other specs)

---

## Notes

- Google OAuth/OIDC is the sole authentication method for Phase 1
- No email/password login
- **Token-only API auth**: `EnsureFrontendRequestsAreStateful` removed from API middleware — no CSRF cookies or sessions for API routes (see ADR 0007)
- Frontend uses popup-based OAuth flow (`flow: "auth-code"`) with `redirectUri: "postmessage"`
- Login responses include a `googleProfile` object for profile form prefill hints
- Profile registration is required but not enforced during login (users can skip and complete later)
- Future custom avatar support is still planned, but Phase 1 persists and displays the Google avatar only
- Sanctum tokens stored in `personal_access_tokens` table (`tokenable_id` is `varchar(36)` for UUID support)
