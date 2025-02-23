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

			stage('deploy-managed-schema') {
				when {
					expression {
						params.CollectionValues && params.CollectionValues.split(",").size() > 0
					}
				}
				steps {

					sh 'echo "Deploying managed schema for ${params.CollectionValues} on ${ENVIRONMENT} with zookeeper host variable: ${ZK_HOST}"'
						echo "${params.CollectionValues}"
						script {
							def collections_list = params.CollectionValues.split(",")
								docker.image('solr:8.8.1').inside('--net solr_881_solr'){
									input 'stop'
										solr_admin=sh (script: "solr zk ls /live_nodes -z ${ZK_HOST}", returnStdout: true).find(/[^_]*/)
										for (collection in collections_list) {
											echo "Got collection: " + collection
												try {
													sh "solr zk rm /configs/${collection}/managed-schema -z ${ZK_HOST}"
												} catch  (Exception e) {
													echo 'Exception: '+ e.toString()
												}
											sh "solr zk upconfig -n ${collection} -d configsets/${collection} -z ${ZK_HOST}"
										}
								}
						}
				}
			}

			stage('reload-collections') {
				steps {
					  sh 'echo "Reloading all collections on ${ENVIRONMENT} with zookeeper host variable: ${ZK_HOST}"'
						script {
							docker.image('solr:8.8.1').inside('--net solr_881_solr') {
								solr_admin=sh (script: "solr zk ls /live_nodes -z ${ZK_HOST}", returnStdout: true).find(/[^_]*/)
								solr_json = sh (label: 'Retrieve Collections List', script :"curl -s -k http://${solr_admin}/solr/admin/collections?action=LIST",returnStdout: true)
								echo "${solr_json}"
								build_map = readJSON(text: solr_json)
								solr_collections_list = build_map['collections']
								echo "${solr_collections_list}"
								for (collection in solr_collections_list) {
									url = "http://${solr_admin}/solr/admin/collections?action=RELOAD\\&name=${collection}"
									echo "Solr core url to be reloaded: " + url
									sh "curl -s -k -v ${url}"
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
