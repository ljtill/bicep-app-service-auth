// ------
// Scopes
// ------

targetScope = 'resourceGroup'

// -------
// Imports
// -------

import 'microsoftGraph@1.0.0'

// ---------
// Resources
// ---------

// Graph

resource application 'Microsoft.Graph/applications@beta' = {
  name: guid(subscription().subscriptionId, resources.applications.name)
  displayName: resources.applications.displayName
  signInAudience: 'AzureADMyOrg'
  identifierUris: [
    'api://${tenant().tenantId}/${resources.sites.name}'
  ]
  requiredResourceAccess: [
    {
      resourceAppId: '00000003-0000-0000-c000-000000000000'
      resourceAccess: [
        {
          id: 'e1fe6dd8-ba31-4d61-89e7-88639da4683d'
          type: 'Scope'
        }
      ]
    }
  ]
  api: {
    oauth2PermissionScopes: [
      {
        id: guid(subscription().subscriptionId, resources.applications.name)
        isEnabled: true
        type: 'User'
        value: 'user_impersonation'
        adminConsentDisplayName: 'Access ${resources.applications.name}'
        adminConsentDescription: 'Allow the application to access ${resources.applications.name} on behalf of the signed-in user.'
        userConsentDisplayName: 'Access ${resources.applications.name}'
        userConsentDescription: 'Allow the application to access ${resources.applications.name} on your behalf.'
      }
    ]
  }
  web: {
    redirectUris: [
      'https://${resources.sites.name}.azurewebsites.net/.auth/login/aad/callback'
    ]
    implicitGrantSettings: {
      enableIdTokenIssuance: true
    }
  }
}

resource servicePrincipal 'Microsoft.Graph/servicePrincipals@beta' = {
  appId: application.appId

}

// Azure

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
          clientId: application.appId
        }
        login: {
          disableWWWAuthenticate: false
        }
        validation: {
          defaultAuthorizationPolicy: {}
          jwtClaimChecks: {}
          allowedAudiences: [
            'api://${tenant().tenantId}/${resources.sites.name}'
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
