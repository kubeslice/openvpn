@Library('jenkins-library@opensource-release') _
dockerImagePipeline(
  script: this,
  service: 'openvpn-client.alpine.amd64',
  dockerfile: 'avesha_openvpn_client.dockerfile',
  buildContext: '.',
  buildArguments: [PLATFORM:"amd64"]
  
)
