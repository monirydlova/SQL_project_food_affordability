# SQL projekt – Dostupnost základních potravin v České republice

## 1. Cíl projektu

Cílem projektu je analyzovat vývoj průměrných mezd a cen vybraných základních potravin v České republice a vyhodnotit změny jejich dostupnosti v čase.

Analýza se zaměřuje na následující výzkumné otázky:

1. Rostou mzdy ve všech odvětvích, nebo v některých dochází k jejich poklesu?
2. Kolik litrů mléka a kilogramů chleba bylo možné koupit za průměrnou mzdu v prvním a posledním srovnatelném období?
3. Která kategorie potravin vykazuje nejnižší průměrný meziroční procentuální růst cen?
4. Existoval rok, ve kterém růst cen potravin převýšil růst mezd o více než 10 procentních bodů?
5. Existuje souvislost mezi vývojem HDP a změnami mezd a cen potravin ve stejném nebo následujícím roce?

Výstupem projektu budou dvě databázové tabulky obsahující sjednocená data mezd a cen potravin za Českou republiku a doplňující ekonomické ukazatele evropských států.

## 2. Použité datové zdroje

Projekt využívá následující databázové tabulky:

**Data o mzdách:**
- `czechia_payroll` – údaje o mzdách v jednotlivých odvětvích.
- `czechia_payroll_value_type` – číselník typů hodnot.
- `czechia_payroll_calculation` – číselník způsobů výpočtu.
- `czechia_payroll_unit` – číselník jednotek.
- `czechia_payroll_industry_branch` – číselník odvětví.

**Data o cenách potravin:**
- `czechia_price` – cenová pozorování vybraných potravin.
- `czechia_price_category` – číselník potravinových kategorií.
- `czechia_region` – číselník krajů České republiky.

**Doplňující ekonomická data:**
- `countries` – informace o jednotlivých státech.
- `economies` – ekonomické ukazatele, například HDP, GINI koeficient a populace.

Primární údaje o mzdách a cenách potravin pocházejí z otevřených dat České republiky.

## 3. Průzkum a kontrola vstupních dat

Před vytvořením výsledných tabulek byl proveden průzkum struktury a obsahu zdrojových dat.

Kontrola byla zaměřena zejména na:
- dostupná časová období,
- význam jednotlivých sloupců a číselníků,
- výskyt chybějících hodnot,
- četnost a úplnost cenových pozorování,
- regionální členění cenových údajů,
- sezónnost vybraných potravin.

### 3.1 Mzdová data – `czechia_payroll`

Tabulka obsahuje údaje za období **2000–2021**, členěné podle roku, čtvrtletí, odvětví a dalších parametrů.

Při průzkumu byly identifikovány dva typy hodnot:

| Kód | Význam |
|---|---|
| 316 | Průměrný počet zaměstnanců |
| 5958 | Průměrná hrubá mzda |

Ve sloupci `value` bylo identifikováno **3 096 chybějících hodnot (NULL)**. Tyto hodnoty se vyskytují pouze u typu 316.

U hodnot odpovídajících průměrné hrubé mzdě (`value_type_code = 5958`) nebyly zjištěny chybějící hodnoty.

Tabulka dále rozlišuje:
- jednotky měření (Kč a tisíce osob),
- způsob výpočtu (fyzický a přepočtený počet zaměstnanců),
- jednotlivá odvětví.

**Dopad na další zpracování:**

Pro analýzu mezd bude použit typ hodnoty 5958 a odpovídající jednotka Kč.

Před roční agregací bude nutné zvolit konzistentní způsob výpočtu mzdy a ověřit úplnost čtvrtletních údajů.

### 3.2 Cenová data – `czechia_price`

Tabulka obsahuje údaje o cenách vybraných potravin za období **2006–2018**.

Nejstarší dostupné cenové období začíná 2. 1. 2006, poslední končí 16. 12. 2018.

Ve sloupci `value` nebyly zjištěny chybějící hodnoty.

Datová sada obsahuje celkem 27 kategorií potravin, jejichž dostupnost se v jednotlivých letech mírně liší.

#### Četnost cenových pozorování

Průzkum ukázal výrazné změny v počtu cenových období.

| Rok | Počet cenových záznamů | Počet různých cenových období |
|---|---:|---:|
| 2006 | 18 795 | 50 |
| 2007 | 18 042 | 48 |
| 2008 | 17 277 | 46 |
| 2009 | 9 030 | 24 |
| 2010 | 8 265 | 22 |
| 2011 | 4 515 | 12 |
| 2012 | 4 515 | 12 |
| 2013 | 4 515 | 12 |
| 2014 | 4 515 | 12 |
| 2015 | 4 695 | 12 |
| 2016 | 4 695 | 12 |
| 2017 | 4 695 | 12 |
| 2018 | 4 695 | 12 |

Z výsledků vyplývá, že četnost dostupných cenových pozorování se postupně snižovala:

- **2006–2008:** přibližně týdenní sledování.
- **2009–2010:** přibližně dvoutýdenní sledování.
- **2011–2018:** měsíční sledování.

Od roku 2011 obsahuje každý rok 12 různých počátečních dat cenových období.

Rok 2018 má stejné počty cenových záznamů i období jako roky 2015–2017. Z tohoto hlediska není důvod jej automaticky vyřazovat z analýzy.

Rozdílná četnost pozorování bude zohledněna při interpretaci ročních průměrných cen.

### 3.3 Regionální a celorepublikové ceny

Sloupec `region_code` obsahuje kódy jednotlivých krajů a hodnoty `NULL`.

Pro ověření významu těchto hodnot byly porovnány počty cenových záznamů, období a kategorií u obou skupin.

Bylo zjištěno, že:
- obě skupiny mají shodné počty cenových období,
- obě skupiny obsahují stejný počet potravinových kategorií v jednotlivých letech,
- na jeden záznam bez uvedeného regionu připadá 14 regionálních záznamů.

Například v roce 2018:

| Ukazatel | Bez uvedeného regionu | Regionální údaje |
|---|---:|---:|
| Počet záznamů | 313 | 4 382 |
| Počet cenových období | 12 | 12 |
| Počet kategorií | 27 | 27 |

Poměr regionálních a neregionálních záznamů odpovídá počtu 14 krajů České republiky.

Oficiální zdroj ČSÚ rozlišuje celorepublikové a krajské údaje.

Na základě těchto zjištění se předpokládá, že záznamy s `region_code IS NULL` představují celorepublikové ceny.

Tento předpoklad nebylo možné přímo potvrdit z dokumentace transformace původních dat do výukové databáze.

**Pro další analýzu budou použity záznamy s `region_code IS NULL`.**

### 3.4 Dostupnost potravinových kategorií

V letech 2006–2014 obsahují data 26 kategorií potravin.

Od roku 2015 je dostupných 27 kategorií.

Při kontrole úplnosti cenových údajů za rok 2018 bylo zjištěno:

- 26 kategorií obsahuje 12 cenových období.
- Jedna kategorie obsahuje pouze jedno cenové období.

Touto kategorií je **Kapr živý** (`category_code = 2000001`).

#### Sezónnost ceny kapra

Podrobnější průzkum ukázal, že kapr je sledován ve všech letech 2006–2018, avšak pouze v listopadu a prosinci.

Četnost měření se během sledovaného období měnila.

Od roku 2010 obsahují data jedno prosincové cenové měření ročně.

V roce 2009 byla zaznamenána:
- listopadová cena 82,85 Kč/kg,
- prosincová cena 81,14 Kč/kg.

Rozdíl činil 1,71 Kč/kg, tedy přibližně 2,1 % vzhledem k listopadové ceně.

Tato kontrola potvrdila sezónní charakter cenových pozorování kapra.

**Rozhodnutí pro další analýzu:**

Kategorie Kapr živý nebude automaticky vyřazena, protože její ceny jsou dostupné ve všech sledovaných letech.

Při interpretaci meziročního vývoje však bude zohledněno, že její roční cena vychází z omezeného počtu sezónních pozorování.

### 3.5 Společné období cen a mezd

Porovnáním dostupných roků obou datových sad bylo zjištěno:

| Datová sada | Dostupné období |
|---|---|
| Mzdy | 2000–2021 |
| Ceny potravin | 2006–2018 |
| **Společné období** | **2006–2018** |

Pro vytvoření primární výsledné tabulky bylo zvoleno období **2006–2018**.

Toto období umožňuje porovnávat vývoj průměrných mezd a cen potravin za stejné kalendářní roky.

## 4. Příprava dat pro analýzu

*Následující část bude doplněna po vytvoření výsledných databázových tabulek.*

Předpokládaný postup:

1. Výběr odpovídajících mzdových údajů.
2. Agregace čtvrtletních mezd na roční úroveň podle odvětví.
3. Výpočet průměrných ročních cen jednotlivých potravin.
4. Propojení dat mezd a cen podle společného roku.
5. Vytvoření sekundární tabulky ekonomických ukazatelů evropských států.

## 5. Výzkumné otázky a výsledky

*Tato část bude doplněna po dokončení SQL analýz.*

## 6. Závěr

*Tato část bude doplněna po vyhodnocení všech výzkumných otázek.*
