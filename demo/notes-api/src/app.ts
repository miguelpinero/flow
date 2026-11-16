import type { Database } from "bun:sqlite";
import { login, userFromRequest } from "./auth";

type NoteRow = { id: number; owner_id: number; title: string; body: string; created_at: string };

const json = (data: unknown, status = 200) => Response.json(data, { status });

const toNote = (row: NoteRow) => ({
  id: row.id,
  title: row.title,
  body: row.body,
  createdAt: row.created_at,
});

async function readJson(req: Request): Promise<Record<string, unknown> | null> {
  try {
    const data = await req.json();
    return data && typeof data === "object" && !Array.isArray(data) ? data : null;
  } catch {
    return null;
  }
}

export function createApp(db: Database) {
  return async function handle(req: Request): Promise<Response> {
    const { pathname } = new URL(req.url);
    const method = req.method;

    if (method === "GET" && pathname === "/health") return json({ ok: true });

    if (method === "POST" && pathname === "/login") {
      const body = await readJson(req);
      if (!body || typeof body.email !== "string" || typeof body.password !== "string") {
        return json({ error: "email and password are required" }, 400);
      }
      const token = login(db, body.email, body.password);
      return token ? json({ token }) : json({ error: "invalid credentials" }, 401);
    }

    const user = userFromRequest(db, req);
    if (!user) return json({ error: "unauthorized" }, 401);

    if (pathname === "/notes" && method === "GET") {
      const rows = db
        .query("SELECT * FROM notes WHERE owner_id = ? ORDER BY id")
        .all(user.id) as NoteRow[];
      return json({ items: rows.map(toNote) });
    }

    if (pathname === "/notes" && method === "POST") {
      const body = await readJson(req);
      const title = typeof body?.title === "string" ? body.title.trim() : "";
      if (!body || title.length === 0 || title.length > 120) {
        return json({ error: "title must be 1 to 120 characters" }, 400);
      }
      if (body.body !== undefined && typeof body.body !== "string") {
        return json({ error: "body must be a string" }, 400);
      }
      const row = db
        .query("INSERT INTO notes (owner_id, title, body) VALUES (?, ?, ?) RETURNING *")
        .get(user.id, title, (body.body as string | undefined) ?? "") as NoteRow;
      return json(toNote(row), 201);
    }

    const match = pathname.match(/^\/notes\/(\d+)$/);
    if (match && method === "GET") {
      const row = db.query("SELECT * FROM notes WHERE id = ?").get(Number(match[1])) as NoteRow | null;
      if (!row || row.owner_id !== user.id) return json({ error: "not found" }, 404);
      return json(toNote(row));
    }

    return json({ error: "not found" }, 404);
  };
}
