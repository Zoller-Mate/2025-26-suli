// 2. Feladat a: Magánhangzók százaléka
function getVowelPercentage(text) {
  if (typeof text !== "string") return 0;
  const vowels = text.match(/[aeiouáéíóöőúüűAEIOUÁÉÍÓÖŐÚÜŰ]/g) || [];
  const letters = text.match(/[a-zA-ZáéíóöőúüűÁÉÍÓÖŐÚÜŰ]/g) || [];
  if (letters.length === 0) return 0;
  return (vowels.length / letters.length) * 100;
}

// 2. Feladat b: Jelszó generátor
function generatePassword(length) {
  if (typeof length !== "number" || length <= 0) return "";
  const chars =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  let result = "";
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
}

// 2. Feladat c: Bankszámla validátor (12345678-12345678 vagy 12345678-12345678-12345678)
function validateBankAccount(account) {
  const regex = /^\d{8}-\d{8}(-\d{8})?$/;
  return regex.test(account);
}

// 2. Feladat d: Kedvezményes ár (Név, Bruttó ár, Kedvezmény)
function getDiscountedPrice(name, grossPrice, discountPercent) {
  if (
    typeof grossPrice !== "number" ||
    typeof discountPercent !== "number" ||
    grossPrice < 0 ||
    discountPercent < 0 ||
    discountPercent > 100
  ) {
    return null;
  }
  const discountAmount = grossPrice * (discountPercent / 100);
  const discountedPrice = grossPrice - discountAmount;
  return `${name}: ${discountedPrice} Ft`;
}

// 2. Feladat e: Rendszám validátor (ABC-123 vagy AB-CD-123)
function validateLicensePlate(plate) {
  const regex = /^([A-Z]{3}-\d{3}|[A-Z]{2}-[A-Z]{2}-\d{3})$/;
  return regex.test(plate);
}
