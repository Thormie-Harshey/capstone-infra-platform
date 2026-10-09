const express = require("express");
const { Pool } = require("pg");

const app = express();
app.use(express.json());
const PORT = process.env.PORT || 3000;

// Database settings come from environment variables, never hard-coded
const pool = new Pool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT || 5432),
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

// If the database drops idle connections (for example during a restart),
// log it instead of crashing the whole program
pool.on("error", (err) => {
  console.error("Database pool error:", err.message);
});

// Liveness: is the program running?
app.get("/api/health/live", (req, res) => res.json({ status: "alive" }));

// Readiness: can we reach the database?
app.get("/api/health/ready", async (req, res) => {
  try {
    await pool.query("SELECT 1");
    res.json({ status: "ready" });
  } catch (err) {
    console.error("Readiness check failed:", err.message);
    res.status(503).json({ status: "not ready" });
  }
});

// Show all tasks
app.get("/api/tasks", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT id, title, created_at FROM tasks ORDER BY id"
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: "could not load tasks" });
  }
});

// Save a new task
app.post("/api/tasks", async (req, res) => {
  const title = (req.body.title || "").trim();
  if (!title) return res.status(400).json({ error: "title is required" });
  try {
    const result = await pool.query(
      "INSERT INTO tasks (title) VALUES ($1) RETURNING id, title, created_at",
      [title]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: "could not save task" });
  }
});

const server = app.listen(PORT, () => console.log(`Backend listening on ${PORT}`));

// Finish current orders before shutting down
process.on("SIGTERM", () => {
  server.close(() => pool.end().then(() => process.exit(0)));
});