-- Customer LTV

USE uber_db;

-- User lifetime value
SELECT
	r.rider_id,
    u.name,
    COUNT(t.trip_id) AS total_completed_trips,
    ROUND(SUM(COALESCE(p.amount, 0)), 2) AS lifetime_value_ltv,
    ROUND(AVG(COALESCE(p.amount, 0)), 2) AS avg_spend_per_trip,
    MIN(t.requested_at) AS first_trip_date,
    MAX(t.requested_at) AS latest_trip_date,
    DATEDIFF(MAX(t.requested_at), MIN(t.requested_at)) AS active_tenure_days
FROM riders r
INNER JOIN users u ON r.user_id = u.user_id
INNER JOIN trips t ON r.rider_id = t.rider_id
LEFT JOIN payments p ON t.trip_id = p.trip_id
WHERE t.status = "completed"
GROUP BY r.rider_id, u.name
ORDER BY lifetime_value_ltv DESC;

WITH rider_ltv AS (
	SELECT 
		r.rider_id,
        COUNT(t.trip_id) AS completed_trips,
        SUM(COALESCE(p.amount, 0)) AS total_spend
	FROM riders r
    INNER JOIN trips t ON r.rider_id = t.rider_id
    LEFT JOIN payments p ON t.trip_id = p.trip_id
    WHERE t.status = "completed"
    GROUP BY r.rider_id
)
SELECT 
	COUNT(rider_id) AS total_active_riders,
    ROUND(AVG(total_spend), 2) AS avg_user_ltv,
    ROUND(MAX(total_spend), 2) AS max_user_ltv,
    ROUND(AVG(completed_trips), 1) AS avg_trips_per_rider
FROM rider_ltv;

-- Power-User concentration (80/20)
WITH user_revenue AS (
	SELECT 
		r.rider_id,
        ROUND(SUM(COALESCE(p.amount, 0)), 2) AS total_spend,
        COUNT(t.trip_id) AS total_trips
	FROM riders r
    INNER JOIN trips t ON r.rider_id = t.rider_id
    LEFT JOIN payments p ON t.trip_id = p.trip_id
    WHERE t.status = "completed"
    GROUP BY r.rider_id
),
ranked_users AS (
	SELECT 
		rider_id,
        total_spend,
        total_trips,
        NTILE(10) OVER (ORDER BY total_spend DESC) AS revenue_decile
	FROM user_revenue
)
SELECT
	revenue_decile,
	CASE
		WHEN revenue_decile = 1 THEN "Top 10% (Power Users)"
        WHEN revenue_decile = 2 THEN "Top 10-20% "
        ELSE CONCAT("Decile ", revenue_decile)
	END AS decile_label,
    COUNT(rider_id) AS rider_count,
    ROUND(SUM(total_spend), 2) AS total_decile_revenue,
    ROUND(AVG(total_spend), 2) AS avg_spend_per_rider,
    ROUND(100.0 * SUM(total_spend) / SUM(SUM(total_spend)) OVER(), 2) AS revenue_share_pct
FROM ranked_users
GROUP BY revenue_decile
ORDER BY revenue_decile;