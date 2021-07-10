SELECT
  'projects_fixed_share'::varchar AS metric,
  mtd.pct AS mtd,
  fytd.pct AS fytd,
  itd.pct AS itd
FROM
(SELECT
   (COUNT(*)::float / (
     SELECT COUNT(*)
     FROM projects
     WHERE type = 'one_off' AND created_at >= DATE(date_part('year', current_date) || '-' || date_part('month', current_date) || '-01')
   )) * 100 AS pct
 FROM projects
 WHERE type = 'one_off' AND pricing_type = 'fixed' AND
       created_at::date >= DATE(date_part('year', current_date) || '-' || date_part('month', current_date) || '-01')
) AS mtd,
(SELECT
   (COUNT(*)::float / (
     SELECT COUNT(*) FROM projects
     WHERE type = 'one_off' AND created_at::date >= (
       CASE
       WHEN current_date >= DATE(date_part('year', current_date) || '/10/01') THEN
         DATE(date_part('year', current_date) || '/10/01')::text
       ELSE
         DATE((date_part('year', current_date) - 1) || '/10/01')::text
       END
     )::date
   )) * 100 AS pct
 FROM projects
 WHERE type = 'one_off' AND pricing_type = 'fixed' AND
       created_at::date >= (CASE
                            WHEN current_date >= DATE(date_part('year', current_date) || '/10/01') THEN DATE(date_part('year', current_date) || '/10/01')::text
                            ELSE DATE((date_part('year', current_date) - 1) || '/10/01')::text
                            END)::date
) AS fytd,
(SELECT
   (COUNT(*)::float / (
     SELECT COUNT(*) FROM projects WHERE type = 'one_off'
   )) * 100 AS pct
 FROM projects
 WHERE type = 'one_off' AND pricing_type = 'fixed'
) AS itd
