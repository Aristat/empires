# PRD: [Feature Name]

## Overview
<!-- One paragraph: what is this feature and why does it exist? -->

## Problem Statement
<!-- What problem does this solve? Who has this problem? -->

## Goals
- [ ] Goal 1
- [ ] Goal 2
- [ ] Goal 3

## Non-Goals
<!-- What is explicitly OUT of scope for this feature? -->
- Not doing X
- Not doing Y

---

## Users & Roles
<!-- Who uses this feature? -->
| Role | Description | Permissions |
|---|---|---|
| Admin | Manages the system | Full access |
| User | Regular account | Limited access |

---

## Functional Requirements

### Core Behavior
<!-- What must the system DO? -->
1. **FR-01** — System must...
2. **FR-02** — User can...
3. **FR-03** — When X happens, Y must occur...

### API Endpoints
<!-- List all endpoints needed -->
| Method | Path | Description | Auth Required |
|---|---|---|---|
| POST | /api/v1/resource | Create resource | ✅ |
| GET | /api/v1/resource/:id | Get resource | ✅ |
| PUT | /api/v1/resource/:id | Update resource | ✅ |
| DELETE | /api/v1/resource/:id | Delete resource | ✅ |

### Business Rules
<!-- Edge cases, constraints, validations -->
- Rule 1: Email must be unique per organization
- Rule 2: User cannot delete their own account
- Rule 3: Maximum 5 retries before lockout

---

## Data Model

### New Tables
```
table_name
  - id: uuid
  - field_1: string, not null
  - field_2: integer, default: 0
  - user_id: FK → users
  - created_at / updated_at
```

### Modified Tables
```
existing_table
  + new_column: string
  + new_index: on (column_name)
```

---

## Acceptance Criteria
<!-- Definition of Done — testable statements -->
- [ ] **AC-01** Given X, When Y, Then Z
- [ ] **AC-02** Given X, When Y, Then Z
- [ ] **AC-03** Error case: Given invalid input, API returns 422 with message
- [ ] **AC-04** Performance: Endpoint responds in < 200ms

---

## Technical Notes
<!-- Hints for the architect agent -->
- Use `[gem name]` for X
- Follow existing pattern in `app/services/[example].rb`
- Reuse `[existing service/concern]`
- Index on `[column]` for performance

---

## Dependencies
<!-- Other features or services this depends on -->
- Requires: User authentication (already built)
- Requires: Email service configured
- Blocks: [feature that depends on this]

---

## Out of Scope / Future Iterations
- v2: Add support for X
- v2: Integrate with Y service

---

## Metadata
| Field | Value |
|---|---|
| Author | |
| Created | |
| Status | Draft / Review / Approved |
| Priority | High / Medium / Low |
| Estimate | X days |
