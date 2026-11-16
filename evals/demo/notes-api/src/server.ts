import { createApp } from "./app";
import { openDb } from "./db";

const port = Number(process.env.PORT ?? 3210);
const server = Bun.serve({ port, fetch: createApp(openDb()) });
console.log(`notes-api listening on http://localhost:${server.port}`);
