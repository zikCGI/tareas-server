#!/bin/bash

echo "=== FIX REAL TAREAS ==="

# ---------- asegurar tasks.json ----------
if [ ! -f tasks.json ]; then
  echo '{"tareas":[]}' > tasks.json
  echo "[OK] tasks.json creado"
else
  echo "[OK] tasks.json existe"
fi

# ---------- BACKEND ----------
cat > server.js << 'EOF'
const express=require("express");
const fs=require("fs");
const cors=require("cors");
const path=require("path");

const app=express();
app.use(express.json());
app.use(cors());

const ROOT_USER="Zik";
const ROOT_PASS="N4v32mbr2";

function readTasks(){
 if(!fs.existsSync("tasks.json")){
  fs.writeFileSync("tasks.json",JSON.stringify({tareas:[]},null,2));
 }
 return JSON.parse(fs.readFileSync("tasks.json","utf8"));
}
function saveTasks(data){
 fs.writeFileSync("tasks.json",JSON.stringify(data,null,2));
}

app.get("/",(req,res)=>{
 res.sendFile(path.join(__dirname,"public","index.html"));
});

// LOGIN
app.post("/login",(req,res)=>{
 const {user,pass}=req.body;
 if(user===ROOT_USER && pass===ROOT_PASS){
  return res.json({user:"Zik",role:"admin"});
 }
 const users=JSON.parse(fs.readFileSync("users.json","utf8"));
 if(!users[user]||users[user].pass!==pass){
  return res.status(401).json({error:"Credenciales incorrectas"});
 }
 res.json({user,role:"user"});
});

// REGISTER
app.post("/register",(req,res)=>{
 const {user,pass}=req.body;
 if(user===ROOT_USER)return res.status(403).json({error:"Usuario reservado"});
 const users=JSON.parse(fs.readFileSync("users.json","utf8"));
 if(users[user])return res.status(400).json({error:"Usuario existe"});
 users[user]={pass,role:"user"};
 fs.writeFileSync("users.json",JSON.stringify(users,null,2));
 res.json({ok:true});
});

// GET TAREAS
app.get("/tasks",(req,res)=>{
 res.json(readTasks().tareas);
});

// CREAR TAREA (ADMIN)
app.post("/tasks",(req,res)=>{
 const {user,titulo,descripcion}=req.body;
 if(user!==ROOT_USER)return res.status(403).json({error:"No autorizado"});
 const data=readTasks();
 data.tareas.push({
  id:Date.now(),
  titulo,
  descripcion,
  respuestas:[]
 });
 saveTasks(data);
 res.json({ok:true});
});

// RESPONDER
app.post("/tasks/respond",(req,res)=>{
 const {taskId,user,respuesta}=req.body;
 const data=readTasks();
 const t=data.tareas.find(x=>x.id===taskId);
 if(!t)return res.status(404).json({error:"Tarea no existe"});
 t.respuestas.push({user,respuesta});
 saveTasks(data);
 res.json({ok:true});
});

const PORT=process.env.PORT||3000;
app.listen(PORT,()=>console.log("SERVER OK",PORT));
EOF

# ---------- FRONTEND ----------
mkdir -p public

cat > public/dashboard.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Tareas</title>
<link rel="stylesheet" href="style.css">
</head>
<body>

<h2>Tareas</h2>

<div id="adminPanel" style="display:none">
<h3>Crear tarea (ADMIN)</h3>
<input id="titulo" placeholder="Título"><br>
<textarea id="descripcion" placeholder="Descripción / Enunciado"></textarea><br>
<button onclick="crear()">Crear tarea</button>
<hr>
</div>

<ul id="lista"></ul>

<div id="detalle" style="display:none">
<hr>
<h3 id="vtitulo"></h3>
<pre id="vdesc"></pre>

<h4>Tu respuesta</h4>
<textarea id="respuesta" placeholder="Escribe tu código aquí"></textarea><br>
<button onclick="responder()">Enviar respuesta</button>
</div>

<script>
const user=localStorage.getItem("user");
const role=localStorage.getItem("role");
if(!user)location="index.html";

if(role==="admin"){
 document.getElementById("adminPanel").style.display="block";
}

let tareaActual=null;

fetch("/tasks")
 .then(r=>r.json())
 .then(t=>{
  lista.innerHTML="";
  t.forEach(x=>{
   let li=document.createElement("li");
   li.textContent=x.titulo;
   li.onclick=()=>ver(x);
   lista.appendChild(li);
  });
 });

function ver(t){
 tareaActual=t;
 detalle.style.display="block";
 vtitulo.textContent=t.titulo;
 vdesc.textContent=t.descripcion;
 respuesta.value="";
}

function crear(){
 fetch("/tasks",{method:"POST",headers:{"Content-Type":"application/json"},
 body:JSON.stringify({
  user:user,
  titulo:titulo.value,
  descripcion:descripcion.value
 })}).then(r=>r.json()).then(d=>{
  if(d.error)return alert(d.error);
  location.reload();
 });
}

function responder(){
 if(!tareaActual)return alert("Selecciona una tarea");
 fetch("/tasks/respond",{method:"POST",headers:{"Content-Type":"application/json"},
 body:JSON.stringify({
  taskId:tareaActual.id,
  user:user,
  respuesta:respuesta.value
 })}).then(()=>alert("Respuesta enviada"));
}
</script>

</body>
</html>
EOF

echo "=== FIX COMPLETADO ==="
echo "Ahora ejecuta:"
echo "git add . && git commit -m \"fix tareas real\" && git push"
