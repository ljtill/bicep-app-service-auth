# App Service Auth

This repository provides the infra-as-code components to quickly deploy a sample Azure App Service with Entra ID Authentication.

---

## Getting Started

Create Entra ID App Registration

Replace the `APP_NAME` in the `--web-redirect-uris`

```shell
az ad app create \
    --display-name '' \
    --sign-in-audience 'AzureADMyOrg' \
    --required-resource-accesses @./src/manifests/resource.json \
    --web-redirect-uris 'https://APP_NAME.azurewebsites.net/.auth/login/aad/callback' \
    --enable-id-token-issuance true

az ad sp create \
    --id ''
```

Replace the `APP_NAME` and `APP_ID` values in the `app.json` file

```shell
az ad app update \
    --id '' \
    --identifier-uris 'api://APP_ID'

az ad app update \
    --id '' \
    --set api=@./src/manifests/scope.json

az ad app credential reset \
    --id '' \
    --display-name 'App Service'
```

Update the `main.bicepparam` file

Create Resource Group

```shell
az group create -n '' -l ''
```

Deploy the Bicep template

```shell
az deployment group create \
    -g '' \
    -n 'Microsoft.Resources' \
    -f ./src/resources/main.bicep \
    -p ./src/resources/main.bicepparam
```
