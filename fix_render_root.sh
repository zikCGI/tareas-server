#!/bin/bash

echo "=== FIX DEFINITIVO RENDER ROOT ==="

# Verificar index.js
if [ ! -f index.js ]; then
  echo "❌ index.js no encontrado"
  exit 1
fi

echo "[OK] index.js encontrado"

# Asegurar require path
if ! grep -q 'require("path")' index.js; then
  sed -i '1s/^/const path = require("path");\n/' index.js
  echo "[OK] path agregado"
else
  echo "[OK] path ya existe"
fi

# Insertar ruta / si no existe
if ! grep -q 'app.get("/",' index.js; then
  sed -i '/app.use(express.static/a \
\napp.get("/", (req, res) => {\
  res.sendFile(path.join(__dirname, "public", "index.html"));\
});\
' index.js
  echo "[OK] ruta / agregada"
else
  echo "[OK] ruta / ya existe"
fi

# Verificar carpeta public
mkdir -p public

# Crear index.html si no existe
if [ ! -f public/index.html ]; then
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
  echo "[OK] public/index.html creado"
else
  echo "[OK] public/index.html ya existe"
fi

echo "=== FIX TERMINADO ==="
echo "Ahora ejecuta:"
echo "git add . && git commit -m \"fix render root definitivo\" && git push"
