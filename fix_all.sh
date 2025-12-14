#!/bin/bash

echo "=== FIX AUTOMÁTICO tareas-server ==="

# 1. Crear carpeta public
mkdir -p public
echo "[OK] carpeta public"

# 2. index.html (login)
cat > public/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Login</title>
</head>
<body>
  <h2>Login</h2>

  <input id="user" placeholder="Usuario"><br><br>
  <input id="pass" type="password" placeholder="Contraseña"><br><br>

  <button onclick="login()">Entrar</button>

  <p>
    ¿No tienes cuenta?
    <a href="register.html">Registrarse</a>
  </p>

<script>
function login() {
  fetch("/login", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      user: user.value,
      pass: pass.value
    })
  })
  .then(r => r.json())
  .then(d => {
    if (d.error) return alert(d.error);
    localStorage.setItem("user", user.value);
    window.location = "dashboard.html";
  });
}
</script>
</body>
</html>
EOF

# 3. register.html
cat > public/register.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Registro</title>
</head>
<body>
  <h2>Registro</h2>

  <input id="user" placeholder="Usuario"><br><br>
  <input id="pass" type="password" placeholder="Contraseña"><br><br>

  <button onclick="register()">Crear cuenta</button>

  <p><a href="index.html">Volver</a></p>

<script>
function register() {
  fetch("/register", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      user: user.value,
      pass: pass.value
    })
  })
  .then(r => r.json())
  .then(d => {
    if (d.error) return alert(d.error);
    alert("Cuenta creada");
    window.location = "index.html";
  });
}
</script>
</body>
</html>
EOF

# 4. dashboard.html
cat > public/dashboard.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Tareas</title>
</head>
<body>
  <h2>Mis tareas</h2>

  <ul id="lista"></ul>

  <hr>

  <h3 id="titulo"></h3>
  <p id="descripcion"></p>
  <p id="nota"></p>

<script>
const user = localStorage.getItem("user");
if (!user) location = "index.html";

fetch("/tasks")
  .then(r => r.json())
  .then(tareas => {
    tareas.forEach(t => {
      const li = document.createElement("li");
      li.textContent = t.titulo;
      li.style.cursor = "pointer";
      li.onclick = () => mostrar(t);
      lista.appendChild(li);
    });
  });

function mostrar(t) {
  titulo.textContent = t.titulo;
  descripcion.textContent = t.descripcion;
  nota.textContent = "Nota: " + t.nota;
}
</script>
</body>
</html>
EOF

echo "[OK] HTML creado"

# 5. Arreglar index.js
if ! grep -q 'require("path")' index.js; then
  sed -i '1i const path = require("path");' index.js
fi

if ! grep -q 'res.sendFile' index.js; then
  sed -i '/app.listen/i \
app.get("/", (req, res) => {\
  res.sendFile(path.join(__dirname, "public", "index.html"));\
});\
' index.js
fi

echo "[OK] index.js corregido"

# 6. Mostrar estructura final
echo "=== ESTRUCTURA FINAL ==="
ls -R public

echo "=== LISTO ==="
echo "Ahora ejecuta:"
echo "git add . && git commit -m \"fix frontend\" && git push"
EOF
