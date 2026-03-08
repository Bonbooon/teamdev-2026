# Profile & Visibility Specification

**Version:** 1.1  
**Last Updated:** 2026/03/08  
**Human Documentation:** `docs/business-logic/workflows/profile-visibility.md`  
**Domain Model:** `docs/diagrams/domain-models/user-aggregate.puml`

---

## Purpose

Define profile viewing and visibility features that help team members understand each other's skills and experience.

## Implementation Status (2026/03/08)

- This document remains the planned visibility scope for the user aggregate.
- The current implementation does **not** yet provide dedicated profile visibility endpoints such as `GET /api/users/{userId}/profile`, `PUT /api/users/{userId}/profile`, or avatar upload.
- The current codebase supports:
  - `GET /api/auth/me` for the authenticated user's profile payload
  - `POST /api/users/me/profile` for the authenticated user's profile registration and edit
  - Google avatar display with default fallback
- Expertise tag extraction, colleague profile viewing, and avatar upload remain planned and should be treated as not-yet-implemented scope.

---

## Scope

**MUST Features (Phase 1):**
- S-06-01: Expertise/Specialization Display
- S-06-02: Profile Viewing (own and others)

---

## Domain Entities

### Profile (Entity)
See user-aggregate.puml. Key fields:
- `firstName`, `lastName`
- `hobby`
- `jobTitle`
- `expertise` - Free-form text describing strong areas
- `joinedCompanyAt`
- `workHistory`
- `avatarUrl`

### ProfileExternalLink (Entity)
- `platform: String?` - e.g., "linkedin", "github", "wantedly"
- `url: String` - External URL

---

## Requirements

### S-06-01: Expertise Display

**Requirement ID:** S-06-01  
**Type:** MUST (Phase 1)  
**Actor:** Manager, Team Member  
**Precondition:** Viewing team member list or member profile  

**Main Flow:**
1. User views team member list
2. Each member card shows:
   - Avatar
   - Name
   - Job title
   - **Expertise tags** (derived from profile.expertise field)
3. Click on member card to view full profile

**Expertise Extraction:**
- Profile.expertise is free-form text
- System parses into skills/keywords
- Phase 1: Simple keyword extraction (comma-separated or regex-based)
- Example: "React, TypeScript, GraphQL" → tags: [React, TypeScript, GraphQL]

**Tag Display:**
```
[Avatar] Alice Smith
Backend Lead

Expertise: [React] [TypeScript] [GraphQL] [+more]
```

**Business Rules:**
- Skills are derived from user's expertise field
- Users can edit their own expertise
- Tags help in finding subject matter experts
- "Who to ask" for specific domains

**Acceptance Criteria:**
- ✅ Expertise displayed as tags
- ✅ Tags extracted from profile
- ✅ Click tag to filter (future: Phase 2)
- ✅ Own profile can be edited

**Test Cases:**
- TC-06-01-01: View team member → expertise tags shown
- TC-06-01-02: Edit own expertise → tags updated
- TC-06-01-03: Multiple expertise areas → multiple tags

**API Endpoint:**
```
GET /api/users/{userId}/profile
Authorization: Bearer {token}

Response (200 OK):
{
  "profile": { ...Profile object... },
  "expertise": ["React", "TypeScript", "GraphQL"]
}
```

---

### S-06-02: Profile Viewing

**Requirement ID:** S-06-02  
**Type:** MUST (Phase 1)  
**Actor:** Manager, Team Member  
**Precondition:** User viewing own profile or colleague profile  

**Main Flow:**
1. User clicks on member name or profile link
2. Profile page opens with:
   - Avatar
   - Name (full name, kana if provided)
   - Job title
   - Expertise (tags)
   - About me (short bio)
   - Hobby
   - Joined company date
   - Work history
   - External links (LinkedIn, GitHub, etc.)
3. For own profile: "Edit Profile" button visible
4. For others: Read-only view

**Own Profile View:**
```
[Avatar]
[Name] [Job Title]

About Me: [Text]
Hobby: [Text]

Expertise: [Tags]

Work History: [Text]

Company Join Date: [Date]
Project Join Date: [Date] (from project)

External Links:
[LinkedIn] [GitHub] [Wantedly]

[Edit Profile] [Change Avatar]
```

**Other's Profile View:**
Same as above, but no Edit button.

**Edit Profile Flow:**
1. Click "Edit Profile"
2. Form opens with editable fields
3. Avatar upload (optional)
4. All profile fields editable
5. External links manageable (add/remove)
6. Click "Save"
7. Profile updated

**Business Rules:**
- Users can edit only their own profile
- Manager cannot edit team member's profile
- Profile fields mostly free-form
- Job title, expertise, etc. are self-reported (not validated)
- Avatar from Google or uploaded by user

**Validation Rules:**
- firstName, lastName: max 100 chars
- hobby, expertise, aboutMe, workHistory: max 500/1000 chars
- External links: valid URLs
- Company join date: past or today

**Error Cases:**
- Profile not found → 404 Not Found
- Permission denied (trying to edit others) → 403 Forbidden
- Invalid field data → 422 Unprocessable Entity

**Acceptance Criteria:**
- ✅ View own profile
- ✅ View others' profiles
- ✅ Edit own profile
- ✅ Cannot edit others
- ✅ External links displayed
- ✅ Expertise shown

**Test Cases:**
- TC-06-02-01: View own profile → all fields displayed
- TC-06-02-02: View colleague's profile → read-only
- TC-06-02-03: Edit own profile → fields updated
- TC-06-02-04: Attempt to edit others → 403 error
- TC-06-02-05: Add external links → saved and displayed

**API Endpoints:**
```
GET /api/users/{userId}/profile
Authorization: Bearer {token}

PUT /api/users/{userId}/profile
Authorization: Bearer {token}
Request:
{
  "firstName": "string",
  "lastName": "string",
  "firstNameKana": "string?",
  "lastNameKana": "string?",
  "jobTitle": "string",
  "expertise": "string",
  "hobby": "string",
  "aboutMe": "string?",
  "workHistory": "string?",
  "joinedCompanyAt": "date",
  "externalLinks": [
    { "platform": "linkedin", "url": "..." },
    { "platform": "github", "url": "..." }
  ]
}

POST /api/users/{userId}/profile/avatar
Content-Type: multipart/form-data
Request:
{
  "avatar": "file" // Image upload
}
```

---

## Profile Visibility by Context

**Team Member Page:**
- All team members visible (own team only, in Phase 1)
- Profile click opens detail

**Project Collaboration:**
- Team members from assigned teams visible
- Quick profile view in assignee list

**Issue Assignees:**
- Clickable assignee avatars
- Hover shows name/title
- Click opens profile

---

## Dependencies & Ordering

**Must complete before:**
- Team management (team member visibility)
- Project management (assignee selection)

**Requires:**
- S-01 (authentication, users/profiles exist)
- S-04 (teams)

---

## Notes

- Profiles are foundational for "Mutual Understanding" pillar
- Expertise parsing simple in Phase 1; can evolve to skill taxonomy in Phase 2
- Custom avatar upload remains future scope; the current implementation uses Google avatar first and falls back to `/user-default.svg`
- Work history not verified; helps PM understand background
- External links help with remote collaboration (LinkedIn for work context, GitHub for code)
- All timestamps in UTC
