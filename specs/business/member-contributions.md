## Spec: Member Contributions Tab (`project/{id}`)

A new "メンバー貢献" tab on the project detail page showing per-member issue and story-point statistics in a sortable table with team filtering and date range selection.

---

### User Story

As a **project manager**, I want to see how many issues and story points each member has completed within a project, so I can identify top contributors, balance workloads, and detect members who may need support.

As a **team member**, I want to see my own contribution stats relative to the project, so I can track my progress.

---

### Location

- **Page:** `/projects/{projectId}` (ProjectDetailPage)
- **Tab:** "メンバー貢献" — positioned after "アンケート結果" and before "設定"
- **Tab order:** 進捗ボード → アラート → アンケート結果 → メンバー貢献 → 設定

---

### Data Source

Computed **on-the-fly** from the `issues` table by querying issues for the project, joining via `issue_assignees` pivot to `team_members`, and aggregating per member.

**Existing model reference:** `TeamMemberProjectPerformanceDaily` exists with pre-calculated fields but has no API endpoint or scheduled population. This feature computes stats directly from issues for the prototype; the daily model can be leveraged later for performance optimization.

---

### API Endpoint

```
GET /api/projects/{projectId}/member-contributions
```

**Query Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `start_date` | `date` (YYYY-MM-DD) | No | Filter issues closed on or after this date |
| `end_date` | `date` (YYYY-MM-DD) | No | Filter issues closed on or before this date |
| `team_id` | `uuid` | No | Filter to members of a specific team |

**Authorization:**
- Authenticated user must be a member of at least one team assigned to the project
- Returns `401` if unauthenticated, `403` if not a project team member

**Response Shape:**
```json
{
  "contributions": [
    {
      "teamMemberId": "uuid",
      "userId": "uuid",
      "userName": "string",
      "teamId": "uuid",
      "teamName": "string",
      "closedIssueCount": 5,
      "completedStoryPoints": 21,
      "estimatedMinutesClosed": 480,
      "actualMinutesLogged": 520,
      "onTimeCompletionRate": 0.8,
      "avgCycleTimeHours": 36.5
    }
  ]
}
```

---

### Metrics

All metrics are scoped to the project and optional date range.

| Metric | Column | Computation | Japanese Label |
|--------|--------|-------------|----------------|
| Closed Issues | `closedIssueCount` | Count of issues where `status = 'done'` assigned to this member | 完了イシュー数 |
| Story Points | `completedStoryPoints` | Sum of `story_points` where `status = 'done'` | ストーリーポイント |
| Estimated Minutes | `estimatedMinutesClosed` | Sum of `estimated_minutes` where `status = 'done'` | 見積時間(分) |
| Actual Minutes | `actualMinutesLogged` | Sum of `actual_minutes_logged` (from work logs or issue field) | 実績時間(分) |
| On-Time Rate | `onTimeCompletionRate` | `count(closed_at <= deadline) / count(done issues with non-null deadline)` — nullable if no issues have deadlines | 納期遵守率 |
| Avg Cycle Time | `avgCycleTimeHours` | `avg(closed_at - started_at)` in hours for done issues — nullable if no issues have both timestamps | 平均サイクルタイム(h) |

**On-time definition:** An issue is "on time" if `closed_at <= deadline`. Issues without a deadline are excluded from the rate calculation.

---

### UI Components

#### Filters Bar
- **Team filter:** `<Select>` dropdown populated from `project.teams`. Default: "すべてのチーム" (all teams). Selecting a team filters the table to that team's members.
- **Date range picker:** Two `<input type="date">` fields (start / end). Changing either triggers a refetch with the new date range. Default: empty (all time).

#### Contributions Table
Uses the existing `Table.tsx` component with **client-side sorting** (implemented in Phase 1 of the combined plan).

| Column | Key | Sortable | Format |
|--------|-----|----------|--------|
| メンバー名 | `userName` | Yes | Text |
| チーム | `teamName` | Yes | Text |
| 完了イシュー数 | `closedIssueCount` | Yes | Integer |
| ストーリーポイント | `completedStoryPoints` | Yes | Integer |
| 見積時間(分) | `estimatedMinutesClosed` | Yes | Integer |
| 納期遵守率 | `onTimeCompletionRate` | Yes | Percentage (e.g., "80%"), "—" if null |
| 平均サイクルタイム | `avgCycleTimeHours` | Yes | Decimal hours (e.g., "36.5h"), "—" if null |

**Default sort:** `completedStoryPoints` descending (highest contributors first).

#### States
- **Loading:** Skeleton rows in table
- **Empty:** EmptyState component — "このプロジェクトにはまだ貢献データがありません"
- **Error:** ErrorState component with retry

---

### Frontend Files to Create/Modify

| File | Action | Description |
|------|--------|-------------|
| `teamdev-2026-front/src/features/projects/components/ProjectDetailPage.tsx` | Modify | Extend `TabKey` to include `"contributions"`, add tab config |
| `teamdev-2026-front/src/features/projects/components/MemberContributionsTab.tsx` | Create | Main tab component composing filters + table |
| `teamdev-2026-front/src/features/projects/components/DateRangePicker.tsx` | Create | Two native date inputs (start/end) |
| `teamdev-2026-front/src/features/projects/hooks/useMemberContributions.ts` | Create | SWR hook with `start_date`, `end_date`, `team_id` params |
| `teamdev-2026-front/src/features/projects/components/__tests__/MemberContributionsTab.test.tsx` | Create | Jest tests |

### Backend Files to Create/Modify

| File | Action | Description |
|------|--------|-------------|
| `teamdev-2026-api/web/app/Interfaces/Http/Controllers/Project/MemberContributionController.php` | Create | Invokable controller |
| `teamdev-2026-api/web/app/Application/Project/UseCases/GetMemberContributionsUseCase.php` | Create | Query + aggregation logic |
| `teamdev-2026-api/web/app/Interfaces/Http/Schemas/MemberContributionResponse.php` | Create | OpenAPI response annotation |
| `teamdev-2026-api/web/routes/api.php` | Modify | Register route |
| `teamdev-2026-api/web/tests/Feature/Interfaces/Http/Project/MemberContributionControllerTest.php` | Create | Feature tests |

---

### Test Cases

#### Backend
1. `test_returns_contributions_for_all_project_members` — verifies response shape with correct member data
2. `test_filters_by_date_range` — only counts issues closed within the range
3. `test_filters_by_team_id` — only returns members of the specified team
4. `test_computes_correct_closed_issue_count` — seed known issues, verify count
5. `test_computes_correct_completed_story_points` — seed known SPs, verify sum
6. `test_computes_on_time_completion_rate_as_closed_at_lte_deadline` — seed on-time and late issues, verify rate
7. `test_computes_avg_cycle_time_hours` — seed issues with known started_at/closed_at, verify avg
8. `test_unauthenticated_returns_401`
9. `test_non_project_member_returns_403`
10. `test_empty_project_returns_empty_contributions_array`

#### Frontend
1. `test_contributions_tab_renders_loading_state`
2. `test_contributions_tab_renders_member_table_with_all_metrics`
3. `test_team_filter_dropdown_filters_displayed_members`
4. `test_date_range_picker_triggers_refetch`
5. `test_table_columns_are_sortable`
6. `test_empty_state_when_no_contributions`
7. `test_null_on_time_rate_displays_dash`

---

### Dependencies

- **Phase 1 of combined plan must be done first:** Table.tsx client-side sorting must be implemented before this tab can use sortable columns.
- **OpenAPI codegen:** After backend endpoint is created, run `mise codegen-openapi` to generate TypeScript types before building frontend.

---

### Future Enhancements (Out of Scope)

- Use `TeamMemberProjectPerformanceDaily` with a scheduled artisan command for pre-computed stats (performance optimization for large projects)
- Data visualization (bar/pie charts) for contribution distribution
- Export to CSV
- Comparison view between time periods
