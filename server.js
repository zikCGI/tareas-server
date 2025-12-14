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
