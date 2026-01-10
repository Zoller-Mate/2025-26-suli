const Express = require("express");
const mysql = require("mysql2/promise");

const App = Express();

App.post();

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
