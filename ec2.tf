name: 'zWindows VM (Call)'
run-name: '${{github.actor}} - Creating App Gateway'
on:
  workflow_call:
    inputs:
      requestType:
        type: string
        required: false
      environment:
        type: string
        required: true
      location:
        type: string
        required: false
      vmsize:
        type: string
        required: false
      purpose:
        type: string
        required: false
      purposeRG:
        type: string
        required: false
      projectou:
        type: string
        required: false
      subnetInfo:
        type: string
        required: false
        description: Combined subnet information in JSON format
        default: '{"subnetNameWVM": "", "subnetNameWVM2": ""}'
      diskSizeGB:
        type: string
        required: false
      diskStorageAccountType:
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
  wvm-create:
    name: 'Create Windows VM'
    env:
      ARM_CLIENT_ID: ${{secrets.ARM_CLIENT_ID}}
      ARM_CLIENT_SECRET: ${{secrets.ARM_CLIENT_SECRET}}
      ARM_TENANT_ID: ${{secrets.ARM_TENANT_ID}}
      ARM_SUBSCRIPTION_ID: ${{secrets.ARM_SUBSCRIPTION_ID}}
      ROOT_PATH: 'Azure/windows-vm'
    runs-on:
      group: aks-runners
    environment: ${{inputs.environment}}
    defaults:
      run:
        shell: bash
    steps:
    - name: 'Checkout - Windows VM (${{ inputs.purpose }})'
      uses: actions/checkout@v3

    - name: 'Parse Subnet Information'
      id: parse_subnet
      run: |
        subnetNameWVM=$(jq -r '.subnetNameWVM' <<< '${{ inputs.subnetInfo }}')
        subnetNameWVM2=$(jq -r '.subnetNameWVM2' <<< '${{ inputs.subnetInfo }}')
        echo "subnetNameWVM=${subnetNameWVM}" >> $GITHUB_ENV
        echo "subnetNameWVM2=${subnetNameWVM2}" >> $GITHUB_ENV

    - name: 'Terraform Initialize - Windows VM (${{ inputs.purpose }})'
      uses: hashicorp/terraform-github-actions@master
      with:
        tf_actions_version: latest
        tf_actions_subcommand: 'init'
        tf_actions_working_dir: ${{env.ROOT_PATH}}
        tf_actions_comment: true
      env:
        TF_VAR_request_type: '${{inputs.requestType}}'
        TF_VAR_location: '${{inputs.location}}'
        TF_VAR_vm_size: '${{inputs.vmsize}}'
        TF_VAR_purpose: '${{inputs.purpose}}'
        TF_VAR_purpose_rg: '${{inputs.purposeRG}}'
        TF_VAR_project_ou: '${{inputs.projectou}}'
        TF_VAR_subnetname_wvm: '${{env.subnetNameWVM}}'
        TF_VAR_subnetname_wvm2: '${{env.subnetNameWVM2}}'
        TF_VAR_disk_size_gb: '${{inputs.diskSizeGB}}'
        TF_VAR_disk_storage_account_type: '${{inputs.diskStorageAccountType}}'
    - name: 'Terraform Plan - Windows VM (${{ inputs.purpose }})'
      uses: hashicorp/terraform-github-actions@master
      with:
        tf_actions_version: latest
        tf_actions_subcommand: 'plan'
        tf_actions_working_dir: ${{env.ROOT_PATH}}
        tf_actions_comment: true
      env:
        TF_VAR_request_type: '${{inputs.requestType}}'
        TF_VAR_location: '${{inputs.location}}'
        TF_VAR_vm_size: '${{inputs.vmsize}}'
        TF_VAR_purpose: '${{inputs.purpose}}'
        TF_VAR_purpose_rg: '${{inputs.purposeRG}}'
        TF_VAR_project_ou: '${{inputs.projectou}}'
        TF_VAR_subnetname_wvm: '${{env.subnetNameWVM}}'
        TF_VAR_subnetname_wvm2: '${{env.subnetNameWVM2}}'
        TF_VAR_disk_size_gb: '${{inputs.diskSizeGB}}'
        TF_VAR_disk_storage_account_type: '${{inputs.diskStorageAccountType}}'
    - name: 'Terraform Apply - Windows VM (${{ inputs.purpose }})'
      uses: hashicorp/terraform-github-actions@master
      with:
        tf_actions_version: latest
        tf_actions_subcommand: 'apply'
        tf_actions_working_dir: ${{env.ROOT_PATH}}
        tf_actions_comment: true
      env:
        TF_VAR_request_type: '${{inputs.requestType}}'
        TF_VAR_location: '${{inputs.location}}'
        TF_VAR_vm_size: '${{inputs.vmsize}}'
        TF_VAR_purpose: '${{inputs.purpose}}'
        TF_VAR_purpose_rg: '${{inputs.purposeRG}}'
        TF_VAR_project_ou: '${{inputs.projectou}}'
        TF_VAR_subnetname_wvm: '${{env.subnetNameWVM}}'
        TF_VAR_subnetname_wvm2: '${{env.subnetNameWVM2}}'
        TF_VAR_disk_size_gb: '${{inputs.diskSizeGB}}'
        TF_VAR_disk_storage_account_type: '${{inputs.diskStorageAccountType}}'
