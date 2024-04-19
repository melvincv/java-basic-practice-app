pipeline {
    agent any

    parameters {
        booleanParam(name: 'skip_test', defaultValue: false, description: 'Skip Sonarqube Analysis?')
    }
    
    tools {
        maven "maven3.9"
    }

    stages {
        
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/melvincv/java-basic-practice-app.git'
            }
        }

        stage("Code Quality"){
            when {
                expression { params.skip_test != true }
            }
            steps{
                script {
                    withSonarQubeEnv(installationName: 'sonar', credentialsId: 'sonar-token') {
                        sh 'mvn sonar:sonar'
                    }
                    timeout(time: 1, unit: 'HOURS') {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }
                }
            }
        }

        stage('Build') {
            steps {
                sh "mvn clean package"
            }
        }
        
        stage('Test') {
            steps {
                sh "mvn test"
            }
        }
    }
}