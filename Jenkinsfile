pipeline {
    agent any

    parameters {
        booleanParam(name: 'skip_test', defaultValue: false, description: 'Skip Sonarqube Analysis?')
        string(name: 'EC2_HOSTA', description: 'Server A IP', defaultValue: '54.199.149.31')
        string(name: 'EC2_HOSTB', description: 'Server B IP', defaultValue: '18.183.213.61')
        booleanParam(name: 'SERVER_A', defaultValue: true, description: 'Deploy to Server A?')
        booleanParam(name: 'SERVER_B', defaultValue: true, description: 'Deploy to Server B?')
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

        stage('Build') {
            steps {
                sh "mvn clean package"
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
                    timeout(time: 5, unit: 'MINUTES') {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }
                }
            }
        }

        stage('Test') {
            steps {
                sh "mvn test"
            }
        }

        stage('CD to Server A') {
            when {
                expression { params.SERVER_A == true }
            }
            steps {
                sshagent(credentials: ['akhil-p1-ssh-key']) {
                    // Use scp to transfer the WAR file(s)
                    sh '''
                        [ -d ~/.ssh ] || mkdir ~/.ssh && chmod 0700 ~/.ssh
                        ssh-keyscan -t rsa,dsa ${EC2_HOSTA} >> ~/.ssh/known_hosts
                        scp *.war ubuntu@${EC2_HOSTA}:/var/lib/tomcat9/webapps/ROOT.war
                    '''
                }
            }
        }

        stage('CD to Server B') {
            when {
                expression { params.SERVER_B == true }
            }
            steps {
                sshagent(credentials: ['akhil-p1-ssh-key']) {
                    // Use scp to transfer the WAR file(s)
                    sh '''
                        [ -d ~/.ssh ] || mkdir ~/.ssh && chmod 0700 ~/.ssh
                        ssh-keyscan -t rsa,dsa ${EC2_HOSTB} >> ~/.ssh/known_hosts
                        scp *.war ubuntu@${EC2_HOSTB}:/var/lib/tomcat9/webapps/ROOT.war
                    '''
                }
            }
        }
    }
}
