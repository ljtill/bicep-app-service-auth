// ------
// Scopes
// ------

targetScope = 'resourceGroup'

// ---------
// Resources
// ---------

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: resources.serverfarms.name
  location: resources.location
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource appService 'Microsoft.Web/sites@2022-09-01' = {
  name: resources.sites.name
  location: resources.location
  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'NODE|18-lts'
      appSettings: [
        {
          name: 'MICROSOFT_PROVIDER_AUTHENTICATION_SECRET'
          value: credentials.clientSecret
        }
      ]
    }
    clientAffinityEnabled: false
    httpsOnly: true
  }
}

resource authsettingsV2 'Microsoft.Web/sites/config@2022-09-01' = {
  parent: appService
  name: 'authsettingsV2'
  properties: {
    platform: {
      enabled: true
      runtimeVersion: '~1'
    }
    globalValidation: {
      requireAuthentication: true
      unauthenticatedClientAction: 'RedirectToLoginPage'
      redirectToProvider: 'azureactivedirectory'
    }
    httpSettings: {
      requireHttps: true
      routes: {
        apiPrefix: '/.auth'
      }
      forwardProxy: {
        convention: 'NoProxy'
      }
    }
    login: {
      preserveUrlFragmentsForLogins: false
      allowedExternalRedirectUrls: []
      tokenStore: {
        enabled: true
        tokenRefreshExtensionHours: 72
      }
      cookieExpiration: {
        convention: 'FixedTime'
        timeToExpiration: '08:00:00'
      }
      nonce: {
        validateNonce: true
        nonceExpirationInterval: '00:05:00'
      }
      routes: {
        logoutEndpoint: ''
      }
    }
    identityProviders: {
      azureActiveDirectory: {
        enabled: true
        registration: {
          openIdIssuer: 'https://sts.windows.net/${tenant().tenantId}/v2.0'
          clientId: credentials.clientId
          clientSecretSettingName: 'MICROSOFT_PROVIDER_AUTHENTICATION_SECRET'
        }
        login: {
          disableWWWAuthenticate: false
        }
        validation: {
          defaultAuthorizationPolicy: {}
          jwtClaimChecks: {}
          allowedAudiences: [
            'api://${credentials.clientId}'
          ]
        }
      }
      legacyMicrosoftAccount: {
        enabled: false
      }
      azureStaticWebApps: {
        enabled: false
      }
      apple: {
        enabled: false
      }
      facebook: {
        enabled: false
      }
      gitHub: {
        enabled: false
      }
      google: {
        enabled: false
      }
      twitter: {
        enabled: false
      }
      customOpenIdConnectProviders: {}
    }

  }
}

// ----------
// Parameters
// ----------

param resources object

@secure()
param credentials object
