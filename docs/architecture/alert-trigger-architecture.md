# Alert System Architecture (Time-Based Triggers)

This document describes how the alert/automation system should be implemented for the application.  
The goal is to support multiple time-based alerts (e.g., overdue tasks, unanswered surveys) in a scalable and maintainable way.

---

# 1. Core Design Principle

Do **not** create separate boolean/timestamp columns in each business table to track whether an alert has been sent.

Example of what **not** to do:

- `tasks.overdue_notified_at`
- `surveys.reminder_sent_at`
- `users.inactivity_warning_sent_at`

This approach tightly couples alert logic to the schema and becomes difficult to maintain as the number of alert types grows.

Instead, alert triggers should be managed **centrally**.

---

# 2. Central Trigger Log Table

Create a centralized table that records when alerts have been triggered.

### `trigger_logs`

| column | description |
|------|-------------|
| id | primary key |
| trigger_type | type of alert (e.g. `task_overdue`, `survey_reminder`) |
| entity_type | domain entity (`task`, `survey`, `user`, etc.) |
| entity_id | id of the entity |
| triggered_at | timestamp when the alert fired |

Example:

```text
trigger_logs
- id
- trigger_type
- entity_type
- entity_id
- triggered_at
```

This table prevents duplicate alerts and keeps alert state separate from domain data.

---

# 3. Scheduler Strategy (Highly Scalable)

Use a time-window scheduler instead of per-item delayed jobs.

Run a scheduler every minute:

```bash
php artisan schedule:run
```

Laravel scheduler configuration:

```php
$schedule->command('alerts:process')->everyMinute();
```

The scheduler should check entities whose trigger conditions are met within a time window.

Example: tasks that just became overdue.

```php
Task::whereBetween('due_date', [
    now()->startOfMinute(),
    now()->endOfMinute()
])
->where('completed', false)
->get();
```

This approach is scalable because:

- The scheduler runs at a constant frequency.
- Queries are bounded by a time window.
- With an index on time fields (e.g. `due_date`), the database performs an efficient range scan instead of scanning the entire table.

---

# 4. Preventing Duplicate Alerts

Before sending an alert, check if the trigger already exists in `trigger_logs`.

Example logic:

```php
$alreadyTriggered = TriggerLog::where([
    'trigger_type' => 'survey_reminder',
    'entity_type'  => 'survey',
    'entity_id'    => $survey->id,
])->exists();
```

If it does not exist:

1. Send the alert (email, notification, etc.)
2. Insert a record into `trigger_logs`

---

# 5. Example Trigger Implementations

## Overdue Task Alert

Condition:

```
task.due_date < now()
task.completed = false
```

If no existing `task_overdue` record exists in `trigger_logs`, send an email.

---

## Survey Reminder

Condition:

```
survey.last_answered_at < now() - 7 days
```

If no `survey_reminder` entry exists in `trigger_logs`, send reminder email.

---

# 6. Job Processing

The scheduler should not send emails directly.

Instead it should dispatch jobs to a queue.

Example flow:

1. Scheduler runs every minute
2. Matching entities are identified
3. Jobs are dispatched to queue
4. Queue workers send emails

Queue worker command:

```bash
php artisan queue:work
```

---

# 7. Infrastructure Requirements

The following background processes must run continuously:

- Laravel scheduler (`schedule:run`)
- Queue workers (`queue:work`)

These can run as container services (e.g., on AWS ECS).

---

# 8. Benefits of This Architecture

This design provides:

- High scalability (bounded queries with indexed timestamps)
- Centralized alert state
- No schema pollution
- Extensibility for future alert types
- Idempotent alert processing
- Operational simplicity

New alert types can be added without modifying existing database schemas.

---

# 9. Example Future Alerts

The system should support additional rules such as:

- User inactive for 30 days
- Project idle for 14 days
- Upcoming deadline reminders
- Daily summary notifications

All of these can reuse the same scheduler + trigger log mechanism.
