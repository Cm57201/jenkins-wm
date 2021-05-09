#!groovy

def collections = ['paycore', 'workercore', 'skillcore', 'clientcore', 'projectcore', 'workcore', 'paycore2', 'groupcore']

//Controls how many builds are kept in Jenkins. Adjust to taste.
properties([
		[$class: 'BuildDiscarderProperty', strategy: [$class: 'LogRotator', numToKeepStr: '10']],
		parameters(
			collections.collect({ booleanParam( name: it )}) +
			[choice(name: 'ENV', choices: ['development', 'qa', 'production'], description: 'Enter the environment you want to deploy to')]
			)
])

env.ENVIRONMENT = params.ENV
env.ENVIRONMENT_TAG = ['development': 'Development', 'qa': 'QA', 'production': 'Production'][env.ENVIRONMENT]

pipeline {
	agent { docker { image 'maven:3.3.3' } }
	stages {
		stage('build') {
			steps {
				sh 'mvn --version'
			}
		}
		stage('rebuild-pod'){
			when {
				anyOf {
					changeset "values.yaml"
						changeset "values.*.yaml"
				}
			}			
			steps {
				sh 'date'
					sh	'echo "===========>KubeDeploy"'			
			}
		}
		stage('deploy-managedschema'){
			steps {
				sh 'echo "Deploying managed schema"'
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
