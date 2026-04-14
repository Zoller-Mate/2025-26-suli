const bodyParser = require("body-parser");
const express = require("express");
const cors = require("cors");

const controller = require("./controller.js");

const app = express();
app.use(cors()); // CORS engedélyezése, hogy a frontend hozzáférjen
app.use(express.json()); // json értelmezése
app.use(express.urlencoded({ extended: true }));

// ROUTES

// beolvasás
app.post("/tranzakciok", controller.tranzakcioFeltoltes);

// export sql

// hibalista, egyenleg html

app.listen(3000, () => {
  console.log("Fut a szerver a 3000-s porton");
});
