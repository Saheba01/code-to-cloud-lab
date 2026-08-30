@description('Name of the storage account')
param storageAccountName string = 'ttclabstor${uniqueString(resourceGroup().id)}'

@description('Location for the storage account')
param location string = resourceGroup().location

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    // VULNERABILITY: allows public network access
    publicNetworkAccess: 'Enabled'
    // VULNERABILITY: allows anonymous blob access
    allowBlobPublicAccess: true
    // VULNERABILITY: does not require HTTPS
    supportsHttpsTrafficOnly: false
    // VULNERABILITY: outdated TLS version
    minimumTlsVersion: 'TLS1_0'
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: 'ttclab-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowAnyInbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: '*'
          // VULNERABILITY: allows inbound traffic from any source
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
        }
      }
    ]
  }
}
