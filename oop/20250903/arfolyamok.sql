CREATE TABLE exchange_rates (
  datum DATE PRIMARY KEY,
  CHF decimal(10,2),
  EUR decimal(10,2),
  GBP decimal(10,2),
  PLN decimal(10,2),
  RON decimal(10,2),
  RUB decimal(10,2),
  SEK decimal(10,2),
  /* azért kell "TRY", mert különben kulcsszónak érzékeli az SQL */
  `TRY` decimal(10,2),
  UAH decimal(10,2),
  USD decimal(10,2)
);