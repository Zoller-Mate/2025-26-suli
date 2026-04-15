const { module, test } = QUnit;

module("1. Feladat: DOM tesztek - Bootstrap bejelentkező űrlap", () => {
  test("1. Az űrlap létezik a DOM-ban", (assert) => {
    const form = document.getElementById("login-form");
    assert.ok(form, "Az űrlap megtalálható.");
  });

  test("2. A bejelentkező konténer megkapta a container osztályt", (assert) => {
    const container = document.getElementById("login-container");
    assert.ok(
      container.classList.contains("container"),
      "Tartalmazza a Bootstrap container osztályt.",
    );
  });

  test("3. Az űrlap rendelkezik a megfelelő Bootstrap formázó osztályokkal: border, p-4, shadow, rounded, bg-light", (assert) => {
    const form = document.getElementById("login-form");
    assert.ok(form.classList.contains("border"), "Van border osztálya.");
    assert.ok(form.classList.contains("p-4"), "Van p-4 osztálya.");
    assert.ok(form.classList.contains("shadow"), "Van shadow osztálya.");
    assert.ok(form.classList.contains("rounded"), "Van rounded osztálya.");
    assert.ok(form.classList.contains("bg-light"), "Van bg-light osztálya.");
  });

  test("4. A felhasználónév input létezik és text típusú", (assert) => {
    const input = document.getElementById("usernameInput");
    assert.ok(input, "A felhasználónév mező létezik.");
    assert.strictEqual(input.type, "text", "A mező típusa text.");
  });

  test("5. A felhasználónév input megkapta a form-control osztályt", (assert) => {
    const input = document.getElementById("usernameInput");
    assert.ok(
      input.classList.contains("form-control"),
      "Tartalmazza a form-control osztályt.",
    );
  });

  test("6. A jelszó input létezik és password típusú", (assert) => {
    const input = document.getElementById("passwordInput");
    assert.ok(input, "A jelszó mező létezik.");
    assert.strictEqual(input.type, "password", "A mező típusa password.");
  });

  test("7. A jelszó mező kitöltése kötelező (required atributúm létezik)", (assert) => {
    const input = document.getElementById("passwordInput");
    assert.ok(input.required, "A jelszó mező kitöltése kötelező.");
  });

  test("8. A felhasználónév címkéjének szövege megfelelő és fw-bold kiegészítő osztály is rajta van", (assert) => {
    const label = document.querySelector('label[for="usernameInput"]');
    assert.strictEqual(
      label.textContent.trim(),
      "Felhasználónév",
      "A címke szövege helyes.",
    );
    assert.ok(label.classList.contains("fw-bold"), "A címke félkövér.");
  });

  test("9. A gomb létezik, és submit típusú", (assert) => {
    const btn = document.getElementById("login-button");
    assert.ok(btn, "Létezik a bejelentkezés gomb.");
    assert.strictEqual(btn.type, "submit", "Submit típusú a gomb.");
  });

  test("10. A gombra megfelelő Bootstrap gomb osztályok (btn, btn-primary, w-100) kerültek", (assert) => {
    const btn = document.getElementById("login-button");
    assert.ok(btn.classList.contains("btn"), "btn osztály van.");
    assert.ok(
      btn.classList.contains("btn-primary"),
      "btn-primary osztály van.",
    );
    assert.ok(
      btn.classList.contains("w-100"),
      "w-100 osztály (teljes szélesség) van.",
    );
  });
});

module("2. Feladat: JS Logika", () => {
  module("a. Magánhangzók aránya", () => {
    test("1. Angol mondat - csak magánhangzók érvényesek a betűk körül", (assert) => {
      // "Hello World" -> Betűk száma: 10, Magánhangzók: e, o, o (3) -> 30%
      assert.strictEqual(
        getVowelPercentage("Hello World"),
        30,
        '"Hello World" -> 30%',
      );
    });

    test("2. Számok és speciális karakterek figyelmen kívül hagyása", (assert) => {
      // "A b, 123 ! E!" -> Betűk: A, b, E (3). Magánhangzók: A, E (2) -> kb. 66.6%
      assert.ok(
        Math.abs(getVowelPercentage("A b, 123 ! E!") - 66.666) < 0.1,
        "A b, 123 ! E! -> ~66.6%",
      );
    });

    test("3. Magyar ékezetes magánhangzókkal (árvíztűrő)", (assert) => {
      // "alma" -> Betűk: 4, Magánhangzók: 2 -> 50%
      assert.strictEqual(getVowelPercentage("alma"), 50, '"alma" -> 50%');
    });
  });

  module("b. Jelszó generátor", () => {
    test("1. A megadott hosszúságú jelszót téríti vissza", (assert) => {
      assert.strictEqual(generatePassword(8).length, 8, "A hossza pontosan 8");
      assert.strictEqual(
        generatePassword(15).length,
        15,
        "A hossza pontosan 15",
      );
    });

    test("2. Csak engedélyezett karaktereket tartalmaz (kis/nagybetű/szám)", (assert) => {
      const pwd = generatePassword(50);
      assert.ok(
        /^[a-zA-Z0-9]+$/.test(pwd),
        "Sikeres - csak angol ABC és számok alkotják.",
      );
    });

    test("3. Hibás paraméterekre üres stringet ad vissza", (assert) => {
      assert.strictEqual(
        generatePassword(-5),
        "",
        "Negatív számra üres string",
      );
      assert.strictEqual(generatePassword(0), "", "Nullára üres string");
      assert.strictEqual(
        generatePassword("10"),
        "",
        "Nem szám típusra üres string (validáció)",
      );
    });
  });

  module("c. Bankszámla validátor", () => {
    test("1. Kétszer 8 számjegy kötőjellel (Helyes)", (assert) => {
      assert.ok(
        validateBankAccount("12345678-12345678"),
        "12345678-12345678 -> OK",
      );
    });

    test("2. Háromszor 8 számjegy kötőjelekkel (Helyes)", (assert) => {
      assert.ok(
        validateBankAccount("12345678-12345678-12345678"),
        "12345678-12345678-12345678 -> OK",
      );
    });

    test("3. Helytelen formátumok (Hibás hosszak, nem csak szám)", (assert) => {
      assert.notOk(
        validateBankAccount("123456-12345"),
        "Túl rövid formátum (NEM JÓ)",
      );
      assert.notOk(
        validateBankAccount("12345678-12345678-"),
        "Plusz kötőjel a végén (NEM JÓ)",
      );
      assert.notOk(
        validateBankAccount("ABCDEFGH-12345678"),
        "Betűket is tartalmaz (NEM JÓ)",
      );
    });
  });

  module("d. Kedvezményes ár számító", () => {
    test("1. Helyes ár kiszámítása", (assert) => {
      assert.strictEqual(
        getDiscountedPrice("Laptop", 100000, 15),
        "Laptop: 85000 Ft",
        "15% kedvezmény 100 000 Ft-ból -> 85000 Ft",
      );
    });

    test("2. Teljes áras, azaz 0% kedvezmény", (assert) => {
      assert.strictEqual(
        getDiscountedPrice("Telefon", 50000, 0),
        "Telefon: 50000 Ft",
        "0% kedvezménnyel marad az eredeti ár",
      );
    });

    test("3. Érvénytelen bemenetek kezelése (negatív ár, vagy túl magas kedvezmény)", (assert) => {
      assert.strictEqual(
        getDiscountedPrice("Kenyér", -500, 10),
        null,
        "Negatív ár formátum nem érvényes",
      );
      assert.strictEqual(
        getDiscountedPrice("Víz", 100, 110),
        null,
        "100% feletti kedvezmény nem érvényes, null-t ad vissza",
      );
    });
  });

  module("e. Rendszám validátor", () => {
    test("1. Régi formátum ABC-123 (Helyes)", (assert) => {
      assert.ok(
        validateLicensePlate("ABC-123"),
        "ABC-123 teljesíti a formátumot",
      );
      assert.ok(
        validateLicensePlate("XYZ-999"),
        "XYZ-999 teljesíti a formátumot",
      );
    });

    test("2. Új formátum AB-CD-123 (Helyes)", (assert) => {
      assert.ok(
        validateLicensePlate("AB-CD-123"),
        "AB-CD-123 teljesíti az új formátumot",
      );
      assert.ok(
        validateLicensePlate("AA-ZZ-000"),
        "AA-ZZ-000 teljesíti az új formátumot",
      );
    });

    test("3. Helytelen formátumok elutasítása", (assert) => {
      assert.notOk(validateLicensePlate("ABC-12"), "Túl rövid sorszám (Hiba)");
      assert.notOk(
        validateLicensePlate("A-BC-123"),
        "Rossz kötőjelezés (Hiba)",
      );
      assert.notOk(
        validateLicensePlate("123-ABC"),
        "Számok és betűk felcserélve (Hiba)",
      );
      assert.notOk(
        validateLicensePlate("abc-123"),
        "Kisbetűk nem megengedettek (Hiba)",
      );
    });
  });
});
