// ✔ jelzés: "\u2714" vagy "&#x2714;" (HTML entitás formában)
// ❌ jelzés: "\u274C" vagy "&#x274C;" (HTML entitás formában)

// Egységtesztek (unitTest) futtatás
function test(description, callback) {
    try {
        callback();
        console.log(`\u2714 ${description}: SUCCESS`);
    } catch (error) {
        console.log(`\u274C ${description}: FAIL - ${error.message}`);
    }
}

function expect(actual){
    return {
        toBe(expected){
            if (actual !== expected) {
                throw new Error(`Várt érték: ${expected}, kapott érték: ${actual}`);
            }
        },
    };
}

// Függvények deklarálása
function add(a, b) {
    return a + b;
}

function subtract(a, b) {
    return a - b;
}

function multiply(a, b) {
    return a * b;
}

function divide(a, b) {
    if (b === 0) {
        // implicit hibakezelés
        throw new Error('Nullával nem lehet osztani!');
    }
    return a / b;
}

console.log(add(2, 3)); // 5 actual
// expected: 5

// Tesztek futtatása / hívása
test('Összeadás', () => {
    expect(add(2, 3)).toBe(5);
});

test('Kivonás', () => {
    expect(subtract(5, 2)).toBe(3);
});

test('Szorzás', () => {
    expect(multiply(4, 3)).toBe(12);
});

test('Osztás', () => {
    expect(divide(10, 2)).toBe(5);
});

test('Nullával való osztás', () => {
    try {
        divide(10, 0);    
        throw new Error('Nem dobott kivételt a nullával való osztásnál!');
    } catch (error) {
        expect(error.message).toBe('Nullával nem lehet osztani!');
    }
});

// add() a 2 és 3 paraméter Hard Code: Minden egész számot nem írhatunk be -> nincs minden esetet kimerítő teszt
// Eddigiek alap funkció tesztek: adott fv, eljárás azt csinálja -e, ami a dolga
// További teszt ötletek: 
// Értékhatáron túlmutató paraméter add(99999999999999999999999999999999999999999999999999999,999999999999999999999999999)
// Értékhatáron túlmutató paraméter add(-99999999999999999999999999999999999999999999999999999,-999999999999999999999999999)
// Webes app-oknál Request, Response (korábbi CRUD-os példák): egyszerre 1000 kérés, 100.000 kérés, 1.000.0000
// Terheléses tesztek - mem, CPU vizsgálat - külön eszközökkel Tool-okkal
// Security: Biztonsági vizsgálat: űrlapon bekért adat(Login felület) - Backend: Session vizsgálat, SQL injection, CSF

// Tesztelés 2 megközelítése
// 1. Manuális tesztelés: Szükséges művelet, de korlátos a használata - minden esetet nem lehet vizsgálni a komplex app-oknál
// 2. Automata tesztek: közelebb áll a programozás részéhez: ilyeneket készítettünk fentebb
// add() 2 és 3 paraméter helyett szöveges állomány (csv, txt, json) belepakol értékeket: -9999 , 0, 9999, 88
// MOCK DATA - teszt adatok: generált adatok (keretrendszerekkel)
// Űrlapadatok kitöltése MOCK DATA-val...
// Programozó, informatikus, rendszergazda - mindent automatizál
// Tesztelő feladata: 
// 1. Teszt terv készítése
// 2. Teszt adatok előkészítése - akár több millió MOCK DATA előállítása
// 3. Tesztek implementálása, futtasa
// 4. Kapcsolattartás a programozókkal
// 5. Jelentés (report) készítése - összegzés

// SCRUM csapatban: 1-2 frontend, 1-2 backend, 1-2 tesztelő
// 2 hétes sprint - egy új funkció megvalósítása 

// TDD - Test Driven Development: Első lépés törjön el a teszt - folyamatos finomítással jutunk az egyre jobb minőségű kódhoz
// TDD - gyakrabban Backend-en, de általában csak ott ahol magas minőségű sw-re van szükség - banki rendszerek