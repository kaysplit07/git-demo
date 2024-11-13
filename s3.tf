name: zLoad Balancer (Call)
run-name: ${{github.actor}} - Creating Load Balancer
true:
  workflow_call:
    inputs:
      RGname:
        required: false
        type: string
      environment:
        required: true
        type: string
      location:
        required: true
        type: string
      private_ip_address:
        required: false
        type: string
      purpose:
        required: false
        type: string
      purposeRG:
        required: false
        type: string
      requestType:
        required: false
        type: string
      sku_name:
        required: false
        type: string
      subnetname:
        required: false
        type: string
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
  contents: read
  permissions: null
jobs:
  lb-create:
    defaults:
      run:
        shell: bash
    env:
      ARM_CLIENT_ID: ${{secrets.ARM_CLIENT_ID}}
      ARM_CLIENT_SECRET: ${{secrets.ARM_CLIENT_SECRET}}
      ARM_SUBSCRIPTION_ID: ${{secrets.ARM_SUBSCRIPTION_ID}}
      ARM_TENANT_ID: ${{secrets.ARM_TENANT_ID}}
      ROOT_PATH: Azure/Azure-LB
    environment: ${{ inputs.environment }}
    name: Create Azure Load Balancer
    runs-on:
      group: aks-runners
    steps:
    - name: Checkout - Load Balancer
      uses: actions/checkout@v3
    - id: envvars
      name: Set environment variables based on deployment environment
      run: "\n    if [ \"${{ inputs.environment }}\" = \"prod\" ]; then\n        echo\
        \ \"BACKEND_STORAGE_ACCOUNT=5471xbpdeus201st1\" >> \"$GITHUB_ENV\"\n     \
        \   echo \"BACKEND_RESOURCE_GROUP=5471xb-prod-eus2-terra-rg\" >> \"$GITHUB_ENV\"\
        \n        echo \"TF_VAR_env=prod\" >> \"$GITHUB_ENV\"\n    elif [ \"${{ inputs.environment\
        \ }}\" = \"uat\" ]; then\n        echo \"BACKEND_STORAGE_ACCOUNT=5471xbuteus201st1\"\
        \ >> \"$GITHUB_ENV\"\n        echo \"BACKEND_RESOURCE_GROUP=5471xb-uat-eus2-terra-rg\"\
        \ >> \"$GITHUB_ENV\"\n        echo \"TF_VAR_env=uat\" >> \"$GITHUB_ENV\"\n\
        \    else\n        echo \"BACKEND_STORAGE_ACCOUNT=5471xbdveus201st1\" >> \"\
        $GITHUB_ENV\"\n        echo \"BACKEND_RESOURCE_GROUP=5471xb-dev-eus2-terra-rg\"\
        \ >> \"$GITHUB_ENV\"\n        echo \"TF_VAR_env=dev\" >> \"$GITHUB_ENV\"\n\
        \    fi\n    "
    - name: Select backend file based on environment
      run: "case \"${{ inputs.environment }}\" in\n  dev) cp backend-dev.tf main.tf\
        \ ;;\n  uat) cp backend-uat.tf main.tf ;;\n  prod) cp backend-prod.tf main.tf\
        \ ;;\nesac\n"
    - env:
        TF_VAR_RGname: ${{inputs.RGname}}
        TF_VAR_environment: ${{inputs.environment}}
        TF_VAR_location: ${{inputs.location}}
        TF_VAR_private_ip_address: ${{inputs.private_ip_address}}
        TF_VAR_purpose: ${{inputs.purpose}}
        TF_VAR_purpose_rg: ${{inputs.purposeRG}}
        TF_VAR_requesttype: ${{inputs.requesttype}}
        TF_VAR_sku_name: ${{inputs.sku_name}}
        TF_VAR_subnetname: ${{inputs.subnetname}}
      name: Terraform Initialize - Load Balancer
      run: "\n        terraform init -backend-config=\"resource_group_name=$BACKEND_RESOURCE_GROUP\"\
        \                        -backend-config=\"storage_account_name=$BACKEND_STORAGE_ACCOUNT\"\
        \                        -backend-config=\"container_name=terra-state\"  \
        \                      -backend-config=\"key=${{ inputs.environment }}-lb-terraform.tfstate\"\
        \                        -input=false\n        "
      uses: hashicorp/terraform-github-actions@master
      with:
        tf_actions_comment: true
        tf_actions_subcommand: init
        tf_actions_version: latest
        tf_actions_working_dir: ${{env.ROOT_PATH}}
    - env:
        TF_VAR_RGname: ${{inputs.RGname}}
        TF_VAR_environment: ${{inputs.environment}}
        TF_VAR_location: ${{inputs.location}}
        TF_VAR_private_ip_address: ${{inputs.private_ip_address}}
        TF_VAR_purpose: ${{inputs.purpose}}
        TF_VAR_purpose_rg: ${{inputs.purposeRG}}
        TF_VAR_requesttype: ${{inputs.requesttype}}
        TF_VAR_sku_name: ${{inputs.sku_name}}
        TF_VAR_subnetname: ${{inputs.subnetname}}
      if: ${{ inputs.requestType == 'Create (with New RG)' || inputs.requestType ==
        'Create (with Existing RG)' }}
      name: Terraform Plan - Load Balancer
      uses: hashicorp/terraform-github-actions@master
      with:
        tf_actions_comment: true
        tf_actions_subcommand: plan
        tf_actions_version: latest
        tf_actions_working_dir: ${{ env.ROOT_PATH }}
    - env:
        TF_VAR_RGname: ${{inputs.RGname}}
        TF_VAR_environment: ${{inputs.environment}}
        TF_VAR_location: ${{inputs.location}}
        TF_VAR_private_ip_address: ${{inputs.private_ip_address}}
        TF_VAR_purpose: ${{inputs.purpose}}
        TF_VAR_purpose_rg: ${{inputs.purposeRG}}
        TF_VAR_requesttype: ${{inputs.requesttype}}
        TF_VAR_sku_name: ${{inputs.sku_name}}
        TF_VAR_subnetname: ${{inputs.subnetname}}
      if: ${{ inputs.requestType == 'Create (with New RG)' || inputs.requestType ==
        'Create (with Existing RG)' }}
      name: Terraform Apply - Load Balancer
      uses: hashicorp/terraform-github-actions@master
      with:
        tf_actions_comment: true
        tf_actions_subcommand: apply
        tf_actions_version: latest
        tf_actions_working_dir: ${{env.ROOT_PATH}}
    - env:
        TF_VAR_RGname: ${{inputs.RGname}}
        TF_VAR_environment: ${{inputs.environment}}
        TF_VAR_location: ${{inputs.location}}
        TF_VAR_private_ip_address: ${{inputs.private_ip_address}}
        TF_VAR_purpose: ${{inputs.purpose}}
        TF_VAR_purpose_rg: ${{inputs.purposeRG}}
        TF_VAR_requesttype: ${{inputs.requesttype}}
        TF_VAR_sku_name: ${{inputs.sku_name}}
        TF_VAR_subnetname: ${{inputs.subnetname}}
      if: ${{ inputs.requestType == 'Remove' }}
      name: Terraform Remove - Load Balancer
      uses: hashicorp/terraform-github-actions@master
      with:
        tf_actions_comment: true
        tf_actions_subcommand: destroy
        tf_actions_version: latest
        tf_actions_working_dir: ${{env.ROOT_PATH}}
