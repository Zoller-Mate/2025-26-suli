//1. Teszt: van -e bootstrap-es táblázat az oldalon?
function testIsTableExist() {
  const table = document.querySelector(".table");

  if (table) {
    console.log(
      "1. Teszt: A táblázat ellenőrzése (table osztály): SIKER (SUCCESS)",
    );
  } else {
    console.log(
      "1. Teszt: A táblázat ellenőrzése (table osztály): ELTÖRT (FAIL)",
    );
  }
}

//2. Teszt: Táblázat fejléc sorának ellenőrzése (van -e thead és tr (ez van a body-ban is))
// Angular: Hydration: szigorúan ellenőrzi a html szerkezetének szabályosságát
function testTableHeadRow() {
  const tableHeadRow = document.querySelectorAll("thead tr");

  if (tableHeadRow.length === 1) {
    console.log(
      "2. Teszt: A táblázat ellenőrzése (van -e fejléc): SIKER (SUCCESS)",
    );
  } else {
    console.log(
      "2. Teszt: A táblázat ellenőrzése (van -e fejléc): ELTÖRT (FAIL)",
    );
  }
}

//3. Teszt: Adatsorok ellenőrzése: van -e legalább 1 sora a táblázatnak?
function testTableBodyRows() {
  const tableBodyRow = document.querySelectorAll("tbody tr");

  if (tableBodyRow.length > 0) {
    console.log(
      "3. Teszt: A táblázat ellenőrzése (van -e legalább 1 sor): SIKER (SUCCESS)",
    );
  } else {
    console.log(
      "3. Teszt: A táblázat ellenőrzése (van -e legalább 1 sor): ELTÖRT (FAIL)",
    );
  }
}

//4. Teszt: Van -e egyátalán td (cella) a táblázatban?
function testAnyTableCellExsist() {
  const tableCells = document.querySelectorAll("td");

  if (tableCells.length > 0) {
    console.log(
      "4. Teszt: A táblázat ellenőrzése (van -e legalább 1 cellája): SIKER (SUCCESS)",
    );
  } else {
    console.log(
      "4. Teszt: A táblázat ellenőrzése (van -e legalább 1 cellája): ELTÖRT (FAIL)",
    );
  }
}

//Feladatok:
//5. Teszt: A táblázat fejléce tartalmaz -e 3 oszlopot?
function testTableHeadColumns() {
  const headerCols = document.querySelectorAll("thead th");
  if (headerCols.length === 3) {
    console.log(
      "5. Teszt: A táblázat fejléce (van -e 3 oszlop): SIKER (SUCCESS)",
    );
  } else {
    console.log(
      "5. Teszt: A táblázat fejléce (van -e 3 oszlop): ELTÖRT (FAIL)",
    );
  }
}

//6. Teszt: A táblázat betűmérete 14px-e?
function testTableFontSize() {
  const table = document.querySelector(".table");
  const style = window.getComputedStyle(table);
  if (style.fontSize === "14px") {
    console.log("6. Teszt: A táblázat betűmérete (14px): SIKER (SUCCESS)");
  } else {
    console.log("6. Teszt: A táblázat betűmérete (14px): ELTÖRT (FAIL)");
  }
}

//7. Teszt: A táblázat külső margója 10px-e?
function testTableMargin() {
  const table = document.querySelector(".table");
  const style = window.getComputedStyle(table);
  if (
    style.marginTop === "10px" &&
    style.marginRight === "10px" &&
    style.marginBottom === "10px" &&
    style.marginLeft === "10px"
  ) {
    console.log("7. Teszt: A táblázat külső margója (10px): SIKER (SUCCESS)");
  } else {
    console.log("7. Teszt: A táblázat külső margója (10px): ELTÖRT (FAIL)");
  }
}

//8. Teszt: A táblázatban lévő szöveg középre van -e igazítva?
function testTableTextAlign() {
  const table = document.querySelector(".table");
  const style = window.getComputedStyle(table);
  if (style.textAlign === "center") {
    console.log(
      "8. Teszt: A táblázat szöveg igazítása (középre): SIKER (SUCCESS)",
    );
  } else {
    console.log(
      "8. Teszt: A táblázat szöveg igazítása (középre): ELTÖRT (FAIL)",
    );
  }
}

//9. Teszt: Ellenőrizzük le, hogy a custom-heading osztály alsó-külső margója 20px-e?
function testCustomHeadingMarginBottom() {
  const heading = document.querySelector(".custom-heading");
  if (heading) {
    const style = window.getComputedStyle(heading);
    if (style.marginBottom === "20px") {
      console.log(
        "9. Teszt: A custom-heading alsó margója (20px): SIKER (SUCCESS)",
      );
    } else {
      console.log(
        "9. Teszt: A custom-heading alsó margója (20px): ELTÖRT (FAIL)",
      );
    }
  } else {
    console.log(
      "9. Teszt: A custom-heading alsó margója (20px): ELTÖRT (FAIL - elem nem található)",
    );
  }
}

//10. Teszt: Ellenőrizzük, hogy a container osztállyal rendelkező div 2. eleme bekezdés -e (az első h1-es)?
function testContainerSecondChild() {
  const container = document.querySelector(".container");
  if (container && container.children.length >= 2) {
    if (container.children[1].tagName.toLowerCase() === "p") {
      console.log("10. Teszt: A container 2. eleme bekezdés: SIKER (SUCCESS)");
    } else {
      console.log("10. Teszt: A container 2. eleme bekezdés: ELTÖRT (FAIL)");
    }
  } else {
    console.log(
      "10. Teszt: A container 2. eleme bekezdés: ELTÖRT (FAIL - elem nem található)",
    );
  }
}

document.addEventListener("DOMContentLoaded", function () {
  testIsTableExist();
  testTableHeadRow();
  testTableBodyRows();
  testAnyTableCellExsist();
  testTableHeadColumns();
  testTableFontSize();
  testTableMargin();
  testTableTextAlign();
  testCustomHeadingMarginBottom();
  testContainerSecondChild();
});
