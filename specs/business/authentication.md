# Authentication & Authorization Specification

**Version:** 1.1  
**Last Updated:** 2026/03/07  
**Human Documentation:** `docs/business-logic/workflows/authentication.md`  
**Domain Model:** `docs/diagrams/domain-models/user-aggregate.puml`

---

## Purpose

Define the complete authentication and authorization flows for all user types (Project Managers, Team Members). This spec covers:
- Google OAuth login (OIDC)
- Profile registration and completion
- Session management (login/logout)
- OAuth account linking

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

---

## Domain Entities

### User (Aggregate Root)
- `id: UUID` - Unique identifier
- `email: String` - Unique, normalized email
- `emailVerifiedAt: DateTime?` - Null until verified via Google
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
- `avatarUrl: String?` (from Google)
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
- `picture` (avatar URL) → Profile.avatarUrl
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
  "redirectUri": "string" // "postmessage" for popup flow, or callback URI
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
2. Required fields are pre-filled from Google (firstName, lastName, avatarUrl)
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
- Profile is updated (not recreated) if user edits later

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
- User already has Profile → 409 Conflict (profile already exists)

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
- TC-01-02-05: User already has Profile → 409 error

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

Response (201 Created):
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
- ✅ User redirected to correct dashboard (manager vs. member)
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
| `/api/users/me/profile` | POST | Sanctum | Create profile (post-login) |
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
- Profile registration is required but not enforced during login (users can skip and complete later)
- Sanctum tokens stored in `personal_access_tokens` table (`tokenable_id` is `varchar(36)` for UUID support)
