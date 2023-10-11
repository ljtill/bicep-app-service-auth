using './main.bicep'

param resources = {
  location: 'uksouth'
  applications: {
    name: ''
    displayName: ''
  }
  serverfarms: {
    name: ''
  }
  sites: {
    name: ''
  }
}
