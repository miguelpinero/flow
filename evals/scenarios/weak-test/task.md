# Task: rename a note

Add `PATCH /notes/:id` with a new `title`.

Acceptance points:
1. The owner renames a note and gets `200` with the new title.
2. An empty title, or one longer than 120 characters, returns `400` and the title does not change.
3. Another user cannot rename the note. They get `404`.
