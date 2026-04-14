const { response } = require("express");

const fileInput = document.getElementById("tranzakciok");
const sendFileBtn = document.getElementById("sendFile");

const exportHtmlBtn = document.getElementById("exportHtml");
const exportSqlBtn = document.getElementById("exportSql");

fileInput.addEventListener("change", () => {
  if (fileInput.files.length > 0) {
    sendFileBtn.disabled = false;
  } else {
    sendFileBtn.disabled = true;
  }
});

sendFileBtn.addEventListener("click", () => {
  const file = fileInput.files[0];

  const formData = new FormData();

  formData.append("tranzakciok", file);

  fetch("http://localhost:3000/tranzakciok", {
    method: "POST",
    body: formData,
  })
    .then((response) => response.json())
    .then((responseJson) => {
      alert(response.message);
      if (response.statusCode == 200) {
        exportHtmlBtn.disabled = false;
        exportSqlBtn.disabled = false;
      }
      fileInput.value = "";
    })
    .catch((error) => {
      alert("Hiba a file küldése során (frontend)");
    });
});
