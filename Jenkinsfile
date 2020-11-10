// Include the library of calls we want to use.
// Since this it the pipeline-test-env, we will
// use the dev branch of pipeline-utils code this way we will
// not effect the existing build pipelines.
// NOTE: all work on pipeline utils for testing should be done
//       on the dev branch and merged into master after validation.
@Library('pipeline-utils@master')_

//
// Global vars so they are available for all stages
// define the global var for all platform form the pipeline.yaml
//
def globalPlatformList=[:]

//
// identify a global var for each platform being built
//
def artifactOne=[:]
def artifactTwo=[:]
def artifactThree=[:]
def artifactFour=[:]

//
// Start the pipeline
//
pipeline {
    // agent must be specified in the particular platform we are building
    agent none
    /*
     // May need in the future
     options {
        // this will abort all parallel stages when any of them fail.
        parallelsAlwaysFailFast()
     }
    */

    environment {
	// Most Vars needed for build are taken from the pipeline.yaml in the bitbucket repository directory
	// We want to limit the number of environment variables in the Jenkinsfile when possible.


	// Build Platforms that we need to build.
	// This values must match the platform.name in the pipeline.yaml
	AVESHA_PLATFORM_ARTIFACT_ONE="openvpn-ca"
	AVESHA_PLATFORM_ARTIFACT_TWO="openvpn-server"
	AVESHA_PLATFORM_ARTIFACT_THREE="openvpn-client-amd64"
	AVESHA_PLATFORM_ARTIFACT_FOUR="openvpn-client-arm32v7"
    }

    stages {
	//
	// Build Stage
	//
        stage('Build and Test') {
            parallel {
                stage ("OpenVPN CA" ) {
		    // any agent items
		    agent {
			docker {
			    // must identify the proper image to build the platform
			    // TODO: find way to dynamically get this from pipeline.yaml
			    image 'avesha-jenkins-ubuntu:1.0.0'
			}
		    }
		    stages {
			stage('Pipeline Init') {
			    steps {
				// test out some pipelining steps
				script {
				    echo "Running on Branch:  "+env.BRANCH_NAME
				    // Read the main pipeline.yaml file and set the names we need
				    myPipelineCfg = pipelineConfig()
				    globalPlatformList = myPipelineCfg.platforms

				    // set build platforms vars & umage names for use in later stages.
				    artifactOne = setPipelineConfig( globalPlatformList, env.AVESHA_PLATFORM_ARTIFACT_ONE)
				    artifactTwo = setPipelineConfig( globalPlatformList, env.AVESHA_PLATFORM_ARTIFACT_TWO)

				    // Login to the Avsha Docker Registry
				    // this is needed here because images may need to pull images for their docker build
				    aveshaRegistryLogin()
				} // script
				// error  "Nothing to do here for now, we only build for branch:  master"
			    } // steps
			} // stage Pipeline Init

			//
			// Build
			// 
			stage ("Build") {
			    when { expression { artifactOne.buildEnabled == true } }
			    steps {
				logBuildInfo()
				script {
				    // Build the product image
				    buildDockerImage( artifactOne.dockerBuildImageNameVer,
						     artifactOne.buildDockerfile,
						     artifactOne.dockerBuildArgs)
				} //script
			    } // steps
			} // Build stage

			//
			// Test
			// 
			stage ("Test") {
			    when { expression { artifactOne.buildEnabled == true } }
			    steps {
				script {
				    echo "Testing image name is:      " + artifactOne.dockerBuildImageNameVer
				    mySize=getDockerImageSize( artifactOne.dockerBuildImageNameVer)
				    valid=validateDockerImageSize( mySize,
								  artifactOne.minDockerImageSize,
								  artifactOne.maxDockerImageSize)
				    if (valid != true) {
					sh "exit 1"
				    }
				}
				// TODO: add test to load PROD binaries into test docker and validate directories are there as needed.
				// Then we will need to delete test docker.

			    } // steps
			} // test stage

			//
			// Promote Build and Latest
			// 
			stage ("Promote Build and Latest") {
			    when { expression { artifactOne.buildEnabled == true } }
			    steps {
				// Ubuntu Promoting Build image.
				// Note that latest is only promoted on master branch
				script {
				    if  (env.BRANCH_NAME.startsWith('PR')) {
					// Choose wqhat we do when it is a Pull Request
					echo "PR Branch, no promotion or pushing to registry"
				    } else {
					// Tag and Promote versioned image
					echo "Promote Latest: Tag then push versioned build image for private Docker Repository:  "
					tagDockerImageForAveshaRegistry( artifactOne.dockerBuildImageNameVer,
									artifactOne.dockerBuildImageNameVer)
					pushDockerImageToAveshaRegistry(artifactOne.dockerBuildImageNameVer)

					// Remove the image tagged for the docker registry
					removeJenkinsDockerImage( artifactOne.dockerBuildImageNameVer, 'true' )

					// Tag and promote versioned image as latest and remove tagged image after successful push
					// Only done if this is master.  There is no equivalent of latest images on non master branch
					echo "Promote Latest: Tag then push latest:" + artifactOne.dockerBuildImageNameVerLatest
					tagDockerImageForAveshaRegistry(artifactOne.dockerBuildImageNameVer,
									artifactOne.dockerBuildImageNameVerLatest)
					pushDockerImageToAveshaRegistry(artifactOne.dockerBuildImageNameVerLatest)
					removeJenkinsDockerImage(artifactOne.dockerBuildImageNameVerLatest, 'true')
				    } // if-else BRANCH is PR
				} // script
			    } // steps
			} // Promote Build and latest image stage

			//
			// Promote Release Versioned Image to Nexus
			//
			stage ("Promote Release versioned image?") {
			    when { expression { artifactOne.buildEnabled == true } }
			    //
			    // only do when branch is master
			    //
			    steps {

				script {
				    if  (env.BRANCH_NAME.startsWith('PR')) {
					// Choose wqhat we do when it is a Pull Request
					echo "PR Branch, no promotion or pushing to registry"
				    } else {
					echo "Do you want to promote the release versioned image"

					// timeout the input for waiting to promote versioned PROD
					timeout(time: 24, unit: 'HOURS') {
					    // May want to allow Release version to be specified in the future
					    def myInput= input (message: "Would you like to Promote Versioned Release image?", ok: "Next Step",
								parameters: [
						    choice(name: 'Promote Versioned Release', choices: ["No Release", "Promote Versioned Release"].join('\n'),
							   description: "Decide whether to promote release to Nexus")
						]
					    )  // input
					    if (myInput == "No Release") {
						echo "Release NOT PROMOTED to Nexus Docker Registry"
					    } else {
						echo "Promoting Versioned "+getAveshaProdName()+" Release: Tagging and pushing Release to Nexus Docker Registry:"
						tagDockerImageForAveshaRegistry(artifactOne.dockerBuildImageNameVer,
										artifactOne.dockerBuildImageNameVerRelease)
						pushDockerImageToAveshaRegistry(artifactOne.dockerBuildImageNameVerRelease)
						removeJenkinsDockerImage(artifactOne.dockerBuildImageNameVerRelease, 'true')
					    } // if myInput
					} // if-else PR Branch
				    } // script
				} // timeout
			    } // steps
			} // Promote Release Versioned Image stage
                    } // stages
		    post {
			// post section for this platform build
			always {
			    sh "docker images"
			    removeJenkinsDockerImage(artifactOne.dockerBuildImageNameVer,'false')
			    cleanWs()
			} // always
		    } // post
		} // Ubuntu Stage

		//
		// Build Platform:  UBUNTU 18.04
		//
		stage ("OpenVPN Server") {
		    // any agent items
		    agent {
			docker {
			    // must identify the proper image to build the platform
			    // TODO: find way to dynamically get this from pipeline.yaml
			    image 'avesha-jenkins-ubuntu:1.0.0'
			}
		    }
		    stages {
			stage('Pipeline Init') {
			    // This snippet will perform what's after if the branch is not master
			    steps {
				// test out some pipelining steps
				script {
				    echo "Running on Branch:  "+env.BRANCH_NAME
				    // Read the main pipeline.yaml file and set the names we need
				    myPipelineCfg = pipelineConfig()
				    globalPlatformList = myPipelineCfg.platforms

				    // set build platforms vars & umage names for use in later stages.
				    artifactOne = setPipelineConfig( globalPlatformList, env.AVESHA_PLATFORM_ARTIFACT_ONE)
				    artifactTwo = setPipelineConfig( globalPlatformList, env.AVESHA_PLATFORM_ARTIFACT_TWO)

				    // Login to the Avsha Docker Registry
				    // this is needed here because images may need to pull images for their docker build
				    aveshaRegistryLogin()
				} // script
				// error  "Nothing to do here for now, we only build for branch:  master"
			    } // steps
			} // stage Pipeline Init

			//
			// Build
			//
			stage ("Build") {
			    when { expression { artifactTwo.buildEnabled == true } }
			    steps {
				logBuildInfo()
				script {
				    // Build the product image
				    buildDockerImage( artifactTwo.dockerBuildImageNameVer,
						     artifactTwo.buildDockerfile,
						     artifactTwo.dockerBuildArgs)
				} //script
			    } // steps
			} // Build RPI Fake build

			//
			// Test
			//
			stage ("Test") {
			    when { expression { artifactTwo.buildEnabled == true } }
			    steps {
				script {
				    echo "Testing image name is:      " + artifactTwo.dockerBuildImageNameVer
				    mySize=getDockerImageSize( artifactTwo.dockerBuildImageNameVer)
				    valid=validateDockerImageSize( mySize,
								  artifactTwo.minDockerImageSize,
								  artifactTwo.maxDockerImageSize)
				    if (valid != true) {
					sh "exit 1"
				    }
				}
				// TODO: add test to load PROD binaries into test docker and validate directories are there as needed.
				// Then we will need to delete test docker.
			    } // steps
			}

			//
			// Promote Build and Latest
			// 
			stage ("Promote Build and Latest") {
			    when { expression { artifactTwo.buildEnabled == true } }
			    steps {
				// UBUNTU_18 Promoting Build image.
				// Note that latest is only promoted on master branch
				script {
				    if  (env.BRANCH_NAME.startsWith('PR')) {
					// Choose wqhat we do when it is a Pull Request
					echo "PR Branch, no promotion or pushing to registry"
				    } else {
					// Tag and Promote versioned image
					echo "Promote Latest: Tag then push versioned build image for private Docker Repository:  "
					tagDockerImageForAveshaRegistry( artifactTwo.dockerBuildImageNameVer,
									artifactTwo.dockerBuildImageNameVer)
					pushDockerImageToAveshaRegistry(artifactTwo.dockerBuildImageNameVer)

					// Remove the image tagged for the docker registry
					removeJenkinsDockerImage( artifactTwo.dockerBuildImageNameVer, 'true' )

					// Tag and promote versioned image as latest and remove tagged image after successful push
					// Only done if this is master.  There is no equivalent of latest images on non master branch
					echo "Promote Latest: Tag then push latest:" + artifactTwo.dockerBuildImageNameVerLatest
					tagDockerImageForAveshaRegistry(artifactTwo.dockerBuildImageNameVer,
									artifactTwo.dockerBuildImageNameVerLatest)
					pushDockerImageToAveshaRegistry(artifactTwo.dockerBuildImageNameVerLatest)
					removeJenkinsDockerImage(artifactTwo.dockerBuildImageNameVerLatest, 'true')
				    } // if-else BRANCH is PR
				} // script
			    } // steps
			} // Promote Build and latest image stage

			//
			// Promote Release Versioned Image to Nexus
			//
			stage ("Promote Release versioned image?") {
			    when { expression { artifactTwo.buildEnabled == true } }
			    //
			    // only do when branch is master
			    //
			    steps {

				script {
				    if  (env.BRANCH_NAME.startsWith('PR')) {
					// Choose wqhat we do when it is a Pull Request
					echo "PR Branch, no promotion or pushing to registry"
				    } else {
					echo "Do you want to promote the release versioned image"

					// timeout the input for waiting to promote versioned PROD
					timeout(time: 24, unit: 'HOURS') {
					    // May want to allow Release version to be specified in the future
					    def myInput= input (message: "Would you like to Promote Versioned Release image?", ok: "Next Step",
								parameters: [
						    choice(name: 'Promote Versioned Release', choices: ["No Release", "Promote Versioned Release"].join('\n'),
							   description: "Decide whether to promote release to Nexus")
						]
					    )  // input
					    if (myInput == "No Release") {
						echo "Release NOT PROMOTED to Nexus Docker Registry"
					    } else {
						echo "Promoting Versioned "+getAveshaProdName()+" Release: Tagging and pushing Release to Nexus Docker Registry:"
						tagDockerImageForAveshaRegistry(artifactTwo.dockerBuildImageNameVer,
										artifactTwo.dockerBuildImageNameVerRelease)
						pushDockerImageToAveshaRegistry(artifactTwo.dockerBuildImageNameVerRelease)
						removeJenkinsDockerImage(artifactTwo.dockerBuildImageNameVerRelease, 'true')
					    } // if myInput
					} // if-else PR Branch
				    } // script
				} // timeout
			    } // steps
			} // Promote Release Versioned Image stage
		    } // stages
		    post {
			// post section for this platform build
			always {
			    sh "docker images"
			    removeJenkinsDockerImage(artifactTwo.dockerBuildImageNameVer,'false')
			    cleanWs()
			} // always
		    } // post
		} // UBUNTU_18  Stage


		//
		// Build Platform:  ALPINE-ARM32V7
		//
		stage ("OpenVPN Client alpine.amd64") {
		    // any agent items
		    agent {
			docker {
			    // must identify the proper image to build the platform
			    // TODO: find way to dynamically get this from pipeline.yaml
			    image 'avesha-jenkins-cross-compile:1.0.0'
			}
		    }
		    stages {
			stage('Pipeline Init') {
			    // This snippet will perform what's after if the branch is not master
			    steps {
				// test out some pipelining steps
				script {
				    echo "Running on Branch:  "+env.BRANCH_NAME
				    // Read the main pipeline.yaml file and set the names we need
				    myPipelineCfg = pipelineConfig()
				    globalPlatformList = myPipelineCfg.platforms

				    // set build platforms vars & umage names for use in later stages.
				    artifactOne = setPipelineConfig( globalPlatformList, env.AVESHA_PLATFORM_ARTIFACT_ONE)
				    artifactTwo = setPipelineConfig( globalPlatformList, env.AVESHA_PLATFORM_ARTIFACT_TWO)
				    artifactThree = setPipelineConfig( globalPlatformList, env.AVESHA_PLATFORM_ARTIFACT_THREE)
				    
				    // Login to the Avsha Docker Registry
				    // this is needed here because images may need to pull images for their docker build
				    aveshaRegistryLogin()
				} // script
				// error  "Nothing to do here for now, we only build for branch:  master"
			    } // steps
			} // stage Pipeline Init

			//
			// Build
			//
			stage ("Build") {
			    when { expression { artifactThree.buildEnabled == true } }
			    steps {
				logBuildInfo()
				script {
				    // Build the product image
				    buildDockerImage( artifactThree.dockerBuildImageNameVer,
						     artifactThree.buildDockerfile,
						     artifactThree.dockerBuildArgs)
				} //script
			    } // steps
			} // Build RPI Fake build

			//
			// Test
			//
			stage ("Test") {
			    when { expression { artifactThree.buildEnabled == true } }
			    steps {
				script {
				    echo "Testing image name is:      " + artifactThree.dockerBuildImageNameVer
				    mySize=getDockerImageSize( artifactThree.dockerBuildImageNameVer)
				    valid=validateDockerImageSize( mySize,
								  artifactThree.minDockerImageSize,
								  artifactThree.maxDockerImageSize)
				    if (valid != true) {
					sh "exit 1"
				    }
				}
				// TODO: add test to load PROD binaries into test docker and validate directories are there as needed.
				// Then we will need to delete test docker.
			    } // steps
			}

			//
			// Promote Build and Latest
			// 
			stage ("Promote Build and Latest") {
			    when { expression { artifactThree.buildEnabled == true } }
			    steps {
				// UBUNTU_18 Promoting Build image.
				// Note that latest is only promoted on master branch
				script {
				    if  (env.BRANCH_NAME.startsWith('PR')) {
					// Choose wqhat we do when it is a Pull Request
					echo "PR Branch, no promotion or pushing to registry"
				    } else {
					// Tag and Promote versioned image
					echo "Promote Latest: Tag then push versioned build image for private Docker Repository:  "
					tagDockerImageForAveshaRegistry( artifactThree.dockerBuildImageNameVer,
									artifactThree.dockerBuildImageNameVer)
					pushDockerImageToAveshaRegistry(artifactThree.dockerBuildImageNameVer)

					// Remove the image tagged for the docker registry
					removeJenkinsDockerImage( artifactThree.dockerBuildImageNameVer, 'true' )

					// Tag and promote versioned image as latest and remove tagged image after successful push
					// Only done if this is master.  There is no equivalent of latest images on non master branch
					echo "Promote Latest: Tag then push latest:" + artifactThree.dockerBuildImageNameVerLatest
					tagDockerImageForAveshaRegistry(artifactThree.dockerBuildImageNameVer,
									artifactThree.dockerBuildImageNameVerLatest)
					pushDockerImageToAveshaRegistry(artifactThree.dockerBuildImageNameVerLatest)
					removeJenkinsDockerImage(artifactThree.dockerBuildImageNameVerLatest, 'true')
				    } // if-else BRANCH is PR
				} // script
			    } // steps
			} // Promote Build and latest image stage

			//
			// Promote Release Versioned Image to Nexus
			//
			stage ("Promote Release versioned image?") {
			    when { expression { artifactThree.buildEnabled == true } }
			    //
			    // only do when branch is master
			    //
			    steps {

				script {
				    if  (env.BRANCH_NAME.startsWith('PR')) {
					// Choose wqhat we do when it is a Pull Request
					echo "PR Branch, no promotion or pushing to registry"
				    } else {
					echo "Do you want to promote the release versioned image"

					// timeout the input for waiting to promote versioned PROD
					timeout(time: 24, unit: 'HOURS') {
					    // May want to allow Release version to be specified in the future
					    def myInput= input (message: "Would you like to Promote Versioned Release image?", ok: "Next Step",
								parameters: [
						    choice(name: 'Promote Versioned Release', choices: ["No Release", "Promote Versioned Release"].join('\n'),
							   description: "Decide whether to promote release to Nexus")
						]
					    )  // input
					    if (myInput == "No Release") {
						echo "Release NOT PROMOTED to Nexus Docker Registry"
					    } else {
						echo "Promoting Versioned "+getAveshaProdName()+" Release: Tagging and pushing Release to Nexus Docker Registry:"
						tagDockerImageForAveshaRegistry(artifactThree.dockerBuildImageNameVer,
										artifactThree.dockerBuildImageNameVerRelease)
						pushDockerImageToAveshaRegistry(artifactThree.dockerBuildImageNameVerRelease)
						removeJenkinsDockerImage(artifactThree.dockerBuildImageNameVerRelease, 'true')
					    } // if myInput
					} // if-else PR Branch
				    } // script
				} // timeout
			    } // steps
			} // Promote Release Versioned Image stage
		    } // stages
		    post {
			// post section for this platform build
			always {
			    sh "docker images"
			    removeJenkinsDockerImage(artifactThree.dockerBuildImageNameVer,'false')
			    cleanWs()
			} // always
		    } // post
		} // ALPINE-ARM32V7  Stage



		//
		// Build Platform:  ALPINE-AMD64
		//
		stage ("OpenVPN Client alpine.arm32v7") {
		    // any agent items
		    agent {
			docker {
			    // must identify the proper image to build the platform
			    // TODO: find way to dynamically get this from pipeline.yaml
			    image 'avesha-jenkins-ubuntu:1.0.0'
			}
		    }
		    stages {
			stage('Pipeline Init') {
			    // This snippet will perform what's after if the branch is not master
			    steps {
				// test out some pipelining steps
				script {
				    echo "Running on Branch:  "+env.BRANCH_NAME
				    // Read the main pipeline.yaml file and set the names we need
				    myPipelineCfg = pipelineConfig()
				    globalPlatformList = myPipelineCfg.platforms

				    // set build platforms vars & umage names for use in later stages.
				    artifactOne = setPipelineConfig( globalPlatformList, env.AVESHA_PLATFORM_ARTIFACT_ONE)
				    artifactTwo = setPipelineConfig( globalPlatformList, env.AVESHA_PLATFORM_ARTIFACT_TWO)
				    artifactThree = setPipelineConfig( globalPlatformList, env.AVESHA_PLATFORM_ARTIFACT_THREE)
				    artifactFour = setPipelineConfig( globalPlatformList, env.AVESHA_PLATFORM_ARTIFACT_FOUR)
				    
				    // Login to the Avsha Docker Registry
				    // this is needed here because images may need to pull images for their docker build
				    aveshaRegistryLogin()
				} // script
				// error  "Nothing to do here for now, we only build for branch:  master"
			    } // steps
			} // stage Pipeline Init

			//
			// Build
			//
			stage ("Build") {
			    when { expression { artifactFour.buildEnabled == true } }
			    steps {
				logBuildInfo()
				script {
				    // Build the product image
				    buildDockerImage( artifactFour.dockerBuildImageNameVer,
						     artifactFour.buildDockerfile,
						     artifactFour.dockerBuildArgs)
				} //script
			    } // steps
			} // Build RPI Fake build

			//
			// Test
			//
			stage ("Test") {
			    when { expression { artifactFour.buildEnabled == true } }
			    steps {
				script {
				    echo "Testing image name is:      " + artifactFour.dockerBuildImageNameVer
				    mySize=getDockerImageSize( artifactFour.dockerBuildImageNameVer)
				    valid=validateDockerImageSize( mySize,
								  artifactFour.minDockerImageSize,
								  artifactFour.maxDockerImageSize)
				    if (valid != true) {
					sh "exit 1"
				    }
				}
				// TODO: add test to load PROD binaries into test docker and validate directories are there as needed.
				// Then we will need to delete test docker.
			    } // steps
			}

			//
			// Promote Build and Latest
			// 
			stage ("Promote Build and Latest") {
			    when { expression { artifactFour.buildEnabled == true } }
			    steps {
				// UBUNTU_18 Promoting Build image.
				// Note that latest is only promoted on master branch
				script {
				    if  (env.BRANCH_NAME.startsWith('PR')) {
					// Choose wqhat we do when it is a Pull Request
					echo "PR Branch, no promotion or pushing to registry"
				    } else {
					// Tag and Promote versioned image
					echo "Promote Latest: Tag then push versioned build image for private Docker Repository:  "
					tagDockerImageForAveshaRegistry( artifactFour.dockerBuildImageNameVer,
									artifactFour.dockerBuildImageNameVer)
					pushDockerImageToAveshaRegistry(artifactFour.dockerBuildImageNameVer)

					// Remove the image tagged for the docker registry
					removeJenkinsDockerImage( artifactFour.dockerBuildImageNameVer, 'true' )

					// Tag and promote versioned image as latest and remove tagged image after successful push
					// Only done if this is master.  There is no equivalent of latest images on non master branch
					echo "Promote Latest: Tag then push latest:" + artifactFour.dockerBuildImageNameVerLatest
					tagDockerImageForAveshaRegistry(artifactFour.dockerBuildImageNameVer,
									artifactFour.dockerBuildImageNameVerLatest)
					pushDockerImageToAveshaRegistry(artifactFour.dockerBuildImageNameVerLatest)
					removeJenkinsDockerImage(artifactFour.dockerBuildImageNameVerLatest, 'true')
				    } // if-else BRANCH is PR
				} // script
			    } // steps
			} // Promote Build and latest image stage

			//
			// Promote Release Versioned Image to Nexus
			//
			stage ("Promote Release versioned image?") {
			    when { expression { artifactFour.buildEnabled == true } }
			    //
			    // only do when branch is master
			    //
			    steps {

				script {
				    if  (env.BRANCH_NAME.startsWith('PR')) {
					// Choose wqhat we do when it is a Pull Request
					echo "PR Branch, no promotion or pushing to registry"
				    } else {
					echo "Do you want to promote the release versioned image"

					// timeout the input for waiting to promote versioned PROD
					timeout(time: 24, unit: 'HOURS') {
					    // May want to allow Release version to be specified in the future
					    def myInput= input (message: "Would you like to Promote Versioned Release image?", ok: "Next Step",
								parameters: [
						    choice(name: 'Promote Versioned Release', choices: ["No Release", "Promote Versioned Release"].join('\n'),
							   description: "Decide whether to promote release to Nexus")
						]
					    )  // input
					    if (myInput == "No Release") {
						echo "Release NOT PROMOTED to Nexus Docker Registry"
					    } else {
						echo "Promoting Versioned "+getAveshaProdName()+" Release: Tagging and pushing Release to Nexus Docker Registry:"
						tagDockerImageForAveshaRegistry(artifactFour.dockerBuildImageNameVer,
										artifactFour.dockerBuildImageNameVerRelease)
						pushDockerImageToAveshaRegistry(artifactFour.dockerBuildImageNameVerRelease)
						removeJenkinsDockerImage(artifactFour.dockerBuildImageNameVerRelease, 'true')
					    } // if myInput
					} // if-else PR Branch
				    } // script
				} // timeout
			    } // steps
			} // Promote Release Versioned Image stage
		    } // stages
		    post {
			// post section for this platform build
			always {
			    sh "docker images"
			    removeJenkinsDockerImage(artifactFour.dockerBuildImageNameVer,'false')
			    cleanWs()
			} // always
		    } // post
		} // ALPINE-AMD64  Stage
	    } // parallel
        } // stage

    } // stages

    // TODO:  Enhance cleanup and exit code
    post {
        aborted {
            echo "ABORTED BY USER"
        }
        success {
            echo "SUCCESS"
        }
        failure {
            echo "FAILURE"
        }
        changed {
            echo "Status Changed: [From: $currentBuild.previousBuild.result, To: $currentBuild.result]"
        }
        always {
            script {
		// sh "docker images"
		def result = currentBuild.result
		if (result == null) {
		    result = "SUCCESS"
		}
            }
	    // cleanWs() // only use this if the agent is specified at the pipeline level.
        } // always
    } // post
} // pipeline
