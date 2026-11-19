/* vytvoření tabulky v návaznosti na prozkoumámí dat countries/economies
 * 
 */

CREATE TABLE t_monika_rydlova_project_sql_secondary_final AS(
	SELECT 
		e.country,
		e."year",
		e.gdp ,
		e.gini ,
		e.population 
	FROM economies e 
	INNER JOIN countries c ON e.country = c.country 
	WHERE e."year" BETWEEN 2006 AND 2018
		AND c.continent = 'Europe'
	);




/* ověření počtu záznamů: 585 * 
 */

SELECT COUNT(*)
FROM t_monika_rydlova_project_sql_secondary_final tmrpssf ;


