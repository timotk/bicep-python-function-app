param name string
param location string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: '${name}-kv'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenant().tenantId
    accessPolicies: [
      
    ]
  }
}

// resource secret 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
//   name: '${name}-secret'
//   properties: {
//   }
// }

// resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' = {
//   name: '${name}-vnet'
//   location: location
// }


resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${name}-application-insights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

resource hostingPlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: name
  location: location
  kind: 'Linux'
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  } 
  properties: {
    reserved: true
  }
}

resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: name
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      pythonVersion: '3.9'
      linuxFxVersion: 'python|3.9'
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT' // required for remote build, see https://docs.microsoft.com/en-us/azure/azure-functions/functions-deployment-technologies#remote-build-on-linux
          value: 'true'
        }
        {
          name: 'ENABLE_ORYX_BUILD' // required for remote build on Linux specifically, see https://docs.microsoft.com/en-us/azure/azure-functions/functions-deployment-technologies#remote-build-on-linux
          value: 'true'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
      ]
    }
    httpsOnly: true
  }
}
