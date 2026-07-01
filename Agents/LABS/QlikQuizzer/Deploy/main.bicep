targetScope = 'subscription'

@description('The location for all resources.')
param location string = 'eastus'

@description('The name of the application. Used as a prefix for all resources.')
param appName string = 'qlik-quizzer'

@description('The OpenAI API Key to be stored in the Key Vault.')
@secure()
param openaiApiKey string

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${appName}-rg'
  location: location
}

module infrastructure 'infra.bicep' = {
  scope: rg
  name: 'infraDeployment'
  params: {
    location: location
    appName: appName
    openaiApiKey: openaiApiKey
  }
}
