param location string
param appName string
@secure()
param openaiApiKey string

// 1. Unique name for the Key Vault (must be globally unique)
var kvName = '${appName}-kv-${uniqueString(resourceGroup().id)}'

// 2. The Key Vault itself
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: kvName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: [] // Updated after identity is created
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    softDeleteRetentionInDays: 7
  }
}

// 3. The Secret (Stored in the Vault)
resource openaiSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: 'OPENAI-API-KEY'
  properties: {
    value: openaiApiKey
  }
}

// 4. App Service Plan (Linux)
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${appName}-plan'
  location: location
  sku: {
    name: 'B1' // Required for Managed Identity
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

// 5. The Web App with System-Assigned Identity
resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'PYTHON|3.9'
      appSettings: [
        {
          name: 'OPENAI_API_KEY'
          value: '@Microsoft.KeyVault(SecretUri=${openaiSecret.properties.secretUri})'
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'true'
        }
      ]
      appCommandLine: 'gunicorn --bind 0.0.0.0:8000 qlikquizzer:app'
    }
  }
}

// 6. Access Policy: Grant the Web App "GET" permission on the Vault
resource kvAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  parent: keyVault
  name: 'add'
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: webApp.identity.principalId
        permissions: {
          secrets: [
            'get'
          ]
        }
      }
    ]
  }
}
