import { createApp } from "../src/app";
import { login } from "../src/auth";
import { openDb } from "../src/db";

export function setup() {
  const db = openDb(":memory:");
  const handle = createApp(db);
  const alice = login(db, "alice@example.test", "alice-demo-password")!;
  const bob = login(db, "bob@example.test", "bob-demo-password")!;
  const call = (method: string, path: string, token?: string, body?: unknown) =>
    handle(
      new Request(`http://test${path}`, {
        method,
        headers: {
          ...(token ? { authorization: `Bearer ${token}` } : {}),
          ...(body !== undefined ? { "content-type": "application/json" } : {}),
        },
        body: body !== undefined ? JSON.stringify(body) : undefined,
      }),
    );
  return { db, call, alice, bob };
}
