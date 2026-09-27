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
-- LANDING DATABASE
-- ==================================================================
use role useradmin;

grant role dev_dcm_landing to user kyrie;
grant role test_dcm_landing to user kyrie;
grant role prod_dcm_landing to user kyrie;

use role dev_dcm_landing;
create dcm project dev_landing.admin.landing_dcm;

use role test_dcm_landing;
create dcm project test_landing.admin.landing_dcm;

use role prod_dcm_landing;
create dcm project prod_landing.admin.landing_dcm;

use role useradmin;
revoke role test_dcm_landing from user kyrie;
revoke role prod_dcm_landing from user kyrie;

-- TODO: create a new github repo specifically for landing database then use repo id to create svc accts

use role useradmin;

create user if not exists test_svc_landing_github
type = service
workload_identity = (
type = oidc
issuer = 'https://token.actions.githubusercontent.com'
subject = 'repository_id:1390942328:environment:test'
);

create user if not exists prod_svc_landing_github
type = service
workload_identity = (
type = oidc
issuer = 'https://token.actions.githubusercontent.com'
subject = 'repository_id:1390942328:environment:prod'
);

grant role test_dcm_landing to user test_svc_landing_github;

grant role prod_dcm_landing to user prod_svc_landing_github;


-- temporary granting myself test and prod so that I can manually seed each database
use role useradmin;
grant role test_dcm_landing to user kyrie;
grant role prod_dcm_landing to user kyrie;

-- do the manual seed using data from the seed dir in snowflake-landing repo
-- this is performed using the Snowsight UI to upload tsv files to FISHING_ERP_RAW_DATA_STAGE
use role useradmin;
revoke role test_dcm_landing from user kyrie;
revoke role prod_dcm_landing from user kyrie;