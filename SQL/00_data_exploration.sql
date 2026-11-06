
--prozkoumání tabulky czechia_payroll:

SELECT *
FROM czechia_payroll cp 
LIMIT 20;

SELECT *
FROM czechia_payroll cp 
WHERE cp.value_type_code = '5958';

SELECT DISTINCT cp.payroll_year 
FROM czechia_payroll cp
order BY cp.payroll_year ASC;

SELECT DISTINCT cp.calculation_code 
FROM czechia_payroll cp ;


/* prozkoumání czechia payroll:
 * co je ID (primární klíč)? zřemě identifikátor daného údaje
 * value - zahrnuje i nulové hodnoty (3096 řádků), nulové hodnoty jsou 
 * pouze u value type code 316 (prům. počet osob v odvětví),
 * u value type code 5958 žádné hodnoty nechybí
 * value type code - prim klíč k cz payroll value type
 * (2 hodnoty: 316 - prům počet osob nebo 5958 - prům hrubá mzda)
 * unit code - 2 hodnoty: tis. osob nebo Kč
 * calculation code - 2 hodnoty: fyzický nebo přepočtený, použít přepočtený (na plný
 * úvazek)
 * tzn. přepočtený na celé úvazky
 * industry branch code - odvětví
 * payroll year, quater - zahrnuty roky 2000-2021
 */

/* prozkoumání czechia price:
 * co je ID (primární klíč)? zřemě identifikátor daného údaje
 * value - nejsou nulové hodnoty
 * category code - 27 kategorií potravin, viz tab cz price category
 * date from - date to - určení časového období
 * nejstarší date_from 2006-01-02 do 2018-12-10
 * nejstarší date_to 2006-01-08 do 2018-12-16  
 * region code - viz tab cz region - názvy regionů
 */


/* tzn. společné období pro obě tabulky je od 2006-01-02 do 2018-12-16 tzn.
 * není zahrnutý celý prosinec 2018 (celý 4. kvartál 2018), 
 * data v payrol jsou po kvartálech: rok, quater
 */

SELECT *
FROM czechia_price cp
LIMIT 20;

SELECT MAX(cp.date_to) AS nejstarsi 
FROM czechia_price cp;

SELECT 
	cp.payroll_year ,
	cp.payroll_quarter 
FROM czechia_payroll cp
ORDER BY cp.payroll_year , payroll_quarter ;

-- Další nálezy: 

/* czechia_payroll:
 * calculation code - 2 hodnoty: 100 fyzický nebo 200 přepočtený, použít přepočtený (na plný
 * úvazek)
 * ověřila jsem, že mám pro každý rok a odvětví všechna 4 čtvrtletí: mám od 1Q 2000 
 * do 2Q 2021, tzn. údaje za 2006 až 2018 jsou kompletní 
 * 
 * czechia_price:
 * region code - jsou tam i NULL hodnoty tzn. pravděpodobně tam, kde se jedná o celou ČR
 * jak ověřím, že se opravu jedná o celorepublikové ceny?
 * ověření kolik cenových porovnání (cenových období např. týdnů, ne jen cenových záznamů) existuje 
 * v jednotlivých letech tzn. zda mám zahrnout i celý rok 2018. 
 * počet cenových záznamů během roku: 
 * roky 2006 až 2008: od 18795 do 17277 záznamů, pak počet klesá:
 * roky 2009 -2010: cca 9000 až 8000,
 * roky 2011 až 2018: kolem 4500 až 4700 záznamů
 * 
 * počet různých cenových období během roku (pro mě důležitější údaj):
 * spojení 2 dotazů, výsledná tabulka:
 */

SELECT 
	EXTRACT (YEAR FROM date_from) AS rok,
	count(*) AS pocet_merení,  -- count(*) spočítá všechny řádky i s NULL hocnotou
	count(DISTINCT cp.date_from ) AS pocet_unikatnich_dat_mereni
FROM czechia_price cp 
GROUP BY rok
ORDER BY rok;

/* zjištění:
 Výrazně se změnila četnost sledování cen, z výsledků vidíme:
- 2006–2008: přibližně týdenní sledování.
- 2009–2010: přibližně dvoutýdenní sledování.
- 2011–2018: měsíční sledování.
Vzhledem k rozdílné četnosti měření musím ověřit, zda měření jsou rovnoměrně rozložena
během celého roku. Pokud by například většina měření pocházela z prvního pololetí, mohl by být
roční průměr zkreslený. 

- rok 2018 vypadá kompletně, stejné počty měření i datumů jako v jiných letech,
 */

/* region code - jsou tam i NULL hodnoty tzn. pravděpodobně tam, kde se jedná o celou ČR
 * ověřím, že se opravu jedná o celorepublikové ceny:
 */
SELECT
	EXTRACT (YEAR FROM date_from) AS rok,
	CASE 
		WHEN region_code IS NULL 
		THEN 'cela CR?'
		ELSE 'regionalni'
	END AS typ_zaznamu,
	count(*) AS pocet_mereni,  
	count(DISTINCT cp.date_from ) AS pocet_cenovych_obdobi,
	count(DISTINCT cp.category_code) AS pocet_ruznych_kategorii
FROM czechia_price cp 
GROUP BY 
	rok,
	typ_zaznamu
ORDER BY rok, typ_zaznamu;	

/*zjištění: regiony obsahují přibližně 14x víc záznamů měření, tzn. vypadá to, že hodnoty NULL opravdu 
 * odpovídají celorepublikovým měřením.
 * v každém roce mají obě skupiny stejný počet cenových období
 * počty kategorií se mění z 26 na 27: 
 * 2006–2014: 26 kategorií.
 * 2015–2018: 27 kategorií.
 * tzn. potravina, která se začala sledovat až v roce 2015, nemůže mít meziroční změnu za rok 2015,
 * musím si dát pozor u třetí výzkumné otázky..
 * ověřím, zda jsou všechny kategorie sledovány pravidelneě, měli bycho mít 27x12 období tzn. 324 ale
 * máme jen 313 záznamů. tzn zjistím, kterých potravin se to týká viz níže př. rok 2018
 * 
 */
	
SELECT 
	cp.category_code,
	count(DISTINCT cp.date_from ) AS pocet_cenovych_obdobi
FROM czechia_price cp 
WHERE EXTRACT (YEAR FROM date_from) = '2018' AND cp.region_code IS NULL 
GROUP BY cp.category_code
ORDER BY pocet_cenovych_obdobi ASC;

/* zjištění: počet cenových pbdobí je u všech kategorií stejný (12) jen u kategorie
 * 2000001 (kapr) je jen jedno cenové období, protože se prodává sezonně.
 * Můžu ho ale zahrnout, pokud je sledován pravidelně každý rok v prosinci, ověření:
 */

SELECT 
	EXTRACT (YEAR FROM date_from) AS rok, 
	EXTRACT (MONTH FROM date_from) AS mesic, 
	count(*) AS pocet_mereni, 
	avg(cp.value) AS prumer_cena 
FROM czechia_price cp 
WHERE cp.category_code = 2000001 AND cp.region_code IS NULL 
GROUP BY rok, mesic
ORDER BY rok, mesic;

/* závěr: 
 * v některých rocích je kapr sledován i v listopadu, ale většinou jen v prosinci.
 * avg(value) lze použít
 * Kapr má cenová data ve všech letech 2006–2018. Ale roční ceny kapra nejsou ve všech letech měřeny ve zcela stejném měsíci. 
Při interpretaci meziročních změn je vhodné toto omezení uvést.
 */


/* do README:
 * Analýza cen potravin vychází z dat za období 2006–2018. 
 * Četnost dostupných cenových pozorování se v průběhu let mění: 
 * v letech 2006–2008 je přibližně týdenní, v letech 2009–2010 přibližně dvoutýdenní 
 * a od roku 2011 měsíční. 
 * Data obsahují 26 potravinových kategorií do roku 2014 a 27 kategorií od roku 2015. 
 * Regionální údaje jsou evidovány samostatně od záznamů bez uvedeného regionu ( = celorepubliková data?).
 * Ověření co znamená region NULL:
 * do README: Při analýze cen potravin byly použity záznamy s hodnotou region_code IS NULL. 
 * Na základě struktury dat, shodného časového pokrytí a poměru regionálních a neregionálních záznamů 14 : 1 se 
 * předpokládá, že tyto záznamy představují celorepublikové ceny. 
 * Z oficiálního zdroje ČSÚ: datová sada skutečně obsahuje ceny za jednotlivé kraje i za celou Českou republiku
 * (hodnota 97 - ČR, hodnoty 100 - kraje).  *Z toho vyplývá, že je velmi pravděpodobné, že 
 * region_code IS NULL označuje celorepublikové ceny.
 *
 * do README:
 * Sezónnost cenových dat: 
 * Při kontrole úplnosti cenových údajů bylo zjištěno, že v roce 2018 obsahuje
 * 26 potravinových kategorií 12 cenových období, zatímco kategorie „Kapr živý“ 
 * (kód 2000001) obsahuje pouze jedno cenové období. Tento rozdíl odpovídá sezónnímu charakteru prodeje 
 * této potraviny. Při analýze meziročního vývoje cen bude zohledněna odlišná četnost 
 * jejího sledování.  
 * /


