# Snowflake Account Infrastructure

This DCM project provides a **single centralized location for managing account-level Snowflake infrastructure**.

The primary purpose is to ensure that every project has consistently configured **development, test, and production environments**, while enforcing that changes to test and production are made exclusively through CI/CD.

## Purpose

Centralizing account-level infrastructure in one DCM project establishes a consistent environment across development, test, and production.

For each project, the infrastructure DCM creates and manages the corresponding databases, database roles, and access privileges. This ensures that the three environments follow the same structure and security model rather than being independently configured.

The access model also separates **development access from deployment access**:

* Developers can modify objects in the development environment.
* CI/CD service accounts own the deployment roles for test and production.
* Users do not receive permissions that allow them to directly modify test or production objects.
* Changes to test and production must therefore flow through the CI/CD pipeline.

This creates a controlled promotion path:

```text
Developer
    │
    ▼
  DEV
    │
    │ CI/CD
    ▼
  TEST
    │
    │ CI/CD
    ▼
  PROD
```

The infrastructure DCM establishes the roles and privileges that enforce this model, while individual project DCMs manage the application-specific objects within each environment.

## Managed Infrastructure

This project is intended to manage account-level infrastructure such as:

* Databases
* Account roles
* Database roles
* Warehouses
* Network rules
* Grants and role relationships

Application-specific objects such as schemas, tables, views, streams, and tasks are managed by the DCM project belonging to the individual application or data project.
