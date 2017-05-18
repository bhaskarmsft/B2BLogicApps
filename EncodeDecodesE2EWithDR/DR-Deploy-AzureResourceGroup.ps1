#Requires -Version 3.0
#Requires -Module AzureRM.Resources
#Requires -Module Azure.Storage

Param(
    [string] $ResourceGroupName = '',
	[string] $ResourceGroupLocation = '',
	[string] $ArtifactStagingDirectory = '.',
	[string] $SubscriptionId = "",
    [string] $SecondaryResourceGroupName = '',
	[string] $SecondaryResourceGroupLocation = ""
)

try
{
    $azureRmcontext = Get-AzureRmContext -ErrorVariable Ignore
}
catch
{
    
}

if(-not $azureRmcontext)
{
    $azureRmcontext = Login-AzureRmAccount
}

if($azureRmcontext.Context.Subscription.SubscriptionId -ne $SubscriptionId)
{
    Select-AzureRmSubscription -SubscriptionId $SubscriptionId
}



	$PrimaryOptionalParameters = New-Object -TypeName Hashtable
    $PrimaryOptionalParameters["SecondaryResourceGroupName"] = $SecondaryResourceGroupName
	$PrimaryOptionalParameters["SecondaryResourceGroupLocation"] = $SecondaryResourceGroupLocation

	$SecondaryOptionalParameters = New-Object -TypeName Hashtable
    $SecondaryOptionalParameters["SecondaryResourceGroupName"] = $ResourceGroupName
	$SecondaryOptionalParameters["SecondaryResourceGroupLocation"] = $ResourceGroupLocation
    $SecondaryOptionalParameters["syncLaState"] = "Enabled"
    
    $PrimaryTemplateFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, ("PrimaryDRLAs.json")))
    $PrimaryTemplateParametersFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, ("PrimaryDRLAs.parameters.json")))
    
    $SecondaryTemplateFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, ("SecondaryDRLAs.json")))
    $SecondaryTemplateParametersFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, ("SecondaryDRLAs.parameters.json")))

New-AzureRmResourceGroupDeployment -Name ($ResourceGroupName + '-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')) `
									-ResourceGroupName $ResourceGroupName `
									-TemplateFile $PrimaryTemplateFile `
									-TemplateParameterFile $PrimaryTemplateParametersFile `
									@PrimaryOptionalParameters `
									-Force -Verbose `
									-ErrorVariable ErrorMessages


New-AzureRmResourceGroupDeployment -Name ($ResourceGroupName + '-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')) `
									-ResourceGroupName $SecondaryResourceGroupName `
									-TemplateFile $SecondaryTemplateFile `
									-TemplateParameterFile $PrimaryTemplateParametersFile `
									@SecondaryOptionalParameters `
									-Force -Verbose `
									-ErrorVariable ErrorMessages




