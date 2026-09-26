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
use role test_dcm_landing