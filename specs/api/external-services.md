# External Services Integration Specification

**Version:** 1.0  
**Last Updated:** 2026/03/06  
**Human Documentation:** `docs/api/external-services.md`

---

## Purpose

Define integration contracts and operational procedures for external services:
- SendGrid (email delivery)
- GitHub (CI/CD, commit tracking)

---

## SendGrid Email Integration

### Purpose

Send alert notifications, survey invitations, team invitations, and system notifications via SendGrid.

### Configuration

**Environment Variables (Laravel .env):**
```
SENDGRID_API_KEY=your_api_key_here
SENDGRID_FROM_EMAIL=alerts@motiv.cloud
SENDGRID_FROM_NAME="Propass"
SENDGRID_ALERT_TEMPLATE_YELLOW=d-template_id_yellow
SENDGRID_ALERT_TEMPLATE_RED=d-template_id_red
SENDGRID_SURVEY_TEMPLATE=d-survey_template_id
SENDGRID_INVITE_TEMPLATE=d-invite_template_id
```

### Template Configuration

All email templates managed in SendGrid web UI (not in code). Templates use variables:

**Alert Email (Yellow) - Template ID: `{SENDGRID_ALERT_TEMPLATE_YELLOW}`**

Variables:
- `{{firstName}}` - Project manager first name
- `{{projectName}}` - Project name
- `{{alertDescription}}` - Alert summary
- `{{currentProgress}}` - Current completion %
- `{{expectedProgress}}` - Expected completion %
- `{{actionPlans}}` - HTML list of suggested actions
- `{{projectUrl}}` - Link to project detail

**Alert Email (Red) - Template ID: `{SENDGRID_ALERT_TEMPLATE_RED}`**

Same variables as Yellow, with additional:
- `{{projectedCompletionDate}}` - When work will finish at current pace
- `{{daysOverdue}}` - Projected number of days past deadline

**Survey Invitation Email - Template ID: `{SENDGRID_SURVEY_TEMPLATE}`**

Variables:
- `{{firstName}}` - Recipient first name
- `{{teamName}}` - Team name
- `{{surveyLink}}` - Direct link to survey
- `{{expiresAt}}` - Survey expiration date

**Team Invitation Email - Template ID: `{SENDGRID_INVITE_TEMPLATE}`**

Variables:
- `{{firstName}}` - Invitee first name
- `{{inviterName}}` - Manager name
- `{{teamName}}` - Team name
- `{{acceptLink}}` - Accept invite link
- `{{declineLink}}` - Decline invite link
- `{{expiresAt}}` - Invitation expiration date

### Sending Logic

**Notification Service** (Laravel Service):

```php
class EmailNotificationService {
    public function sendAlertNotification(Alert $alert): void {
        $template = $alert->level === 'yellow' 
            ? env('SENDGRID_ALERT_TEMPLATE_YELLOW')
            : env('SENDGRID_ALERT_TEMPLATE_RED');
            
        $data = [
            'firstName' => $alert->project->managers[0]->profile->firstName,
            'projectName' => $alert->project->title,
            'alertDescription' => $alert->description,
            // ... other variables
        ];
        
        $this->queue(new SendAlertEmail(
            to: $projectManager->email,
            templateId: $template,
            data: $data
        ));
    }
}
```

### Queue Management

All emails queued (asynchronous delivery):

1. **Queue Provider:** Laravel Queue (database or Redis, configurable)
2. **Queue Name:** `emails` (default)
3. **Retry Policy:** 
   - Max attempts: 3
   - Backoff: exponential (1m, 5m, 15m)
   - Timeout: 60 seconds per attempt
4. **Failure Handling:**
   - Failed job logged to `email_delivery_logs` table
   - Manual retry available via admin command
   - Alert if repeated failures

**Database Table for Tracking:**

```sql
CREATE TABLE email_delivery_logs (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  job_id VARCHAR(255),
  recipient_email VARCHAR(255),
  subject VARCHAR(255),
  template_type VARCHAR(50),
  status ENUM('queued', 'sent', 'failed', 'bounced'),
  sendgrid_message_id VARCHAR(255),
  sendgrid_response JSON,
  error_message TEXT,
  attempts INT DEFAULT 1,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  INDEX idx_status (status),
  INDEX idx_created_at (created_at)
);
```

### Rate Limiting

**SendGrid Account Limits:**
- Verify plan allows sufficient daily volume (typically 40K/day for paid plans)
- Phase 1 expected volume: < 1K emails/day

**Application Rate Limiting:**
- Max 10 alert emails per project per day (prevent spam/fatigue)
- Check: `COUNT(AlertLog WHERE projectId = ? AND createdAt >= NOW() - 1 DAY) < 10`
- Subsequent triggers queue but don't send email until next day

### Webhook Integration (Future)

SendGrid events webhook (optional Phase 1, recommended Phase 2):
- Endpoint: `POST /webhooks/sendgrid/events`
- Events tracked: delivered, opened, clicked, bounced, dropped
- Stored in `email_delivery_logs` for analytics

### Error Handling

| Scenario | Action |
|----------|--------|
| API key invalid | 401 error logged, retry after 1 hour |
| Template not found | 400 error logged, alert developer |
| Recipient invalid | 422 error logged, skip (don't retry) |
| Rate limited (429) | Back off 5 minutes, retry |
| Server error (5xx) | Retry with exponential backoff |

### Testing (Phase 1)

- **Development:** Use SendGrid sandbox mode or test email addresses
- **Testing:** Mock SendGrid API responses in unit tests
- **Staging:** Use SendGrid with real but test email addresses
- **Production:** Real SendGrid account with monitoring

---

## GitHub Integration

### Purpose

Link Propass issues to GitHub commits and CI/CD pipelines for:
- Automatic work logging from commits
- Issue status updates from CI/CD
- Linking commits to issues

### Configuration

**Environment Variables:**

```
GITHUB_WEBHOOK_SECRET=your_webhook_secret
GITHUB_APP_ID=your_github_app_id
GITHUB_APP_PRIVATE_KEY=path-to-private-key
GITHUB_ORG_NAME=your_org_name
GITHUB_REPO_NAME=your_repo_name
```

**GitHub App Setup:**

1. Create GitHub App in organization settings
2. Grant permissions:
   - Pull requests: read & write
   - Commits: read
   - Issues: read & write
   - Webhooks: read & write
3. Subscribe to events:
   - `push` - Commit pushed
   - `pull_request` - PR opened/closed/merged
4. Set webhook URL: `https://app.motiv.cloud/webhooks/github/push`
5. Set webhook secret (GITHUB_WEBHOOK_SECRET)

### Webhook Contract

**Incoming Event: Push**

```json
{
  "ref": "refs/heads/feature/S-03-01-api-endpoint",
  "repository": { "name": "..." },
  "pusher": { "name": "alice_smith" },
  "commits": [
    {
      "id": "abc123",
      "message": "Implement GET endpoint\n\nCloses #S-03-01",
      "timestamp": "2026-03-06T10:30:00Z",
      "author": { "email": "alice@example.com" }
    }
  ]
}
```

### Issue Linking

**Branch Naming Convention:**
```
feature/S-03-01-issue-title
fix/S-03-02-issue-title
refactor/S-03-03-issue-title

Regex: (feature|fix|refactor)/([A-Z]-\d{2}-\d{2})-.*
```

**Commit Message Convention:**
```
Implement API endpoint

Closes #S-03-01
```

**Parsing Logic:**
1. Extract branch name: `feature/S-03-01-api-endpoint`
2. Extract issue ID: `S-03-01` from branch
3. Parse commit message for "Closes #S-03-01"
4. Match to Propass issue ID (stored in issue.external_id or mapping table)
5. Create IssueWorkLog entry

### Work Logging from GitHub

**IssueWorkLog Entry Created:**

```
IssueWorkLog {
  issueId: UUID (matched via S-03-01),
  teamMemberId: UUID (matched via git author email),
  source: "github_api",
  externalLogId: "abc123" (commit SHA),
  startedAt: commit_timestamp - 30 min (estimate),
  endedAt: commit_timestamp,
  minutes: 30 (default; can be refined later)
}
```

**Progress Recalculation:**
- IssueWorkLog creates audit trail
- Issue.estimatedMinutes can accumulate real time logged
- Progress bar updated (S-03-08)

### CI/CD Status Updates

**Incoming Event: Pull Request / Actions Status**

When GitHub Actions runs tests:
- Success → Issue comment with success link
- Failure → Issue comment with error details and test failure logs

**Comment Template:**
```
✅ / ❌ CI/CD Status Update

Tests: [PASSED / FAILED]
Link: [GitHub Actions run]
Time: 2m 45s

Details: [Log output excerpt]
```

### Webhook Validation

All incoming GitHub webhooks must be validated:

```php
// Verify webhook signature
$signature = request()->header('X-Hub-Signature-256');
$payload = request()->getContent();
$expected = 'sha256=' . hash_hmac('sha256', $payload, env('GITHUB_WEBHOOK_SECRET'));

if (!hash_equals($signature, $expected)) {
    abort(403, 'Invalid webhook signature');
}
```

### Error Handling

| Scenario | Action |
|----------|--------|
| Issue not found (S-03-01) | Log warning, skip work log creation |
| Author email not found | Log warning, use system user |
| Webhook signature invalid | Reject (403) and log |
| GitHub API down | Queue for retry after 1 hour |

### Testing

**Development:**
- Mock GitHub webhook payloads in tests
- No real GitHub integration in unit tests

**Staging:**
- Test with real (non-production) GitHub repo
- Verify work logs created correctly

**Production:**
- Monitor webhook delivery logs
- Alert if webhooks fail repeatedly

### Rate Limiting

GitHub API has rate limits:
- Authenticated requests: 5,000 per hour
- Unauthenticated: 60 per hour
- Phase 1 expected: < 100 per day (well within limits)

---

## API Endpoint Summary

| Endpoint | Method | Purpose | Auth |
|----------|--------|---------|------|
| `/webhooks/github/push` | POST | Receive push event | Signature |
| `/api/emails/delivery-logs` | GET | View email delivery history | Bearer |
| `/api/emails/{emailId}/resend` | POST | Manually resend failed email | Bearer |

---

## Monitoring & Alerting

**Key Metrics:**
- Email delivery success rate (target: 99%+)
- Email delivery latency (target: < 5 seconds)
- GitHub webhook failures (target: 0)
- GitHub sync lag (target: < 5 minutes)

**Alerts Triggered If:**
- Email delivery rate drops below 95% for 1 hour
- 3+ consecutive GitHub webhook failures
- SendGrid API unavailable

---

## Security Considerations

**SendGrid API Key:**
- Never commit to repository
- Use environment variables
- Rotate annually
- Monitor usage for unauthorized access

**GitHub Webhook Secret:**
- Strong random string (min 32 chars)
- Verified on every request
- Rotate if compromised

**Email Privacy:**
- Only send to intended recipients
- No PII in email body (only names, no passwords)
- Comply with email list unsubscribe requirements

---

## Costs

**SendGrid:**
- Free tier: 100 emails/day
- Paid: $9.95+/month (varies by volume)
- Phase 1 estimate: Free tier sufficient

**GitHub:**
- Free for public repos
- GitHub App: Free
- No additional cost

---

## Dependencies & Ordering

**Must complete before:**
- Alert system (emails required)
- Issue work logging from GitHub
- Team invitations (emails required)

**Requires:**
- SendGrid account created
- GitHub App registered in repo organization
- API keys configured in .env

---

## Future Enhancements

- Slack integration (notifications)
- Jira integration (issue sync)
- Google Workspace integration (calendar sync for vacation detection)
- Automated commit message validation
