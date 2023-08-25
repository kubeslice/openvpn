@Library('ml-library@enterprise-ml-release') _
dockerImagePipeline(
  script: this,
  serviceCython: 'openvpn-server.alpine.amd64',
  service: 'openvpn-client.alpine.amd64',
  dockerfile: 'avesha_openvpn_client.dockerfile',
  dockerFileCython: 'avesha_openvpn_server.dockerfile',
  runUnitTests: false,
  pushed: true,
  testArguments: 'pytest --alluredir=/workspace/allure-report test/tools/', 
  buildContext: '.',
  buildArguments: [PLATFORM:"amd64"]
  
)
