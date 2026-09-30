-- ==================================================================
-- INFRASTRUCTURE GITHUB REPO - create a new repo dedicated to this DCM project
-- ==================================================================
-- 1. create repo
-- 2. navigate to Settings > Actions > OIDC
-- 3. uncheck default subject claim
-- 4. modify subject claim template as: repository_id, environment
-- 5. save
-- 6. make note of repository_id, usually shown in the default subject claim prefix

-- ==================================================================
-- GITHUB DCM SERVICE USERS - service accounts used for test/prod actions
-- ==================================================================
-- create service accounts for test and prod
-- naming convention: <env>_svc_<project_name>_<service>
use role useradmin;

create user if not exists test_svc_infrastructure_github
type = service
workload_identity = (
type = oidc
issuer = 'https://token.actions.githubusercontent.com'
subject = 'repository_id:1380835041:environment:test'
);

create user if not exists prod_svc_infrastructure_github
type = service
workload_identity = (
type = oidc
issuer = 'https://token.actions.githubusercontent.com'
subject = 'repository_id:1380835041:environment:prod'
);

-- ==================================================================
-- INFRASTRUCTURE DATABASES - create dedicated database/schema to store 
-- the DCM project that is used to setup every future DCM project
-- ==================================================================
-- Note: this is done manually the first time since nothing exists yet
use role sysadmin;

-- create the database
create database if not exists dev_infrastructure;
create database if not exists test_infrastructure;
create database if not exists prod_infrastructure;

-- create a schema where the DCM project can be stored
create schema if not exists dev_infrastructure.admin;
create schema if not exists test_infrastructure.admin;
create schema if not exists prod_infrastructure.admin;

-- ==================================================================
-- DCM INFRASTRUCTURE ROLES
-- ==================================================================
use role useradmin;

-- create the roles that own the DCM projects
create role if not exists dev_dcm_infrastructure;
create role if not exists test_dcm_infrastructure;
create role if not exists prod_dcm_infrastructure;

-- to create a DCM project, a role needs usage on database and create DCM project on schema
use role sysadmin;
grant usage on database dev_infrastructure to role dev_dcm_infrastructure;
grant usage on database test_infrastructure to role test_dcm_infrastructure;
grant usage on database prod_infrastructure to role prod_dcm_infrastructure;

grant create dcm project on schema dev_infrastructure.admin to role dev_dcm_infrastructure;
grant create dcm project on schema test_infrastructure.admin to role test_dcm_infrastructure;
grant create dcm project on schema prod_infrastructure.admin to role prod_dcm_infrastructure;

-- the purpose of these roles is to do exactly what we're doing now, but in a scalable way
-- this means that we need to grant these DCM roles the same privs to do what we've already done
use role sysadmin;

-- priv to create databases
grant create database on account to role dev_dcm_infrastructure;
grant create database on account to role test_dcm_infrastructure;
grant create database on account to role prod_dcm_infrastructure;

-- priv to manage grants (future objects inside a database)
use role securityadmin;
grant manage grants on account to role dev_dcm_infrastructure;
grant manage grants on account to role test_dcm_infrastructure;
grant manage grants on account to role prod_dcm_infrastructure;

-- priv to create warehouses
-- there will only be a single dev/test/prod xs warehouse for now
-- this will make granting usage on warehouses easier
use role sysadmin;
grant create warehouse on account to role dev_dcm_infrastructure;
grant create warehouse on account to role test_dcm_infrastructure;
grant create warehouse on account to role prod_dcm_infrastructure;

-- priv to create dcm roles that will be used for objects within a project
use role securityadmin;
grant create role on account to role dev_dcm_infrastructure;
grant create role on account to role test_dcm_infrastructure;
grant create role on account to role prod_dcm_infrastructure;


-- ==================================================================
-- GRANT DCM INFRASTRUCTURE ROLES TO USERS
-- ==================================================================
use role useradmin;
GRANT ROLE dev_dcm_infrastructure TO USER kyrie;
GRANT ROLE test_dcm_infrastructure TO USER test_svc_infrastructure_github;
GRANT ROLE prod_dcm_infrastructure TO USER prod_svc_infrastructure_github;

-- ============================================================================
-- CREATE DCM PROJECTS
-- ============================================================================
-- Unfortunately, you can't use a DCM project to create DCM projects
-- So this workflow will always require the following during DCM setup:
-- 1. manual assignment of dev/test/prod dcm roles to a user
-- 2a. use dcm role
-- 2b. create dcm project in environment's admin schema
-- 3. revoke test/prod dcm roles from user

grant role test_dcm_infrastructure to user kyrie;
grant role prod_dcm_infrastructure to user kyrie;

use role dev_dcm_infrastructure;
create dcm project dev_infrastructure.admin.infrastructure_dcm;

use role test_dcm_infrastructure;
create dcm project test_infrastructure.admin.infrastructure_dcm;

use role prod_dcm_infrastructure;
create dcm project prod_infrastructure.admin.infrastructure_dcm;

use role useradmin;
revoke role test_dcm_infrastructure from user kyrie;
revoke role prod_dcm_infrastructure from user kyrie;


-- ============================================================================
-- CREATE DESIGNATED DEV/TEST/PROD WAREHOUSES
-- ============================================================================
-- gotta follow the same format at DCM
-- grant myself the test/prod roles
-- use each role to create a warehouse so the roles own them
-- in the future, service users can manage usage