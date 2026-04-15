QUnit.module("1. Feladat: DOM Tesztek - Táblázat", function () {
  QUnit.test(
    "Táblázat szerkezetének és osztályainak vizsgálata",
    function (assert) {
      const table = document.getElementById("task1-table");
      assert.ok(table, "1. A táblázat létezik a DOM-ban.");
      assert.ok(
        table.classList.contains("table"),
        "2. A táblázat rendelkezik a Bootstrap 'table' osztállyal.",
      );
      assert.ok(
        table.classList.contains("table-striped"),
        "3. A táblázat rendelkezik a 'table-striped' osztállyal.",
      );
      assert.ok(
        table.querySelector("thead.table-dark"),
        "4. A táblázat fejléce 'table-dark' osztállyal rendelkezik.",
      );

      const rows = table.querySelectorAll("tbody tr");
      assert.ok(rows.length >= 2, "5. A táblázatban legalább 2 adatsor van.");

      const firstProductName =
        rows[0].querySelector(".product-name").textContent;
      assert.equal(firstProductName, "Alma", "6. Az első Gyümölcs 'Alma'.");
    },
  );
});

QUnit.module("2. Feladat: DOM Tesztek - Regisztrációs űrlap", function () {
  QUnit.test("Űrlap szerkezete és elemei", function (assert) {
    const form = document.getElementById("task2-form");
    assert.ok(form, "1. Az űrlap létezik.");
    assert.ok(
      form.classList.contains("p-4"),
      "2. Az űrlap 'p-4' (padding) Bootstrap osztállyal rendelkezik.",
    );

    const username = document.getElementById("username");
    assert.ok(username, "3. Felhasználónév mező létezik.");
    assert.ok(
      username.classList.contains("form-control"),
      "4. Felhasználónév rendelkezik 'form-control' osztállyal.",
    );

    const password = document.getElementById("password");
    assert.equal(
      password.type,
      "password",
      "5. A jelszó mező típusa 'password'.",
    );

    const email = document.getElementById("email");
    assert.equal(email.type, "email", "6. Az email mező típusa 'email'.");

    const firstname = document.getElementById("firstname");
    assert.ok(firstname.required, "7. Keresztnév mező kötelező.");

    const lastname = document.getElementById("lastname");
    assert.ok(lastname, "8. Vezetéknév mező létezik.");

    const genderRadios = document.querySelectorAll('input[name="gender"]');
    assert.equal(
      genderRadios.length,
      2,
      "9. Két nem (radio) választógomb létezik.",
    );
    assert.ok(
      genderRadios[0].classList.contains("form-check-input"),
      "10. A rádiógombok rendelkeznek 'form-check-input' osztállyal.",
    );

    const address = document.getElementById("address");
    assert.equal(
      address.tagName,
      "TEXTAREA",
      "11. A lakcím beviteli mező TEXTAREA típusú.",
    );

    const submitBtn = document.getElementById("submitBtn");
    assert.ok(
      submitBtn.classList.contains("btn-primary"),
      "12. A gomb 'btn-primary' Bootstrap osztállyal rendelkezik.",
    );
  });
});

QUnit.module("3. Feladat: Egységtesztek", function () {
  QUnit.test("3.a Téglalap területe és kerülete", function (assert) {
    assert.deepEqual(
      calcRectangle(5, 10),
      { area: 50, perimeter: 30 },
      "Helyes számítás: a=5, b=10 -> area: 50, perimeter: 30",
    );
    assert.deepEqual(
      calcRectangle(1, 1),
      { area: 1, perimeter: 4 },
      "Helyes számítás: a=1, b=1 -> area: 1, perimeter: 4",
    );
    assert.equal(
      calcRectangle(-5, 10),
      null,
      "Hibás paraméter (negatív érték) kezelése",
    );
  });

  QUnit.test("3.b Bruttó ár számítása", function (assert) {
    assert.equal(
      calcGrossPrice(1000, 27),
      1270,
      "Helyes bruttó számítás 27% áfával (1000 -> 1270)",
    );
    assert.equal(
      calcGrossPrice(2000, 5),
      2100,
      "Helyes bruttó számítás 5% áfával (2000 -> 2100)",
    );
    assert.equal(calcGrossPrice(-100, 27), null, "Negatív nettó ár kezelése");
  });

  QUnit.test("3.c Prímszám ellenőrzése", function (assert) {
    assert.ok(isPrime(7), "A 7 prímszám.");
    assert.notOk(isPrime(4), "A 4 nem prímszám.");
    assert.notOk(isPrime(-3), "Negatív szám nem lehet prím.");
    assert.notOk(isPrime(1), "Az 1 nem prím.");
  });

  QUnit.test("3.d Szökőév ellenőrzése", function (assert) {
    assert.ok(isLeapYear(2024), "2024 is szökőév.");
    assert.notOk(isLeapYear(2023), "2023 nem szökőév.");
    assert.ok(isLeapYear(2000), "2000 kivételes szökőév (osztható 400-zal).");
    assert.notOk(
      isLeapYear(1900),
      "1900 nem szökőév (osztható 4-gyel és 100-zal, de 400-zal nem).",
    );
  });

  QUnit.test("3.e Másodfokú egyenlet", function (assert) {
    assert.throws(
      function () {
        solveQuadratic(0, 5, 2);
      },
      Error,
      "'a = 0' esetén hibát kell dobnia (nem másodfokú).",
    );
    // x^2 - 5x + 6 = 0 -> gyökök: 3 és 2
    assert.deepEqual(
      solveQuadratic(1, -5, 6),
      [3, 2],
      "Két valós gyök (1, -5, 6)",
    );
    // x^2 - 4x + 4 = 0 -> gyök(ök): 2
    assert.deepEqual(
      solveQuadratic(1, -4, 4),
      [2],
      "Egy valós gyök (1, -4, 4)",
    );
    // x^2 + x + 1 = 0 -> nincs valós gyök
    assert.deepEqual(
      solveQuadratic(1, 1, 1),
      [],
      "Nincs valós gyök, mert a diszkrimináns negatív (1, 1, 1)",
    );
  });

  QUnit.test("3.f Hatoldalú dobókocka", function (assert) {
    let roll = rollDice();
    assert.ok(
      roll >= 1 && roll <= 6 && Number.isInteger(roll),
      `A dobás egy 1 és 6 közötti egész szám: ${roll}`,
    );

    let minExceeded = false,
      maxExceeded = false;
    for (let i = 0; i < 1000; i++) {
      let r = rollDice();
      if (r < 1) minExceeded = true;
      if (r > 6) maxExceeded = true;
    }
    assert.notOk(
      minExceeded,
      "1000 dobás alatt sosem dobott 1-nél kevesebbet.",
    );
    assert.notOk(maxExceeded, "1000 dobás alatt sosem dobott 6-nál többet.");
  });

  QUnit.test("3.g Leltárszám generálása", function (assert) {
    let inv = generateInventoryNumber();
    assert.ok(inv, "A függvény visszatér egy értékkel: " + inv);
    assert.ok(
      /^[A-Z]{4}-\d{8}-\d{5}$/.test(inv),
      "A formátum megfelelő (4Nagybetű - 8SzámjegyesDátum - 5Számjegy), pl. UFJK-20240205-34598",
    );

    let inv2 = generateInventoryNumber();
    assert.notEqual(
      inv,
      inv2,
      "Két egymás után generált azonosító jó eséllyel nem azonos.",
    );
  });

  QUnit.test("3.h Email validátor", function (assert) {
    assert.ok(validateEmail("teszt@pelda.hu"), "Helyes email cím elfogadva.");
    assert.notOk(validateEmail("tesztpelda.hu"), "Hiányzó @ jel.");
    assert.notOk(validateEmail("teszt@pelda"), "Hiányzó TLD/pont.");
    assert.notOk(validateEmail(""), "Üres string elutasítva.");
  });

  QUnit.test("3.i Mobiltelefon validátor", function (assert) {
    assert.ok(
      validateMobile("+36 20 123 4567"),
      "Helyes magyar formátum szóközzel: +36 20 123 4567",
    );
    assert.ok(
      validateMobile("06701234567"),
      "Helyes magyar formátum egybeírva: 06701234567",
    );
    assert.notOk(validateMobile("12345"), "Rossz formátum, túl rövid.");
    assert.notOk(
      validateMobile("+36 99 123 4567"),
      "Érvénytelen körzetszám (+36 99).",
    );
  });
});
