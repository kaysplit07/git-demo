Invalid workflow file: .github/workflows/mysql_server.yml#L74
The workflow is not valid. .github/workflows/mysql_server.yml (Line: 74, Col: 34): Invalid secret, BACKEND_STORAGE_ACCOUNT is not defined in the referenced workflow. .github/workflows/mysql_server.yml (Line: 75, Col: 34): Invalid secret, BACKEND_RESOURCE_GROUP is not defined in the referenced workflow.

###################

name: 'Create MS SQL Server'
run-name: ${{github.actor}}
on:
    workflow_call:
      inputs:
        name:
          type: string
          required: false
        subscription:
            type: string
            required: true
        location:
          type: string
          required: true
        environment:
          type: string
          required: true
        purpose:
          type: string
          required: true
        subnetname:
          type: string
          required: true
        dbcollation:
          type: string
          required: false
        skuname:
          type: string
          required: false
        zoneredundancy:
          type: string
          required: false
      secrets:
        ARM_CLIENT_ID:
          required: true
        ARM_CLIENT_SECRET:
          required: true
        ARM_SUBSCRIPTION_ID:
          required: true
        ARM_TENANT_ID:
          required: true
      # Define storage account where tfstate would be stored.
        BACKEND_STORAGE_ACCOUNT:
          required: true
        BACKEND_RESOURCE_GROUP:
          required: true
env:
 permissions:
 contents: read
jobs:
  mssql-server-reusable-workflow:
    name: 'Creating - MSSQL Server'
    env:
        ARM_CLIENT_ID: ${{secrets.ARM_CLIENT_ID}}
        ARM_CLIENT_SECRET: ${{secrets.ARM_CLIENT_SECRET}}
        ARM_TENANT_ID: ${{secrets.ARM_TENANT_ID}}
        ARM_SUBSCRIPTION_ID: ${{secrets.ARM_SUBSCRIPTION_ID}}
        BACKEND_STORAGE_ACCOUNT: ${{secrets.BACKEND_STORAGE_ACCOUNT}}
        BACKEND_RESOURCE_GROUP: ${{secrets.BACKEND_RESOURCE_GROUP}}
        ROOT_PATH: 'Azure/Azure-LB'
    runs-on: 
      group: aks-runners
    environment: ${{inputs.environment}}
    # Use the Bash shell regardless whether the GitHub Actions runner is ubuntu-latest, macos-latest, or windows-latest
    defaults:
      run:
        shell: bash
        working-directory: 'Azure/Azure-LB'  
    steps:
    # Checkout the repository to the GitHub Actions runner
    - name: 'Checkout - Create MS SQL Server (${{ inputs.purpose }})'
      uses: actions/checkout@v3 
    - name: 'Setup Node.js'
      uses: actions/setup-node@v2
      with:
        node-version: '20'  # Specify the required Node.js version  
    - name: 'Setup Terraform'
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: latest      
    - id: envvars
      name: Set environment variables based on deployment environment
      run: |
          if [ "${{ inputs.environment }}" = "prod" ]; then
            echo "BACKEND_STORAGE_ACCOUNT=${{ secrets.BACKEND_STORAGE_ACCOUNT }}" >> "$GITHUB_ENV"
            echo "BACKEND_RESOURCE_GROUP=${{ secrets.BACKEND_RESOURCE_GROUP }}" >> "$GITHUB_ENV"
          elif [ "${{ inputs.environment }}" = "uat" ]; then
            echo "BACKEND_STORAGE_ACCOUNT=${{ secrets.BACKEND_STORAGE_ACCOUNT }}" >> "$GITHUB_ENV"
            echo "BACKEND_RESOURCE_GROUP=${{ secrets.BACKEND_RESOURCE_GROUP }}" >> "$GITHUB_ENV"
          else
            echo "BACKEND_STORAGE_ACCOUNT=${{ secrets.BACKEND_STORAGE_ACCOUNT }}" >> "$GITHUB_ENV"
            echo "BACKEND_RESOURCE_GROUP=${{ secrets.BACKEND_RESOURCE_GROUP }}" >> "$GITHUB_ENV"
          fi
         
    #Use native github action module with custom args to pass variables to the terraform
    - name: 'Terraform Initialize - MS SQL Server (${{ inputs.purpose }})'
      run: terraform init -backend-config="resource_group_name=$BACKEND_RESOURCE_GROUP" -backend-config="storage_account_name=$BACKEND_STORAGE_ACCOUNT" -backend-config="container_name=terraform-state" -backend-config="key=${{ inputs.environment }}-${{ inputs.purpose }}-terraform.tfstate" -input=false
      env:
        TF_VAR_name:                   '${{inputs.name}}'
        TF_VAR_location:               '${{inputs.location}}'
        TF_VAR_environment:            '${{inputs.environment}}'
        TF_VAR_purpose:                '${{inputs.purpose}}'
        TF_VAR_subnetname:             '${{inputs.subnetname}}'
        TF_VAR_dbcollation:            '${{inputs.dbcollation}}'
        TF_VAR_skuname:                '${{inputs.skuname}}'
        TF_VAR_zoneredundancy:         '${{inputs.zoneredundancy}}'
        TF_VAR_BACKEND_STORAGE_ACCOUNT: ${{secrets.BACKEND_STORAGE_ACCOUNT}}
        TF_VAR_BACKEND_RESOURCE_GROUP:  ${{secrets.BACKEND_RESOURCE_GROUP}}

    - name: Terraform Plan
      uses: hashicorp/terraform-github-actions@master
      with:
       tf_actions_version: latest
       tf_actions_subcommand: 'plan'
       tf_actions_working_dir: ${{env.ROOT_PATH}}
       tf_actions_comment: true
      env: 
        TF_VAR_name: '${{inputs.name}}'
        TF_VAR_location: '${{inputs.location}}'
        TF_VAR_environment: '${{inputs.environment}}'
        TF_VAR_purpose: '${{inputs.purpose}}'
        TF_VAR_subnetname: '${{inputs.subnetname}}'
        TF_VAR_dbcollation: '${{inputs.dbcollation}}'
        TF_VAR_skuname: '${{inputs.skuname}}'
        TF_VAR_zoneredundancy: '${{inputs.zoneredundancy}}'
        TF_VAR_BACKEND_STORAGE_ACCOUNT: ${{secrets.BACKEND_STORAGE_ACCOUNT}}
        TF_VAR_BACKEND_RESOURCE_GROUP:  ${{secrets.BACKEND_RESOURCE_GROUP}}
    - name: Terraform apply
      uses: hashicorp/terraform-github-actions@master
      with:
        tf_actions_version: latest
        tf_actions_subcommand: 'apply'
        tf_actions_working_dir: ${{env.ROOT_PATH}}
        tf_actions_comment: true
      env:
        TF_VAR_name: '${{inputs.name}}'
        TF_VAR_location: '${{inputs.location}}'
        TF_VAR_environment: '${{inputs.environment}}'
        TF_VAR_purpose: '${{inputs.purpose}}'
        TF_VAR_subnetname: '${{inputs.subnetname}}'
        TF_VAR_dbcollation: '${{inputs.dbcollation}}'
        TF_VAR_skuname: '${{inputs.skuname}}'
        TF_VAR_zoneredundancy: '${{inputs.zoneredundancy}}'
        TF_VAR_BACKEND_STORAGE_ACCOUNT: ${{secrets.BACKEND_STORAGE_ACCOUNT}}
        TF_VAR_BACKEND_RESOURCE_GROUP:  ${{secrets.BACKEND_RESOURCE_GROUP}}
    - name: Terraform Destroy
      uses: hashicorp/terraform-github-actions@master
      with:
        tf_actions_version: latest
        tf_actions_subcommand: 'apply'
        tf_actions_working_dir: ${{env.ROOT_PATH}}
        tf_actions_comment: true
      env:
        TF_VAR_name: '${{inputs.name}}'
        TF_VAR_location: '${{inputs.location}}'
        TF_VAR_environment: '${{inputs.environment}}'
        TF_VAR_purpose: '${{inputs.purpose}}'
        TF_VAR_subnetname: '${{inputs.subnetname}}'
        TF_VAR_dbcollation: '${{inputs.dbcollation}}'
        TF_VAR_skuname: '${{inputs.skuname}}'
        TF_VAR_zoneredundancy: '${{inputs.zoneredundancy}}'
        TF_VAR_BACKEND_STORAGE_ACCOUNT: ${{secrets.BACKEND_STORAGE_ACCOUNT}}
        TF_VAR_BACKEND_RESOURCE_GROUP:  ${{secrets.BACKEND_RESOURCE_GROUP}}
    
########################

name: 'Deploy MSSQL Server'
run-name: '${{github.actor}} - Deployingto_${{inputs.subscription}}_${{inputs.environment}}'
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
            - Remove (Destroy SQL)
          default: "Create (with New RG)"
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
    if: ${{ inputs.requesttype == 'Create (with New RG)' }}
    name: 'Deploying - resource-group'
    uses: ./.github/workflows/CreateResourceGroup.yml
    secrets:
      ARM_CLIENT_ID: ${{secrets.AZURE_CLIENT_ID}}
      ARM_CLIENT_SECRET: ${{secrets.AZURE_CLIENT_SECRET}}
      ARM_SUBSCRIPTION_ID: ${{secrets.AZURE_SUBSCRIPTION_ID}}
      ARM_TENANT_ID: ${{secrets.AZURE_TENANT_ID}}
      BACKEND_STORAGE_ACCOUNT:   ${{secrets.BACKEND_STORAGE_ACCOUNT}}
      BACKEND_RESOURCE_GROUP:    ${{secrets.BACKEND_RESOURCE_GROUP}}
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
      BACKEND_STORAGE_ACCOUNT:   ${{secrets.BACKEND_STORAGE_ACCOUNT}}
      BACKEND_RESOURCE_GROUP:    ${{secrets.BACKEND_RESOURCE_GROUP}}
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
      
  Deploying-Mssql-server-existing-rg:
    if: ${{ inputs.requesttype == 'Create (with Existing RG)' }}
    name: 'Deploying - MSSQL Server (Existing RG)'
    uses: ./.github/workflows/Createmssqlserver.yml
    secrets:
      ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      ARM_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
      ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
      BACKEND_STORAGE_ACCOUNT:   ${{secrets.BACKEND_STORAGE_ACCOUNT}}
      BACKEND_RESOURCE_GROUP:    ${{secrets.BACKEND_RESOURCE_GROUP}}
    with:
      name: 'mssql'
      subscription: '${{ inputs.subscription }}'
      location: '${{ inputs.location }}'
      environment: '${{ inputs.environment }}'
      purpose: '${{ inputs.purpose }}'
      subnetname: '${{ inputs.subnetname }}'
      dbcollation: '${{ inputs.dbcollation }}'
      skuname: '${{ inputs.skuname }}'
      zoneredundancy: '${{ inputs.zoneredundancy }}'

  Removing-Mssql-server:
    if: ${{ inputs.requesttype == 'Remove (Destroy SQL)' }}
    name: 'Removing - MSSQL Server'
    uses: ./.github/workflows/Createmssqlserver.yml
    secrets:
      ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      ARM_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
      ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
      BACKEND_STORAGE_ACCOUNT:   ${{secrets.BACKEND_STORAGE_ACCOUNT}}
      BACKEND_RESOURCE_GROUP:    ${{secrets.BACKEND_RESOURCE_GROUP}}
    with:
      name: 'mssql'
      subscription: '${{ inputs.subscription }}'
      location: '${{ inputs.location }}'
      environment: '${{ inputs.environment }}'
      purpose: '${{ inputs.purpose }}'
      subnetname: '${{ inputs.subnetname }}'
      dbcollation: '${{ inputs.dbcollation }}'
      skuname: '${{ inputs.skuname }}'
      zoneredundancy: '${{ inputs.zoneredundancy }}'
