create database condition_monitoring ;

use condition_monitoring ;

drop table if exists sensor_readings ;
CREATE TABLE sensor_readings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  asset_id VARCHAR(20),
  vibration_mm_s FLOAT,
  temperature_c FLOAT,
  motor_current_a FLOAT,
  reading_time DATETIME
);

CREATE TABLE alert_log (
  alert_id INT AUTO_INCREMENT PRIMARY KEY,
  asset_id VARCHAR(20),
  alert_type VARCHAR(20),
  message VARCHAR(200),
  alert_time DATETIME
);



select *  from sensor_readings  ;

SELECT MAX(temperature_c) as Max_Temp, MIN(temperature_c) as Min_Temp
FROM sensor_readings;
	    
SELECT COUNT(*) as Total_Readings FROM sensor_readings;

#----> See all sensor data (operator view) 
select * from sensor_readings ;

#---> See latest reading (MOST COMMON)
SELECT *
FROM sensor_readings
ORDER BY reading_time DESC
LIMIT 1;

#---> See last 10 readings
select *
from sensor_readings 
order by reading_time desc
limit 10 ;


#--->See data for specific pump
select *
from sensor_readings
where asset_id = 'pump' ;

#----> Average vibration (baseline)
SELECT
  asset_id,
  AVG(vibration_mm_s) AS avg_vibration
FROM sensor_readings
GROUP BY asset_id;

#----> Max temperature (safety check)
select 
    asset_id,
    max(temperature_c) as max_temputure 
from sensor_readings
group by asset_id ;

#---> Readings in last 10 minutes

SELECT *
FROM sensor_readings
WHERE reading_time >= NOW() - INTERVAL 10 MINUTE;

create index idx_sensor_readings
on sensor_readings (reading_time) ;

explain analyze 
SELECT *
FROM sensor_readings
WHERE reading_time >= NOW() - INTERVAL 10 MINUTE;

#----> CONDITION MONITORING (CORE INDUSTRY LOGIC)
#----> Rate of change (MOST IMPORTANT)
select 
    asset_id,
    vibration_mm_s,
    reading_time,
    vibration_mm_s -
    lag(vibration_mm_s) over (partition by asset_id order by reading_time) as vibration_change 
from  sensor_readings ;

#-----> Sudden vibration spike
WITH vib_calc AS (
  SELECT
    asset_id,
		,
    vibration_mm_s -
    LAG(vibration_mm_s) OVER (
      PARTITION BY asset_id ORDER BY reading_time
    ) AS vib_diff
  FROM sensor_readings
)
SELECT *
FROM vib_calc
WHERE vib_diff > 1.5;

#----> Moving average (trend analysis)

select 
    asset_id,
    reading_time,
    avg(vibration_mm_s) over (partition by asset_id order by reading_time
    rows between 5 preceding and current row ) as moving_avg_vibration 
from sensor_readings ;

#---> Latest health status
SELECT
    asset_id,
    vibration_mm_s,
    temperature_c,
    motor_current_a,
    case 
    when vibration_mm_s > 6 then 'CRITICAL'
    when vibration_mm_s > 5 then 'WARNING'
    else 'NORMAL'
   end as health_status,
   reading_time
from sensor_readings 
order by reading_time desc
limit 1 ;


#---> Find unstable pumps
SELECT
  asset_id,
  STDDEV(vibration_mm_s) AS vibration_variation
FROM sensor_readings
GROUP BY asset_id
HAVING vibration_variation > 0.8;


#----> Alert Generation
INSERT INTO alert_log (asset_id, alert_type, message, alert_time)
SELECT
asset_id,
'WARNING',
'Sudden vibration increase detected',
NOW()
FROM (
SELECT
asset_id,
vibration_mm_s -
LAG(vibration_mm_s) OVER (
PARTITION BY asset_id ORDER BY reading_time
) AS diff
FROM sensor_readings
) t
WHERE diff > 1.5;


SELECT * FROM alert_log
ORDER BY alert_time DESC;







