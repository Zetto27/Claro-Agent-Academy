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
  res.render("index");
});

app.get("/login", (req, res) => {
  res.render("login");
});

app.get("/principal", (req, res) => {
  res.render("principal");
});

app.listen(3000, (req, res) => {
  console.log("Server is running on port http://localhost:3000");
});
