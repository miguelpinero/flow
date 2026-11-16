import { Database } from "bun:sqlite";
import { mkdirSync } from "node:fs";
import { dirname } from "node:path";
import { hashPassword } from "./auth";

// Demo users. These are public test accounts for a local demo, not secrets.
const DEMO_USERS = [
  { email: "alice@example.test", password: "alice-demo-password" },
  { email: "bob@example.test", password: "bob-demo-password" },
];

export function openDb(path = process.env.NOTES_DB ?? "data/notes.db"): Database {
  if (path !== ":memory:") mkdirSync(dirname(path), { recursive: true });
  const db = new Database(path);
  db.run(`CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL
  )`);
  db.run(`CREATE TABLE IF NOT EXISTS sessions (
    token TEXT PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id)
  )`);
  db.run(`CREATE TABLE IF NOT EXISTS notes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    owner_id INTEGER NOT NULL REFERENCES users(id),
    title TEXT NOT NULL,
    body TEXT NOT NULL DEFAULT '',
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
  )`);
  const count = db.query("SELECT COUNT(*) AS n FROM users").get() as { n: number };
  if (count.n === 0) {
    const insert = db.query("INSERT INTO users (email, password_hash) VALUES (?, ?)");
    for (const user of DEMO_USERS) insert.run(user.email, hashPassword(user.password));
  }
  return db;
}
