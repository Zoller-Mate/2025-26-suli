-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Gép: 127.0.0.1
-- Létrehozás ideje: 2025. Nov 12. 10:13
-- Kiszolgáló verziója: 10.4.28-MariaDB
-- PHP verzió: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Adatbázis: `meseorszag`
--
CREATE DATABASE IF NOT EXISTS `meseorszag` DEFAULT CHARACTER SET utf8 COLLATE utf8_hungarian_ci;
USE `meseorszag`;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `batorsag`
--

CREATE TABLE `batorsag` (
  `fokozat` int(11) NOT NULL,
  `minosites` varchar(50) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- A tábla adatainak kiíratása `batorsag`
--

INSERT INTO `batorsag` (`fokozat`, `minosites`) VALUES
(1, 'Gyáva féreg'),
(2, 'Nyúlszívű'),
(3, 'Ijedős'),
(4, 'Megfontolt'),
(5, 'Szokványos'),
(6, 'Bátor'),
(7, 'Rettenthetetlen'),
(8, 'Vakmerő'),
(9, 'Eszement');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `borzasztosag`
--

CREATE TABLE `borzasztosag` (
  `fokozat` int(11) NOT NULL,
  `minosites` varchar(50) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- A tábla adatainak kiíratása `borzasztosag`
--

INSERT INTO `borzasztosag` (`fokozat`, `minosites`) VALUES
(1, 'Szeretnivaló, barátságos'),
(2, 'Mosolyognivaló'),
(3, 'Unalmas'),
(4, 'Érdekes'),
(5, 'Kicsit Ijesztő'),
(6, 'Hátborzongató'),
(7, 'Félelmetes'),
(8, 'Rettenetes'),
(9, 'Iszonyatos');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `kiraly`
--

CREATE TABLE `kiraly` (
  `kiralykod` varchar(50) NOT NULL,
  `nev` varchar(50) NOT NULL,
  `vagyon` int(11) NOT NULL,
  `eletkor` int(11) NOT NULL,
  `cimer` varchar(12) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- A tábla adatainak kiíratása `kiraly`
--

INSERT INTO `kiraly` (`kiralykod`, `nev`, `vagyon`, `eletkor`, `cimer`) VALUES
('REX ALFONZ', 'Gazdag Alfonz Nagyherceg', 420000, 43, 'Alma'),
('REX FELIX', 'I. Félix Király', 30000, 56, 'Oroszlán'),
('REX FREDERIC', 'Rettegett Frederik', 8000, 55, 'Kard'),
('REX FRIDRICH', 'IV. Potrohos Frigyes Király', 65000, 84, 'Sas'),
('REX VALDEMAR', 'IV. Kolduskirály Valdemár', 10, 63, 'Rózsa');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `kiralylany`
--

CREATE TABLE `kiralylany` (
  `nev` varchar(50) NOT NULL,
  `apa` varchar(12) NOT NULL,
  `eletkor` int(11) NOT NULL,
  `szepseg` int(11) NOT NULL,
  `fogvatarto` varchar(30) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- A tábla adatainak kiíratása `kiralylany`
--

INSERT INTO `kiralylany` (`nev`, `apa`, `eletkor`, `szepseg`, `fogvatarto`) VALUES
('Aranyfürtös Amália', 'REX ALFONZ', 18, 6, 'Lovagpörkölő'),
('Kacskalábú Kamilla', 'REX VALDEMAR', 15, 4, 'Vasagyar'),
('Lófogú Eleonóra', 'REX ALFONZ', 21, 1, ''),
('Mosolygós Melinda', 'REX FELIX', 8, 5, ''),
('Pisze Panna', 'REX FELIX', 22, 6, 'K\'ssh Xith\'ng Hos\'har'),
('Szeplős Rozalinda', 'REX VALDEMAR', 17, 5, 'K\'ssh Xith\'ng Hos\'har'),
('Szépséges Kunigunda', 'REX FELIX', 23, 2, 'Hamvasztó Hruxgar'),
('Táncosléptü Tünde', 'REX FREDERIC', 14, 7, ''),
('Tündérszép Ilona', 'REX VALDEMAR', 21, 9, 'Csorbafog'),
('Varkocsos Kasszandra', 'REX FELIX', 13, 8, 'Csorbafog'),
('Vasfogú Hermina', 'REX ALFONZ', 32, 3, ''),
('Világszép Valéria', 'REX FELIX', 19, 9, 'Lovagpörkölő');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `lovag`
--

CREATE TABLE `lovag` (
  `nev` varchar(30) NOT NULL,
  `cimer` varchar(22) NOT NULL,
  `batorsag` int(11) NOT NULL,
  `orszaga` varchar(30) NOT NULL,
  `holgye` varchar(30) NOT NULL,
  `vagyon` int(11) NOT NULL,
  `had` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- A tábla adatainak kiíratása `lovag`
--

INSERT INTO `lovag` (`nev`, `cimer`, `batorsag`, `orszaga`, `holgye`, `vagyon`, `had`) VALUES
('Álmos Vitéz', 'Kakas', 3, 'Teknőc Sziget', 'Vasfogú Hermina', 110, 20),
('Aranylovag', 'Érme', 6, 'Bergengócia', 'Aranyfürtös Amália', 120000, 2800),
('Aranypajzsos Aurél', 'Kettős Kard', 4, 'Bergengócia', 'Tündérszép Ilona', 1200, 400),
('Bősz Botond', 'Buzogány', 7, 'Dombvidék', 'Tündérszép Ilona', 3500, 1400),
('Dalnok Dortmund', 'Lant', 4, 'Kerekerdő', 'Vasfogú Hermina', 50, 600),
('Ezüsthajú Erik', 'Sirály', 6, 'Sirályváros', 'Szépséges Kunigunda', 100, 25),
('Fekete Lovag', 'Kitépett fa', 6, 'Naposföld', 'Tündérszép Ilona', 100, 600),
('Gyorslábú Gevin', 'Ugró nyúl', 2, 'Kerekerdő', 'Aranyfürtös Amália', 12, 100),
('Harcias Hedvig', 'Kétfejű kutya', 5, 'Szélesmező', 'Aranyfürtös Amália', 500, 500),
('Karmazsin Károly', 'Lángoló kard', 3, 'Naposföld', 'Pisze Panna', 400, 2000),
('Lassúész Levente', 'Hajló nád', 7, 'Szélesmező', 'Szeplős Rozalinda', 600, 1100),
('Messzelátó Márton', 'Nyúl és Oroszlán', 4, 'Bergengócia', 'Táncosléptü Tünde', 630, 800),
('Nyakigláb Norbert', 'Kard és Oroszlán', 3, 'Bergengócia', 'Lófogú Eleonóra', 75200, 400),
('Nyúlszívű Ernő', 'Griff és Alma', 1, 'Szélesmező', 'Tündérszép Ilona', 4500, 300),
('Ördöngős Ödön', 'Ördög', 2, 'Naposföld', 'Mosolygós Melinda', 910, 500),
('Páratlan Parszifál', 'Lándzsa', 8, 'Naposföld', 'Világszép Valéria', 1300, 1800),
('Rettenthetetlen Ronaldo', 'Bika', 8, 'Szélesmező', 'Világszép Valéria', 1300, 2500),
('Sárkányszabdaló Sándor', 'Sárkányfarok', 7, 'Bergengócia', 'Táncosléptü Tünde', 10000, 200),
('Tűzszemű Taksony', 'Törött kard', 5, 'Varacskosfölde', 'Aranyfürtös Amália', 900, 400),
('Vasöklű Valdemár', 'Ököl', 5, 'Bergengócia', 'Világszép Valéria', 6300, 3000),
('Vérgőzős Vazul', 'Sárkánykoponya', 9, 'Teknőc Sziget', 'Mosolygós Melinda', 12000, 200),
('Vészterhes Tamás', 'Kondér', 7, 'Sirályváros', 'Világszép Valéria', 3, 900),
('Vörös Lovag', 'Kígyó és sas', 4, 'Naposföld', 'Mosolygós Melinda', 5000, 600);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `orszag`
--

CREATE TABLE `orszag` (
  `orszagnev` varchar(30) NOT NULL,
  `terulet` int(11) NOT NULL,
  `lakossag` int(11) NOT NULL,
  `kiralya` varchar(12) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- A tábla adatainak kiíratása `orszag`
--

INSERT INTO `orszag` (`orszagnev`, `terulet`, `lakossag`, `kiralya`) VALUES
('Bergengócia', 220, 870, 'REX FELIX'),
('Dombvidék', 180, 150, 'REX FRIDRICH'),
('Kerekerdő', 75, 180, 'REX FRIDRICH'),
('Naposföld', 370, 1240, 'REX FREDERIC'),
('Sirályváros', 2, 300, 'REX ALFONZ'),
('Szélesmező', 200, 420, 'REX FRIDRICH'),
('Teknőc Sziget', 89, 110, 'REX ALFONZ'),
('Üveghegység', 131, 2, ''),
('Vadvidék', 132, 231, 'REX FRIDRICH'),
('Varacskosfölde', 120, 1, 'REX VALDEMAR');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `osellensegek`
--

CREATE TABLE `osellensegek` (
  `lovag` varchar(30) NOT NULL,
  `sarkany` varchar(30) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- A tábla adatainak kiíratása `osellensegek`
--

INSERT INTO `osellensegek` (`lovag`, `sarkany`) VALUES
('Aranylovag', 'Csontmorzsoló'),
('Aranylovag', 'Csorbafog'),
('Aranylovag', 'Hamvasztó Hruxgar'),
('Aranylovag', 'K\'ssh Xith\'ng Hos\'har'),
('Aranypajzsos Aurél', 'Csillámpikkely'),
('Aranypajzsos Aurél', 'K\'ssh Xith\'ng Hos\'har'),
('Aranypajzsos Aurél', 'Randagyík'),
('Bősz Botond', 'Csillámpikkely'),
('Bősz Botond', 'Csorbafog'),
('Bősz Botond', 'Lovagpörkölő'),
('Bősz Botond', 'Naghu Xindra'),
('Bősz Botond', 'Vasagyar'),
('Ezüsthajú Erik', 'VérHörpölő'),
('Fekete Lovag', 'K\'ssh Xith\'ng Hos\'har'),
('Fekete Lovag', 'Naghu Xindra'),
('Gyorslábú Gevin', 'Taifouna'),
('Harcias Hedvig', 'Csillámpikkely'),
('Harcias Hedvig', 'Csorbafog'),
('Harcias Hedvig', 'K\'ssh Xith\'ng Hos\'har'),
('Harcias Hedvig', 'Könnyű Szellő'),
('Harcias Hedvig', 'Lovagpörkölő'),
('Harcias Hedvig', 'Randagyík'),
('Harcias Hedvig', 'Taifouna'),
('Harcias Hedvig', 'VérHörpölő'),
('Karmazsin Károly', 'Taifouna'),
('Lassúész Levente', 'Csillámpikkely'),
('Lassúész Levente', 'K\'ssh Xith\'ng Hos\'har'),
('Lassúész Levente', 'Randagyík'),
('Lassúész Levente', 'VérHörpölő'),
('Nyakigláb Norbert', 'K\'ssh Xith\'ng Hos\'har'),
('Nyakigláb Norbert', 'Taifouna'),
('Nyakigláb Norbert', 'VérHörpölő'),
('Nyúlszívű Ernő', 'K\'ssh Xith\'ng Hos\'har'),
('Ördöngős Ödön', 'Csillámpikkely'),
('Ördöngős Ödön', 'Csorbafog'),
('Ördöngős Ödön', 'K\'ssh Xith\'ng Hos\'har'),
('Ördöngős Ödön', 'Lovagpörkölő'),
('Ördöngős Ödön', 'Naghu Xindra'),
('Ördöngős Ödön', 'Randagyík'),
('Páratlan Parszifál', 'K\'ssh Xith\'ng Hos\'har'),
('Páratlan Parszifál', 'Taifouna'),
('Páratlan Parszifál', 'Vasagyar'),
('Rettenthetetlen Ronaldo', 'Taifouna'),
('Rettenthetetlen Ronaldo', 'Vasagyar'),
('Sárkányszabdaló Sándor', 'Csontmorzsoló'),
('Sárkányszabdaló Sándor', 'K\'ssh Xith\'ng Hos\'har'),
('Sárkányszabdaló Sándor', 'Naghu Xindra'),
('Sárkányszabdaló Sándor', 'Randagyík'),
('Sárkányszabdaló Sándor', 'Vasagyar'),
('Sárkányszabdaló Sándor', 'VérHörpölő'),
('Tűzszemű Taksony', 'Lovagpörkölő'),
('Vörös Lovag', 'Csontmorzsoló'),
('Vörös Lovag', 'Könnyű Szellő'),
('Vörös Lovag', 'Lovagpörkölő'),
('Vörös Lovag', 'Taifouna');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `sarkany`
--

CREATE TABLE `sarkany` (
  `nev` varchar(30) NOT NULL,
  `faj` varchar(30) NOT NULL,
  `eletkor` int(11) NOT NULL,
  `borzasztosag` int(11) NOT NULL,
  `testhossz` int(11) NOT NULL,
  `feszkelohely` varchar(30) NOT NULL,
  `nosteny` tinyint(1) NOT NULL,
  `kincs` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- A tábla adatainak kiíratása `sarkany`
--

INSERT INTO `sarkany` (`nev`, `faj`, `eletkor`, `borzasztosag`, `testhossz`, `feszkelohely`, `nosteny`, `kincs`) VALUES
('Csillámpikkely', 'Aranysárkány', 1005, 1, 107, 'Naposföld', 0, 120000),
('Csontmorzsoló', 'Közönséges Hétfejű Sárkány', 97, 7, 29, 'Kerekerdő', 0, 1200),
('Csorbafog', 'Mocsárisárkány', 45, 5, 18, 'Varacskosfölde', 0, 800),
('Fuvallat', 'Keleti Szél Sárkány', 43, 2, 9, 'Teknőc Sziget', 0, 30),
('Hamvasztó Hruxgar', 'Lángköpő Nagyféreg', 575, 8, 38, 'Bergengócia', 0, 95000),
('Könnyű Szellő', 'Keleti Szél Sárkány', 812, 3, 180, 'Teknőc Sziget', 1, 80000),
('K\'ssh Xith\'ng Hos\'har', 'Közönséges Hétfejű Sárkány', 412, 6, 32, 'Üveghegység', 1, 30000),
('Lógónyelv', 'Mocsárisárkány', 144, 4, 32, 'Kerekerdő', 1, 1600),
('Lovagpörkölő', 'Lángköpő Nagyféreg', 302, 5, 30, 'Kerekerdő', 0, 5000),
('Naghu Xindra', 'Őssárkány', 4912, 9, 120, 'Üveghegység', 1, 3200000),
('Randagyík', 'Mocsárisárkány', 44, 4, 8, 'Vadvidék', 0, 40),
('Süsü', 'Bamaba Egyfejű Sárkány', 62, 1, 12, 'Kerekerdő', 0, 10),
('Taifouna', 'Viharsárkány', 132, 7, 41, 'Vadvidék', 1, 2300),
('Vasagyar', 'Közönséges Hétfejű Sárkány', 403, 6, 44, 'Varacskosfölde', 0, 45000),
('VérHörpölő', 'Kilencfejű Sárkány', 187, 7, 28, 'Üveghegység', 1, 8300);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `sarkanyfajta`
--

CREATE TABLE `sarkanyfajta` (
  `sarkanyfaj` varchar(30) NOT NULL,
  `tuzokado` tinyint(1) NOT NULL,
  `emberevo` tinyint(1) NOT NULL,
  `ropkepes` tinyint(1) NOT NULL,
  `fejszam` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- A tábla adatainak kiíratása `sarkanyfajta`
--

INSERT INTO `sarkanyfajta` (`sarkanyfaj`, `tuzokado`, `emberevo`, `ropkepes`, `fejszam`) VALUES
('Aranysárkány', 1, 0, 1, 1),
('Bamaba Egyfejű Sárkány', 0, 0, 0, 1),
('Keleti Szél Sárkány', 1, 0, 1, 1),
('Kilencfejű Sárkány', 1, 1, 0, 9),
('Közönséges Hétfejű Sárkány', 0, 1, 0, 7),
('Lángköpő Nagyféreg', 1, 1, 1, 3),
('Mocsárisárkány', 0, 1, 0, 1),
('Őssárkány', 1, 0, 0, 1),
('Viharsárkány', 0, 0, 1, 5);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `szepseg`
--

CREATE TABLE `szepseg` (
  `fokozat` int(11) NOT NULL,
  `minosites` varchar(20) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- A tábla adatainak kiíratása `szepseg`
--

INSERT INTO `szepseg` (`fokozat`, `minosites`) VALUES
(1, 'Rút banya'),
(2, 'Randa'),
(3, 'Csúnyácska'),
(4, 'Jellegtelen'),
(5, 'Tetszetős'),
(6, 'Csinos'),
(7, 'Szépséges'),
(8, 'Gyönyörű'),
(9, 'Világszép');

--
-- Indexek a kiírt táblákhoz
--

--
-- A tábla indexei `batorsag`
--
ALTER TABLE `batorsag`
  ADD PRIMARY KEY (`fokozat`);

--
-- A tábla indexei `borzasztosag`
--
ALTER TABLE `borzasztosag`
  ADD PRIMARY KEY (`fokozat`);

--
-- A tábla indexei `kiraly`
--
ALTER TABLE `kiraly`
  ADD PRIMARY KEY (`kiralykod`);

--
-- A tábla indexei `kiralylany`
--
ALTER TABLE `kiralylany`
  ADD PRIMARY KEY (`nev`),
  ADD KEY `apa` (`apa`,`szepseg`);

--
-- A tábla indexei `lovag`
--
ALTER TABLE `lovag`
  ADD PRIMARY KEY (`nev`),
  ADD KEY `batorsag` (`batorsag`,`orszaga`,`holgye`);

--
-- A tábla indexei `orszag`
--
ALTER TABLE `orszag`
  ADD PRIMARY KEY (`orszagnev`),
  ADD KEY `kiralya` (`kiralya`);

--
-- A tábla indexei `osellensegek`
--
ALTER TABLE `osellensegek`
  ADD KEY `lovag` (`lovag`,`sarkany`);

--
-- A tábla indexei `sarkany`
--
ALTER TABLE `sarkany`
  ADD PRIMARY KEY (`nev`),
  ADD KEY `feszkelohely` (`feszkelohely`);

--
-- A tábla indexei `sarkanyfajta`
--
ALTER TABLE `sarkanyfajta`
  ADD PRIMARY KEY (`sarkanyfaj`);

--
-- A tábla indexei `szepseg`
--
ALTER TABLE `szepseg`
  ADD PRIMARY KEY (`fokozat`);

--
-- A kiírt táblák AUTO_INCREMENT értéke
--

--
-- AUTO_INCREMENT a táblához `batorsag`
--
ALTER TABLE `batorsag`
  MODIFY `fokozat` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT a táblához `borzasztosag`
--
ALTER TABLE `borzasztosag`
  MODIFY `fokozat` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT a táblához `szepseg`
--
ALTER TABLE `szepseg`
  MODIFY `fokozat` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
