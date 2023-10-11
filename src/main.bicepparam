using './main.bicep'

param resources = {
  location: ''
  serverfarms: {
    name: ''
  }
  sites: {
    name: ''
  }
}

param credentials = {
  clientId: ''
  clientSecret: ''
}
