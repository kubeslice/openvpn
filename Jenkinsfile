@Library('jenkins-library@opensource-release') _
dockerImagePipeline(
  script: this,
  service: 'openvpn-server.alpine.amd64',
  dockerfile: 'avesha_openvpn_server.dockerfile',
  buildContext: '.',
  buildArguments: [PLATFORM:"amd64"]
  
)
