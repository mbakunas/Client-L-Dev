$managementGroup = "ExtensisTLG"
$location = "eastus2"
$templateFile = ".\hub-spoke-deploy.bicep"
$templateParameterFile = ".\hub-spoke-deploy-centralus.bicepparam"
$deploymentName = "HubSpokeDeploy3"



New-AzManagementGroupDeployment -ManagementGroupId $managementGroup -Location $location -TemplateFile $templateFile -TemplateParameterFile $templateParameterFile -name $deploymentName
New-AzManagementGroupDeployment -ManagementGroupId ExtensisTLG -Location eastus2 -TemplateFile .\hub-spoke-deploy.bicep -TemplateParameterFile .\hub-spoke-deploy-eastus2.bicepparam -name HubSpokeDeploy12
New-AzManagementGroupDeployment -ManagementGroupId ExtensisTLG -Location eastus2 -TemplateFile .\hub-spoke-deploy.bicep -TemplateParameterFile .\hub-spoke-deploy-test2.bicepparam -name HubSpokeDeploy19
New-AzResourceGroupDeployment -ResourceGroupName Firewall-Test-01 -TemplateFile .\modules\vnet.bicep -name VNetDeploy1
New-AzResourceGroupDeployment -ResourceGroupName Firewall-Test-01 -TemplateFile .\modules\loadBalancer.bicep -TemplateParameterFile .\modules\loadBalancer.bicepparam -name LbDeploy1
New-AzResourceGroupDeployment -ResourceGroupName Firewall-Test-01 -TemplateFile .\PaloAltoFWdeploy.bicep -TemplateParameterFile .\PaloAltoFWdeploy.bicepparam -name FwDeploy1


# firewall test
New-AzResourceGroupDeployment -ResourceGroupName FWTest03 -TemplateFile .\PaloAltoFWvnetDeploy.bicep -name VnetDeploy1
New-AzResourceGroupDeployment -ResourceGroupName FWTest03 -TemplateFile .\PaloAltoFWdeploy.bicep -templateParameterFile .\PaloAltoFWdeploy.bicepparam -name FwDeploy1