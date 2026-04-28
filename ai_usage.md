# AI Usage Disclosure

**Tool Used**: Antigravity (powered by Google DeepMind / Gemini)

## What AI Was Used For

| Task | AI Contribution |
|---|---|
| Project structure | Designed the folder layout and file list |
| `docker-compose.yml` | Generated and improved (healthcheck, named volume) |
| `scripts/seed_data.sql` | Generated full schema: tables, indexes, views, JSONB column, `generate_series` bulk data |
| `sample_queries.sql` | Generated all SQL including window functions, CTEs, JSONB operators, execution plan queries |
| `README.md` | Drafted all 6 required sections, version tables, expected output |
| Presentation strategy | Suggested the 10–15 minute demo flow and UI feature order |

## Human Oversight

All generated code was:
- Reviewed line-by-line by the student.
- Tested live against the running Docker PostgreSQL instance.
- Modified to fix `docker-compose` → `docker compose` (V2) and other environment-specific issues.
- Validated that all queries return correct results in DBeaver before inclusion.

## AI Tools Not Used For
- The live DBeaver demo recording / video.
- The slide deck content (written independently).
- The final presentation narration.

---
*Disclosure required by YZV 322E — Applied Data Engineering, Spring 2026.*
