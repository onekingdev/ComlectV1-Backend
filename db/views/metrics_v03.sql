SELECT * FROM metrics_projects_posted
UNION SELECT * FROM metrics_projects_value
UNION SELECT * FROM metrics_projects_share
UNION SELECT * FROM metrics_projects_hourly_share
UNION SELECT * FROM metrics_projects_fixed_share
UNION SELECT * FROM metrics_projects_hourly_pay
UNION SELECT * FROM metrics_projects_hourly_upon_completion_pay
UNION SELECT * FROM metrics_projects_hourly_bi_weekly_pay
UNION SELECT * FROM metrics_projects_hourly_monthly_pay
UNION SELECT * FROM metrics_projects_fixed_pay
UNION SELECT * FROM metrics_projects_fixed_50_50_pay
UNION SELECT * FROM metrics_projects_fixed_upon_completion_pay
UNION SELECT * FROM metrics_projects_fixed_bi_weekly_pay
UNION SELECT * FROM metrics_projects_fixed_monthly_pay
UNION SELECT * FROM metrics_jobs_posted
UNION SELECT * FROM metrics_jobs_value
UNION SELECT * FROM metrics_jobs_share
UNION SELECT * FROM metrics_jobs_upfront_pay
UNION SELECT * FROM metrics_jobs_installment_pay
UNION SELECT * FROM metrics_project_completions
UNION SELECT * FROM metrics_job_completions
UNION SELECT * FROM metrics_time_to_completion
UNION SELECT * FROM metrics_avg_staffing_times
UNION SELECT * FROM metrics_escalated_projects
UNION SELECT * FROM metrics_extended_projects
UNION SELECT * FROM metrics_account_deletions
UNION SELECT * FROM metrics_signups