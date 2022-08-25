Param(
      [string]$tenantId
    , [string]$subscriptionId
    , [string]$storageAccountId
    , [string]$servicePrincipalName
    , [string]$servicePrincipalPassword
	, [string]$deploymentName
	, [string]$resourceGroupName
	, [string]$templateFileName
	, [string]$templateParameterFileName
)

Function ConnectToAzure  {
        Disconnect-AzAccount
        [securestring]$encrypted_servicePrincipalPassword = ConvertTo-SecureString $servicePrincipalPassword -AsPlainText -Force
        [pscredential]$credentials = New-Object System.Management.Automation.PSCredential ($servicePrincipalName, $encrypted_servicePrincipalPassword)
        Connect-AzAccount -ServicePrincipal -Credential $credentials -Tenant $tenantId -SubscriptionId $subscriptionId | Out-Null
        Select-AzSubscription -SubscriptionId $subscriptionId
}

$ErrorView = "NormalView"
$ErrorActionPreference = "Stop"
$global:successArray = [System.Collections.ArrayList]@()

try {
    Install-Module -Name Az -Force -AllowClobber
    Disable-AzContextAutosave –Scope Process
    ConnectToAzure

	New-AzResourceGroupDeployment -Name $deploymentName -ResourceGroupName $resourceGroupName -TemplateFile $templateFileName -TemplateParameterFile $templateParameterFileName
}
catch {
    Write-Error $_.Exception.Message
}