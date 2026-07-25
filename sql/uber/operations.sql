-- Operational & Trip Dynamics

USE uber_db;

-- Traffic bottlenecks
SELECT 
	CASE
		WHEN distance_km < 3 THEN "Very short (Less than 3km)"
        WHEN distance_km BETWEEN 3 AND 10 THEN "Short (3-10km)"
        WHEN distance_km BETWEEN 10.01 AND 25 THEN "Medium (10-25km)"
        ELSE "Long (More than 25km)"
	END AS distance_bucket,
    COUNT(trip_id) AS total_trips,
    ROUND(AVG(duration_mins), 1) AS avg_duration_mins,
    ROUND(AVG(distance_km), 2) AS avg_distance_km,
    ROUND(AVG(duration_mins / NULLIF(distance_km, 0)), 2) AS avg_mins_per_km,
    ROUND(AVG(distance_km / NULLIF(duration_mins / 60.0, 0)), 2) AS avg_speed_kmh
FROM trips
WHERE status = "completed"
	AND duration_mins > 0
    AND distance_km > 0
GROUP BY distance_bucket
ORDER BY distance_bucket;
-- There are no traffic bottlenecks

-- Peak hours & top spatial corridor
SELECT
	HOUR(t.requested_at) AS hour_of_day,
    COUNT(t.trip_id) AS total_requested_trips,
    ROUND(100.0 * SUM(CASE WHEN t.status = "completed" THEN 1 ELSE 0 END) / COUNT(*), 1) as completion_rate_pct,
    ROUND(AVG(t.surge_multiplier), 2) AS avg_surge_multiplier,
    ROUND(SUM(COALESCE(p.amount, 0)), 2) AS total_hourly_revenue
FROM trips t
LEFT JOIN payments p ON t.trip_id = p.trip_id
GROUP BY HOUR(t.requested_at)
ORDER BY total_requested_trips DESC, completion_rate_pct;

SELECT 
	pickup_loc.zone_name AS pickup_location,
    dropoff_loc.zone_name AS dropoff_location,
    COUNT(t.trip_id) AS total_trips,
    ROUND(AVG(t.distance_km), 2) AS avg_distance_km,
    ROUND(AVG(t.duration_mins), 2) AS avg_duration_mins,
    ROUND(SUM(COALESCE(p.amount, 0)), 2) AS total_corridor_revenue
FROM trips t
LEFT JOIN locations pickup_loc ON t.pickup_location_id = pickup_loc.location_id
LEFT JOIN locations dropoff_loc ON t.dropoff_location_id = dropoff_loc.location_id
LEFT JOIN payments p ON t.trip_id = p.trip_id
WHERE t.status = "completed"
GROUP BY pickup_location, dropoff_location
ORDER BY total_trips DESC
LIMIT 10;
-- Many of the trips are from a location to an airport and viceversa