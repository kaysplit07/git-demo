Invalid workflow file: .github/workflows/mysql_server.yml#L84
error parsing called workflow
".github/workflows/mysql_server.yml"
-> "./.github/workflows/Createmssqlserver.yml" (source branch with sha:e2fd7c1b6745760718ff072c752fabe29d748c48)
: You have an error in your yaml syntax on line 53

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
        ROOT_PATH: 'Azure/Azure-LB
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
    
