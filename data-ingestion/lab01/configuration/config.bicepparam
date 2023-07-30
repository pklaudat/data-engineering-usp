using '../adf_workspace.bicep'

param name = 'usp'
param managedIdentityName = 'midentity${name}'
param storageAccountName = 'storageacc${name}'
param sqlServerName = 'sqlserver${name}'
param sqlUser = 'usp'
param sqlPassword = 'PecePoli#!2023'
param location = 'eastus2'

