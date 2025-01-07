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
        BACKEND_STORAGE_ACCOUNT:   # ✅ Fix: Adding missing secrets here
          required: true
        BACKEND_RESOURCE_GROUP:    # ✅ Fix: Adding missing secrets here
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



#######################

  Deploying-Mysql-server:
    name: 'Deploying - MSSQL server'
    uses: ./.github/workflows/Createmssqlserver.yml
    needs: Deploying-Resource-Group
    secrets: 
      ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      ARM_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
      ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
      BACKEND_STORAGE_ACCOUNT:   ${{ secrets.BACKEND_STORAGE_ACCOUNT }}  # ✅ Ensure this is passed
      BACKEND_RESOURCE_GROUP:    ${{ secrets.BACKEND_RESOURCE_GROUP }}  # ✅ Ensure this is passed
