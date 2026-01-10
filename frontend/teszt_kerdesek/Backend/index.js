const express = require("express");
const mysql = require("mysql2/promise");
const cors = require("cors");

const app = express();

app.use(cors());
app.use(express.json());

app.post("/api/teszt-generalas", async (req, res) => {
  try {
    res.status(200).json(await tesztGeneralas(req.body));
  } catch (error) {
    res.status(500).json({
      error,
    });
  }
});

const pool = mysql.createPool({
  host: "localhost",
  user: "root",
  password: "password",
  database: "feladatbank",
  waitForConnections: true,
});

async function tesztGeneralas(bemeneti_json) {
  try {
    const connection = await pool.getConnection();

    await connection.query("SET @be = ?", [JSON.stringify(bemeneti_json)]);
    await connection.query("CALL teszt_generalasa_jo(@be, @ki)");
    const [rows] = await connection.query("SELECT @ki AS eredmeny");

    connection.release();
    return JSON.parse(rows[0]["@ki"]);
  } catch (error) {
    throw error;
  }
}

app.listen(3000, () => {
  console.log("Server is running on port 3000.");
});
