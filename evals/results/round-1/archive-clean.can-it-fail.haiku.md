## Report: archive a note (`change/archive-clean` vs `main`)

**8 tests pass, 0 fail.** Acceptance points: 4 passed, 0 failed, 0 not-run, 0 could-not-run.

The archive endpoint was already on this branch in the `change` commit. I verified it, found one defect in it, fixed that defect, and ran can-it-fail on the new tests.

### Defect found and fixed

A database created before this change has no `archived` column. `CREATE TABLE IF NOT EXISTS` does not add it, so `GET /notes` threw `SQLiteError: no such column: archived` on such a DB. I reproduced it against the `main` schema.

- **Fix, `src/db.ts`:** `openDb` checks `PRAGMA table_info(notes)` and runs `ALTER TABLE notes ADD COLUMN archived INTEGER NOT NULL DEFAULT 0` when the column is missing.
- **Test, `test/archive.test.ts`:** "a database created before archiving still lists notes". It builds an old-schema file DB with one note and checks that `GET /notes` returns it.

### Acceptance points

| Acceptance point | Proof | Result |
|---|---|---|
| 1. Owner archives and gets `204` | `bun test` "archives a note and removes it from the list" passes. Smoke test: `POST /notes/1/archive` as alice returned `204`. | `passed` |
| 2. Archived note leaves `GET /notes` | Same test checks `list.items` is `[]`. Smoke test: alice's `GET /notes` returned `{"items":[]}` after archiving. | `passed` |
| 3. Other user gets `404`, note stays in owner's list | "does not let another user archive the note" passes. Smoke test: bob got `404`, and alice's list still held note 2 after bob's attempt. | `passed` |
| 4. Unknown id returns `404` | "returns 404 for an unknown note" passes. Smoke test: `POST /notes/99999/archive` returned `404`. | `passed` |

Existing-DB migration (not one of the four points): covered by its own test, which passes.

### Can it fail

Baseline: all 4 archive tests passed before any break.

| Test | Claims to prove | Break | Test after the break | Result |
|---|---|---|---|---|
| archives a note and removes it from the list | Archive writes the row and hides it from the list | Deleted the `UPDATE notes SET archived = 1` line in `src/app.ts` | Red on `expect(list.items).toEqual([])` | `passed` |
| returns 404 for an unknown note | Unknown id gives 404 | Inserted `if (!row) return 204` before the 404 check | Red: expected 404, received 204 | `passed` |
| does not let another user archive the note | Only the owner can archive | Removed `\|\| row.owner_id !== user.id` | Red: expected 404, received 204 | `passed` |
| a database created before archiving still lists notes | Migration adds the column and keeps notes visible | First try: removed the `ALTER TABLE` line in `src/db.ts` | Red, but on a thrown `SQLiteError`, not an assertion. Not counted. | — |
| (same test, second break) | Same | Changed the migration default to `DEFAULT 1`, which hides existing notes | Red on `expect(list.items...).toEqual(["Kept"])` | `passed` |

Counting the migration test as `passed` rests on the second break. Its first break only produced an exception.

**Weak tests:** none found. Each test goes red on an assertion for the behavior it names.

**Working tree restored:** yes. After the breaks, `git diff` matched the patch saved before them, byte for byte, and `git status` shows only `src/db.ts` and `test/archive.test.ts` modified.

### Smoke test

The dev server ran on a free port (62110) with `NOTES_DB` set to a temp file, so `data/` was not touched. It is stopped, and I deleted the temp DB and log.

### Not done

- Nothing committed. The two changed files are uncommitted on `change/archive-clean`. Commit when you're ready.
- No PR description written.
- The `/notes/:id` GET response now includes an `archived` boolean. That comes from the earlier commit and was not part of this review.