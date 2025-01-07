name: 'Deploy MSSQL Server'
run-name: '${{ github.actor }} - Deploying to_${{ inputs.subscription }}_${{ inputs.environment }}'

on:
  workflow_dispatch:
    inputs:
      requesttype:
        type: choice
        required: true
        description: Select deployment type
        options:
          - Create (New Resource Group)
          - Use Existing Resource Group
        default: Create (New Resource Group)
      subscription:
        type: string
        required: true
        description: Please enter your subscription Name
      location:
        type: choice
        description: Pick the Location
        options:
          - eastus2
          - centralus
      environment:
        type: choice
        description: Choose the environment
        options:
          - dev
          - qa 
          - UAT
          - Prod
      purpose:
        type: string
        required: true
        description: Enter Purpose for app (3-5 char)
      existing_resource_group:
        type: string
        required: false
        description: Enter the name of an **existing resource group** (only if using existing RG)
      subnetname:
        type: string
        required: true
        description: Enter the subnet name for DB endpoints
      dbcollation:
        type: string
        required: false
        description: Specify Collation of the database
        default: SQL_Latin1_General_CP1_CI_AS
      skuname:
        type: choice
        description: Select SKU_NAME used by Database
        options:
          - S0
          - P2
          - Basic
          - ElasticPool
          - BC_Gen5_2
          - HS_Gen4_1
          - GP_S_Gen5_2
          - DW100c
          - DS100
      zoneredundancy:
        type: choice
        options:
          - "false"
          - "true"

jobs:
  Deploying-Resource-Group:
    if: github.event.inputs.requesttype == 'Create (New Resource Group)'
    name: 'Deploying - New Resource Group'
    uses: ./.github/workflows/CreateResourceGroup.yml
    secrets:
      ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      ARM_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
      ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
    with:
      name: 'resource-group'
      subscription: '${{ inputs.subscription }}'
      location: '${{ inputs.location }}'
      environment: '${{ inputs.environment }}'
      purpose: '${{ inputs.purpose }}'

  Deploying-Mssql-Server:
    name: 'Deploying - MSSQL Server'
    uses: ./.github/workflows/Createmssqlserver.yml
    needs: [Deploying-Resource-Group]
    secrets: 
      ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      ARM_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
      ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
      BACKEND_STORAGE_ACCOUNT: ${{ secrets.BACKEND_STORAGE_ACCOUNT }}
      BACKEND_RESOURCE_GROUP: ${{ secrets.BACKEND_RESOURCE_GROUP }}
    with:
      name: 'mssql'
      subscription: '${{ inputs.subscription }}'
      location: '${{ inputs.location }}'
      environment: '${{ inputs.environment }}'
      purpose: '${{ inputs.purpose }}'
      resource_group: '${{ github.event.inputs.requesttype == 'Use Existing Resource Group' && inputs.existing_resource_group || 'resource-group' }}'
      subnetname: '${{ inputs.subnetname }}'
      dbcollation: '${{ inputs.dbcollation }}'
      skuname: '${{ inputs.skuname }}'
      zoneredundancy: '${{ inputs.zoneredundancy }}'
