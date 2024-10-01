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
        ROOT_PATH: 'Azure/${{inputs.name}}'
    runs-on: ubuntu-latest
    environment: ${{inputs.environment}}
    # Use the Bash shell regardless whether the GitHub Actions runner is ubuntu-latest, macos-latest, or windows-latest
    defaults:
      run:
        shell: bash

    steps:
    # Checkout the repository to the GitHub Actions runner
    - name: Checkout
      uses: actions/checkout@v3
    - name: Terraform Initialize
      uses: hashicorp/terraform-github-actions@master
      with:
        tf_actions_version: latest
        tf_actions_subcommand: 'init'
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
    
