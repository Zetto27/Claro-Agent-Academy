console.log("Rutas de módulos cargadas");

const express = require("express");
const router = express.Router();

// 🔥 IMPORTANTE: activar PROMESAS
const db = require("../database/db").promise();

router.get("/modulo/:id", async (req, res) => {
  try {
    const id = req.params.id;

    // 🔹 1. MÓDULO
    const [modulo] = await db.query("SELECT * FROM modulos WHERE id_modulo = ?", [id]);

    if (modulo.length === 0) {
      return res.send("Módulo no encontrado");
    }

    // 🔹 2. CONTENIDOS
    const [contenido] = await db.query("SELECT * FROM contenidos WHERE id_modulo = ? ORDER BY orden", [id]);

    // 🔹 3. EVALUACIÓN
    const [evaluacion] = await db.query("SELECT * FROM evaluaciones WHERE id_modulo = ?", [id]);

    let preguntas = [];
    let opciones = [];

    if (evaluacion.length > 0) {
      // 🔹 4. PREGUNTAS
      const [preguntasDB] = await db.query("SELECT * FROM preguntas WHERE id_evaluacion = ? ORDER BY orden", [
        evaluacion[0].id_evaluacion,
      ]);

      preguntas = preguntasDB;

      // 🔹 5. OPCIONES
      const idsPreguntas = preguntas.map((p) => p.id_pregunta);

      if (idsPreguntas.length > 0) {
        const [opcionesDB] = await db.query("SELECT * FROM opciones WHERE id_pregunta IN (?)", [idsPreguntas]);

        opciones = opcionesDB;
      }
    }

    // 🧪 DEBUG (NO BORRAR TODAVÍA)
    console.log("MODULO:", modulo[0]);
    console.log("CONTENIDO:", contenido);
    console.log("PREGUNTAS:", preguntas);
    console.log("OPCIONES:", opciones);
    console.log("EVALUACION BACK:", evaluacion);

    const [totalModulos] = await db.query("SELECT COUNT(*) as total FROM modulos");

    // 🔥 RENDER (MUY IMPORTANTE)
    res.render("modulo1", {
      modulo: modulo[0], // ⚠️ NO array
      contenido, // array
      evaluacion: evaluacion[0] || null,
      preguntas,
      opciones,
      totalModulos: totalModulos[0].total, // 🔥 nuevo
      numeroModulo: parseInt(id), // 🔥 nuevo
    });
  } catch (error) {
    console.error(error);
    res.send("Error cargando módulo");
  }
});

router.post("/guardar-intento", async (req, res) => {
  try {
    // 🔥 usuario
    const id_usuario = req.session.id_usuario;

    if (!id_usuario) {
      return res.json({ ok: false, mensaje: "Debes iniciar sesión" });
    }

    // 🔹 datos del frontend
    const { respuestas, id_evaluacion } = req.body;

    // 🔒 🔥 BLOQUEO VA AQUÍ (ANTES DEL INSERT)
    const [intentosPrevios] = await db.query("SELECT * FROM intentos WHERE id_usuario = ? AND id_evaluacion = ?", [
      id_usuario,
      id_evaluacion,
    ]);

    const LIMITE_INTENTOS = 3;

    if (intentosPrevios.length >= LIMITE_INTENTOS) {
      return res.json({
        ok: false,
        mensaje: "Ya alcanzaste el máximo de 3 intentos",
      });
    }

    // 🔹 crear intento (AHORA SÍ)
    const [intento] = await db.query(
      "INSERT INTO intentos (id_usuario, id_evaluacion, puntaje, aprobado) VALUES (?, ?, 0, 0)",
      [id_usuario, id_evaluacion],
    );

    const id_intento = intento.insertId;

    let correctas = 0;

    for (let r of respuestas) {
      const [op] = await db.query("SELECT es_correcta FROM opciones WHERE id_opcion = ?", [r.id_opcion]);

      const es_correcta = op[0].es_correcta;

      if (es_correcta == 1) correctas++;

      await db.query(
        "INSERT INTO respuestas_intento (id_intento, id_pregunta, id_opcion, es_correcta) VALUES (?, ?, ?, ?)",
        [id_intento, r.id_pregunta, r.id_opcion, es_correcta],
      );
    }

    const puntaje = respuestas.length > 0 ? Math.round((correctas / respuestas.length) * 100) : 0;

    // 🔥 NUEVA LÍNEA
    const aprobado = puntaje >= 70;

    // guardar en BD
    await db.query("UPDATE intentos SET puntaje = ?, aprobado = ? WHERE id_intento = ?", [
      puntaje,
      aprobado ? 1 : 0,
      id_intento,
    ]);

    // 🔥 enviar al frontend
    res.json({
      ok: true,
      puntaje,
      aprobado,
      intento_actual: intentosPrevios.length + 1,
      limite: LIMITE_INTENTOS,
    });
  } catch (error) {
    console.log(error);
    res.json({ ok: false });
  }
});

module.exports = router;
