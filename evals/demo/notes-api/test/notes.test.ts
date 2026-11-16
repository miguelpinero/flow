import { describe, expect, test } from "bun:test";
import { setup } from "./helpers";

describe("notes", () => {
  test("rejects a request with no session", async () => {
    const { call } = setup();
    const res = await call("GET", "/notes");
    expect(res.status).toBe(401);
  });

  test("creates a note and lists it for its owner", async () => {
    const { call, alice } = setup();
    const created = await call("POST", "/notes", alice, { title: "Buy milk" });
    expect(created.status).toBe(201);
    const list = await (await call("GET", "/notes", alice)).json();
    expect(list.items.map((n: { title: string }) => n.title)).toEqual(["Buy milk"]);
  });

  test("rejects an empty title", async () => {
    const { call, alice } = setup();
    const res = await call("POST", "/notes", alice, { title: "   " });
    expect(res.status).toBe(400);
  });

  test("hides a note from another user", async () => {
    const { call, alice, bob } = setup();
    const note = await (await call("POST", "/notes", alice, { title: "Private" })).json();
    expect((await call("GET", `/notes/${note.id}`, bob)).status).toBe(404);
    const list = await (await call("GET", "/notes", bob)).json();
    expect(list.items).toEqual([]);
  });
});
