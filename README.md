# App Service Auth

This repository provides the infra-as-code components to quickly deploy a sample Azure App Service with Entra IDgit c Authentication.

---

## Getting Started

Update the `main.bicepparam` file

Create Resource Group

```shell
az group create \
    --name '' \
    --location ''
```

Deploy the Bicep template

```shell
az deployment group create \
    --resource-group '' \
    --name 'Microsoft.Resources' \
    --template-file ./src/main.bicep \
    --parameters ./src/main.bicepparam
```
