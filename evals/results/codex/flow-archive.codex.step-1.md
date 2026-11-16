Exploration and plan review are complete. No code changes yet. The probe server is stopped and its temporary data removed.

- [x] 0 workspace checked
- [x] 1 explore → brief.md
- [x] 2 plan → plan.md
- [ ] GATE A: plan approved
- [ ] 3 build → diff
- [ ] 4 prove → checks/*.md
- [ ] 5 report → report.md
- [ ] GATE B: user reviews and commits

The plan:

1. **Persist archive state.** Update `src/db.ts` with an `archived` integer column, defaulting to `0`, and a guarded migration for existing databases. First add `test/db.test.ts` coverage for fresh databases, preservation of existing notes, repeated initialization, and archive persistence after reopening.

2. **Implement the endpoint and list filter.** Update `src/app.ts`, `test/notes.test.ts`, and `README.md`. First write tests, then add an authenticated update constrained by both note ID and owner ID. Return an empty `204` for a matching note and `404` otherwise. Exclude archived notes from `GET /notes`.

3. **Use these behavior defaults.** Repeated owner archive requests return `204`. Owners retain access through `GET /notes/:id`. Use a single archive column; restore, archive listings, deletion, and UI are outside scope.

4. **Prove each acceptance point with real HTTP requests.**

   | Acceptance point | Planned proof |
   |---|---|
   | Owner receives `204` | Archive through HTTP; assert status and empty body |
   | Archived note disappears | Compare list IDs before/after; retain an active control note |
   | Other user receives `404` without changing the note | Attempt against a fresh active note; verify owner’s list and saved state |
   | Unknown ID receives `404` | Send an authenticated request for an absent numeric ID |

   Also verify migration from an old database and persistence across a server restart. Add regression tests for unauthenticated requests, repeated archiving, and direct reads.

5. **Validate and review.** Run the full `bun test` suite. Use `can-it-fail`, including separate ownership and list-filter mutations, restore the code, and rerun tests. Run `prove-it` and `review`; record evidence under `checks/`. Use temporary databases and a free port, then stop servers and remove probe data. No design or manual testing step is needed.

6. **Report and leave the diff for you.** Write `report.md` mapping acceptance points to evidence. No commit or push. Lint/type-check tooling is absent; record unavailable checks explicitly. Adding that tooling is a separate task.

The challenger found no blocking objections. The only open decision is approval of this plan and its behavior defaults.

**Approve this plan?**

The [flow skill](.agents/skills/flow/SKILL.md) explicitly requires: “No code, test, or config edit until the user approves the plan.” That Gate A requirement is why I’m pausing here.