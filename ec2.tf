name: 'Deploy Subnet'
run-name: '${{inputs.environment}}:Deploying Subnet - ${{github.actor}}'

on:
  workflow_dispatch:
    inputs:
      location:
        type: choice
        description: Location
        required: true
        options:
          - 'Select'
          - eastus2
          - centralus
          - uksouth
          - ukwest
      environment:
        type: choice
        description: Environment
        required: true
        options:
          - 'Select'
          - dev
          - qa
          - uat
          - Prod
      purpose:
        type: string
        description: Purpose for Subnet Name [3-5 unique char, CAN include Numbers] ex-kub1, wapp2, func3, etc...
        required: true
      subnetSize:
        type: choice
        description: Subnet Size
        required: true
        default: "small"
        options:
          - 'small'
          - "medium"
          - "large"
      subnetNumber:
        type: string
        description: Number for Subnet to differentiate multiple subnets of the same purpose (e.g., 01, 02)
        required: true
        default: "01"
      adtEmailAddress:
        type: string
        description: ADT Email Address (specify as 'first.last@nationalgrid.com'. NO '@uk.' or '@us.' in Domain)
        required: true  

jobs:
  Add-Subnet:
    name: 'Add Subnet'
    env:
      ARM_CLIENT_ID: ${{secrets.AZURE_CLIENT_ID}}
      ARM_CLIENT_SECRET: ${{secrets.AZURE_CLIENT_SECRET}}
      ARM_TENANT_ID: ${{secrets.AZURE_TENANT_ID}}
      ARM_SUBSCRIPTION_ID: ${{secrets.AZURE_SUBSCRIPTION_ID}}
    runs-on: ubuntu-latest
    environment: ${{inputs.environment}}
    defaults:
      run:
        shell: bash
    steps:
      - uses: actions/checkout@v2

      - name: Az login
        uses: azure/login@v2
        with: 
            creds: '{"clientId":"${{ secrets.AZURE_CLIENT_ID }}","clientSecret":"${{ secrets.AZURE_CLIENT_SECRET }}","subscriptionId":"${{ secrets.AZURE_SUBSCRIPTION_ID }}","tenantId":"${{ secrets.AZURE_TENANT_ID }}"}'
            enable-AzPSSession: true

      - name: Azure PowerShell Action
        id: 'AddSubnet'
        uses: azure/powershell@v2
        with:
          azPSVersion: latest
          inlineScript: |
            $subscription = (Set-AzContext -Subscription ${{ secrets.AZURE_SUBSCRIPTION_ID }})
            $subscriptionName = $subscription.Subscription.Name
            $bu = $subscriptionName.split('-')[1]
            $env = $subscriptionName.split('-')[2]
            $nn = $subscriptionName.split('-')[3]
            $tenantId = $subscription.Tenant.Id

            if ("${{inputs.location}}" -eq "eastus2") {
              $region = "eus2"
              $geo = "US"
            }
            elseif ("${{inputs.location}}" -eq "centralus") {
              $region = "cus"
              $geo = "US"
            }
            elseif ("${{inputs.location}}" -eq "uksouth") {
              $region = "uks"
              $geo = "UK"
            }
            else{
              $region = "ukw"
              $geo = "UK"
            }

            $spokenetworkName = $bu + "-" + $env + "-" + $region + "-spokenetwork-rg"
            Write-Output "SPOKENETWORK NAME: $spokenetworkName" 

            $vnetName = $bu + "-" + $env + "-" + $region + "-vnet-" + $nn
            Write-Output "VNET NAME: $vnetName"

            # Modified subnet name to include purpose and subnetNumber
            $subnetName = "lz" + $bu + "-" + $env + "-" + $region + "-" + "${{inputs.purpose}}" + "-snet-${{inputs.subnetNumber}}"
            $subnetName_Lowercase = $subnetName.ToLower()
            Write-Output "SUBNET NAME: $subnetName_Lowercase" 

            $data = @{
                "geo"                   = $geo
                "location"              = $region
                "VNetName"              = $vnetName
                "SubnetName"            = $subnetName_Lowercase
                "subnetSize"            = "${{inputs.subnetSize}}"
                "SubscriptionName"      = $subscriptionName
                "resourceGroupName"     = $spokenetworkName
                "requesterEmailAddress" = "${{inputs.adtEmailAddress}}"
            }
            
            # Retrieve API secrets from KeyVault
            $spAppId = Get-AzKeyVaultSecret -VaultName 'ng-prd-eus2-kv-01' -Name "PLAT-logicAppAPI-prod-01-SPN-appId" -AsPlainText
            $Password = Get-AzKeyVaultSecret -VaultName 'ng-prd-eus2-kv-01' -Name "PLAT-logicAppAPI-prod-01-SPN-Password"
            $credential = New-Object System.Management.Automation.PsCredential($spAppId, $Password.SecretValue)
            Connect-AzAccount -ServicePrincipal -Credential $credential -Tenant $tenantId
            $accessToken = Get-AzAccessToken -ResourceUrl 'https://management.core.windows.net/'

            $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
            $headers.Add("Authorization", "Bearer " + $accessToken.Token)
            $headers.Add("Content-Type", "application/json")
            $json = $data | ConvertTo-Json
            Write-Host "==> Sent"
            Write-Host $json
            Write-Host "==> EOM"

            $logicAppInfo = Invoke-RestMethod 'https://prod-24.eastus2.logic.azure.com:443/workflows/66492a0351fe422ea527a48f797a59d4/triggers/manual/paths/invoke?api-version=2016-10-01' -Method 'POST' -Headers $headers -Body $json
            $logicAppInfo | ConvertTo-Json
            Write-Host "==> Received"
            Write-Host $logicAppInfo
            Write-Host "==> EOM"
