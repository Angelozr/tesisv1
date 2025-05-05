require("dotenv").config();

const SECRET_KEY = process.env.SECRET_KEY;

if (!SECRET_KEY) {
  console.error("La clave secreta no está configurada correctamente");
  process.exit(1); // Termina el proceso si no está configurada
} else {
  console.log("Clave secreta cargada correctamente");
}

const express = require("express");
const cors = require("cors");
const { Pool } = require("pg");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const app = express();
app.use(express.json());
app.use(cors());

// Conexión a PostgreSQL
const pool = new Pool({
  user: "postgres",
  host: "localhost",
  database: "uleam",
  password: "123456",
  port: 5432,
});


// Ruta para cerrar sesión
app.post('/api/logout', (req, res) => {
  const token = req.headers['authorization'];

  if (!token) {
    return res.status(400).json({ message: 'Token no proporcionado' });
  }

  // Aquí debes invalidar el token, por ejemplo:
  // Si usas JWT, puedes manejar la invalidación o simplemente no hacer nada
  // porque el token caducará eventualmente, o podrías eliminarlo del almacenamiento.

  res.status(200).json({ message: 'Sesión cerrada exitosamente' });
});



// Obtener todos los usuarios
app.get("/usuarios", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM usuarios");
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Registro de usuarios
// Registro de usuarios
app.post("/register", async (req, res) => {
  const { nombre, apellido, email, password } = req.body;

  if (!nombre || !apellido || !email || !password) {
    return res.status(400).json({ error: "Todos los campos son obligatorios" });
  }

  try {
    // Encriptamos la contraseña antes de guardarla en la base de datos
    const hashedPassword = await bcrypt.hash(password, 10);

    // Generamos el token de autenticación
    const token = jwt.sign({ email }, SECRET_KEY, { expiresIn: "1h" });

    // Insertamos el usuario en la base de datos, incluyendo el token
    const result = await pool.query(
      "INSERT INTO usuarios (nombre, apellido, email, password, token) VALUES ($1, $2, $3, $4, $5) RETURNING *",
      [nombre, apellido, email, hashedPassword, token]
    );

    // Recuperamos los datos del usuario insertado
    const user = result.rows[0];

    // Respondemos al cliente con el token y la información del usuario
    res.status(201).json({
      message: "Usuario registrado con éxito",
      token: token,  // Aquí estamos enviando el token
      usuario: { id: user.id, nombre: user.nombre, email: user.email }
    });
  } catch (err) {
    if (err.code === "23505") {
      // Error de correo duplicado
      res.status(400).json({ error: "El correo ya está registrado" });
    } else {
      res.status(500).json({ error: err.message });
    }
  }
});



// Login de usuario
app.post("/login", async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: "Email y contraseña son obligatorios" });
  }

  try {
    // Buscar el usuario por su email
    const result = await pool.query("SELECT * FROM usuarios WHERE email = $1", [email]);

    if (result.rows.length === 0) {
      return res.status(401).json({ error: "Correo no registrado" });
    }

    const user = result.rows[0];

    // Comparar la contraseña proporcionada con la almacenada
    const passwordMatch = await bcrypt.compare(password, user.password);

    if (!passwordMatch) {
      return res.status(401).json({ error: "Contraseña incorrecta" });
    }

    // Generar el token JWT
    const token = jwt.sign({ id: user.id, email: user.email }, SECRET_KEY, { expiresIn: "1h" });

    // Devolver el token y los datos del usuario
    res.json({
      message: "Login exitoso",
      token: token,
      usuario: { id: user.id, nombre: user.nombre, email: user.email }
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});













//////////////////////DATOS USUARIOS
// Obtener el perfil del usuario
app.get('/profile', async (req, res) => {
  const token = req.headers.authorization?.split(" ")[1];

  if (!token) {
    return res.status(401).json({ message: "Acceso denegado, token no proporcionado." });
  }

  try {
    const decoded = jwt.verify(token, SECRET_KEY);
    const result = await pool.query('SELECT nombre, apellido, email FROM usuarios WHERE id = $1', [decoded.id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Usuario no encontrado." });
    }

    return res.json(result.rows[0]);
  } catch (error) {
    return res.status(400).json({ message: "Token no válido." });
  }
});

/////////////////////// LUGARES AGREGAR, MODIFICAR, ELIMINAR //////////////////////////////////

// Obtener todos los lugares
app.get('/api/lugar', async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM lugar");
    res.json(result.rows); // Devolver los lugares en formato JSON
  } catch (err) {
    console.error('Error al obtener los lugares:', err);
    res.status(500).json({ error: 'Error al cargar los lugares' });
  }
});

// Agregar un lugar
app.post('/api/lugar', async (req, res) => {
  try {
    const { nombre, fecha_creacion } = req.body;

    if (!nombre) {
      return res.status(400).json({ error: 'El nombre es obligatorio' });
    }

    const query = 'INSERT INTO lugar (nombre, fecha_creacion) VALUES ($1, $2) RETURNING *';
    const values = [nombre, fecha_creacion];

    const result = await pool.query(query, values);

    res.status(201).json({ mensaje: 'Lugar agregado', lugar: result.rows[0] });
  } catch (error) {
    console.error('Error al insertar en la base de datos:', error);
    res.status(500).json({ error: 'Error en el servidor' });
  }
});

// Modificar lugar
app.put('/api/lugar/:id', async (req, res) => {
  const { id } = req.params;
  const { nombre, fecha_creacion } = req.body;

  if (!nombre || !fecha_creacion) {
    return res.status(400).json({ error: "Nombre y fecha de creación son obligatorios" });
  }

  try {
    const query = 'UPDATE lugar SET nombre = $1, fecha_creacion = $2 WHERE id = $3 RETURNING *';
    const values = [nombre, fecha_creacion, id];

    const result = await pool.query(query, values);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Lugar no encontrado" });
    }

    res.json({ mensaje: 'Lugar actualizado', lugar: result.rows[0] });
  } catch (error) {
    console.error('Error al actualizar el lugar:', error);
    res.status(500).json({ error: 'Error en el servidor' });
  }
});

// Eliminar lugar
app.delete('/api/lugar/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query('DELETE FROM lugar WHERE id = $1 RETURNING *', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Lugar no encontrado" });
    }

    res.json({ mensaje: 'Lugar eliminado', lugar: result.rows[0] });
  } catch (error) {
    console.error('Error al eliminar el lugar:', error);
    res.status(500).json({ error: 'Error en el servidor' });
  }
});

///////////////////////////////////////////////////////////////////////////////////////


//////////////////////////// CATEGORIAS CRUD //////////////////////////////////

// 📌 Obtener todas las categorías (sin filtros)
app.get('/api/categorias', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM categoria');
    res.json(result.rows);
  } catch (error) {
    console.error('Error al obtener categorías:', error);
    res.status(500).json({ error: 'Error en el servidor' });
  }
});

// 📌 Obtener categorías por lugar específico
app.get('/api/categorias/lugar', async (req, res) => {
  const { lugar_id } = req.query;
  try {
    let query = 'SELECT DISTINCT c.* FROM categoria c JOIN edificios e ON c.id = e.categoria_id';
    let params = [];

    if (lugar_id) {
      query += ' WHERE e.lugar_id = $1';
      params.push(lugar_id);
    }

    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (error) {
    console.error('Error al obtener categorías por lugar:', error);
    res.status(500).json({ error: 'Error en el servidor' });
  }
});


// 📌 Agregar una nueva categoría
app.post('/api/categorias', async (req, res) => {
  try {
    const { nombre } = req.body;

    if (!nombre) {
      return res.status(400).json({ error: 'El nombre es obligatorio' });
    }

    const query = 'INSERT INTO categoria (nombre) VALUES ($1) RETURNING *';
    const values = [nombre];

    const result = await pool.query(query, values);

    res.status(201).json({ mensaje: 'Categoría agregada', categoria: result.rows[0] });
  } catch (error) {
    console.error('Error al agregar la categoría:', error);
    res.status(500).json({ error: 'Error en el servidor' });
  }
});

// 📌 Modificar una categoría
app.put('/api/categorias/:id', async (req, res) => {
  const { id } = req.params;
  const { nombre } = req.body;

  if (!nombre) {
    return res.status(400).json({ error: "El nombre es obligatorio" });
  }

  try {
    const query = 'UPDATE categoria SET nombre = $1 WHERE id = $2 RETURNING *';
    const values = [nombre, id];

    const result = await pool.query(query, values);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Categoría no encontrada" });
    }

    res.json({ mensaje: 'Categoría modificada', categoria: result.rows[0] });
  } catch (error) {
    console.error('Error al modificar la categoría:', error);
    res.status(500).json({ error: 'Error en el servidor' });
  }
});

// 📌 Eliminar una categoría
app.delete('/api/categorias/:id', async (req, res) => {
  const { id } = req.params;

  try {
    // Comprobar si la categoría existe antes de eliminarla
    const checkQuery = 'SELECT * FROM categoria WHERE id = $1';
    const checkResult = await pool.query(checkQuery, [id]);

    if (checkResult.rows.length === 0) {
      return res.status(404).json({ error: 'Categoría no encontrada' });
    }

    // Eliminar la categoría
    const deleteQuery = 'DELETE FROM categoria WHERE id = $1';
    await pool.query(deleteQuery, [id]);

    res.json({ mensaje: 'Categoría eliminada correctamente' });
  } catch (error) {
    console.error('Error al eliminar la categoría:', error);
    res.status(500).json({ error: 'Error en el servidor' });
  }
});

//////////////////////////////////////////////////////////////////////
//////////////////////////////CRUD EDIFICACIONES//////////////////////////////////////////

// Obtener edificios filtrados por categoría
app.get('/api/edificios', async (req, res) => {
  const { categoria_id, lugar_id } = req.query; // Recibe la categoría y lugar seleccionados
  try {
    let query = 'SELECT * FROM edificios WHERE 1=1';
    let params = [];

    if (categoria_id) {
      params.push(categoria_id);
      query += ` AND categoria_id = $${params.length}`;
    }

    if (lugar_id) {
      params.push(lugar_id);
      query += ` AND lugar_id = $${params.length}`;
    }

    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (error) {
    console.error('Error al obtener edificios:', error);
    res.status(500).json({ error: 'Error en el servidor' });
  }
});


// Obtener todas las edificaciones
app.get('/api/edificios', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM edificios');
    res.json(result.rows);
  } catch (error) {
    console.error('Error al obtener edificaciones:', error);
    res.status(500).json({ error: 'Error en el servidor' });
  }
});

// Agregar una edificación
app.post('/api/edificios', async (req, res) => {
  try {
    const { nombre, lugar_id, categoria_id } = req.body;

    if (!nombre || !lugar_id || !categoria_id) {
      return res.status(400).json({ error: 'Todos los campos son obligatorios' });
    }

    const query =
      'INSERT INTO edificios (nombre, lugar_id, categoria_id) VALUES ($1, $2, $3) RETURNING *';
    const values = [nombre, lugar_id, categoria_id];

    const result = await pool.query(query, values);
    res.status(201).json({ mensaje: 'Edificación agregada', edificio: result.rows[0] });
  } catch (error) {
    console.error('Error al agregar la edificación:', error);
    res.status(500).json({ error: 'Error en el servidor' });
  }
});

// Modificar una edificación
app.put('/api/edificios/:id', async (req, res) => {
  const { id } = req.params;
  const { nombre, lugar_id, categoria_id } = req.body;

  try {
    const query =
      'UPDATE edificios SET nombre = $1, lugar_id = $2, categoria_id = $3 WHERE id = $4 RETURNING *';
    const values = [nombre, lugar_id, categoria_id, id];

    const result = await pool.query(query, values);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Edificación no encontrada' });
    }

    res.json({ mensaje: 'Edificación actualizada', edificio: result.rows[0] });
  } catch (error) {
    console.error('Error al modificar la edificación:', error);
    res.status(500).json({ error: 'Error en el servidor' });
  }
});

// Eliminar una edificación
app.delete('/api/edificios/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const deleteQuery = 'DELETE FROM edificios WHERE id = $1 RETURNING *';
    const result = await pool.query(deleteQuery, [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Edificación no encontrada' });
    }

    res.json({ mensaje: 'Edificación eliminada correctamente' });
  } catch (error) {
    console.error('Error al eliminar la edificación:', error);
    res.status(500).json({ error: 'Error en el servidor' });
  }
});

/////////////////////////////////////////////////////////////////
///////////////////// GESTION DE BLOQUES ////////////////////////

//Obtener laboratorios filtrados por bloque
app.get('/api/laboratorios', async (req, res) => {
  const { bloque_id } = req.query;
  try {
    let query = 'SELECT laboratorios FROM bloques WHERE id = $1';
    const result = await pool.query(query, [bloque_id]);
    if (result.rows.length > 0) {
      res.json(result.rows[0].laboratorios || []);
    } else {
      res.json([]);
    }
  } catch (error) {
    console.error('Error al obtener laboratorios:', error);
    res.status(500).json({ error: 'Error en el servidor' });
  }
});



// Obtener todos los bloques
app.get('/api/bloques', async (req, res) => {
  const { edificio_id } = req.query;
  try {
    let query = `
      SELECT 
        bloques.id,
        bloques.nombre,
        bloques.descripcion,
        bloques.latitud,
        bloques.longitud,
        bloques.laboratorios,
        bloques.edificios_id,
        edificios.nombre AS nombre_edificio
      FROM bloques
      JOIN edificios ON bloques.edificios_id = edificios.id
    `;
    const values = [];

    // Agrega filtro si viene el query param
    if (edificio_id) {
      query += ' WHERE bloques.edificios_id = $1';
      values.push(edificio_id);
    }

    const result = await pool.query(query, values);
    res.json(result.rows);
  } catch (error) {
    console.error('Error al obtener bloques:', error);
    res.status(500).json({ error: 'Error en el servidor' });
  }
});



// Agregar un bloque
app.post('/api/bloques', async (req, res) => {
  try {
    let { nombre, descripcion, latitud, longitud, edificios_id, laboratorios } = req.body;

    if (!nombre || !edificios_id) {
      return res.status(400).json({ error: 'El nombre y el edificio son obligatorios' });
    }

    // Si laboratorios no es un array, inicializarlo como un array vacío
    if (!Array.isArray(laboratorios)) {
      laboratorios = [];
    }

    const query = `
      INSERT INTO bloques (nombre, descripcion, latitud, longitud, edificios_id, laboratorios) 
      VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`;
    const values = [nombre, descripcion, latitud, longitud, edificios_id, `{${laboratorios.join(',')}}`]; // Convertimos la lista a formato PostgreSQL

    const result = await pool.query(query, values);
    res.status(201).json({ mensaje: 'Bloque agregado', bloque: result.rows[0] });
  } catch (error) {
    console.error('Error al agregar el bloque:', error);
    res.status(500).json({ error: 'Error en el servidor' });
  }
});


// Modificar un bloque
app.put('/api/bloques/:id', async (req, res) => {
  const { id } = req.params;
  const { nombre, descripcion, latitud, longitud, edificios_id, laboratorios } = req.body;

  try {
    const query = `
      UPDATE bloques 
      SET nombre = $1, descripcion = $2, latitud = $3, longitud = $4, edificios_id = $5, laboratorios = $6 
      WHERE id = $7 RETURNING *`;
    const values = [nombre, descripcion, latitud, longitud, edificios_id, laboratorios, id];

    const result = await pool.query(query, values);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Bloque no encontrado' });
    }

    res.json({ mensaje: 'Bloque actualizado', bloque: result.rows[0] });
  } catch (error) {
    console.error('Error al actualizar el bloque:', error);
    res.status(500).json({ error: 'Error en el servidor' });
  }
});

// Eliminar un bloque
app.delete('/api/bloques/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const checkQuery = 'SELECT * FROM bloques WHERE id = $1';
    const checkResult = await pool.query(checkQuery, [id]);

    if (checkResult.rows.length === 0) {
      return res.status(404).json({ error: 'Bloque no encontrado' });
    }

    const deleteQuery = 'DELETE FROM bloques WHERE id = $1';
    await pool.query(deleteQuery, [id]);

    res.json({ mensaje: 'Bloque eliminado correctamente' });
  } catch (error) {
    console.error('Error al eliminar el bloque:', error);
    res.status(500).json({ error: 'Error en el servidor' });
  }
});

///////////////////////////////////////////////////////////////
/////////////////////////EVALUCIONES CRUD/////////////////////
// Obtener todas las evaluaciones
app.get('/api/evaluaciones', async (req, res) => {
  try {
    const query = `
      SELECT 
          e.id,
          e.nombre,
          e.lugar_id,
          l.nombre AS lugar_nombre,
          e.categoria_id,
          c.nombre AS categoria_nombre,
          e.edificio_id,
          ed.nombre AS edificio_nombre,
          e.bloque_id,
          b.nombre AS bloque_nombre,
          e.laboratorios,
          e.fecha_inicio,
          e.fecha_fin,
          e.horarios
      FROM evaluaciones e
      JOIN lugar l ON e.lugar_id = l.id
      JOIN categoria c ON e.categoria_id = c.id
      JOIN edificios ed ON e.edificio_id = ed.id
      JOIN bloques b ON e.bloque_id = b.id
    `;
    const result = await pool.query(query);
    res.json(result.rows);
  } catch (error) {
    console.error('Error al obtener evaluaciones:', error);
    res.status(500).json({ error: 'Error en el servidor' });
  }
});

// Obtener detalles de un bloque por ID
app.get('/api/bloques/:id', async (req, res) => {
  const bloqueId = req.params.id;
  try {
    const query = `
      SELECT 
          b.id,
          b.nombre,
          b.descripcion,
          ed.nombre AS nombre_edificio,
          b.laboratorios
      FROM bloques b
      JOIN edificios ed ON b.edificios_id = ed.id
      WHERE b.id = $1
    `;
    const result = await pool.query(query, [bloqueId]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Bloque no encontrado' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error al obtener detalles del bloque:', error);
    res.status(500).json({ error: 'Error en el servidor' });
  }
});

// Crear nueva evaluación
app.post('/api/evaluaciones', async (req, res) => {
  const {
    nombre,
    lugar_id,
    categoria_id,
    edificio_id,
    bloque_id,
    laboratorios,
    fecha_inicio,
    fecha_fin,
    horarios
  } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO evaluaciones (
        nombre, lugar_id, categoria_id, edificio_id, bloque_id,
        laboratorios, fecha_inicio, fecha_fin, horarios
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *`,
      [
        nombre,
        lugar_id,
        categoria_id,
        edificio_id,
        bloque_id,
        laboratorios,
        fecha_inicio,
        fecha_fin,
        horarios
      ]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Error al crear evaluación:', error);
    res.status(500).json({ error: 'Error al crear evaluación' });
  }
});

// Modificar evaluación
app.put('/api/evaluaciones/:id', async (req, res) => {
  const { id } = req.params;
  const {
    nombre,
    lugar_id,
    categoria_id,
    edificio_id,
    bloque_id,
    laboratorios,
    fecha_inicio,
    fecha_fin,
    horarios
  } = req.body;

  try {
    const result = await pool.query(
      `UPDATE evaluaciones SET
        nombre = $1,
        lugar_id = $2,
        categoria_id = $3,
        edificio_id = $4,
        bloque_id = $5,
        laboratorios = $6,
        fecha_inicio = $7,
        fecha_fin = $8,
        horarios = $9
      WHERE id = $10 RETURNING *`,
      [
        nombre,
        lugar_id,
        categoria_id,
        edificio_id,
        bloque_id,
        laboratorios,
        fecha_inicio,
        fecha_fin,
        horarios,
        id
      ]
    );

    if (result.rowCount === 0) {
      res.status(404).json({ error: 'Evaluación no encontrada' });
    } else {
      res.json(result.rows[0]);
    }
  } catch (error) {
    console.error('Error al modificar evaluación:', error);
    res.status(500).json({ error: 'Error al modificar evaluación' });
  }
});

// Eliminar evaluación
app.delete('/api/evaluaciones/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query('DELETE FROM evaluaciones WHERE id = $1', [id]);

    if (result.rowCount === 0) {
      res.status(404).json({ error: 'Evaluación no encontrada' });
    } else {
      res.json({ message: 'Evaluación eliminada correctamente' });
    }
  } catch (error) {
    console.error('Error al eliminar evaluación:', error);
    res.status(500).json({ error: 'Error al eliminar evaluación' });
  }
});




const PORT = process.env.PORT || 5000;
app.listen(PORT, 'localhost', () => console.log(`Servidor en http://localhost:${PORT}`));

