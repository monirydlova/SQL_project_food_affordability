# SQL projekt – Dostupnost základních potravin v České republice

## 1. Cíl projektu

Projekt jsem samostatně zpracovala jako součást kurzu Datová akademie od společnosti Engeto.

Cílem projektu je analyzovat vývoj průměrných mezd a cen vybraných základních potravin v České republice a vyhodnotit změny jejich dostupnosti v čase.

Analýza se zaměřuje na následující výzkumné otázky:

1. Rostou mzdy ve všech odvětvích, nebo v některých dochází k jejich poklesu?
2. Kolik litrů mléka a kilogramů chleba bylo možné koupit za průměrnou mzdu v prvním a posledním srovnatelném období?
3. Která kategorie potravin vykazuje nejnižší průměrný meziroční procentuální růst cen?
4. Existoval rok, ve kterém růst cen potravin převýšil růst mezd o více než 10 procentních bodů?
5. Existuje souvislost mezi vývojem HDP a změnami mezd a cen potravin ve stejném nebo následujícím roce?

Pro zpracování projektu jsem vytvořila dvě databázové tabulky: primární tabulku s údaji o mzdách a cenách potravin v ČR a sekundární tabulku s ekonomickými ukazateli evropských států.

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

**Rozhodnutí pro další zpracování:**

Pro analýzu jsem použila údaje o průměrné hrubé mzdě (`value_type_code = 5958`) a přepočtený způsob výpočtu (`calculation_code = 200`). Ten jsem zvolila proto, aby bylo možné lépe porovnávat mzdy mezi odvětvími bez zkreslení způsobeného rozdílnými pracovními úvazky.

Ověřila jsem, že pro období 2006–2018 jsou dostupná všechna čtyři čtvrtletí a u vybraných mzdových údajů nechybí hodnoty.

Průměrnou měsíční mzdu za jednotlivé roky počítám jako aritmetický průměr čtyř čtvrtletních hodnot.

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

Pro další analýzu jsem vytvořila dvě výsledné databázové tabulky za období 2006–2018.

### 4.1 Primární tabulka – mzdy a ceny potravin

**Tabulka:** `t_monika_rydlova_project_sql_primary_final`

Pro vytvoření primární tabulky jsem nejprve samostatně připravila roční údaje o mzdách a cenách potravin za období 2006–2018.

U mezd jsem pro jednotlivá odvětví vypočítala průměrnou měsíční hrubou mzdu za rok ze čtyř čtvrtletních hodnot. Ponechala jsem také souhrnné mzdy za všechna odvětví, které jsou ve zdrojových datech označené `industry_branch_code IS NULL`.

U potravin jsem vypočítala průměrnou roční cenu jednotlivých kategorií z dostupných cenových pozorování.

Obě datové sady jsem připravila pomocí CTE (`wages` a `prices`) a následně propojila podle společného roku.

Zkontrolovala jsem také propojení s číselníky odvětví a potravin. U všech vyplněných kódů byly nalezeny odpovídající názvy.

**Výsledná tabulka obsahuje 6 840 záznamů** a slouží jako podklad pro analýzu vývoje mezd, cen a dostupnosti potravin v ČR.

### 4.2 Sekundární tabulka – ekonomické údaje evropských států

**Tabulka:** `t_monika_rydlova_project_sql_secondary_final`

Pro vytvoření sekundární tabulky jsem použila údaje z tabulek `economies` a `countries` za období 2006–2018.

Nejdříve jsem ověřila možnost propojení obou tabulek podle názvu země. Zjistila jsem, že 68 unikátních názvů z `economies` nemá odpovídající záznam v `countries`. Jedná se především o souhrnné geografické a ekonomické oblasti, ale také o některé státy a území.

Pro výslednou tabulku jsem proto použila `INNER JOIN` a vybrala pouze evropské státy podle sloupce `continent`.

Získala jsem **45 evropských států**, u kterých jsem ověřila úplnost časového pokrytí a případné duplicity. Každý stát má záznam za všech 13 let a žádná kombinace státu a roku se neopakuje.

Při kontrole chybějících hodnot jsem zjistila:

| Ukazatel | Chybějící záznamy |
|---|---:|
| HDP | 37 |
| GINI koeficient | 124 |
| Populace | 0 |

Chybějící hodnoty jsem ponechala jako `NULL`, abych zachovala ostatní dostupné údaje bez jejich nahrazování odhady.

**Výsledná tabulka obsahuje 585 záznamů** (45 států × 13 let) a zahrnuje HDP, GINI koeficient a počet obyvatel jednotlivých států.

### 4.3 Metodická omezení

Při následné analýze bude potřeba zohlednit několik omezení vstupních dat a zvolené metodiky:

- **Mzdy:** Pracuji s průměrnými hrubými mzdami, ne s čistými příjmy. Výsledky dostupnosti potravin proto budou představovat orientační srovnání.
- **Ceny potravin:** Četnost cenových pozorování se během sledovaného období měnila. Roční průměry tak vycházejí z různého počtu měření.
- **Sezónnost:** U kapra jsou dostupná převážně listopadová a prosincová měření, což může ovlivnit meziroční porovnání.
- **Potravinové kategorie:** Od roku 2015 přibyla jedna kategorie. Při výpočtu meziročních změn bude nutné ověřit dostupnost ceny v předchozím roce.
- **Celorepublikové ceny:** Používám záznamy s `region_code IS NULL`, u kterých na základě průzkumu předpokládám, že představují ceny za celou ČR.
- **Ekonomické údaje:** Některé hodnoty HDP a GINI koeficientu chybí. V sekundární tabulce zůstávají jako `NULL`.

## 5. SQL skripty v repozitáři

Všechny SQL skripty jsou uložené ve složce `SQL`. Kromě finálních dotazů obsahují také průběžné kontroly a moje poznámky k práci s daty.

| Soubor | Obsah |
|---|---|
| `00_data_exploration.sql` | Průzkum zdrojových dat a kontrola jejich úplnosti |
| `01_data_payrol_price.sql` | Příprava a propojení údajů o mzdách a cenách potravin |
| `02_data_countries_economies.sql` | Průzkum ekonomických údajů evropských států |
| `t_monika_rydlova_project_sql_primary_final.sql` | Vytvoření primární tabulky |
| `t_monika_rydlova_project_sql_secondary_final.sql` | Vytvoření sekundární tabulky |

## 6. Výzkumné otázky a výsledky

*Tato část bude doplněna po dokončení SQL analýz.*

## 7. Závěr

*Tato část bude doplněna po vyhodnocení všech výzkumných otázek.*
