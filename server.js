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
