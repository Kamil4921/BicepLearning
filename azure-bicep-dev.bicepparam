using 'azure-bicep.bicep'

param ConfigurationSettings = {
  awesomeFeature: true
  awesomeFeatureCounter: 2
  displayedAwesomeFeatureName: 'LinuxPc'
}
param enviroment = 'dev'
param serverFarmOs = 'linux'
