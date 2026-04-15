// 3.a Téglalap kerülete, területe
function calcRectangle(a, b) {
  if (a <= 0 || b <= 0) return null;
  return {
    area: a * b,
    perimeter: 2 * (a + b),
  };
}

// 3.b Bruttó ár számítása
function calcGrossPrice(net, vatPercent) {
  if (net < 0 || vatPercent < 0) return null;
  return net * (1 + vatPercent / 100);
}

// 3.c Prímszám ellenőrzése
function isPrime(num) {
  if (num <= 1 || !Number.isInteger(num)) return false;
  for (let i = 2, s = Math.sqrt(num); i <= s; i++) {
    if (num % i === 0) return false;
  }
  return true;
}

// 3.d Szökőév ellenőrzése
function isLeapYear(year) {
  if (year <= 0 || !Number.isInteger(year)) return false;
  return (year % 4 === 0 && year % 100 !== 0) || year % 400 === 0;
}

// 3.e Másodfokú egyenlet megoldása
function solveQuadratic(a, b, c) {
  if (a === 0) throw new Error("Az 'a' értéke nem lehet 0!");
  let d = Math.pow(b, 2) - 4 * a * c;
  if (d < 0) return [];
  if (d === 0) return [-b / (2 * a)];
  return [(-b + Math.sqrt(d)) / (2 * a), (-b - Math.sqrt(d)) / (2 * a)];
}

// 3.f Hatoldalú dobókocka
function rollDice() {
  return Math.floor(Math.random() * 6) + 1;
}

// 3.g Leltárszám generálása: UFJK-20240205-34598
function generateInventoryNumber() {
  const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  let random4Chars = "";
  for (let i = 0; i < 4; i++) {
    random4Chars += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  const d = new Date();
  const dateStr =
    d.getFullYear() +
    String(d.getMonth() + 1).padStart(2, "0") +
    String(d.getDate()).padStart(2, "0");
  let random5Digits = "";
  for (let i = 0; i < 5; i++) {
    random5Digits += Math.floor(Math.random() * 10);
  }
  return `${random4Chars}-${dateStr}-${random5Digits}`;
}

// 3.h Email validátor
function validateEmail(email) {
  const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return re.test(email);
}

// 3.i Mobiltelefon validátor
function validateMobile(phone) {
  // Alap magyar mobil validátor: +36 vagy 06, utána 20/30/70, majd 7 számjegy
  const re = /^(\+36|06)[\s-]?([237]0)[\s-]?(\d{3})[\s-]?(\d{4})$/;
  return re.test(phone);
}
