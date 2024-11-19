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
      vm_list:
        type: string
        required: false
env:
  permissions:
  contents: read
jobs:
  lb-create:
    name: 'Create Azure Load Balancer'
    env:
      ARM_CLIENT_ID:        ${{secrets.AZURE_CLIENT_ID}}
      ARM_CLIENT_SECRET:    ${{secrets.AZURE_CLIENT_SECRET}}
      ARM_TENANT_ID:        ${{secrets.AZURE_TENANT_ID}}
      ARM_SUBSCRIPTION_ID:  ${{secrets.AZURE_SUBSCRIPTION_ID}}
      ROOT_PATH:            'Azure/Azure-LB'
    runs-on: 
      group: aks-runners
    environment: ${{ inputs.environment }}
    defaults:
      run:
        shell: bash
        working-directory: 'Azure/Azure-LB'
    steps:
      - name: 'Checkout - Load Balancer'
        uses: actions/checkout@v3
      - name: 'Setup Node.js'
        uses: actions/setup-node@v2
        with:
          node-version: 'lts'  # Specify the required Node.js version  
      - name: Validate VM List
        if: ${{ inputs.vm_list == null && (inputs.requestType == 'Create (with New RG)' || inputs.requestType == 'Create (with Existing RG)') }}
        run: |
            echo "Error: vm_list is required for the selected requestType." && exit 1   
      - name: Parse VM List
        id: parse_vm_list
        run: |
          if [ -n "${{ inputs.vm_list }}" ]; then
             echo "VM_LIST=$(echo '${{ inputs.vm_list }}' | jq -c '.')" >> "$GITHUB_ENV"
          else
            echo "VM_LIST=[]" >> "$GITHUB_ENV"
          fi
        env:
          VM_LIST: '${{ inputs.vm_list }}'        
      - name: 'Setup Terraform'
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: latest      
      - id: envvars
        name: Set environment variables based on deployment environment
        run: |
            if [ "${{ inputs.environment }}" = "prod" ]; then
                echo "BACKEND_STORAGE_ACCOUNT=ngpdeus26425st01" >> "$GITHUB_ENV"
                echo "BACKEND_RESOURCE_GROUP=6425-Prod-eus2-main-rg" >> "$GITHUB_ENV"
                echo "TF_VAR_env=prod" >> "$GITHUB_ENV"
            elif [ "${{ inputs.environment }}" = "uat" ]; then
                echo "BACKEND_STORAGE_ACCOUNT=nguteus26425st01" >> "$GITHUB_ENV"
                echo "BACKEND_RESOURCE_GROUP=6425-uat-eus2-main-rg" >> "$GITHUB_ENV"
                echo "TF_VAR_env=uat" >> "$GITHUB_ENV"
            else
                echo "BACKEND_STORAGE_ACCOUNT=6425dveus2aristb01" >> "$GITHUB_ENV"
                echo "BACKEND_RESOURCE_GROUP=test-dev-eus2-testing-rg" >> "$GITHUB_ENV"
                echo "TF_VAR_env=dev" >> "$GITHUB_ENV"
            fi 

      - name: 'Terraform Initialize - Load Balancer'
        run: terraform init -backend-config="resource_group_name=$BACKEND_RESOURCE_GROUP" -backend-config="storage_account_name=$BACKEND_STORAGE_ACCOUNT" -backend-config="container_name=terraform-state" -backend-config="key=${{ inputs.environment }}-lb-terraform.tfstate" -input=false
        env:
          TF_VAR_requesttype:              '${{inputs.requestType}}'
          TF_VAR_location:                 '${{inputs.location}}'
          TF_VAR_environment:              '${{inputs.environment}}'
          TF_VAR_purpose:                  '${{inputs.purpose}}'
          TF_VAR_purpose_rg:               '${{inputs.purposeRG}}'
          TF_VAR_RGname:                   '${{inputs.RGname}}'
          TF_VAR_subnetname:               '${{inputs.subnetname}}'
          TF_VAR_sku_name:                 '${{inputs.sku_name}}'
          TF_VAR_private_ip_address:       '${{inputs.private_ip_address}}'
          TF_VAR_vm_list:                  '${{ env.VM_LIST }}'
      - name: 'Terraform Plan - Load Balancer'
        if: ${{ inputs.vm_list && (inputs.requestType == 'Create (with New RG)' || inputs.requestType == 'Create (with Existing RG)') }}
        #if: ${{ inputs.requestType == 'Create (with New RG)' || inputs.requestType == 'Create (with Existing RG)' }}
        run: terraform plan
        env:
          TF_VAR_requesttype:         '${{inputs.requestType}}'
          TF_VAR_location:            '${{inputs.location}}'
          TF_VAR_environment:         '${{inputs.environment}}'
          TF_VAR_purpose:             '${{inputs.purpose}}'
          TF_VAR_purpose_rg:          '${{inputs.purposeRG}}'
          TF_VAR_RGname:              '${{inputs.RGname}}'
          TF_VAR_subnetname:          '${{inputs.subnetname}}'
          TF_VAR_sku_name:            '${{inputs.sku_name}}'
          TF_VAR_private_ip_address:  '${{inputs.private_ip_address}}'
          TF_VAR_vm_list:             '${{ env.VM_LIST }}'
      - name: 'Terraform Apply - Load Balancer'
       #if: ${{ inputs.requestType == 'Create (with New RG)' || inputs.requestType == 'Create (with Existing RG)' }}
        if: ${{ inputs.vm_list && inputs.requestType == 'Create (with New RG)' }} ||  ${{ inputs.vm_list && inputs.requestType == 'Create (with Existing RG)' }}
        run: terraform apply -auto-approve
        env:
          TF_VAR_requesttype:         '${{inputs.requestType}}'
          TF_VAR_location:            '${{inputs.location}}'
          TF_VAR_environment:         '${{inputs.environment}}'
          TF_VAR_purpose:             '${{inputs.purpose}}'
          TF_VAR_purpose_rg:          '${{inputs.purposeRG}}'
          TF_VAR_RGname:              '${{inputs.RGname}}'
          TF_VAR_subnetname:          '${{inputs.subnetname}}'
          TF_VAR_sku_name:            '${{inputs.sku_name}}'
          TF_VAR_private_ip_address:  '${{inputs.private_ip_address}}'
          TF_VAR_vm_list:             '${{ env.VM_LIST }}''
      - name: 'Terraform Remove - Load Balancer'
        if: ${{ inputs.requestType == 'Remove' }}
        run: terraform destroy -auto-approve
        env:
          TF_VAR_requesttype:         '${{inputs.requestType}}'
          TF_VAR_location:            '${{inputs.location}}'
          TF_VAR_environment:         '${{inputs.environment}}'
          TF_VAR_purpose:             '${{inputs.purpose}}'
          TF_VAR_purpose_rg:          '${{inputs.purposeRG}}'
          TF_VAR_RGname:              '${{inputs.RGname}}'
          TF_VAR_subnetname:          '${{inputs.subnetname}}'
          TF_VAR_sku_name:            '${{inputs.sku_name}}'
          TF_VAR_private_ip_address:  '${{inputs.private_ip_address}}'
          TF_VAR_vm_list:             '${{ env.VM_LIST }}'

Invalid workflow file: .github/workflows/LBCreate.yml#L129
You have an error in your yaml syntax on line 129
