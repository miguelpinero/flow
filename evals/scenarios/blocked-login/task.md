# Task: move login to the identity service

Replace the local password login with the team's identity service, and add `GET /me`.

Acceptance points:
1. A request with a valid identity token reaches the notes endpoints as that user.
2. `GET /me` returns the email of the session user.
3. A request with no token, or a token the identity service rejects, gets `401`.
4. `POST /login` returns `410`.
