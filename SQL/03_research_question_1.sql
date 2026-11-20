/* 1. výzkumná otázka: 
 * Rostou mzdy ve všech odvětvích, nebo v některých letech dochází k jejich poklesu?
 */


/* 2 pomocná CTE, abych mohla spočítat meziroční %ní změnu ve mzdách v jednotlivých odvětvích
 */

WITH wages AS (
	SELECT DISTINCT 
    	tmrpspf."year" ,
    	tmrpspf.industry_branch_code ,
    	tmrpspf.industry_name ,
    	tmrpspf.avg_monthly_wage
	FROM t_monika_rydlova_project_sql_primary_final tmrpspf
	),
wage_comparison AS (	
	SELECT
		w."year" ,
    	w.industry_branch_code ,
    	w.industry_name ,
    	w.avg_monthly_wage,
    	LAG(w.avg_monthly_wage) OVER (
    		PARTITION BY w.industry_branch_code 
    		ORDER BY w."year") AS previous_year_wage 
	FROM wages w
	)
	SELECT 
		wc."year" ,
		wc.industry_branch_code ,
		wc.industry_name ,
		wc.avg_monthly_wage ,
		ROUND(((wc.avg_monthly_wage - wc.previous_year_wage)/wc.previous_year_wage *100)::NUMERIC, 2) 
		AS wage_change_percentage
	FROM wage_comparison wc
	WHERE wc.avg_monthly_wage < wc.previous_year_wage
	ORDER BY wc.industry_branch_code ,
		wc."year" ;


-- průzkum 5-ti největších %ních poklesů

WITH wages AS (
	SELECT DISTINCT 
    	tmrpspf."year" ,
    	tmrpspf.industry_branch_code ,
    	tmrpspf.industry_name ,
    	tmrpspf.avg_monthly_wage
	FROM t_monika_rydlova_project_sql_primary_final tmrpspf
	),
wage_comparison AS (	
	SELECT
		w."year" ,
    	w.industry_branch_code ,
    	w.industry_name ,
    	w.avg_monthly_wage,
    	LAG(w.avg_monthly_wage) OVER (
    		PARTITION BY w.industry_branch_code 
    		ORDER BY w."year") AS previous_year_wage 
	FROM wages w
	)
	SELECT 
		wc."year" ,
		wc.industry_branch_code ,
		wc.industry_name ,
		wc.avg_monthly_wage ,
		ROUND(((wc.avg_monthly_wage - wc.previous_year_wage)/wc.previous_year_wage *100)::NUMERIC, 2) 
		AS wage_change_percentage
	FROM wage_comparison wc
	WHERE wc.avg_monthly_wage < wc.previous_year_wage
	ORDER BY wage_change_percentage ASC
	LIMIT 5;


/* kolik odvětví zaznamenalo alespoň jeden meziroční pokles za sledované období?
 * 16 z 19 odvětví
 */

WITH wages AS (
	SELECT DISTINCT 
    	tmrpspf."year" ,
    	tmrpspf.industry_branch_code ,
    	tmrpspf.industry_name ,
    	tmrpspf.avg_monthly_wage
	FROM t_monika_rydlova_project_sql_primary_final tmrpspf
	),
wage_comparison AS (	
	SELECT
		w."year" ,
    	w.industry_branch_code ,
    	w.industry_name ,
    	w.avg_monthly_wage,
    	LAG(w.avg_monthly_wage) OVER (
    		PARTITION BY w.industry_branch_code 
    		ORDER BY w."year") AS previous_year_wage 
	FROM wages w
	)
	SELECT 
		COUNT(DISTINCT wc.industry_branch_code) AS number_of_branches  -- nepočítá NULL položky
	FROM wage_comparison wc
	WHERE wc.avg_monthly_wage < wc.previous_year_wage;
	

/* která 3 odvětví pokles meziroční pokles nezaznamenala?
 * S, C, Q
 */

WITH wages AS (
	SELECT DISTINCT 
    	tmrpspf."year" ,
    	tmrpspf.industry_branch_code ,
    	tmrpspf.industry_name ,
    	tmrpspf.avg_monthly_wage
	FROM t_monika_rydlova_project_sql_primary_final tmrpspf
	),
wage_comparison AS (	
	SELECT
		w."year" ,
    	w.industry_branch_code ,
    	w.industry_name ,
    	w.avg_monthly_wage,
    	LAG(w.avg_monthly_wage) OVER (
    		PARTITION BY w.industry_branch_code 
    		ORDER BY w."year") AS previous_year_wage 
	FROM wages w
	)
	SELECT 
		wc.industry_branch_code ,
		wc.industry_name
	FROM wage_comparison wc
	WHERE wc.industry_branch_code NOT IN (
		SELECT 
			wc.industry_branch_code
    	FROM wage_comparison wc
    	WHERE wc.avg_monthly_wage < wc.previous_year_wage AND industry_branch_code IS NOT NULL 
    	)
	GROUP BY
		wc.industry_branch_code ,
		wc.industry_name ;
	

