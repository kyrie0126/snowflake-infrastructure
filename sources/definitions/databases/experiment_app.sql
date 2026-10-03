-- ==================================================================
-- DCM ROLE - account level role that owns env's DCM project
-- ==================================================================
-- only account-level roles can own a DCM project
define role {{ env }}_dcm_{{ experiment_app }};
grant usage on warehouse {{ warehouse_xs }} to role {{ env }}_dcm_{{ experiment_app }};

-- ==================================================================
-- DATABASE
-- ==================================================================
define database {{ env }}_{{ experiment_app }};

-- ==================================================================
-- DATABASE ROLES
-- ==================================================================
define database role {{ env }}_{{ experiment_app }}.developer;
define database role {{ env }}_{{ experiment_app }}.consumer;

-- ==================================================================
-- DATABASE ROLE HIERARCHY
-- ==================================================================
grant database role {{ env }}_{{ experiment_app }}.consumer to database role {{ env }}_{{ experiment_app }}.developer;
grant database role {{ env }}_{{ experiment_app }}.developer to role {{ env }}_dcm_{{ experiment_app }};

-- ==================================================================
-- DATABASE GRANTS
-- ==================================================================
grant usage on database {{ env }}_{{ experiment_app }} to database role {{ env }}_{{ experiment_app }}.consumer;

-- ==================================================================
-- SCHEMAS
-- ==================================================================
-- <env>_<database_name>
-- |
-- |- admin         -- DCM project, metadata, and utility procedures
-- |- app           -- Snowflake App Runtime service
-- |- data          -- Application data and supporting tables
-- |- pipeline      -- Transformations supporting application data
-- |- analytics     -- Consumer-facing analytics views


-- ==================================================================
-- SCHEMA: ADMIN
-- ==================================================================
define schema {{ env }}_{{ experiment_app }}.admin
    comment = 'DCM project, metadata, and utility procedures';

grant usage on schema {{ env }}_{{ experiment_app }}.admin to database role {{ env }}_{{ experiment_app }}.developer;
grant create table on schema {{ env }}_{{ experiment_app }}.admin to database role {{ env }}_{{ experiment_app }}.developer;
grant create procedure on schema {{ env }}_{{ experiment_app }}.admin to database role {{ env }}_{{ experiment_app }}.developer;

grant create dcm project on schema {{ env }}_{{ experiment_app }}.admin to role {{ env }}_dcm_{{ experiment_app }};

-- ==================================================================
-- SCHEMA: APP
-- ==================================================================
define schema {{ env }}_{{ experiment_app }}.app
    comment = 'Snowflake App Runtime service';

grant usage on schema {{ env }}_{{ experiment_app }}.app to database role {{ env }}_{{ experiment_app }}.consumer;
-- will need to add more grants here as I figure out what those will be

-- ==================================================================
-- SCHEMA: DATA
-- ==================================================================
define schema {{ env }}_{{ experiment_app }}.data
    comment = 'Application data and supporting tables';

grant usage on schema {{ env }}_{{ experiment_app }}.data to database role {{ env }}_{{ experiment_app }}.developer;
grant create table on schema {{ env }}_{{ experiment_app }}.data to database role {{ env }}_{{ experiment_app }}.developer;

-- ==================================================================
-- SCHEMA: PIPELINE
-- ==================================================================
define schema {{ env }}_{{ experiment_app }}.pipeline
    comment = 'Transformations supporting application data';

grant usage on schema {{ env }}_{{ experiment_app }}.pipeline to database role {{ env }}_{{ experiment_app }}.developer;
grant create view on schema {{ env }}_{{ experiment_app }}.pipeline to database role {{ env }}_{{ experiment_app }}.developer;
grant create dynamic table on schema {{ env }}_{{ experiment_app }}.pipeline to database role {{ env }}_{{ experiment_app }}.developer;
grant create stream on schema {{ env }}_{{ experiment_app }}.pipeline to database role {{ env }}_{{ experiment_app }}.developer;
grant create task on schema {{ env }}_{{ experiment_app }}.pipeline to database role {{ env }}_{{ experiment_app }}.developer;
grant create procedure on schema {{ env }}_{{ experiment_app }}.pipeline to database role {{ env }}_{{ experiment_app }}.developer;
grant create function on schema {{ env }}_{{ experiment_app }}.pipeline to database role {{ env }}_{{ experiment_app }}.developer;

-- ==================================================================
-- SCHEMA: ANALYTICS
-- ==================================================================
define schema {{ env }}_{{ experiment_app }}.analytics
    comment = 'Consumer-facing analytics views';

grant usage on schema {{ env }}_{{ experiment_app }}.analytics to database role {{ env }}_{{ experiment_app }}.consumer;

grant select on future views in schema {{ env }}_{{ experiment_app }}.analytics to database role {{ env }}_{{ experiment_app }}.consumer;

grant create view on schema {{ env }}_{{ experiment_app }}.analytics to database role {{ env }}_{{ experiment_app }}.developer;
