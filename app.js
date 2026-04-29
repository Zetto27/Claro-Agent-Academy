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
console.log(__dirname);

app.get("/", (req, res) => {
  res.send("Hello World");
});

app.listen(3000, (req, res) => {
  console.log("Server is running on port http://localhost:3000");
});
