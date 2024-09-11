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
# env:
#   ROOT_PATH: 'terraform/initialsetup'
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
    # Use the Bash shell regardless whether the GitHub Actions runner is ubuntu-latest, macos-latest, or windows-latest
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
        inlineScript: "$subscription = (Set-AzContext -Subscription ${{ secrets.AZURE_SUBSCRIPTION_ID }})\n$subscriptionName = $subscription.Subscription.Name\n$bu = $subscriptionName.split('-')[1]\n$env = $subscriptionName.split('-')[2]\n$nn = $subscriptionName.split('-')[3]\n$tenantId = $subscription.Tenant.Id\nif (\"${{inputs.location}}\" -eq \"eastus2\") {\n  $region = \"eus2\"\n  $geo = \"US\"\n}\nelseif (\"${{inputs.location}}\" -eq \"centralus\") {\n  $region = \"cus\"\n  $geo = \"US\"\n}\nelseif (\"${{inputs.location}}\" -eq \"uksouth\") {\n  $region = \"uks\"\n  $geo = \"UK\"\n}\nelse{\n  $region = \"ukw\"\n  $geo = \"UK\"\n}\n  #magic___^_^___line\n$spokenetworkName = $bu + \"-\" + $env + \"-\" + $region + \"-spokenetwork-rg\"\nWrite-Output \"SPOKENETWORK NAME: $spokenetworkName\" \n  #magic___^_^___line\n$vnetName = $bu + \"-\" + $env + \"-\" + $region + \"-vnet-\" + $nn\nWrite-Output \"VNET NAME: $vnetName\"\n  #magic___^_^___line\n# Modified subnet name to include purpose and subnetNumber\n$subnetName = \"lz\" + $bu + \"-\" + $env + \"-\" + $region + \"-\" + \"${{inputs.purpose}}\" + \"-snet-${{inputs.subnetNumber}}\"\n$subnetName_Lowercase = $subnetName.ToLower()\nWrite-Output \"SUBNET NAME: $subnetName_Lowercase\" \n  #magic___^_^___line\n$data = @{\n    \"geo\"                   = $geo\n    \"location\"              = $region\n    \"VNetName\"              = $vnetName\n    \"SubnetName\"            = $subnetName_Lowercase\n    \"subnetSize\"            = \"${{inputs.subnetSize}}\"\n    \"SubscriptionName\"      = $subscriptionName\n    \"resourceGroupName\"     = $spokenetworkName\n    \"requesterEmailAddress\" = \"${{inputs.adtEmailAddress}}\"\n}\n$spAppId = Get-AzKeyVaultSecret -VaultName 'ng-prd-eus2-kv-01' -Name \"PLAT-logicAppAPI-prod-01-SPN-appId\" -AsPlainText\n$Password = Get-AzKeyVaultSecret -VaultName 'ng-prd-eus2-kv-01' -Name \"PLAT-logicAppAPI-prod-01-SPN-Password\"\n$credential = New-Object System.Management.Automation.PsCredential($spAppId, $Password.SecretValue)\nConnect-AzAccount -ServicePrincipal -Credential $credential -Tenant $tenantId\n$accessToken = Get-AzAccessToken -ResourceUrl 'https://management.core.windows.net/'\n    #magic___^_^___line\n$headers = New-Object \"System.Collections.Generic.Dictionary[[String],[String]]\"\n$headers.Add(\"Authorization\", \"Bearer \" + $accessToken.Token)\n$headers.Add(\"Content-Type\", \"application/json\")\n$json = $data | ConvertTo-Json\nWrite-Host \"==> Sent\"\nWrite-Host $json\nWrite-Host \"==> EOM\"\n    #magic___^_^___line\n$logicAppInfo = Invoke-RestMethod 'https://prod-24.eastus2.logic.azure.com:443/workflows/66492a0351fe422ea527a48f797a59d4/triggers/manual/paths/invoke?api-version=2016-10-01' -Method 'POST' -Headers $headers -Body $json\n$logicAppInfo | ConvertTo-Json\nWrite-Host \"==> Received\"\nWrite-Host $logicAppInfo\nWrite-Host \"==> EOM\"\n"
