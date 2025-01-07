name: 'Deploy MSSQL Server'
run-name: '${{github.actor}} - Deployingto_${{inputs.subscription}}_${{inputs.environment}}'
on:
    workflow_dispatch:
     inputs:
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
          required: true
          description: Enter Purpose for app (3-5 char)
        subnetname:
          type: string
          required: true
          description: Enter the subnet name for db end points
        dbcollation:
          type: string
          required: false
          description: Specify Collation of the database
          default: SQL_Latin1_General_CP1_CI_AS
        skuname:
          type: choice
          description: select SKU_NAME used by Database
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
    name: 'Deploying - resource-group'
    uses: ./.github/workflows/CreateResourceGroup.yml
    secrets:
      ARM_CLIENT_ID: ${{secrets.AZURE_CLIENT_ID}}
      ARM_CLIENT_SECRET: ${{secrets.AZURE_CLIENT_SECRET}}
      ARM_SUBSCRIPTION_ID: ${{secrets.AZURE_SUBSCRIPTION_ID}}
      ARM_TENANT_ID: ${{secrets.AZURE_TENANT_ID}}

    with:
      name: 'resource-group'
      subscription: '${{inputs.subscription}}'
      location: '${{inputs.location}}'
      environment: '${{inputs.environment}}'
      purpose: '${{inputs.purpose}}'
  Deploying-Mysql-server:
    name: 'Deploying - MSSQL server'
    uses: ./.github/workflows/Createmssqlserver.yml
    needs: Deploying-Resource-Group
    secrets: 
      ARM_CLIENT_ID: ${{secrets.AZURE_CLIENT_ID}}
      ARM_CLIENT_SECRET: ${{secrets.AZURE_CLIENT_SECRET}}
      ARM_SUBSCRIPTION_ID: ${{secrets.AZURE_SUBSCRIPTION_ID}}
      ARM_TENANT_ID: ${{secrets.AZURE_TENANT_ID}}
      BACKEND_STORAGE_ACCOUNT: ${{secrets.BACKEND_STORAGE_ACCOUNT}}
      BACKEND_RESOURCE_GROUP: ${{secrets.BACKEND_RESOURCE_GROUP}}
    with:
      name: 'mssql'
      subscription: '${{inputs.subscription}}'
      location: '${{inputs.location}}'
      environment: '${{inputs.environment}}'
      purpose: '${{inputs.purpose}}'
      subnetname: '${{inputs.subnetname}}'
      dbcollation: '${{inputs.dbcollation}}'
      skuname: '${{inputs.skuname}}'
      zoneredundancy: '${{inputs.zoneredundancy}}'



##################

name: '- Deploy Load Balancer'
run-name: 'Load Balancer - ${{ inputs.environment }} purpose: ${{ inputs.purpose }} : ${{ inputs.requesttype }}'

on:
  workflow_dispatch:
    inputs:
      requesttype:
        type: choice
        required: true
        description: Request Type
        options:
            - Create (with New RG)
            - Create (with Existing RG)
            - Remove (Destroy LB)
        default: 
            "Create (with New RG)"
      environment:
        type: choice
        required: true
        description: Environment
        options:
        - DEV
        - UAT
        - QA
        - PROD
      location:
        type: choice
        required: true
        description: Deployment Location
        options:
            - Select the location
            - eastus2
            - uksouth
            - centralus
            - ukwest
      purposeRG:
        type: string
        required: true
        description: Resource Group Purpose. Hyphen designates an existing RG
      sku:
        type: choice
        required: false
        description: SKU Type for the Load Balancer
        options:
            - Basic
            - Standard
        default: "Standard"
      private_ip:
        type: string
        required: false
        description: Private IP address for the Load Balancer frontend configuration (if applicable)
      subnetName:
        type: string
        required: true
        description: Subnet name for the network interface

jobs:
  resource_group:
    if: (github.event.inputs.requesttype == 'Create (with New RG)')
    name: 'Resource Group ${{ inputs.purposeRG }}'
    uses: ./.github/workflows/CreateResourceGroup.yml
    secrets:
      ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      ARM_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
      ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
    with:
      name: 'resource-group'
      subscription: 'SNow Input'
      environment: '${{ inputs.environment }}'
      location: '${{ inputs.location }}'
      purpose: '${{ inputs.purposeRG }}'

  load_balancer_new_rg:
    if: (github.event.inputs.requesttype == 'Create (with New RG)')
    name: 'Load Balancer ${{ inputs.purpose }}'
    uses: ./.github/workflows/LBCreate.yml
    needs: resource_group
    secrets:
      ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      ARM_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
      ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
    with:
      requesttype: '${{ inputs.requesttype }}'
      environment: '${{ inputs.environment }}'
      location: '${{ inputs.location }}'
      purposeRG: '${{ inputs.purposeRG }}'
      sku: '${{ inputs.sku }}'
      private_ip: '${{ inputs.private_ip }}'
      subnetName: '${{ inputs.subnetName }}'

  load_balancer_existing_rg:
    if: (github.event.inputs.requesttype == 'Create (with Existing RG)')
    name: 'Load Balancer ${{ inputs.purpose }}'
    uses: ./.github/workflows/LBCreate.yml
    secrets:
      ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      ARM_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
      ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
    with:
      requesttype: '${{ inputs.requesttype }}'
      environment: '${{ inputs.environment }}'
      location: '${{ inputs.location }}'
      purposeRG: '${{ inputs.purposeRG }}'
      sku: '${{ inputs.sku }}'
      private_ip: '${{ inputs.private_ip }}'
      subnetName: '${{ inputs.subnetName }}'

  load_balancer_remove:
    if: (github.event.inputs.requesttype == 'Remove (Destroy LB)')
    name: 'Remove Load Balancer ${{ inputs.purpose }}'
    uses: ./.github/workflows/LBRemove.yml
    secrets:
      ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      ARM_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
      ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
    with:
      requesttype: '${{ inputs.requesttype }}'
      environment: '${{ inputs.environment }}'
      location: '${{ inputs.location }}'
      purposeRG: '${{ inputs.purposeRG }}'
      sku: '${{ inputs.sku }}'
      private_ip: '${{ inputs.private_ip }}'
      subnetName: '${{ inputs.subnetName }}'
