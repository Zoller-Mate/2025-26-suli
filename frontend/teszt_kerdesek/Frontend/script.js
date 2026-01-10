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
      console.log('Teljes adat:', data);
      console.log('Első kérdés válaszai:', data[0].valaszok);
      window.tesztKerdesek = data;
      megjelenitKerdesek(data);
    });
}

function megjelenitKerdesek(kerdesek) {
  var container = document.getElementById('tesztKontener');
  container.innerHTML = '';
  
  for (var i = 0; i < kerdesek.length; i++) {
    var kerdes = kerdesek[i];
    var kerdesDiv = document.createElement('div');
    
    var h3 = document.createElement('h3');
    h3.textContent = (i + 1) + '. ' + kerdes.leiras;
    kerdesDiv.appendChild(h3);
    
    var valaszokDiv = document.createElement('div');
    valaszokDiv.id = 'valaszok_' + kerdes.id;
    
    for (var j = 0; j < kerdes.valaszok.length; j++) {
      var valasz = kerdes.valaszok[j];
      var label = document.createElement('label');
      var radio = document.createElement('input');
      radio.type = 'radio';
      radio.name = 'kerdes_' + kerdes.id;
      radio.value = valasz.id;
      label.appendChild(radio);
      label.appendChild(document.createTextNode(' ' + valasz.leiras));
      valaszokDiv.appendChild(label);
      valaszokDiv.appendChild(document.createElement('br'));
    }
    
    kerdesDiv.appendChild(valaszokDiv);
    kerdesDiv.appendChild(document.createElement('hr'));
    container.appendChild(kerdesDiv);
  }
  
  var gomb = document.createElement('button');
  gomb.textContent = 'Ellenőrzés';
  gomb.onclick = ellenorzes;
  container.appendChild(gomb);
}

function ellenorzes() {
  var helyes = 0;
  var osszPont = 0;
  var elertPont = 0;
  
  for (var i = 0; i < window.tesztKerdesek.length; i++) {
    var kerdes = window.tesztKerdesek[i];
    var kivalasztott = document.querySelector('input[name="kerdes_' + kerdes.id + '"]:checked');
    
    var helyesValasz = null;
    for (var j = 0; j < kerdes.valaszok.length; j++) {
      if (kerdes.valaszok[j].helyes_e === 1) {
        helyesValasz = kerdes.valaszok[j];
        break;
      }
    }
    
    osszPont += kerdes.pontszam;
    
    if (kivalasztott) {
      var valaszId = parseInt(kivalasztott.value);
      if (valaszId === helyesValasz.id) {
        helyes++;
        elertPont += kerdes.pontszam;
        document.getElementById('valaszok_' + kerdes.id).style.backgroundColor = 'lightgreen';
      } else {
        document.getElementById('valaszok_' + kerdes.id).style.backgroundColor = 'lightcoral';
        var helyesDiv = document.createElement('div');
        helyesDiv.innerHTML = '<strong>Helyes válasz: ' + helyesValasz.leiras + '</strong>';
        document.getElementById('valaszok_' + kerdes.id).appendChild(helyesDiv);
      }
    }
  }
  
  var szazalek = Math.round((elertPont / osszPont) * 100);
  alert('Eredmény: ' + helyes + '/' + window.tesztKerdesek.length + ' helyes\nPontszám: ' + elertPont + '/' + osszPont + ' (' + szazalek + '%)');
}
