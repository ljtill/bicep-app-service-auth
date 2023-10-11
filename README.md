# App Service Auth

This repository provides the infra-as-code components to quickly deploy a sample Azure App Service with Entra ID Authentication.

---

## Getting Started

Create Resource Group

```shell
az group create -n '' -l ''
```

Create Entra ID App Registration

```shell
az ad app create \
    --display-name '' \
    --sign-in-audience 'AzureADMyOrg' \
    --required-resource-accesses '[{"resourceAppId":"00000003-0000-0000-c000-000000000000","resourceAccess":[{"id":"e1fe6dd8-ba31-4d61-89e7-88639da4683d","type":"Scope"}]}]' \
    --web-redirect-uris 'https://APPLICATION_NAME.azurewebsites.net/.auth/login/aad/callback' \
    --enable-id-token-issuance true
```

Replace the 'APPLICATION_NAME' and 'APPLICATION_ID' values in the `app.json` file

```shell
az ad app update \
    --id '' \
    --set api=@./src/app.json

az ad app credential reset \
    --id '' \
    --display-name
```

Update the `main.bicepparam` file

Deploy the Bicep template

```shell
az deployment group create -g '' -n 'Microsoft.Resources' -f ./src/main.bicep -p ./src/main.bicepparam
```
