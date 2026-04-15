// 01. Teszt: a subheading osztállyal rendelkező elem betűmérete 20px-e?
function testSubHeadingStyle() {
    const subheading = document.querySelector('.subheading');

    const computedStyles = window.getComputedStyle(subheading);
    const actual = computedStyles.getPropertyValue('font-size');
    const expected = '20px';

    if (actual === expected) {
        console.log('01. Teszt: Az alcím stílusának ellenőrzése: Siker (Success)');
    } else {
        console.error('01. Teszt: Hiba, az alcím stílusának ellenőrzése: FAIL ');
    }
}

// 02. Teszt: title osztállyal rendelkező elem ellenőrzése mérete és középre igazítása
// CC szabályszegés- mert egyszerre két dolgot ellenőriz
// Megoldás: két külön teszt text-align és font-size
function testTitleStyle() {
    const title = document.querySelector('.title');

    const computedStyles = window.getComputedStyle(title);
    const textAlign = computedStyles.getPropertyValue('text-align');
    const fontSize = computedStyles.getPropertyValue('font-size');

    const expectedTextAlign = 'center'; // Várhatóan középre igazítva
    const expectedFontSize = '35px'; // Várhatóan 35 képpont méretű

    if (textAlign === expectedTextAlign && fontSize === expectedFontSize) {
        console.log('02. Teszt: A címsor stílusának ellenőrzése: Siker (Success)');
    } else {
        console.error('02. Teszt: Hiba, A címsor stílusának ellenőrzése');
    }
}

// 03. Teszt: táblázat szegélyeinek ellenőrzése (mindegyik sornál van -e folytonos 1px vastag szegély)
// BOM miatt ctrl+0 - alapértelmezett mérete lesz az oldalnak 1px solid - 0.8 solid nagyítástnál pld.
function testTableBorders() {
    const table = document.querySelector('table');
    const th = table.querySelectorAll('th');
    const td = table.querySelectorAll('td');

    let hasBorder = true;

    th.forEach((thElem) => {
        const computedStyles = window.getComputedStyle(thElem);
        const border = computedStyles.getPropertyValue('border');
        console.log(border);

        if (!border.includes('1px solid')) {
            hasBorder = false;
        }
    });

    td.forEach((tdElem) => {
        const computedStyles = window.getComputedStyle(tdElem);
        const border = computedStyles.getPropertyValue('border');
        console.log(border);
        if (!border.includes('1px solid')) {
            hasBorder = false;
        }
    });

    if (hasBorder) {
        console.log('03. Teszt: A táblázat szegélyeinek ellenőrzése: Siker (SUCCESS)');
    } else {
        console.error('03. Teszt: Hiba, a táblázat szegélyeinek ellenőrzése (FAIL)');
    }
}

// 04. Teszt: h2 címsor - inline formázásának ellenőrzése: dőlt -e "JS egység teszt"
function testCustomHeadingStyle() {
    const customHeading = document.querySelector('h2');
    const style = customHeading.getAttribute('style');

    if (style.includes('font-style: italic;')) {
        console.log('04. Teszt: Az egyéni alcím stílusának ellenőrzése: Siker (SUCCESS)');
    } else {
        console.error('04. Teszt: Hiba, az egyéni alcím stílusának ellenőrzése');
    }
}

// 05. Teszt: Terméknevek ellenőrzése a táblázatban. Termék 1, Termék 2, Termék 3
function testProductNames() {
    const table = document.querySelector('#myTable');
    const productNames = Array.from(table.querySelectorAll('td:first-child')).map(td => td.textContent.trim());
    const expectedProductNames = ['Termék 1', 'Termék 2', 'Termék 3'];

    if (productNames.length === expectedProductNames.length && productNames.every((name, index) => name === expectedProductNames[index])) {
        console.log('05. Teszt: Terméknevek ellenőrzése a táblázatban: Siker (SUCCESS)');
    } else {
        console.error('05. Teszt: Hiba, A terméknevek ellenőrzése a táblázatban');
    }
}

// 06. Teszt: Termék árak ellenőrzése a táblázatban. 1000 Ft, 2000 Ft, 1500 Ft
function testProductPrices() {
    const table = document.querySelector('#myTable');
    const productPrices = Array.from(table.querySelectorAll('td:nth-child(2)')).map(td => td.textContent.trim());
    const expectedProductPrices = ['1000 Ft', '2000 Ft', '1500 Ft'];

    if (productPrices.length === expectedProductPrices.length && productPrices.every((price, index) => price === expectedProductPrices[index])) {
        console.log('06. Teszt: Termék árak ellenőrzése a táblázatban: Siker (SUCCESS)');
    } else {
        console.error('06. Teszt: Hiba, a termék árak ellenőrzése a táblázatban');
    }
}
/* Készítsünk további min. 5 tesztet! */
document.addEventListener('DOMContentLoaded', function () {
    testSubHeadingStyle();
    testTitleStyle();
    testTableBorders();
    testCustomHeadingStyle();
    testProductNames();
    testProductPrices();

});