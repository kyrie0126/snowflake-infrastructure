-- ============================================================================
-- CREATE DCM PROJECTS
-- ============================================================================
-- Unfortunately, you can't use a DCM project to create DCM projects
-- So this workflow will always require the following during DCM setup:
-- 1. manual assignment of dev/test/prod dcm roles to a user
-- 2a. use dcm role
-- 2b. create dcm project in environment's admin schema
-- 3. revoke test/prod dcm roles from user
-- 4. create service users for test and prod

-- ==================================================================
-- EXPERIMENT_APP DATABASE
-- ==================================================================
use role useradmin;

grant role dev_dcm_experiment_app to user kyrie;
grant role test_dcm_experiment_app to user kyrie;
grant role prod_dcm_experiment_app to user kyrie;

use role dev_dcm_experiment_app;
create dcm project dev_experiment_app.admin.experiment_app_dcm;

use role test_dcm_experiment_app;
create dcm project test_experiment_app.admin.experiment_app_dcm;

use role prod_dcm_experiment_app;
create dcm project prod_experiment_app.admin.experiment_app_dcm;

use role useradmin;
revoke role test_dcm_experiment_app from user kyrie;
revoke role prod_dcm_experiment_app from user kyrie;

-- TODO: create a new github repo specifically for experiment_app database then use repo id to create svc accts

use role useradmin;

create user if not exists test_svc_experiment_app_github
type = service
workload_identity = (
type = oidc
issuer = 'https://token.actions.githubusercontent.com'
subject = 'repository_id:1397656315:environment:test'
);

create user if not exists prod_svc_experiment_app_github
type = service
workload_identity = (
type = oidc
issuer = 'https://token.actions.githubusercontent.com'
subject = 'repository_id:1397656315:environment:prod'
);

grant role test_dcm_experiment_app to user test_svc_experiment_app_github;

grant role prod_dcm_experiment_app to user prod_svc_experiment_app_github;