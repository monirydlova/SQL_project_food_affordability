--průměrná roční mzda z kvartálních hodnot

SELECT 
	cp.payroll_year ,
	cp.industry_branch_code ,
	avg(cp.value) AS avg_annual_wage
FROM czechia_payroll cp
WHERE cp.value_type_code = '5958'
	AND cp.calculation_code = '200'
	AND cp.payroll_year BETWEEN '2006' AND '2018'
GROUP BY cp.payroll_year, 
		cp.industry_branch_code 
ORDER BY cp.payroll_year, cp.industry_branch_code;

/* u každého roku jsou i NULL hodnoty v industry_branch_code, ověřím jejich význam,
 * zda jsou to průměrné hodnoty za celé odvětví - např pro rok 2018 viz níže.
 * Ověřeno následně i z dat ČSÚ, kvartální hodnoty přesně odpovídají, celoroční se liší pouze
 * o 8 Kč.
 */

SELECT 
	cp.payroll_year ,
	cp.industry_branch_code ,
	avg(cp.value) AS avg_annual_wage
FROM czechia_payroll cp
WHERE cp.value_type_code = '5958'
	AND cp.calculation_code = '200'
	AND cp.payroll_year = '2018'
	AND cp.industry_branch_code IS NULL 
GROUP BY cp.payroll_year, 
		cp.industry_branch_code 
ORDER BY cp.payroll_year, cp.industry_branch_code;


SELECT 
	cp.payroll_year ,
	cp.payroll_quarter ,
	cp.industry_branch_code ,
	cp.value
FROM czechia_payroll cp
WHERE cp.value_type_code = '5958'
	AND cp.calculation_code = '200'
	AND cp.payroll_year = '2018'
	AND cp.industry_branch_code IS NULL 
ORDER BY cp.payroll_year, cp.industry_branch_code;

/* získání i názvu odvětví propojením tabulek - výsledkem dotazu jsou roční průměrné mzdy 
 * podle odvětví včetně souhrnné mzdy za ČR
 */

SELECT 
	cp.payroll_year ,
	cp.industry_branch_code ,
	cpib."name" ,
	avg(cp.value) AS avg_annual_wage
FROM czechia_payroll cp
LEFT JOIN czechia_payroll_industry_branch cpib ON cp.industry_branch_code = cpib.code 
WHERE cp.value_type_code = '5958'
	AND cp.calculation_code = '200'
	AND cp.payroll_year BETWEEN 2006 AND 2018
GROUP BY cp.payroll_year, 
		cp.industry_branch_code,
		cpib."name" 
ORDER BY cp.payroll_year, cp.industry_branch_code;


-- příprava ročních průměrných cen z tabulky czechia_price

SELECT
	EXTRACT(YEAR FROM cp.date_from) AS year,
	cp.category_code,
	cpc.name,
	avg(cp.value) AS avg_annual_price	
FROM czechia_price cp 
LEFT JOIN czechia_price_category cpc ON cp.category_code = cpc.code
WHERE cp.region_code IS NULL 
GROUP BY 
	year,
	cp.category_code,
	cpc.name
ORDER BY YEAR, cp.category_code;


/* vytvoření CTEs (wages, prices) a propojení podle roku,
 * pomocí WHERE jsem skontrolovala, že všude, kde je zadaný kód odvětví a kód potravin, jsou také
 * vyplněny názvy 
 */

WITH wages AS (
	SELECT 
		cp.payroll_year ,
		cp.industry_branch_code ,
		cpib."name" ,
		avg(cp.value) AS avg_monthly_wage
	FROM czechia_payroll cp
	LEFT JOIN czechia_payroll_industry_branch cpib ON cp.industry_branch_code = cpib.code 
	WHERE cp.value_type_code = '5958'
		AND cp.calculation_code = '200'
		AND cp.payroll_year BETWEEN 2006 AND 2018
	GROUP BY 
		cp.payroll_year, 
		cp.industry_branch_code,
		cpib."name" 
	),
prices AS (
	SELECT
		EXTRACT(YEAR FROM cp.date_from) AS year,
		cp.category_code,
		cpc.name,
		avg(cp.value) AS avg_annual_price	
	FROM czechia_price cp 
	LEFT JOIN czechia_price_category cpc ON cp.category_code = cpc.code
	WHERE cp.region_code IS NULL 
	GROUP BY 
		year,
		cp.category_code,
		cpc.name
	)
SELECT 
	w.payroll_year AS YEAR,
	w.industry_branch_code,
	w."name" as industry_name,
	w.avg_monthly_wage,
	p.category_code ,
	p.name AS category_name,
	p.avg_annual_price 
FROM wages w
JOIN prices p ON w.payroll_year = p."year" 
WHERE p.name IS NULL 
	AND p.category_code IS NOT NULL
ORDER BY
	year,
	w.industry_branch_code;


