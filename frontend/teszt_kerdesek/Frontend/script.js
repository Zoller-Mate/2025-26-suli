function kerdesek_lekerese() {
  var kerdesek_data = [];

  for (let i = 1; i <= 5; i++) {
    const tema_kell_e = document.getElementById("tema_" + i.toString()).checked;

    if (tema_kell_e) {
      const kerdes_db = document.getElementById("db_" + i.toString()).value;

      kerdesek_data.push({
        id: i,
        db: parseInt(kerdes_db) || 0,
      });
    }
  }

  fetch("http://localhost:3000/api/teszt-generalas", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify(kerdesek_data),
  })
    .then((res) => res.json())
    .then((data) => {
      console.log(data);
    });
}
