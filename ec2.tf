name: 'Deploy MSSQL Database'
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
        server_id:
          type: string
          required: true
          description: SQL Server Resource ID
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
          description: Database purpose
          required: true
        db_name(s):
          type: string
          required: true
          description: Database names List (comma-separated)
        skuname:
          type: choice
          description: Database SKU
          options:
            - S0
            - P2
            - Basic
            - ElasticPool
            - GP_S_Gen5_2
        collation:
          type: string
          required: false
          default: "SQL_Latin1_General_CP1_CI_AS"
        zoneredundancy:
          type: string
          required: false
          default: "false"

jobs:
  sql-database_create:
    if: (github.event.inputs.requestType == 'Create')
    name: 'Deploying - MSSQL Database'
    uses: ./.github/workflows/Createmssqldatabase.yml
    secrets: 
      ARM_CLIENT_ID: ${{secrets.AZURE_CLIENT_ID}}
      ARM_CLIENT_SECRET: ${{secrets.AZURE_CLIENT_SECRET}}
      ARM_SUBSCRIPTION_ID: ${{secrets.AZURE_SUBSCRIPTION_ID}}
      ARM_TENANT_ID: ${{secrets.AZURE_TENANT_ID}}
    with:
      name: 'mssql-db'
      server_id: '${{inputs.server_id}}'
      location: '${{inputs.location}}'
      environment: '${{inputs.environment}}'
      purpose: '${{inputs.purpose}}'
      db_purpose: '${{inputs.db_purpose}}'
      skuname: '${{inputs.skuname}}'
      collation: '${{inputs.collation}}'
      zoneredundancy: '${{inputs.zoneredundancy}}'

  sql-database_remove:
    if: (github.event.inputs.requestType == 'Remove')
    name: 'Removing - MSSQL Database'
    uses: ./.github/workflows/Createmssqldatabase.yml
    secrets: 
      ARM_CLIENT_ID: ${{secrets.AZURE_CLIENT_ID}}
      ARM_CLIENT_SECRET: ${{secrets.AZURE_CLIENT_SECRET}}
      ARM_SUBSCRIPTION_ID: ${{secrets.AZURE_SUBSCRIPTION_ID}}
      ARM_TENANT_ID: ${{secrets.AZURE_TENANT_ID}}
    with:
      name: 'mssql-db'
      server_id: '${{inputs.server_id}}'
      location: '${{inputs.location}}'
      environment: '${{inputs.environment}}'
      purpose: '${{inputs.purpose}}'
      db_purpose: '${{inputs.db_purpose}}'
      skuname: '${{inputs.skuname}}'
      collation: '${{inputs.collation}}'
      zoneredundancy: '${{inputs.zoneredundancy}}'
