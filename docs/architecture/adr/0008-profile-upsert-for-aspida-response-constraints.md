# ADR 0008: Use Profile Upsert for Generated Client Simplicity

## Status

Accepted

## Context

The initial authentication and onboarding flow treated profile completion as a create-only operation.

Under that design:

- first-time profile completion would return `201 Created`
- later profile edits would require a separate update path or a different response contract

In practice, the frontend relies on generated API clients from the OpenAPI contract via `aspida`.
Keeping separate create and update success semantics for the same profile setup flow made the generated client contract awkward to use and added unnecessary branching in the UI.

## Decision

The authenticated profile setup endpoint will use one upsert-style API contract:

- endpoint: `POST /api/users/me/profile`
- behavior: create the profile if it does not exist, otherwise update it in place
- success response: `200 OK`
- frontend usage: the same screen and generated client method handle both first-time completion and later edits

## Consequences

### Positive

- The generated client contract remains simple and stable.
- The profile setup page can use one mutation path for both registration and edit.
- OpenAPI and `aspida` output stay easier to consume in TypeScript.

### Negative

- The endpoint is less strictly REST-distinct than separate create and update operations.
- Documentation must be explicit that profile completion is implemented as upsert, not create-only.
- Earlier create-only expectations such as `409 Conflict` for an existing profile are no longer accurate.

## Follow-up

- Keep user-facing and architecture docs explicit about the upsert behavior.
- Revisit the endpoint shape only if the generated client tooling constraints change enough to justify separate create and update contracts.