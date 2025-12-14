#!/bin/bash

echo "=== AUTO FIX TOTAL tareas-server ==="

# ---------- FRONTEND ----------
mkdir -p public

# style.css (modo oscuro)
cat > public/style.css << 'EOF'
body {
  background-color: #121212;
  color: #ffffff;
  font-family: Arial, sans-serif;
}
input, button {
  background-color: #1e1e1e;
  color: white;
  border: 1px solid #333;
  padding: 10px;
  margin: 6px;
  border-radius: 6px;
}
button { cursor: pointer; }
a { color: #bb86fc; }
EOF

# index.html
cat > public/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Login</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
<h2>Login</h2>
<input id="user" placeholder="Usuario">
<input id="pass" type="password" placeholder="Contraseña">
<button onclick="login()">Entrar</button>
<p><a href="register.html">Registrarse</a></p>
<script>
function login(){
 fetch("/login",{method:"POST",headers:{"Content-Type":"application/json"},
 body:JSON.stringify({user:user.value,pass:pass.value})})
 .then(r=>r.json()).then(d=>{
  if(d.error)return alert(d.error);
  localStorage.setItem("user",d.user);
  localStorage.setItem("role",d.role);
  location="dashboard.html";
 });
}
</script>
</body>
</html>
EOF

# register.html
cat > public/register.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Registro</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
<h2>Registro</h2>
<input id="user" placeholder="Usuario">
<input id="pass" type="password" placeholder="Contraseña">
<button onclick="register()">Crear</button>
<p><a href="index.html">Volver</a></p>
<script>
function register(){
 fetch("/register",{method:"POST",headers:{"Content-Type":"application/json"},
 body:JSON.stringify({user:user.value,pass:pass.value})})
 .then(r=>r.json()).then(d=>{
  if(d.error)return alert(d.error);
  alert("Cuenta creada");
  location="index.html";
 });
}
</script>
</body>
</html>
EOF

# dashboard.html
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
<ul id="lista"></ul>
<h3 id="titulo"></h3>
<p id="desc"></p>
<p id="nota"></p>
<script>
if(!localStorage.getItem("user"))location="index.html";
fetch("/tasks").then(r=>r.json()).then(t=>{
 t.forEach(x=>{
  let li=document.createElement("li");
  li.textContent=x.titulo;
  li.onclick=()=>{titulo.textContent=x.titulo;desc.textContent=x.descripcion;nota.textContent="Nota: "+x.nota;}
  lista.appendChild(li);
 });
});
</script>
</body>
</html>
EOF

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

app.get("/",(req,res)=>{
 res.sendFile(path.join(__dirname,"public","index.html"));
});

app.post("/login",(req,res)=>{
 const {user,pass}=req.body;
 if(user===ROOT_USER && pass===ROOT_PASS){
  return res.json({user:"Zik",role:"admin"});
 }
 const users=JSON.parse(fs.readFileSync("./users.json","utf8"));
 if(!users[user]||users[user].pass!==pass){
  return res.status(401).json({error:"Credenciales incorrectas"});
 }
 res.json({user,role:users[user].role});
});

app.post("/register",(req,res)=>{
 const {user,pass}=req.body;
 if(!user||!pass)return res.status(400).json({error:"Datos incompletos"});
 if(user===ROOT_USER)return res.status(403).json({error:"Usuario reservado"});
 const users=JSON.parse(fs.readFileSync("./users.json","utf8"));
 if(users[user])return res.status(400).json({error:"Usuario existe"});
 users[user]={pass,role:"user"};
 fs.writeFileSync("./users.json",JSON.stringify(users,null,2));
 res.json({ok:true});
});

app.get("/tasks",(req,res)=>{
 const tasks=JSON.parse(fs.readFileSync("./tasks.json","utf8"));
 res.json(tasks.tareas);
});

app.post("/tasks",(req,res)=>{
 const {user,titulo,descripcion,nota}=req.body;
 if(user!==ROOT_USER)return res.status(403).json({error:"No autorizado"});
 const tasks=JSON.parse(fs.readFileSync("./tasks.json","utf8"));
 tasks.tareas.push({titulo,descripcion,nota});
 fs.writeFileSync("./tasks.json",JSON.stringify(tasks,null,2));
 res.json({ok:true});
});

const PORT=process.env.PORT||3000;
app.listen(PORT,()=>console.log("SERVER OK EN",PORT));
EOF

echo "=== LISTO ==="
echo "Ejecuta ahora:"
echo "git add . && git commit -m \"auto fix total\" && git push"
