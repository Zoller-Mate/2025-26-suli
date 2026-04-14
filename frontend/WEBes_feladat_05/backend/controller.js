const multer = require("multer");
const fs = require("fs");
const Model = require("./model");

const upload = multer({ dest: "/uploads" });
exports.tranzakcioFeltoltes(upload.single("tranzakciok"), (req, res), () => {
  if (!req.file) {
    return response(res, 400, "Nem érkezett file.");
  }

  fs.readFile(req.file.path, "utf8", (err, data) => {
    if (err) {
      console.log(err);
      return response(res, 500, "Hiba a file olvasásakor.");
    }

    Model.tranzakciokFrissites(data);
  });

  response(res, 200, "Sikeres beolvasás.");
});

const response = (res, code, message) => {
  res.status(code).json({
    message,
  });
};

exports.exportSql();

exports.exportHtml();
