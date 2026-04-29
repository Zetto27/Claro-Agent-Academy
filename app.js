// 1- Invocamos a express y lo guardamos en una variable
const express = require("express");
const app = express();

// 2- Middleware para parsear el body de las solicitudes
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// 3- Invocar a dotenv
const dotenv = require("dotenv");
dotenv.config({ path: "./env/.env" });

//4 - El directorio público
app.use(express("/resources", express.static("public")));
app.use("/resources", express.static(__dirname + "/public"));

// 5 Establecer conexion de plantillas
app.set("view engine", "ejs");

// 6- Invocar a bycryptjs
const bcryptjs = require("bcryptjs");

// 7- variables de sesión
const session = require("express-session");
app.use(
  session({
    secret: "secret",
    resave: true,
    saveUninitialized: true,
  }),
);

// 8- Invocar a la base de datos
const connnection = require("./database/db");

// 9- Rutas

app.get("/", (req, res) => {
  res.render("index", { nombre: "Karen Paez" });
});

app.get("/login", (req, res) => {
  res.render("login");
});

app.get("/principal", (req, res) => {
  res.render("principal");
});

app.get("/registro", (req, res) => {
  res.render("registro");
});

// 10- Ruta para registrar usuarios
app.post("/registro", async (req, res) => {
  try {
    const { nombre, rol, cedula, correo, telefono, contrasena } = req.body;

    // 🔍 Validar contraseña
    if (!contrasena) {
      return res.send("Contraseña vacía");
    }

    // 🔐 Encriptar contraseña
    const passwordHash = await bcryptjs.hash(contrasena, 8);

    // 🔹 Generar usuario automático
    async function generarUsuarioUnico(nombre) {
      const partes = nombre.split(" ");
      const nombre1 = partes[0].toLowerCase();
      const apellido = partes[partes.length - 1].toLowerCase();

      let base = `${apellido}.${nombre1}`;
      let usuario = base;
      let contador = 1;

      while (true) {
        const [rows] = await connnection.promise().query("SELECT usuario FROM usuarios WHERE usuario = ?", [usuario]);

        if (rows.length === 0) {
          return usuario; // ✔ libre
        }

        usuario = `${base}${contador}`;
        contador++;
      }
    }
    const usuario = await generarUsuarioUnico(nombre);
    // 🔹 Obtener id del rol
    const [rolDB] = await connnection.promise().query("SELECT id_rol FROM roles WHERE nombre_rol = ?", [rol]);

    if (rolDB.length === 0) {
      return res.send("Rol no válido");
    }

    const id_rol = rolDB[0].id_rol;

    // 🔹 Insertar usuario
    connnection.query(
      "INSERT INTO usuarios SET ?",
      {
        nombre,
        usuario,
        cedula,
        correo,
        telefono,
        contrasena: passwordHash,
        id_rol,
      },
      (error, results) => {
        if (error) {
          console.log(error);
        } else {
          res.render("index", {
            alert: true,
            alertTitle: "Registration",
            alertMessage: "!Succesful Registration¡",
            alertIcon: "success",
            showConfirmButton: false,
            timer: 1500,
            ruta: "",
          });
        }
      },
    );
  } catch (error) {
    console.log(error);
    res.send("Error en servidor");
  }
});

//11 Usuarios

app.get("/usuarios", async (req, res) => {
  try {
    const [rows] = await connnection.promise().query(`
      SELECT 
        u.nombre,
        u.usuario,
        u.correo,
        u.cedula,
        u.telefono,
        u.fecha_registro,
        r.nombre_rol
      FROM usuarios u
      LEFT JOIN roles r ON u.id_rol = r.id_rol
    `);

    res.render("usuarios", { usuarios: rows });
  } catch (error) {
    console.log(error);
    res.send("Error al cargar usuarios");
  }
});

// const PORT = process.env.PORT || 3000;

app.listen(3000, (req, res) => {
  console.log("Server is running on port http://localhost:3000");
});
