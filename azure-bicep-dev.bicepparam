using 'azure-bicep.bicep'

param configurationSettings = {
  awesomeFeature: true
  awesomeFeatureCounter: 2
  displayedAwesomeFeatureName: 'LinuxPc'
}
param enviroment = 'dev'
param serverFarmOs = 'linux'
