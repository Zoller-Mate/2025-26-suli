const bodyParser = require("body-parser");
const express = require("express");

const controller = require("./controller.js");

const app = express();
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
