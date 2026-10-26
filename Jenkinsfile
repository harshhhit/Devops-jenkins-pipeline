pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }
        stage('Trivy FS Scan') {
            steps {
                sh 'trivy fs --severity HIGH,CRITICAL --exit-code 0 website/'
            }
        }
        stage('Deploy') {
            steps {
                sh '''
                  rm -rf /var/jenkins_home/deployment/*
                  cp -r website/* /var/jenkins_home/deployment/
                '''
            }
        }
    }

    post {
        success { echo 'Deployed to http://localhost:8081' }
        failure { echo 'Pipeline failed' }
    }
}
