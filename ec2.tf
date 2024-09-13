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
else {
  $region = "ukw"
  $geo = "UK"
}
#magic___^_^___line
$spokenetworkName = $bu + "-" + $env + "-" + $region + "-spokenetwork-rg"
Write-Output "SPOKENETWORK NAME: $spokenetworkName"
#magic___^_^___line
$vnetName = $bu + "-" + $env + "-" + $region + "-vnet-" + $nn
Write-Output "VNET NAME: $vnetName"
#magic___^_^___line
$subnetName = "lz" + $bu + "-" + $env + "-" + $region + "-" + "${{inputs.purpose}}" + "-snet-${{inputs.subnetNumber}}"
$subnetName_Lowercase = $subnetName.ToLower()
Write-Output "SUBNET NAME: $subnetName_Lowercase"
#magic___^_^___line
$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $spokenetworkName
#magic___^_^___line
if ("${{inputs.action}}" -eq "Add") {
  Write-Output "==> Adding Subnet"
  #magic___^_^___line
  $subnetConfig = Add-AzVirtualNetworkSubnetConfig -Name $subnetName_Lowercase -AddressPrefix "10.0.1.0/24" -VirtualNetwork $vnet
  Set-AzVirtualNetwork -VirtualNetwork $vnet
  Write-Output "==> Subnet Added: $subnetName_Lowercase"
  #magic___^_^___line
} elseif ("${{inputs.action}}" -eq "Remove") {
  Write-Output "==> Removing Subnet"
  #magic___^_^___line
  $subnetConfig = Remove-AzVirtualNetworkSubnetConfig -Name $subnetName_Lowercase -VirtualNetwork $vnet
  Set-AzVirtualNetwork -VirtualNetwork $vnet
  Write-Output "==> Subnet Removed: $subnetName_Lowercase"
  #magic___^_^___line
} else {
  throw "Invalid action. Please specify either 'Add' or 'Remove'."
}
#magic___^_^___line
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
#magic___^_^___line
$spAppId = Get-AzKeyVaultSecret -VaultName 'ng-prd-eus2-kv-01' -Name "PLAT-logicAppAPI-prod-01-SPN-appId" -AsPlainText
$Password = Get-AzKeyVaultSecret -VaultName 'ng-prd-eus2-kv-01' -Name "PLAT-logicAppAPI-prod-01-SPN-Password"
$credential = New-Object System.Management.Automation.PsCredential($spAppId, $Password.SecretValue)
Connect-AzAccount -ServicePrincipal -Credential $credential -Tenant $tenantId
$accessToken = Get-AzAccessToken -ResourceUrl 'https://management.core.windows.net/'
#magic___^_^___line
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer " + $accessToken.Token)
$headers.Add("Content-Type", "application/json")
$json = $data | ConvertTo-Json
Write-Host "==> Sent"
Write-Host $json
Write-Host "==> EOM"
#magic___^_^___line
$logicAppInfo = Invoke-RestMethod 'https://prod-24.eastus2.logic.azure.com:443/workflows/66492a0351fe422ea527a48f797a59d4/triggers/manual/paths/invoke?api-version=2016-10-01' -Method 'POST' -Headers $headers -Body $json
$logicAppInfo | ConvertTo-Json
Write-Host "==> Received"
Write-Host $logicAppInfo
Write-Host "==> EOM"
