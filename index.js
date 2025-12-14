const path = require("path");
const express = require("express");
const fs = require("fs");
const cors = require("cors");

const app = express();
app.use(express.json());
app.use(cors());
app.use(express.static("public"));

const USERS_FILE = "./users.json";
const TASKS_FILE = "./tasks.json";

// ---------- helpers ----------
function readUsers() {
  return JSON.parse(fs.readFileSync(USERS_FILE));
}

function readTasks() {
  return JSON.parse(fs.readFileSync(TASKS_FILE));
}

function saveTasks(data) {
  fs.writeFileSync(TASKS_FILE, JSON.stringify(data, null, 2));
}

// ---------- LOGIN ----------
app.post("/login", (req, res) => {
  const { user, pass } = req.body;
  const users = readUsers();

  if (!users[user] || users[user].pass !== pass) {
    return res.status(401).json({ error: "Credenciales incorrectas" });
  }

  res.json({ role: users[user].role });
});

// ---------- REGISTER ----------
app.post("/register", (req, res) => {
  const { user, pass } = req.body;

  if (!user || !pass) {
    return res.status(400).json({ error: "Datos incompletos" });
  }

  const users = readUsers();

  if (users[user]) {
    return res.status(400).json({ error: "Usuario ya existe" });
  }

  users[user] = {
    pass,
    role: "user"
  };

  fs.writeFileSync(USERS_FILE, JSON.stringify(users, null, 2));
  res.json({ ok: true });
});

// ---------- VER TAREAS ----------
app.get("/tasks", (req, res) => {
  const tasks = readTasks();
  res.json(tasks.tareas);
});

// ---------- AGREGAR TAREA (ADMIN) ----------
app.post("/tasks", (req, res) => {
  const { user, titulo, descripcion, nota } = req.body;

  if (user !== "Zik") {
    return res.status(403).json({ error: "No autorizado" });
  }

  const tasks = readTasks();
  tasks.tareas.push({ titulo, descripcion, nota });
  saveTasks(tasks);

  res.json({ ok: true });
});

const PORT = process.env.PORT || 3000;
app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "public", "index.html"));
});

app.listen(PORT, () => {
  console.log("Servidor funcionando en puerto", PORT);
});
