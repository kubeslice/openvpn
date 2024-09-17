@Library('jenkins-library@opensource-release-multiarch') _
dockerImagePipeline(
  script: this,
  services: ['openvpn-server.alpine','openvpn-client.alpine'],
  dockerfiles: ['avesha_openvpn_server.dockerfile','avesha_openvpn_client.dockerfile'],
  pushed: true,
  buildArgumentsList: [
    [ENV: 'production', PLATFORM: 'linux/arm64,linux/amd64'],
    [ENV: 'production', PLATFORM: 'linux/arm64,linux/amd64']
]
  
)
