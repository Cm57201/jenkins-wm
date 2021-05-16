#!groovy


//Controls how many builds are kept in Jenkins. Adjust to taste.
properties([
		[$class: 'BuildDiscarderProperty', strategy: [$class: 'LogRotator', numToKeepStr: '10']]
])

	env.ENVIRONMENT = params.ENV
	env.ENVIRONMENT_TAG = ['development': 'Development', 'qa': 'QA', 'production': 'Production'][env.ENVIRONMENT]
	pipeline {
		agent {
			docker {
				image 'maven:3.3.3'
			}
		}
		parameters {
			choice(name: 'ENV', choices: ['development', 'qa', 'production'], description: 'Enter the environment you want to deploy to')
				extendedChoice(defaultValue: '', description: '', descriptionPropertyValue: '', multiSelectDelimiter: ',', name: 'CollectionValues', quoteValue: false, saveJSONParameterToFile: false, type: 'PT_CHECKBOX', value: 'paycore, workercore, skillcore, clientcore, projectcore, workcore, paycore2, groupcore', visibleItemCount: 8)
		}
		stages {
			stage('build') {
				steps {
					sh 'mvn --version'
				}
			}
			stage('rebuild-pod') {
				when {
					anyOf {
						changeset "values.yaml"
							changeset "values.*.yaml"
					}
				}
				steps {
					sh 'date'
						sh 'echo "===========>KubeDeploy"'
				}
			}

			stage('check-selected-collections') {
				steps {
					script {
						if (!params.CollectionValues?.trim()) {
							echo "Atleast one collection has to be selected"
								currentBuild.result = "FAIL"
								return
						}
					}
				}
			}
			stage('install-docker') {
				agent {
					docker {
						image 'solr:8.8.1'
					}
				}
				steps {
				  input 'stop'
					sh 'bin/solr version'
				}
			}


		}

		post {
			always {
				echo 'This will always run'
			}
			success {
				echo 'This will run only if successful'
			}
			failure {
				echo 'This will run only if failed'
			}
			unstable {
				echo 'This will run only if the run was marked as unstable'
			}
			changed {
				echo 'This will run only if the state of the Pipeline has changed'
					echo 'For example, if the Pipeline was previously failing but is now successful'
			}
		}
	}
