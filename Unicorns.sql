/*Unicorn Trends 2019 - 2021 */

/* 1st CTE joins all data neeeded filtering only the years needed*/
WITH complete_data AS ( 
Select c.company_id, c.company, f.valuation, i.industry, EXTRACT(YEAR FROM	d.date_joined) AS year
FROM public.companies c
INNER JOIN public.funding f 
	ON f.company_id = c.company_id
INNER JOIN public.industries i
	ON i.company_id = f.company_id
INNER JOIN public.dates d 
	ON d.company_id = c.company_id
WHERE EXTRACT(YEAR FROM d.date_joined) IN (2019, 2020, 2021)
),

/*2nd CTE groups our data by industry & year to count # of companies within each 
industry and to calculate avg valuation of each industry*/
grouped_data AS (
SELECT industry,year, COUNT(company) AS num_unicorns, ROUND(AVG(valuation/1000000000),2) AS average_valuation_billions
FROM complete_data
GROUP BY 1,2),

/*3rd cte ranks each industry by the # of unicorns it has each year. Will rank from 1-3 for each year with 1 being the top rank*/
ranked_data AS (
SELECT RANK() OVER(PARTITION BY year ORDER BY num_unicorns DESC) AS rank, industry, year, num_unicorns, average_valuation_billions
FROM grouped_data)

/* Final query selects top 3 industries per year*/
SELECT rank, industry, year, num_unicorns, average_valuation_billions
FROM ranked_data
WHERE rank IN (1,2,3)
ORDER BY year DESC, rank ASC
