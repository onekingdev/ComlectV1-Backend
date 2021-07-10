WITH base AS (
  SELECT created_at
  FROM projects
  WHERE type = 'one_off' AND pricing_type = 'fixed' AND payment_schedule = 'Monthly'
)
SELECT 'projects_fixed_monthly_pay'::varchar AS metric,
  (SELECT COUNT(*) FROM base WHERE created_at >= date_trunc('month', now())) AS mtd,
  (SELECT COUNT(*) FROM base WHERE created_at >= date_trunc('year', now())) AS fytd,
  (SELECT COUNT(*) FROM base) AS itd
