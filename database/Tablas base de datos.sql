-- ============================================================
--  ClaroAgent Academy — Script SQL completo
--  Proyecto SENA 2025 — Karen Páez
--  Base de datos: MySQL 8+
-- ============================================================

CREATE DATABASE IF NOT EXISTS claro_academy
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE Claro_Agent_Academy;

SELECT * FROM contenidos WHERE id_contenido = 1
-- ============================================================
-- 1. ROLES
-- ============================================================
CREATE TABLE roles (
    id_rol      INT          PRIMARY KEY AUTO_INCREMENT,
    nombre_rol  VARCHAR(50)  UNIQUE NOT NULL
);

INSERT INTO roles (nombre_rol) VALUES
  ('administrador'),
  ('usuario');

-- ============================================================
-- 2. USUARIOS
-- ============================================================
CREATE TABLE usuarios (
    id_usuario      INT           PRIMARY KEY AUTO_INCREMENT,
    nombre          VARCHAR(100)  NOT NULL,
    usuario         VARCHAR(50)   UNIQUE NOT NULL,
    correo          VARCHAR(100)  UNIQUE NOT NULL,
    cedula          VARCHAR(20)   UNIQUE NOT NULL,
    telefono        VARCHAR(20)   UNIQUE NOT NULL,
    contrasena      VARCHAR(255)  NOT NULL,
    id_rol          INT           DEFAULT 2,          -- 2 = usuario por defecto
    fecha_registro  TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_rol) REFERENCES roles(id_rol)
);

-- ============================================================
-- 3. MÓDULOS
-- ============================================================
CREATE TABLE modulos (
    id_modulo     INT           PRIMARY KEY AUTO_INCREMENT,
    titulo        VARCHAR(150)  NOT NULL,
    descripcion   TEXT,
    orden_modulo  INT           NOT NULL DEFAULT 1
);

-- ============================================================
-- 4. CONTENIDOS
--    tipo: 'video' | 'pdf' | 'texto'
-- ============================================================
CREATE TABLE contenidos (
    id_contenido  INT           PRIMARY KEY AUTO_INCREMENT,
    id_modulo     INT           NOT NULL,
    titulo        VARCHAR(150)  NOT NULL,
    tipo          VARCHAR(50)   NOT NULL,
    descripcion   TEXT,
    url_recurso   VARCHAR(500),                        -- ruta o URL del archivo/video
    orden         INT           NOT NULL DEFAULT 1,    -- orden dentro del módulo
    FOREIGN KEY (id_modulo) REFERENCES modulos(id_modulo)
);

-- ============================================================
-- 5. EVALUACIONES
-- ============================================================
CREATE TABLE evaluaciones (
    id_evaluacion       INT           PRIMARY KEY AUTO_INCREMENT,
    id_modulo           INT           NOT NULL,
    titulo              VARCHAR(150)  NOT NULL,
    puntaje_aprobacion  INT           NOT NULL DEFAULT 60,  -- % mínimo para aprobar
    FOREIGN KEY (id_modulo) REFERENCES modulos(id_modulo)
);

-- ============================================================
-- 6. PREGUNTAS
-- ============================================================
CREATE TABLE preguntas (
    id_pregunta    INT   PRIMARY KEY AUTO_INCREMENT,
    id_evaluacion  INT   NOT NULL,
    enunciado      TEXT  NOT NULL,
    orden          INT   NOT NULL DEFAULT 1,
    FOREIGN KEY (id_evaluacion) REFERENCES evaluaciones(id_evaluacion)
);

-- ============================================================
-- 7. OPCIONES
--    es_correcta = TRUE indica la respuesta correcta
-- ============================================================
CREATE TABLE opciones (
    id_opcion    INT      PRIMARY KEY AUTO_INCREMENT,
    id_pregunta  INT      NOT NULL,
    texto        TEXT     NOT NULL,
    es_correcta  BOOLEAN  NOT NULL DEFAULT FALSE,
    FOREIGN KEY (id_pregunta) REFERENCES preguntas(id_pregunta)
);

-- ============================================================
-- 8. INTENTOS
--    ✔ fecha cambiada a TIMESTAMP para registrar hora exacta
-- ============================================================
CREATE TABLE intentos (
    id_intento     INT        PRIMARY KEY AUTO_INCREMENT,
    id_usuario     INT        NOT NULL,
    id_evaluacion  INT        NOT NULL,
    puntaje        INT        NOT NULL DEFAULT 0,
    aprobado       BOOLEAN    NOT NULL DEFAULT FALSE,  -- TRUE si puntaje >= puntaje_aprobacion
    fecha          TIMESTAMP  DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario)    REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_evaluacion) REFERENCES evaluaciones(id_evaluacion)
);

-- ============================================================
-- 9. RESPUESTAS POR INTENTO  ← tabla nueva
--    Guarda qué opción eligió el usuario en cada pregunta
-- ============================================================
CREATE TABLE respuestas_intento (
    id_respuesta  INT      PRIMARY KEY AUTO_INCREMENT,
    id_intento    INT      NOT NULL,
    id_pregunta   INT      NOT NULL,
    id_opcion     INT      NOT NULL,
    es_correcta   BOOLEAN  NOT NULL DEFAULT FALSE,   -- copia del valor al momento de responder
    FOREIGN KEY (id_intento)  REFERENCES intentos(id_intento),
    FOREIGN KEY (id_pregunta) REFERENCES preguntas(id_pregunta),
    FOREIGN KEY (id_opcion)   REFERENCES opciones(id_opcion)
);

-- ============================================================
-- 10. PROGRESO
--     ✔ fecha_actualizacion cambiada a TIMESTAMP con auto-update
-- ============================================================
CREATE TABLE progreso (
    id_progreso         INT             PRIMARY KEY AUTO_INCREMENT,
    id_usuario          INT             NOT NULL,
    id_modulo           INT             NOT NULL,
    porcentaje          DECIMAL(5,2)    NOT NULL DEFAULT 0.00,
    completado          BOOLEAN         NOT NULL DEFAULT FALSE,
    fecha_actualizacion TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
                                        ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_progreso (id_usuario, id_modulo),   -- un registro por usuario/módulo
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_modulo)  REFERENCES modulos(id_modulo)
);

-- ============================================================
-- 11. CERTIFICADOS
-- ============================================================
CREATE TABLE certificados (
    id_certificado      INT           PRIMARY KEY AUTO_INCREMENT,
    id_usuario          INT           NOT NULL,
    fecha_emision       TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    codigo_certificado  VARCHAR(100)  UNIQUE NOT NULL,
    ruta_pdf            VARCHAR(500),   -- ruta del archivo: /certificados/CERT-001.pdf
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
);

-- ============================================================
-- DATOS DE PRUEBA
-- ============================================================

-- Módulos
INSERT INTO modulos (titulo, descripcion, orden_modulo) VALUES
  ('Bienvenida a Claro y el Contact Center',  'Conoce la empresa, tu rol como agente y las reglas básicas que debes seguir.', 1),
  ('PBX Móvil',           'Funcionamiento y configuración del PBX Móvil',       2),
  ('Fallas',              'Identificación y manejo de fallas comunes',           3),
  ('Scripts',             'Guiones de atención al cliente',                      4),
  ('Evaluación Final',    'Evaluación integral de todos los módulos',            5);

-- Contenido del módulo 1
INSERT INTO contenidos (id_modulo, titulo, tipo, descripcion, orden) VALUES
  (1, 'Claro Colombia y tu rol',      'texto',  'Claro Colombia es la operadora de telecomunicaciones más grande del país. Hace parte del Grupo América Móvil y ofrece servicios de telefonía móvil, internet, televisión y soluciones empresariales como el PBX Móvil.

Como agente de contact center, tú eres la voz de Claro ante el cliente. Tus responsabilidades principales son:

Resolver en el primer contacto: intenta solucionar sin transferir la llamada
Documentar todo: registra cada caso en el sistema
Escalar cuando sea necesario: si no puedes resolver en 20-60 minutos, pasa el caso al nivel 2 con toda la información
La estructura del equipo es: Agente → Supervisor → Analista de Calidad → Coordinador.', 1),
  (1, 'Reglas legales básicas',        'txt',    'Hay leyes colombianas que regulan tu trabajo. Las más importantes son:',   2);

-- Contenido del módulo 2
INSERT INTO contenidos (id_modulo, titulo, tipo, descripcion, orden) VALUES
  (2, '¿Qué es el PBX Móvil',      'texto',  'PBX significa Private Branch Exchange — es como una centralita telefónica, pero 100% virtual. No necesita hardware ni cables: funciona con los celulares de los empleados de la empresa.

La empresa contrata un número único (ej: +57 323 563 9033) y cuando un cliente llama, el sistema redistribuye la llamada a los celulares de los empleados registrados.', 1),
  (2, 'La consola Web',        'txt',    'El cliente administra su PBX desde pbxmovil.claro.com.co. Allí puede:

Agregar agentes: con número en formato +57 + 10 dígitos
Configurar horario: definir franjas por día de la semana
Grabar mensajes: bienvenida, cierre y "ocupados" (en .mp3 o .wav)
Toggle Abierto/Cerrado: cierre manual inmediato
Error más común: El cliente registra un agente SIN el prefijo +57 → las llamadas nunca le llegan. Siempre verifica esto primero.',   2);


-- Contenido del módulo 3
INSERT INTO contenidos (id_modulo, titulo, tipo, descripcion, orden) VALUES
  (3, 'Fallas de audio y configuracion',      'texto',  ' <div class="acordeon-cuerpo"><div class="acordeon-inner">
            <table class="tabla-fallas">
                <tr><th>Código</th><th>Problema</th><th>Causa</th><th>Solución</th></tr>
                <tr><td><span class="codigo">FA-01</span></td><td>Audio entrecortado</td><td>Internet lento</td><td>Verificar velocidad (mín. 5 Mbps)</td></tr>
                <tr><td><span class="codigo">FA-02</span></td><td>Eco en llamada</td><td>Latencia alta</td><td>Reiniciar router</td></tr>
                <tr><td><span class="codigo">FB-01</span></td><td>No llegan llamadas</td><td>Sin +57 en número</td><td>Verificar formato del número</td></tr>
                <tr><td><span class="codigo">FB-02</span></td><td>IVR en loop</td><td>Menú mal configurado</td><td>Revisar opciones del menú</td></tr>
                <tr><td><span class="codigo">FB-03</span></td><td>Siempre "cerrado"</td><td>Toggle o horario mal</td><td>Verificar toggle + franjas</td></tr>
            </table>
        </div></div>', 1),
  (3, 'Falla de acceso y servicio',        'txt',    '<div class="acordeon-cuerpo"><div class="acordeon-inner">
            <table class="tabla-fallas">
                <tr><th>Código</th><th>Problema</th><th>Causa</th><th>Solución</th></tr>
                <tr><td><span class="codigo">FC-01</span></td><td>No accede a la web</td><td>Internet o contraseña</td><td>Verificar internet → reset clave</td></tr>
                <tr><td><span class="codigo">FD-01</span></td><td>No llega SMS devol.</td><td>No configurado</td><td>Configurar en "Info empresa"</td></tr>
                <tr><td><span class="codigo">FD-02</span></td><td>Anuncios no suenan</td><td>Formato incorrecto</td><td>Subir en .mp3 o .wav</td></tr>
                <tr><td><span class="codigo">FD-03</span></td><td>No agrega agentes</td><td>Límite del plan</td><td>Ofrecer upgrade comercial</td></tr>
            </table>
            <div class="nota">
                <strong>Regla:</strong> Si no puedes resolver en 20-60 minutos → escala a nivel 2 con toda la info del caso.
            </div>
        </div></div>',   2);
        
        
-- Contenido del módulo 4
INSERT INTO contenidos (id_modulo, titulo, tipo, descripcion, orden) VALUES
  (4,'Scripts de apertura y cierre', 'texto','<div class="acordeon" data-sec="1">
        <div class="acordeon-cuerpo"><div class="acordeon-inner">
            <div class="script-box"><span class="tag">Apertura</span><br>"Gracias por comunicarse con soporte de <strong>Claro</strong>. Mi nombre es <span class="campo">[TU NOMBRE]</span>, agente <span class="campo">[TU ID]</span>. ¿Con quién tengo el gusto? ¿En qué puedo ayudarle?"</div>
            <div class="script-box"><span class="tag">Cierre resuelto</span><br>"¿Pudimos resolver su problema? Perfecto, <span class="campo">[NOMBRE]</span>. ¿Hay algo más? Que tenga un excelente día."</div>
            <div class="script-box"><span class="tag">Cierre escalado</span><br>"Su caso queda escalado con ticket <span class="campo">[ID]</span>. Le contactaremos en máximo <span class="campo">[X]</span> horas."</div>
            <table class="tabla-sla">
                <tr><th>Nivel</th><th>Tipo</th><th>Tiempo máximo</th></tr>
                <tr><td><strong>N1 (tú)</strong></td><td>Diagnóstico básico</td><td>20-60 minutos</td></tr>
                <tr><td><strong>N2</strong></td><td>Soporte técnico</td><td>4-8 horas</td></tr>
                <tr><td><strong>N3</strong></td><td>Ingeniería</td><td>1-3 días</td></tr>
            </table>
        </div></div>
    </div>', 1),
  (4,'Clientes dificiles: E-A-R', 'texto','    <div class="acordeon" data-sec="2">
        <div class="acordeon-cuerpo"><div class="acordeon-inner">
            <p>Cuando un cliente está enojado, usa esta técnica:</p>
            <div class="pasos-ear">
                <div class="paso-ear"><div class="paso-letra">E</div><div class="paso-texto"><strong>Empatizar</strong><span>"Entiendo que es frustrante..."</span></div></div>
                <div class="paso-ear"><div class="paso-letra">A</div><div class="paso-texto"><strong>Aclarar</strong><span>"Déjeme revisar su caso..."</span></div></div>
                <div class="paso-ear"><div class="paso-letra">R</div><div class="paso-texto"><strong>Resolver</strong><span>"Voy a hacer esto para solucionarlo..."</span></div></div>
            </div>
            <div class="nota">
                <strong>Nunca:</strong> subas el tono, uses jerga técnica sin explicar, ni prometas algo que no puedas cumplir.
            </div>
        </div></div>
    </div>',   2);
    
    -- Contenido del módulo 5
INSERT INTO contenidos (id_modulo, titulo, tipo, descripcion, orden) VALUES
  (5,'📊 Métricas del agente (KPIs)', 'texto','    <div class="kpi-card">
        <table class="tabla-kpi">
            <tr><th>KPI</th><th>Significado</th><th>Meta</th></tr>
            <tr><td><strong>AHT</strong></td><td>Tiempo promedio de llamada</td><td>≤ 8 min</td></tr>
            <tr><td><strong>FCR</strong></td><td>Resuelto en primera llamada</td><td>≥ 75%</td></tr>
            <tr><td><strong>CSAT</strong></td><td>Satisfacción del cliente</td><td>≥ 4/5</td></tr>
            <tr><td><strong>SL</strong></td><td>Atender en menos de 20s</td><td>≥ 80%</td></tr>
            <tr><td><strong>Adherencia</strong></td><td>Cumplimiento de horario</td><td>≥ 95%</td></tr>
        </table>
    </div>', 1),
    (5,'','','',1);

-- Evaluación del módulos
INSERT INTO evaluaciones (id_modulo, titulo, puntaje_aprobacion) VALUES
(1, 'Evaluación — Bienvenida a Claro', 70),
(2, 'Evaluación — PBX y su Plataforma Web', 70),
(3, 'Fallasa Comunes del PBX Móvil', 70),
(4, 'Scripts de Atención y Protocolos',70),
(5, 'Evaluación Final',70);
  
  
  
-- Preguntas de la evaluación 1
INSERT INTO preguntas (id_evaluacion, enunciado, orden) VALUES
  (1, '¿A qué grupo pertenece Claro Colombia?', 1),
  (1, '¿Hasta que horas puedes llamar clientes un sábado',2),
  (1, 'Son las 8:30 pc de un martes y tu supervisor te pide llamar a  20 clientes para cobranza ¿Qué haces?',3);
  
  -- Preguntas de la evaluación 2
INSERT INTO preguntas (id_evaluacion, enunciado, orden) VALUES
  (2, '¿El PBX Móvil necesita hardware?', 1),
  (2, '¿En qué formato se registran los agentes?',2),
  (2, 'Un cliente dice. "Agregué a mi empleado pero las llamadas no llegan". ¿Qué verificas primero?',3);
  
  
    -- Preguntas de la evaluación 3
  INSERT INTO preguntas (id_evaluacion, enunciado, orden) VALUES
  (3, '¿Cuál es la falla más común cuando las llamadas no llegan?', 1),
  (3, '¿Qué formato de audio acepta la plataforma?',2),
  (3, 'Un cliente dice: "El menú de voz se repite sin parar y nunca conecta con mis empleados". ¿Qué falla es?',3);
  
      -- Preguntas de la evaluación 4
  INSERT INTO preguntas (id_evaluacion, enunciado, orden) VALUES
  (4, '¿Qué debes decir siempre al abrir una llamada?', 1),
  (4, '¿Qué significa E-A-R?',2),
  (4, '¿Un cliente dice furioso: "¡Llevan 3 días sin solucionar nada!" ¿Cómo respondes?',3);

  -- Preguntas de la evaluación 5
  INSERT INTO preguntas (id_evaluacion, enunciado, orden) VALUES
  (5, '¿A qué grupo pertenece Claro?', 1),
  (5, '¿El PBX Móvil necesita hardware?',2),
  (5, '¿Cuál es la falla FB-01?',3),
  (5, '¿Qué es E-A-R?',4),
  (5, '¿Qué KPI mide la resolución en primera llamada?',5);

-- Opciones pregunta  modulo 1
INSERT INTO opciones (id_pregunta, texto, es_correcta) VALUES
  (1, 'Grupo Telefonica',         FALSE),
  (1, 'Grupo América Movil',   TRUE),
  (1, 'Grupo Movistar',     FALSE),
    (2, 'Hasta las 3:oo pm',        TRUE),
  (2, 'Hasta las 7:00 pm',   FALSE),
  (2, 'No se puede los sábados',     FALSE),
    (3, 'Llamo porque es día Hábil',        FALSE),
  (3, 'Le explico que después de las 7:00 pm no se puede llamar',   TRUE),
  (3, 'Solo llamo a los que conozco',     FALSE);
  
  -- Opciones pregunta  modulo 2
  INSERT INTO opciones (id_pregunta, texto, es_correcta) VALUES
  (4, 'Si, un servidor',         FALSE),
  (4, 'Si, un router especial',   FALSE),
  (4, 'No, es 100% en la nube',     TRUE),
    (5, '+57 seguido de 10 dígitos',        TRUE),
  (5, 'Hasta las 7:00 pm',   FALSE),
  (5, 'Con prefijo 03',     FALSE),
    (6, 'Si tiene señal celular',        FALSE),
  (6, 'Si el numero tiene el prefijo +57',   TRUE),
  (6, 'Si tiene plan de datos',     FALSE);
  
    -- Opciones pregunta  modulo 3
  INSERT INTO opciones (id_pregunta, texto, es_correcta) VALUES
  (7, 'Audio entrecortado',         FALSE),
  (7, 'Número sin prefijo +57',   TRUE),
  (7, 'Internet lento',     FALSE),
    (8, '.ogg y .m4a',        FALSE),
  (8, 'Cualquier formato',   FALSE),
  (8, '.mp3 y wav',     TRUE),
    (9, 'FA-01 — Audio entrecortado',        FALSE),
  (9, 'FB-02 — IVR en loop',   TRUE),
  (9, 'FC-01 — No accede a la web',     FALSE);


 -- Opciones pregunta  modulo 4
 INSERT INTO opciones (id_pregunta, texto, es_correcta) VALUES
  (10, 'Solo el nombre de la empresa',         FALSE),
  (10, 'Tu correo electronico',   FALSE),
  (10, 'Tu nombre y número de agente',     TRUE),
    (11, 'Escalar, Asignar, Reportar',        FALSE),
  (11, 'Empatizar, Aclarar, Resolver',   TRUE),
  (11, 'Evaluar, Analizar, Redirigir',     FALSE),
    (12, '"El equipo técnico está muy ocupado..."',        FALSE),
  (12, '"Entendido su frustración. Voy a revisar si tickt ahora mismo"',   TRUE),
  (12, '"Lo transfiero a mi supervisor"',     FALSE);


 -- Opciones pregunta  modulo 4
 INSERT INTO opciones (id_pregunta, texto, es_correcta) VALUES
  (38, 'Solo el nombre de la empresa',         FALSE),
  (38, 'Tu correo electronico',   FALSE),
  (38, 'Tu nombre y número de agente',     TRUE),
    (39, 'Escalar, Asignar, Reportar',        FALSE),
  (39, 'Empatizar, Aclarar, Resolver',   TRUE),
  (39, 'Evaluar, Analizar, Redirigir',     FALSE),
    (40, '"El equipo técnico está muy ocupado..."',        FALSE),
  (40, '"Entendido su frustración. Voy a revisar si tickt ahora mismo"',   TRUE),
  (40, '"Lo transfiero a mi supervisor"',     FALSE);
  
   -- Opciones pregunta  modulo 4
 INSERT INTO opciones (id_pregunta, texto, es_correcta) VALUES
(16, 'Telefonica',         FALSE),
(16, 'Américo Móvil',         	TRUE),
(16, 'Liberty',         FALSE),
(17, 'No, es 100% nube',         TRUE),
(17, 'Si, un servidor',         FALSE),
(17, 'Si, un router',         FALSE),
(18, 'Audio entrecortado',         FALSE),
(18, 'IVR en loop',         FALSE),
(18, 'Llamadas no llegas (sin +57)',         TRUE),
(19, 'Escalar, Asignar, Reportar',         FALSE),
(19, 'Empatizar, Aclarar, Resolver',         TRUE),
(19, 'Evaluar, Analizar, Redirigir',         FALSE),
(20, 'FCR',        TRUE),
(20, 'AHT',         FALSE),
(20, 'CSAT',         FALSE);

  

DELETE FROM respuesta_intentos WHERE id_usuario;

-- Opciones pregunta 2
INSERT INTO opciones (id_pregunta, texto, es_correcta) VALUES
  (2, 'Private Branch Exchange Móvil',   TRUE),
  (2, 'Public Broadband Extension',      FALSE),
  (2, 'Personal Business Exchange',      FALSE),
  (2, 'Premium Bandwidth Experience',    FALSE);
  


-- ============================================================
-- VISTAS ÚTILES PARA EL BACKEND
-- ============================================================

-- Vista: progreso general de cada usuario
CREATE OR REPLACE VIEW vista_progreso_usuario AS
SELECT
    u.id_usuario,
    u.nombre,
    u.usuario,
    COUNT(m.id_modulo)                                        AS total_modulos,
    COUNT(p.id_progreso)                                      AS modulos_iniciados,
    SUM(CASE WHEN p.completado = TRUE THEN 1 ELSE 0 END)      AS modulos_completados,
    ROUND(
        SUM(CASE WHEN p.completado = TRUE THEN 1 ELSE 0 END)
        / COUNT(m.id_modulo) * 100, 2
    )                                                         AS porcentaje_general
FROM usuarios u
CROSS JOIN modulos m
LEFT JOIN progreso p
       ON p.id_usuario = u.id_usuario
      AND p.id_modulo  = m.id_modulo
GROUP BY u.id_usuario, u.nombre, u.usuario;

-- Vista: detalle de intentos con resultado
CREATE OR REPLACE VIEW vista_intentos_detalle AS
SELECT
    i.id_intento,
    u.nombre                    AS nombre_usuario,
    m.titulo                    AS modulo,
    e.titulo                    AS evaluacion,
    i.puntaje,
    e.puntaje_aprobacion,
    i.aprobado,
    i.fecha
FROM intentos i
JOIN usuarios    u ON u.id_usuario    = i.id_usuario
JOIN evaluaciones e ON e.id_evaluacion = i.id_evaluacion
JOIN modulos     m ON m.id_modulo     = e.id_modulo
ORDER BY i.fecha DESC;

-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================


SELECT * FROM contenidos;