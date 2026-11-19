/* propojení tabulek countries a economies - nejdříve ověřím, zda máme všechny země
 * z tabulky economies i v tabulce countries
 * zjištění - celkem 68 záznamů bez odpovídající hodnoty v countris - zahrnují ekonomické oblasti 
 * s agregovanými údaji i samostané státy/území (př. Kosovo)
 */
 
SELECT DISTINCT e.country 
FROM economies e 
LEFT JOIN countries c ON e.country = c.country
WHERE e."year" BETWEEN 2006 AND 2018
	AND c.country IS NULL;  

/* ověření kolik máme evropských států, které můžeme propojit: 45 * 
 */

SELECT DISTINCT e.country
FROM economies e 
INNER JOIN countries c ON e.country = c.country 
WHERE e."year" BETWEEN 2006 AND 2018
	AND c.continent = 'Europe';

/* ověření zda máme ke všem státům údaje za požadované období 2006-2018:
 * u všech zemí požadovaných 13 let
 */

SELECT 
	e.country,
	count(DISTINCT e."year" ) AS num_years
FROM economies e 
INNER JOIN countries c ON e.country = c.country 
WHERE e."year" BETWEEN 2006 AND 2018
	AND c.continent = 'Europe'
GROUP BY e.country ;


/* kontrola chybějících hodnot GDP, GINI, population:
 * z 585 záznamů: HDP chybí u 37 záznamů, GINI u 124 záznamů a populace je kompletní všude
 * ČR má údaje kompletní
 * chybějící údaje ponechám jako NULL
 */

SELECT 
	e.country,
	count(*) FILTER (WHERE e.gdp IS NULL) AS missing_gdp,  
	count(*) FILTER (WHERE e.gini IS NULL) AS missing_gini,  
	count(*) FILTER (WHERE e.population IS NULL) AS missing_population
FROM economies e 
INNER JOIN countries c ON e.country = c.country 
WHERE e."year" BETWEEN 2006 AND 2018
	AND c.continent = 'Europe'
GROUP BY e.country ;

/* kontrola případných duplicit - zda má každý stát za jeden rok právě jeden záznam:
 * dotqaz vrátil 0 řádků = ověřeno
 */

SELECT 
	e.country,
	e."year" 
FROM economies e 
INNER JOIN countries c ON e.country = c.country 
WHERE e."year" BETWEEN 2006 AND 2018
	AND c.continent = 'Europe'
GROUP BY 
	e.country,
	e."year" 
HAVING COUNT(*) > 1;

/* tzn. mám ověřeno:
 * každá kombinace stát × rok je v propojených datech jedinečná
 * mám 45 evropských států za období 2006–2018
 * každý stát má záznam za všech 13 let
 * chybějící hodnoty HDP a GINI jsem identifikovala a nechám jako NULL
 * sestavím sekundární tabulku viz další SQL file
 */


SELECT 
	e.country,
	e."year",
	e.gdp ,
	e.gini ,
	e.population 
FROM economies e 
INNER JOIN countries c ON e.country = c.country 
WHERE e."year" BETWEEN 2006 AND 2018
	AND c.continent = 'Europe';



