CREATE TABLE t_monika_rydlova_project_SQL_primary_final AS
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
ORDER BY
	year,
	w.industry_branch_code;

