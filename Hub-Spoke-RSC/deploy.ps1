$managementGroup = "ExtensisTLG"
$location = "eastus2"
$templateFile = ".\hub-spoke-deploy.bicep"
$templateParameterFile = ".\hub-spoke-deploy-centralus.bicepparam"
$deploymentName = "HubSpokeDeploy3"



New-AzManagementGroupDeployment -ManagementGroupId $managementGroup -Location $location -TemplateFile $templateFile -TemplateParameterFile $templateParameterFile -name $deploymentName
New-AzManagementGroupDeployment -ManagementGroupId ExtensisTLG -Location eastus2 -TemplateFile .\hub-spoke-deploy.bicep -TemplateParameterFile .\hub-spoke-deploy-eastus2.bicepparam -name HubSpokeDeploy12
New-AzManagementGroupDeployment -ManagementGroupId ExtensisTLG -Location eastus2 -TemplateFile .\hub-spoke-deploy.bicep -TemplateParameterFile .\hub-spoke-deploy-test2.bicepparam -name HubSpokeDeploy19