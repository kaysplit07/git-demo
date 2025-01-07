on:
    workflow_call:
      inputs:
        name:
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
        TF_VAR_BACKEND_STORAGE_ACCOUNT:
          required: true
        TF_VAR_BACKEND_RESOURCE_GROUP:
          required: true
#####################

  Deploying-Mysql-server:
    name: 'Deploying - MSSQL server'
    uses: ./.github/workflows/Createmssqlserver.yml
    needs: Deploying-Resource-Group
    secrets: 
      ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      ARM_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
      ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
      BACKEND_STORAGE_ACCOUNT: ${{ secrets.BACKEND_STORAGE_ACCOUNT }}
      BACKEND_RESOURCE_GROUP: ${{ secrets.BACKEND_RESOURCE_GROUP }}
      TF_VAR_BACKEND_STORAGE_ACCOUNT: ${{ secrets.BACKEND_STORAGE_ACCOUNT }}
      TF_VAR_BACKEND_RESOURCE_GROUP: ${{ secrets.BACKEND_RESOURCE_GROUP }}
