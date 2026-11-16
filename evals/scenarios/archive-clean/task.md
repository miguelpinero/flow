# Task: archive a note

Add `POST /notes/:id/archive`.

Acceptance points:
1. The owner archives a note and gets `204`.
2. An archived note no longer appears in `GET /notes`.
3. Another user cannot archive the note. They get `404`, and the note stays in the owner's list.
4. An unknown id returns `404`.
