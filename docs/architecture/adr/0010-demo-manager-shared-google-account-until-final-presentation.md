# ADR 0010: Use One Shared Dedicated Google Account for Demo Manager Access Until the Final Presentation

- Status: Accepted
- Date: 2026-04-02

## Context

The current demo-data flow is built around one canonical demo manager identity.

The repository currently:
- Reads one `DEMO_MANAGER_EMAIL` from application config
- Requires that Google login create that user before demo seeding
- Attaches demo team, project, alert, and survey relationships to the resolved demo manager user ID
- Reuses the same Google account on returning login via provider user ID

We considered three approaches for allowing multiple team members to access the demo account:
- Share one dedicated Google account for demo use
- Add support for multiple demo-manager emails
- Add a separate impersonation or delegated-access mechanism

The final presentation is near, and we want the lowest-risk option with the fewest code and operational changes during the remaining demo period.

## Decision

We will use one dedicated shared Google account for demo manager access until the final presentation.

This means:
- The team will keep the existing single-account seeding and login flow
- We will not implement multiple demo-manager emails before the final presentation
- We will not implement impersonation or delegated access before the final presentation
- The account email used in docs will remain a placeholder until the real account is created
- The password will not be written in the repository; team members must ask the designated owner directly

## Consequences

### Positive

- No application code changes are required
- The existing `DEMO_MANAGER_EMAIL`-based seeding flow remains valid
- The existing Google OAuth mapping remains stable
- The demo dataset stays attached to one canonical user identity
- This is the lowest-risk option for the remaining presentation period

### Trade-offs

- The account is operationally shared
- Team members do not have individual attribution while using the demo account
- Concurrent use can overwrite visible state such as profile or in-app activity
- Password handling must be managed outside the repository

### Follow-up After the Final Presentation

After the final presentation, revisit a safer long-term option:
- delegated access to one canonical demo persona, or
- an allowlist-based impersonation flow

## References

- `README.md`
- `scripts/laravel-init.sh`
- `teamdev-2026-api/web/config/app.php`
- `teamdev-2026-api/web/database/seeders/DemoUserSeeder.php`
- `teamdev-2026-api/web/app/Application/Auth/UseCases/AuthenticateWithGoogleUseCase.php`