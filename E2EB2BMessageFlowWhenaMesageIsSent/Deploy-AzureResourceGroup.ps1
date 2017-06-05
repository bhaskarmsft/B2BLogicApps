#Requires -Version 3.0
#Requires -Module AzureRM.Resources
#Requires -Module Azure.Storage

Param(
    [string] $ResourceGroupName = '',
	[string] $ResourceGroupLocation = '',
	[string] $ArtifactStagingDirectory = '.',
	[string] $SubscriptionId = "",
	[string] $KeyFileName = "Contoso",
	[string] $KeyFilePassword = "password"
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


New-AzureRmResourceGroup -Location "$ResourceGroupLocation" -Name $ResourceGroupName -Force

    $ArtifactsLocationName = '_artifactsLocation'
    $ArtifactsLocationSasTokenName = '_artifactsLocationSasToken'

	$storageName = $ResourceGroupName.ToLower() -replace '[^a-zA-Z0-9]', ''
	if ($storageName.Length -gt 24)
	{
	    $storageName = $storageName.Substring(0,24)
	}
    $StorageAccountName = $storageName
    $StorageContainerName = "artifacts"
    $StorageAccount = (Get-AzureRmStorageAccount | Where-Object{$_.StorageAccountName -eq $StorageAccountName})

    # Create the storage account if it doesn't already exist
    if ($StorageAccount -eq $null) {
        New-AzureRmResourceGroup -Location "$ResourceGroupLocation" -Name $ResourceGroupName -Force
        $StorageAccount = New-AzureRmStorageAccount -StorageAccountName $StorageAccountName -Type 'Standard_LRS' -ResourceGroupName $ResourceGroupName -Location "$ResourceGroupLocation"
    }

	$OptionalParameters = New-Object -TypeName Hashtable
    # Generate the value for artifacts location if it is not provided in the parameter file
    if ($OptionalParameters[$ArtifactsLocationName] -eq $null) {
        $OptionalParameters[$ArtifactsLocationName] = $StorageAccount.Context.BlobEndPoint + $StorageContainerName
    }

    # Copy files from the local storage staging location to the storage account container
    New-AzureStorageContainer -Name $StorageContainerName -Context $StorageAccount.Context -ErrorAction SilentlyContinue *>&1

    $ArtifactFilePaths = Get-ChildItem $ArtifactStagingDirectory -Recurse -File | ForEach-Object -Process {$_.FullName}
    foreach ($SourcePath in $ArtifactFilePaths) {
        Set-AzureStorageBlobContent -File $SourcePath -Blob ([System.Io.Path]::GetFileName($SourcePath)) `
            -Container $StorageContainerName -Context $StorageAccount.Context -Force
    }

    # Generate a 4 hour SAS token for the artifacts location if one was not provided in the parameters file
    if ($OptionalParameters[$ArtifactsLocationSasTokenName] -eq $null) {
        $OptionalParameters[$ArtifactsLocationSasTokenName] = ConvertTo-SecureString -AsPlainText -Force `
            (New-AzureStorageContainerSASToken -Container $StorageContainerName -Context $StorageAccount.Context -Permission r -ExpiryTime (Get-Date).AddHours(4))
    }
	$OptionalParameters["KeyvaultName"] = $StorageAccountName
	$OptionalParameters["KeyvaultKeyName"] = $KeyFileName

	$kayVault = Get-AzureRmKeyVault -VaultName $StorageAccountName -ResourceGroupName $ResourceGroupName -ErrorAction Ignore
	 if ($kayVault -eq $null) {
        New-AzureRmKeyVault -VaultName $StorageAccountName -ResourceGroupName $ResourceGroupName -Location $ResourceGroupLocation -Sku Standard
    }

	$KeyFilePath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, ($KeyFileName  + ".PFX")))

	Set-AzureRmKeyVaultAccessPolicy -UserPrincipalName $azureRmcontext.Account.Id -VaultName $StorageAccountName -ResourceGroupName $ResourceGroupName -PermissionsToKeys all -PermissionsToSecrets all -PermissionsToCertificates all -Verbose
    Set-AzureRmKeyVaultAccessPolicy -ServicePrincipalName "7cd684f4-8a78-49b0-91ec-6a35d38739ba" -VaultName $StorageAccountName -ResourceGroupName $ResourceGroupName -PermissionsToKeys list,get,decrypt,sign
	Add-AzureKeyVaultKey -VaultName $StorageAccountName -Name $KeyFileName -KeyFilePath $KeyFilePath -KeyFilePassword (ConvertTo-SecureString -String $KeyFilePassword -AsPlainText -Force) -Verbose
    
    $TemplateFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, ("LogicApp.json")))
    $TemplateParametersFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, ("LogicApp.parameters.json")))

New-AzureRmResourceGroupDeployment -Name ($ResourceGroupName + '-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')) `
									-ResourceGroupName $ResourceGroupName `
									-TemplateFile $TemplateFile `
									-TemplateParameterFile $TemplateParametersFile `
									@OptionalParameters `
									-Force -Verbose `
									-ErrorVariable ErrorMessages
