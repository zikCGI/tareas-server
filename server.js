const express = require("express");
const fs = require("fs");
const cors = require("cors");
const path = require("path");

const app = express();
app.use(express.json());
app.use(cors());

// ---------- ROOT ----------
app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "public", "index.html"));
});

// ---------- LOGIN ----------
app.post("/login", (req, res) => {
  const users = JSON.parse(fs.readFileSync("./users.json"));
  const { user, pass } = req.body;

  if (!users[user] || users[user].pass !== pass) {
    return res.status(401).json({ error: "Credenciales incorrectas" });
  }

  res.json({ role: users[user].role });
});

// ---------- TASKS ----------
app.get("/tasks", (req, res) => {
  const tasks = JSON.parse(fs.readFileSync("./tasks.json"));
  res.json(tasks.tareas);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log("SERVER.JS FUNCIONANDO EN PUERTO", PORT);
});
