#!groovy


//Controls how many builds are kept in Jenkins. Adjust to taste.
properties([
		[$class: 'BuildDiscarderProperty', strategy: [$class: 'LogRotator', numToKeepStr: '10']]
])

env.ENVIRONMENT = params.ENV
env.ZK_HOST = ['Development': 'zoo1:2181', 'QA': 'QA_ZK', 'Production': 'PROD_ZK'][env.ENVIRONMENT]

	pipeline {
		agent any
		parameters {
			choice(name: 'ENV', choices: ['Development', 'QA', 'Production'], description: 'Enter the environment you want to deploy to')
				extendedChoice(defaultValue: '', description: '', descriptionPropertyValue: '', multiSelectDelimiter: ',', name: 'CollectionValues', quoteValue: false, saveJSONParameterToFile: false, type: 'PT_CHECKBOX', value: 'paycore, workercore, skillcore, clientcore, projectcore, workcore, paycore2, groupcore', visibleItemCount: 8)
		}
		stages {
			stage('build') {
				steps {
					checkout scm
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


			stage('deploy-managed-schema') {
				when {
					expression {
						params.CollectionValues.split(",").size() > 0
					}
				}
				steps {

					sh 'echo "Deploying managed schema"'
						echo params.ENV
						echo env.ZK_HOST
						echo "${params.CollectionValues}"
						sh 'echo "Print the ZKHOST variable value here: ${ZK_HOST}"'
						script {
							def collections_list = params.CollectionValues.split(",")
								docker.image('solr:8.8.1').inside(){
									for (collection in collections_list) {
										echo "Got collection: " + collection
										sh "solr zk rm /configs/${collection}/managed-schema -z ${env.ZK_HOST}"
                    sh "solr zk upconfig -n ${collection} -d configsets/${collection} -z ${env.ZK_HOST}"
									}
								}
						}
				}
			}

		}

		post {
			always {
				echo 'Solr Jenkinsfile execution complete'
			}
			success {
				echo 'Solr Jenkinsfile execution completed successfully'
			}
			failure {
				echo 'Solr Jenkinsfile execution has failed'
			}
			unstable {
				echo 'This execution was marked as unstable'
			}
			changed {
				echo 'The state of the Pipeline has changed from previous execution'
			}
		}
	}
