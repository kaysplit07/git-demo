name: 'Azure Function with Container'
run-name: '${{github.actor}} Create Azure Function with Container   '
on:
  push:
    branches:
      - stlf-modelcicd
      - stlf-modelcicd-dev
      - stlf-modelcicd-uat
jobs:
  az_func:
    name: 'Creating Azure-Function '
    # Use the Bash shell regardless whether the GitHub Actions runner is ubuntu-latest, macos-latest, or windows-latest
    defaults:
      run:
        shell: bash
        working-directory: ${{env.ROOT_PATH}}
    env:
        ROOT_PATH: 'Azure/stlf-model-deployement-function-app-container'
        ARM_CLIENT_ID: ${{secrets.AZURE_CLIENT_ID}}
        ARM_CLIENT_SECRET: ${{secrets.AZURE_CLIENT_SECRET}}
        ARM_TENANT_ID: ${{secrets.AZURE_TENANT_ID}}
        ARM_SUBSCRIPTION_ID: ${{secrets.AZURE_SUBSCRIPTION_ID}}
        TF_VAR_clientid: ${{secrets.AZURE_CLIENT_ID}}
        TF_VAR_clientsecret: ${{secrets.AZURE_CLIENT_SECRET}}
        DEPLOYMENT_ENVIRONMENT: |-
          ${{
             github.ref_name == 'stlf-modelcicd' && 'prod'
          || github.ref_name == 'stlf-modelcicd-uat'    && 'uat'
          ||                                'dev'
          }}
        # TF_WORKSPACE: ${{inputs.location}}
    runs-on:
      group: aks-runners
      # labels: aks-runner-khtkc-f78qc
    environment: |-
      ${{
         github.ref_name == 'stlf-modelcicd' && 'prod'
      || github.ref_name == 'stlf-modelcicd-uat'    && 'uat'
      ||                                'dev'
      }}
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      # - name: Node workaround
      #   id: node_workaround
      #   run: chown -R $(whoami) /opt/hostedtoolcache
      # can possibly be removed
      - run: az login --service-principal -t $ARM_TENANT_ID -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET
      - name: Set environment variables-
        id: envvars
        run: |
            if [ "$DEPLOYMENT_ENVIRONMENT" = "prod" ]; then
            echo "BACKEND_STORAGE_ACCOUNT=5471xbpdeus201st1" >> "$GITHUB_ENV"
            echo "BACKEND_RESOURCE_GROUP=5471xb-prod-eus2-terra-rg" >> "$GITHUB_ENV"
            echo "TF_VAR_subnet_id=/subscriptions/6422bf23-0ce2-4920-a521-0699583f14fd/resourceGroups/5471xb-prod-eus2-spokenetwork-rg/providers/Microsoft.Network/virtualNetworks/5471xb-Prod-eus2-vnet-03/subnets/lz5471xb-prod-eus2-modelcd-snet-02" >> "$GITHUB_ENV"
            echo "TF_VAR_kv_id=/subscriptions/6422bf23-0ce2-4920-a521-0699583f14fd/resourceGroups/ferc-prd-eus2-dataplatform-rg/providers/Microsoft.KeyVault/vaults/stlf-prd-eus2-data-kv-01" >> "$GITHUB_ENV"
            echo "TF_VAR_env=prd" >> "$GITHUB_ENV"
            echo "TF_LOG=true" >> "$GITHUB_ENV"
            echo "TF_VAR_app_insights=InstrumentationKey=90d4255c-f26d-492f-8941-6c0de138018d;IngestionEndpoint=https://eastus2-3.in.applicationinsights.azure.com/;LiveEndpoint=https://eastus2.livediagnostics.monitor.azure.com/" >> "$GITHUB_ENV"
            
            elif [ "$DEPLOYMENT_ENVIRONMENT" = "uat" ]; then
            echo "BACKEND_STORAGE_ACCOUNT=5471xbuteus201st1" >> "$GITHUB_ENV"
            echo "BACKEND_RESOURCE_GROUP=5471xb-uat-eus2-terra-rg" >> "$GITHUB_ENV"
            echo "TF_VAR_subnet_id=/subscriptions/c89afcf7-6ab2-46bb-8697-dcd2ba54902d/resourceGroups/5471XB-UAT-eus2-spokenetwork-rg/providers/Microsoft.Network/virtualNetworks/5471XB-UAT-eus2-vnet-03/subnets/lz5471xb-uat-eus2-modelcd-snet-01" >> "$GITHUB_ENV"
            echo "TF_VAR_kv_id=/subscriptions/c89afcf7-6ab2-46bb-8697-dcd2ba54902d/resourceGroups/ferc-uat-eus2-dataplatform-rg/providers/Microsoft.KeyVault/vaults/stlf-uat-eus2-data-kv-01" >> "$GITHUB_ENV"
            echo "TF_VAR_env=uat" >> "$GITHUB_ENV"
            echo "TF_LOG=true" >> "$GITHUB_ENV"
            echo "TF_VAR_app_insights=InstrumentationKey=b0d7ce0e-7977-478c-a7c3-15334615f645;IngestionEndpoint=https://eastus2-3.in.applicationinsights.azure.com/;LiveEndpoint=https://eastus2.livediagnostics.monitor.azure.com/" >> "$GITHUB_ENV"
            
            else
            echo "BACKEND_STORAGE_ACCOUNT=5471xbdveus201st1" >> "$GITHUB_ENV"
            echo "BACKEND_RESOURCE_GROUP=5471xb-dev-eus2-terra-rg" >> "$GITHUB_ENV"
            echo "TF_VAR_subnet_id=/subscriptions/c457ccb9-b9e8-4665-b802-c4c374cc3125/resourceGroups/5471xb-dev-eus2-spokenetwork-rg/providers/Microsoft.Network/virtualNetworks/5471xb-dev-eus2-vnet-03/subnets/lz5471xb-dev-eus2-modelcd-snet-02" >> "$GITHUB_ENV"
            echo "TF_VAR_kv_id=/subscriptions/c457ccb9-b9e8-4665-b802-c4c374cc3125/resourceGroups/ferc-dev-eus2-dataplatform-rg/providers/Microsoft.KeyVault/vaults/ferc-dev-eus2-kv-01" >> "$GITHUB_ENV"
            echo "TF_VAR_env=dev" >> "$GITHUB_ENV"
            echo "TF_LOG=true" >> "$GITHUB_ENV"
            echo "TF_VAR_app_insights=InstrumentationKey=0754d84c-41ea-475d-9888-688a319b30b5;IngestionEndpoint=https://eastus2-4.in.applicationinsights.azure.com/;LiveEndpoint=https://eastus2.livediagnostics.monitor.azure.com/" >> "$GITHUB_ENV"
            echo DATABRICKS_HOST=$(az keyvault secret show -n databricks-host --vault-name ferc-dev-eus2-kv-01 --query value -o tsv) >> "$GITHUB_ENV"
            echo DATABRICKS_TOKEN=$(az keyvault secret show -n databricks-token --vault-name ferc-dev-eus2-kv-01 --query value -o tsv) >> "$GITHUB_ENV"
            echo JOB_ID=955582136915677 >> "$GITHUB_ENV"

            fi
      - name: Node setup 
        uses: actions/setup-node@v4
        with:
            node-version: 20
      - name: TF Setup
        id: setup
        uses: hashicorp/setup-terraform@v3

      - name: Terraform fmt
        id: fmt
        run: terraform fmt -check
        continue-on-error: true

      - name: Terraform init
        id: init
        run: terraform init -backend-config="resource_group_name=$BACKEND_RESOURCE_GROUP" -backend-config="storage_account_name=$BACKEND_STORAGE_ACCOUNT" -backend-config="container_name=terra-state" -backend-config="key=terraform.tfstate" -input=false
        # env:
        env:
          BACKEND_RESOURCE_GROUP: ${{env.BACKEND_RESOURCE_GROUP}}
          BACKEND_STORAGE_ACCOUNT: ${{env.BACKEND_STORAGE_ACCOUNT}}

      # - name: Terraform unlock
      #   run: terraform force-unlock -force 4b04d070-4282-5093-4558-312c7ac12dca
      #   continue-on-error: true
        
      - name: Terraform Validate
        id: validate
        run: terraform validate 
      - name: Terraform Plan
        id: plan
        run: terraform plan
      - name: Terraform Apply
        id: apply
        run: terraform apply -auto-approve
      - name: Terraform Output
        id: output
        run: |
              echo "ACR_NAME=$(terraform output --raw acr_name)" >> "$GITHUB_ENV"
              echo "ACR_LOGIN_SERVER=$(terraform output --raw acr_login_server)" >> "$GITHUB_ENV"
              echo "AZ_FUNC_NAME=$(terraform output --raw az_func_name)" >> "$GITHUB_ENV"
              echo "AZ_RESOURCE_GROUP=$(terraform output --raw az_resource_group)" >> "$GITHUB_ENV"

              echo "terraform outputs  exported"
      - run: az acr login -n $ACR_NAME
        name: Login to Registry
      - run: docker build . -t ${ACR_LOGIN_SERVER}/stlf-modelcicd-mass:latest 
        name: Build Container
        working-directory: ${{env.ROOT_PATH}}/azure_function
      - run: docker run --name stlf-modelcicd-test -t ${ACR_LOGIN_SERVER}/stlf-modelcicd-mass:latest pytest /home/site/wwwroot
        working-directory: ${{env.ROOT_PATH}}/azure_function
        name: Unit Test
      - run: docker push ${ACR_LOGIN_SERVER}/stlf-modelcicd-mass:latest
        working-directory: ${{env.ROOT_PATH}}/azure_function
        name: Push to Registry
      - run: az account set --subscription ${ARM_SUBSCRIPTION_ID}
        name: Set Subscription to Current Environments Subscription
      - run: az functionapp list
        name: List Function Apps
      - run: az functionapp restart --name ${AZ_FUNC_NAME} --resource-group ${AZ_RESOURCE_GROUP}
        name: Restart Azure Function App
      # - run: docker run -e DATABRICKS_TOKEN -e JOB_ID ${ACR_LOGIN_SERVER}/stlf-modelcicd-mass:latest /run_databricks_job.sh
      #   if: ${{github.ref_name}} == 'stlf-modelcicd-dev'
      #   name: Integration Test
      #   working-directory: ${{env.ROOT_PATH}}
    outputs:
      RUNNER: ${{ runner.name }}
      IMAGE_NAME: ${ACR_LOGIN_SERVER}/stlf-modelcicd-mass:latest        
