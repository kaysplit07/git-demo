name: 'Deploy SQL Failover Group'
run-name: '${{github.actor}} - Deployingto_${{inputs.subscription}}_${{inputs.environment}}'
on:
  workflow_dispatch:
      inputs:
        requesttype:
          type: choice
          required: true
          description: Request Type
          options:
              - Create
              - Remove
          default: "Create"
        primary_server_id:
          type: string
          required: true
          description: Primary SQL Server Resource ID
        secondary_server_id:
          type: string
          required: true
          description: Secondary SQL Server Resource ID
        database_ids:
          type: string
          required: true
          description: Database IDs (comma-separated list)
        subscription:
          type: string
          required: true
          description: Please enter your subcription Name
        location:
          type: choice
          description: Pick the Location
          options:
            - eastus2
            - centralus
        secondary_location:
          type: choice
          description: Pick the Location for secondary
          options:
            - eastus2
            - centralus
          default:
              "centralus"
        environment:
          type: choice
          description: choose the environment
          options:
             - dev
             - qa 
             - UAT
             - Prod
        purpose:
          type: string
          description: Failover Group purpose
          required: true

jobs:
  sql-failover_create:
    if: (github.event.inputs.requestType == 'Create')
    name: 'Deploying - MSSQL Failover Group'
    uses: ./.github/workflows/Createmssqlfailover.yml
    secrets: 
      ARM_CLIENT_ID: ${{secrets.AZURE_CLIENT_ID}}
      ARM_CLIENT_SECRET: ${{secrets.AZURE_CLIENT_SECRET}}
      ARM_SUBSCRIPTION_ID: ${{secrets.AZURE_SUBSCRIPTION_ID}}
      ARM_TENANT_ID: ${{secrets.AZURE_TENANT_ID}}
    with:
      name: 'mssql-failover'
      primary_server_id: '${{inputs.primary_server_id}}'
      secondary_server_id: '${{inputs.secondary_server_id}}'
      database_ids: '${{inputs.database_ids}}'
      location: '${{inputs.location}}'
      secondary_location: '${{inputs.secondary_location}}'
      environment: '${{inputs.environment}}'
      purpose: '${{inputs.purpose}}'

  sql-failover_remove:
    if: (github.event.inputs.requestType == 'Remove')
    name: 'Removing - MSSQL Failover Group'
    uses: ./.github/workflows/Createmssqlfailover.yml
    secrets: 
      ARM_CLIENT_ID: ${{secrets.AZURE_CLIENT_ID}}
      ARM_CLIENT_SECRET: ${{secrets.AZURE_CLIENT_SECRET}}
      ARM_SUBSCRIPTION_ID: ${{secrets.AZURE_SUBSCRIPTION_ID}}
      ARM_TENANT_ID: ${{secrets.AZURE_TENANT_ID}}
    with:
      name: 'mssql-failover'
      primary_server_id: '${{inputs.primary_server_id}}'
      secondary_server_id: '${{inputs.secondary_server_id}}'
      database_ids: '${{inputs.database_ids}}'
      location: '${{inputs.location}}'
      secondary_location: '${{inputs.secondary_location}}'
      environment: '${{inputs.environment}}'
      purpose: '${{inputs.purpose}}'
