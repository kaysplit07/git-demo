name: 'Deploy MSSQL Database'
run-name: '${{ github.actor }} - Deploying to_${{ inputs.subscription }}_${{ inputs.environment }}'

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
        description: Database purpose
        required: true
      db_names:
        type: string
        required: true
        description: Database names list (comma-separated)
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
    if: github.event.inputs.requesttype == 'Create'
    name: 'Deploying - MSSQL Database'
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: latest

      - name: Terraform Init
        run: terraform init

      - name: Terraform Apply
        run: terraform apply -auto-approve
        env:
          ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
          ARM_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
          ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}

  sql-database_remove:
    if: github.event.inputs.requesttype == 'Remove'
    name: 'Removing - MSSQL Database'
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: latest

      - name: Terraform Destroy
        run: terraform destroy -auto-approve
        env:
          ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
          ARM_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
          ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
