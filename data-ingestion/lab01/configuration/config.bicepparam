using '../adf_workspace.bicep'

param name = 'usp'
param managedIdentityName = 'midentity${name}'
param storageAccountName = 'storageacc${name}'
param sqlServerName = 'sqlserver${name}'
param sqlSid = '1b8bec2c-9878-45d5-87cf-b161d55d16e7'
// param sqlUser = 'usp'
// param sqlPassword = 'PecePoli#!2023'
param location = 'eastus2'

