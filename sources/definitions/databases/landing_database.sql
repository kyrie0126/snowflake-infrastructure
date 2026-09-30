-- ==================================================================
-- DCM ROLE - account level role that owns env's DCM project
-- ==================================================================
-- only account-level roles can own a DCM project
define role {{ env }}_dcm_{{ landing_database }};
grant usage on warehouse {{ warehouse_xs }} to role {{ env }}_dcm_{{ landing_database }};

-- ==================================================================
-- DATABASE
-- ==================================================================
define database {{ env }}_{{ landing_database }};

-- ==================================================================
-- SCHEMA
-- ==================================================================
-- this is where the environment's DCM project will live
define schema {{ env }}_{{ landing_database }}.admin;

grant usage on schema {{ env }}_{{ landing_database }}.admin to database role {{ env }}_{{ landing_database }}.developer;

grant create dcm project on schema {{ env }}_{{ landing_database }}.admin to role {{ env }}_dcm_{{ landing_database }};

-- ==================================================================
-- DATABASE ROLES
-- ==================================================================
define database role {{ env }}_{{ landing_database }}.developer;
define database role {{ env }}_{{ landing_database }}.consumer;

-- ==================================================================
-- DATABASE ROLE HIERARCHY
-- ==================================================================
grant database role {{ env }}_{{ landing_database }}.consumer to database role {{ env }}_{{ landing_database }}.developer;
grant database role {{ env }}_{{ landing_database }}.developer to role {{ env }}_dcm_{{ landing_database }};

-- ==================================================================
-- DATABASE ROLE GRANTS
-- ==================================================================
-- consumer: current grants
grant usage on database {{ env }}_{{ landing_database }} to database role {{ env }}_{{ landing_database }}.consumer;

-- consumer: future grants so it can access items created by developer
grant select on future tables in database {{ env }}_{{ landing_database }} to database role {{ env }}_{{ landing_database }}.consumer;
grant select on future views in database {{ env }}_{{ landing_database }} to database role {{ env }}_{{ landing_database }}.consumer;

-- developer: current grants
grant create schema on database {{ env }}_{{ landing_database }} to database role {{ env }}_{{ landing_database }}.developer; 
grant create table on future schemas in database {{ env }}_{{ landing_database }} to database role {{ env }}_{{ landing_database }}.developer;
grant create view on future schemas in database {{ env }}_{{ landing_database }} to database role {{ env }}_{{ landing_database }}.developer;
grant create stage on future schemas in database {{ env }}_{{ landing_database }} to database role {{ env }}_{{ landing_database }}.developer;
grant create file format on future schemas in database {{ env }}_{{ landing_database }} to database role {{ env }}_{{ landing_database }}.developer;
-- since nothing is created yet and developer will be doing all future creating, no future grants needed


-- ==================================================================
-- EXTERNAL DATA ACCESS - GRADUALLY ADDED OVER TIME AS MORE ROLES NEED ACCESS
-- ==================================================================
-- access should never be granted directly to a user, instead always grant to a role
-- if data is used in another project, grant data access only to the project's dcm owner role to ensure deployment works
grant database role {{ env }}_{{ landing_database }}.consumer to role {{ env }}_dcm_{{ experiment_app }};