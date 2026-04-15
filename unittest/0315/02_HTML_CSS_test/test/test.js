// 01. Teszt: a subheading osztállyal rendelkező elem betűmérete 20px-e?
function testSubHeadingStyle() {
  const subheading = document.querySelector(".subheading");

  const computedStyles = window.getComputedStyle(subheading);
  const actual = computedStyles.getPropertyValue("font-size");
  const expected = "20px";

  if (actual === expected) {
    console.log("01. Teszt: Az alcím stílusának ellenőrzése: Siker (Success)");
  } else {
    console.error("01. Teszt: Hiba, az alcím stílusának ellenőrzése: FAIL ");
  }
}

// 02. Teszt: title osztállyal rendelkező elem ellenőrzése mérete és középre igazítása
// CC szabályszegés- mert egyszerre két dolgot ellenőriz
// Megoldás: két külön teszt text-align és font-size
function testTitleStyle() {
  const title = document.querySelector(".title");

  const computedStyles = window.getComputedStyle(title);
  const textAlign = computedStyles.getPropertyValue("text-align");
  const fontSize = computedStyles.getPropertyValue("font-size");

  const expectedTextAlign = "center"; // Várhatóan középre igazítva
  const expectedFontSize = "35px"; // Várhatóan 35 képpont méretű

  if (textAlign === expectedTextAlign && fontSize === expectedFontSize) {
    console.log("02. Teszt: A címsor stílusának ellenőrzése: Siker (Success)");
  } else {
    console.error("02. Teszt: Hiba, A címsor stílusának ellenőrzése");
  }
}

// 03. Teszt: táblázat szegélyeinek ellenőrzése (mindegyik sornál van -e folytonos 1px vastag szegély)
// BOM miatt ctrl+0 - alapértelmezett mérete lesz az oldalnak 1px solid - 0.8 solid nagyítástnál pld.
function testTableBorders() {
  const table = document.querySelector("table");
  const th = table.querySelectorAll("th");
  const td = table.querySelectorAll("td");

  let hasBorder = true;

  th.forEach((thElem) => {
    const computedStyles = window.getComputedStyle(thElem);
    const border = computedStyles.getPropertyValue("border");
    console.log(border);

    if (!border.includes("1px solid")) {
      hasBorder = false;
    }
  });

  td.forEach((tdElem) => {
    const computedStyles = window.getComputedStyle(tdElem);
    const border = computedStyles.getPropertyValue("border");
    console.log(border);
    if (!border.includes("1px solid")) {
      hasBorder = false;
    }
  });

  if (hasBorder) {
    console.log(
      "03. Teszt: A táblázat szegélyeinek ellenőrzése: Siker (SUCCESS)",
    );
  } else {
    console.error(
      "03. Teszt: Hiba, a táblázat szegélyeinek ellenőrzése (FAIL)",
    );
  }
}

// 04. Teszt: h2 címsor - inline formázásának ellenőrzése: dőlt -e "JS egység teszt"
function testCustomHeadingStyle() {
  const customHeading = document.querySelector("h2");
  const style = customHeading.getAttribute("style");

  if (style.includes("font-style: italic;")) {
    console.log(
      "04. Teszt: Az egyéni alcím stílusának ellenőrzése: Siker (SUCCESS)",
    );
  } else {
    console.error("04. Teszt: Hiba, az egyéni alcím stílusának ellenőrzése");
  }
}

// 05. Teszt: Terméknevek ellenőrzése a táblázatban. Termék 1, Termék 2, Termék 3
function testProductNames() {
  const table = document.querySelector("#myTable");
  const productNames = Array.from(table.querySelectorAll("td:first-child")).map(
    (td) => td.textContent.trim(),
  );
  const expectedProductNames = ["Termék 1", "Termék 2", "Termék 3"];

  if (
    productNames.length === expectedProductNames.length &&
    productNames.every((name, index) => name === expectedProductNames[index])
  ) {
    console.log(
      "05. Teszt: Terméknevek ellenőrzése a táblázatban: Siker (SUCCESS)",
    );
  } else {
    console.error("05. Teszt: Hiba, A terméknevek ellenőrzése a táblázatban");
  }
}

// 06. Teszt: Termék árak ellenőrzése a táblázatban. 1000 Ft, 2000 Ft, 1500 Ft
function testProductPrices() {
  const table = document.querySelector("#myTable");
  const productPrices = Array.from(
    table.querySelectorAll("td:nth-child(2)"),
  ).map((td) => td.textContent.trim());
  const expectedProductPrices = ["1000 Ft", "2000 Ft", "1500 Ft"];

  if (
    productPrices.length === expectedProductPrices.length &&
    productPrices.every(
      (price, index) => price === expectedProductPrices[index],
    )
  ) {
    console.log(
      "06. Teszt: Termék árak ellenőrzése a táblázatban: Siker (SUCCESS)",
    );
  } else {
    console.error("06. Teszt: Hiba, a termék árak ellenőrzése a táblázatban");
  }
}
/* Készítsünk további min. 5 tesztet! */

// 07. Teszt: Táblázat sorainak száma (fejléccel együtt 4 sor kell legyen)
function testTableRowCount() {
  const tableRows = document.querySelectorAll("#myTable tr");
  const expectedRowCount = 4; // 1 fejléc + 3 adat sor

  if (tableRows.length === expectedRowCount) {
    console.log("07. Teszt: Táblázat sorainak száma: Siker (SUCCESS)");
  } else {
    console.error("07. Teszt: Hiba, a táblázat sorainak száma nem megfelelő");
  }
}

// 08. Teszt: A h2 elem tartalmának ellenőrzése
function testH2Content() {
  const h2Elem = document.querySelector("h2");
  if (h2Elem && h2Elem.textContent.includes("JS egység teszt")) {
    console.log("08. Teszt: A h2 címe megfelelő: Siker (SUCCESS)");
  } else {
    console.error(
      "08. Teszt: Hiba, a h2 címe hibás vagy az elem nem található",
    );
  }
}

// 09. Teszt: A táblázat fejlécének ellenőrzése (Termék neve, Ár (Ft), Mennyiség (db))
function testTableHeaders() {
  const headers = document.querySelectorAll("#myTable th");
  if (
    headers.length >= 3 &&
    headers[0].textContent.trim() === "Termék neve" &&
    headers[1].textContent.trim() === "Ár (Ft)" &&
    headers[2].textContent.trim() === "Mennyiség (db)"
  ) {
    console.log("09. Teszt: A táblázat fejléce megfelelő: Siker (SUCCESS)");
  } else {
    console.error("09. Teszt: Hiba, a táblázat fejléce eltér a várttól");
  }
}

// 10. Teszt: Táblázat border-collapse tulajdonságának ellenőrzése
function testTableCollapse() {
  const table = document.querySelector("#myTable");
  const computedStyles = window.getComputedStyle(table);
  const collapse = computedStyles.getPropertyValue("border-collapse");
  if (collapse === "collapse") {
    console.log(
      "10. Teszt: A táblázat szegélyei össze vannak vonva (collapse): Siker (SUCCESS)",
    );
  } else {
    console.error("10. Teszt: Hiba, a táblázat szegélyei nincsenek összevonva");
  }
}

// 11. Teszt: A táblázat celláinak (td) belső margójának (padding) ellenőrzése
function testTableCellsPadding() {
  const td = document.querySelector("#myTable td");
  if (!td) {
    console.error("11. Teszt: Hiba, nem található táblázat cella");
    return;
  }
  const computedStyles = window.getComputedStyle(td);
  const padding = computedStyles.getPropertyValue("padding");
  if (padding === "10px") {
    console.log(
      "11. Teszt: A táblázat celláinak padding-je 10px: Siker (SUCCESS)",
    );
  } else {
    console.error("11. Teszt: Hiba, a táblázat celláinak padding-je nem 10px");
  }
}

document.addEventListener("DOMContentLoaded", function () {
  testSubHeadingStyle();
  testTitleStyle();
  testTableBorders();
  testCustomHeadingStyle();
  testProductNames();
  testProductPrices();

  testTableRowCount();
  testH2Content();
  testTableHeaders();
  testTableCollapse();
  testTableCellsPadding();
});
