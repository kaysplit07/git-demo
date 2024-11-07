name: 'zLoad Balancer (Call)'
run-name: '${{github.actor}} - Creating Load Balancer'
on:
  workflow_call:
    inputs:
      requestType:
        type: string
        required: false
      location:
        type: string
        required: true
      environment:
        type: string
        required: true
      purpose:
        type: string
        required: false
      purposeRG:
        type: string
        required: false
      RGname:
        type: string
        required: false
      subnetname:
        type: string
        required: false
      sku_name:
        type: string
        required: false
      private_ip_address:
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
  lb-create:
    name: 'Create Azure Load Balancer'
    env:
      ARM_CLIENT_ID:        ${{secrets.ARM_CLIENT_ID}}
      ARM_CLIENT_SECRET:    ${{secrets.ARM_CLIENT_SECRET}}
      ARM_TENANT_ID:        ${{secrets.ARM_TENANT_ID}}
      ARM_SUBSCRIPTION_ID:  ${{secrets.ARM_SUBSCRIPTION_ID}}
      RESOURCE_GROUP_NAME:  ${{secrets.RESOURCE_GROUP_NAME}}
      STORAGE_ACCOUNT_NAME: ${{secrets.STORAGE_ACCOUNT_NAME}}
      ROOT_PATH:            'Azure/Azure-LB'
    runs-on: 
      group: aks-runners
    environment: ${{inputs.environment}}
    defaults:
      run:
        shell: bash
    steps:
      - name: 'Checkout - Load Balancer'
        uses: actions/checkout@v3
      
      - name: Select backend file based on environment
        run: |
          case "${{ inputs.environment }}" in
            dev) cp backend-dev.tf main.tf ;;
            uat) cp backend-uat.tf main.tf ;;
            prod) cp backend-prod.tf main.tf ;;
          esac
        
      - name: 'Terraform Initialize - Load Balancer'
        uses: hashicorp/terraform-github-actions@master
        with:
          tf_actions_version:     latest
          tf_actions_subcommand:  'init'
          tf_actions_working_dir: ${{env.ROOT_PATH}}
          tf_actions_comment:     true 
        env:
          TF_VAR_resource_group_name:      '${{ secrets.RESOURCE_GROUP_NAME }}' 
          TF_VAR_storage_account_name:     '${{ secrets.STORAGE_ACCOUNT_NAME }}' 
          TF_VAR_requesttype:              '${{inputs.requesttype}}'
          TF_VAR_location:                 '${{inputs.location}}'
          TF_VAR_environment:              '${{inputs.environment}}'
          TF_VAR_purpose:                  '${{inputs.purpose}}'
          TF_VAR_purpose_rg:               '${{inputs.purposeRG}}'
          TF_VAR_RGname:                   '${{inputs.RGname}}'
          TF_VAR_subnetname:               '${{inputs.subnetname}}'
          TF_VAR_sku_name:                 '${{inputs.sku_name}}'
          TF_VAR_private_ip_address:       '${{inputs.private_ip_address}}'
      - name: 'Terraform Plan - Load Balancer'
        run: terraform plan -var="environment=${{ inputs.environment }}"
        if: ${{ inputs.requestType == 'Create (with New RG)' || inputs.requestType == 'Create (with Existing RG)' }} 
        uses: hashicorp/terraform-github-actions@master
        with:
          tf_actions_version:     latest
          tf_actions_subcommand:  'plan'
          tf_actions_working_dir: ${{env.ROOT_PATH}}
          tf_actions_comment:     true
        env:
          TF_VAR_resource_group_name:      '${{ secrets.RESOURCE_GROUP_NAME }}' 
          TF_VAR_storage_account_name:      '${{ secrets.STORAGE_ACCOUNT_NAME }}'
          TF_VAR_requesttype:         '${{inputs.requesttype}}'
          TF_VAR_location:            '${{inputs.location}}'
          TF_VAR_environment:         '${{inputs.environment}}'
          TF_VAR_purpose:             '${{inputs.purpose}}'
          TF_VAR_purpose_rg:          '${{inputs.purposeRG}}'
          TF_VAR_RGname:              '${{inputs.RGname}}'
          TF_VAR_subnetname:          '${{inputs.subnetname}}'
          TF_VAR_sku_name:            '${{inputs.sku_name}}'
          TF_VAR_private_ip_address:  '${{inputs.private_ip_address}}'

      - name: 'Terraform Apply - Load Balancer'
        run: terraform apply -auto-approve -var="environment=${{ inputs.environment }}"
        if: ${{ inputs.requestType == 'Create (with New RG)' || inputs.requestType == 'Create (with Existing RG)' }}
        uses: hashicorp/terraform-github-actions@master
        with:
          tf_actions_version:     latest
          tf_actions_subcommand:  'apply'
          tf_actions_working_dir: ${{env.ROOT_PATH}}
          tf_actions_comment:     true
        env:
          TF_VAR_resource_group_name:      '${{ secrets.RESOURCE_GROUP_NAME }}' 
          TF_VAR_storage_account_name:      '${{ secrets.STORAGE_ACCOUNT_NAME }}'
          TF_VAR_requesttype:         '${{inputs.requesttype}}'
          TF_VAR_location:            '${{inputs.location}}'
          TF_VAR_environment:         '${{inputs.environment}}'
          TF_VAR_purpose:             '${{inputs.purpose}}'
          TF_VAR_purpose_rg:          '${{inputs.purposeRG}}'
          TF_VAR_RGname:              '${{inputs.RGname}}'
          TF_VAR_subnetname:          '${{inputs.subnetname}}'
          TF_VAR_sku_name:            '${{inputs.sku_name}}'
          TF_VAR_private_ip_address:  '${{inputs.private_ip_address}}'
      - name: 'Terraform Remove - Load Balancer'
        if: ${{ inputs.requestType == 'Remove' }}
        uses: hashicorp/terraform-github-actions@master
        with:
          tf_actions_version:     latest
          tf_actions_subcommand:  'destroy'
          tf_actions_working_dir: ${{env.ROOT_PATH}}
          tf_actions_comment:     true
        env:
          TF_VAR_resource_group_name:      '${{ secrets.RESOURCE_GROUP_NAME }}' 
          TF_VAR_storage_account_name:      '${{ secrets.STORAGE_ACCOUNT_NAME }}'
          TF_VAR_requesttype:         '${{inputs.requesttype}}'
          TF_VAR_location:            '${{inputs.location}}'
          TF_VAR_environment:         '${{inputs.environment}}'
          TF_VAR_purpose:             '${{inputs.purpose}}'
          TF_VAR_purpose_rg:          '${{inputs.purposeRG}}'
          TF_VAR_RGname:              '${{inputs.RGname}}'
          TF_VAR_subnetname:          '${{inputs.subnetname}}'
          TF_VAR_sku_name:            '${{inputs.sku_name}}'


error
LBCreate.yml" (source branch with sha:e8319ec2bdcb84d88b113f59531277cde037c273)
: a step cannot have both the `uses` and `run` keys
          TF_VAR_private_ip_address:  '${{inputs.private_ip_address}}'
