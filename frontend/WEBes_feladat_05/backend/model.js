class Tranzakcio {
  constructor(kod, id, datum, osszeg, sikeresseg, hibaOka) {
    this.kod = kod;
    this.id = id;
    this.datum = datum;
    this.osszeg = osszeg;
    this.sikeresseg = sikeresseg;
    this.hibaOka = hibaOka;
  }
}

exports.tranzakciok = [];

exports.tranzakciokFrissites = (data) => {
  // korábbi tranzakciók nullázása
  this.tranzakciok = [];

  // tranzakciók array feltöltése Tranzakcio példányokkal
  dataSorok = data.split("/n");
  dataSorok.forEach((egySor) => {
    let tmp = egySor.split(";");

    // hiba okának megkeresése, ha sikertelen a tranzakció
    var hiba = null;
    if (tmp[4] == "N") hiba = hibaOkaKereso(tmp[0], tmp[1]);

    this.tranzakciok.push(
      new Tranzakcio(tmp[0], tmp[1], tmp[2], tmp[3], tmp[4], hiba),
    );
  });
};

function hibaOkaKereso(kod, id) {
  if (kod == "new") return "hálózati hiba"; // ha új tranzakció - csak hálózati hiba lehet

  this.tranzakciok.forEach((egyTranzakcio) => {
    if (egyTranzakcio.id == id) return "hálózati hiba"; // ha létezik már ez az azonosító egy korábbi tranzakciónál: hálózati hiba
  });

  return "nincs ilyen azonosító"; // ha nem létezik ilyen azonosító korábbi lekérdezésnél, és a kód nem "new" akkor: nincs ilyen azonosító
}
