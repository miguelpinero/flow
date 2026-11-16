import type { Database } from "bun:sqlite";

export type User = { id: number; email: string };

export function hashPassword(password: string): string {
  return new Bun.CryptoHasher("sha256").update(`notes-demo:${password}`).digest("hex");
}

export function login(db: Database, email: string, password: string): string | null {
  const row = db
    .query("SELECT id FROM users WHERE email = ? AND password_hash = ?")
    .get(email, hashPassword(password)) as { id: number } | null;
  if (!row) return null;
  const token = crypto.randomUUID();
  db.query("INSERT INTO sessions (token, user_id) VALUES (?, ?)").run(token, row.id);
  return token;
}

export function userFromRequest(db: Database, req: Request): User | null {
  const header = req.headers.get("authorization") ?? "";
  if (!header.startsWith("Bearer ")) return null;
  return db
    .query(
      "SELECT users.id AS id, users.email AS email FROM sessions JOIN users ON users.id = sessions.user_id WHERE sessions.token = ?",
    )
    .get(header.slice(7)) as User | null;
}
