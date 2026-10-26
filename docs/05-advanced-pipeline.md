# Advanced Pipeline

Status: planned, not yet created.

Adds code-quality analysis, a quality gate, image scanning, a failing security gate, and a manual approval before deploy.

## Prerequisites

- Trivy in Jenkins (see [setup](01-setup.md))
- Jenkins plugins: *SonarQube Scanner*, *Pipeline*, *Git*
- SonarQube: create a project and a token (My Account, Security)
- Jenkins:
  - Add the token as a **Secret text** credential with id `sonar-token`
  - Configure the server under *Manage Jenkins, System, SonarQube servers*, name `sonarqube`, URL `http://sonarqube:9000` (containers reach each other by service name)
  - Add *SonarScanner* under *Manage Jenkins, Tools*, name `sonar-scanner`
- To scan the Nginx image you need the Docker CLI and socket inside Jenkins. That is a security trade-off, so skip the image stage if you do not want it.

## Jenkinsfile

```groovy
pipeline {
    agent any

    environment {
        IMAGE = 'website-nginx:latest'
    }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh '''
                      ${tool 'sonar-scanner'}/bin/sonar-scanner \
                        -Dsonar.projectKey=website \
                        -Dsonar.sources=website
                    '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Trivy FS Scan') {
            steps {
                sh 'trivy fs --severity HIGH,CRITICAL --exit-code 1 website/'
            }
        }

        stage('Build and Scan Image') {
            steps {
                sh 'docker build -t $IMAGE .'
                sh 'trivy image --severity HIGH,CRITICAL --exit-code 1 $IMAGE'
            }
        }

        stage('Approval') {
            steps {
                input message: 'Deploy to production?'
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
        always {
            sh 'trivy fs --format json -o trivy-report.json website/ || true'
            archiveArtifacts artifacts: 'trivy-report.json', allowEmptyArchive: true
        }
    }
}
```

The `${tool ...}` call in the Sonar stage uses Groovy interpolation. If it errors, switch the `sh` block to double-quoted triple quotes (`"""`) or set the scanner path in a variable first.

## Comparison

| | Freestyle | Basic pipeline | Advanced pipeline |
|---|---|---|---|
| Config stored in | Jenkins UI | `Jenkinsfile` in Git | `Jenkinsfile` in Git |
| Trivy scan | No | Report only | Fails the build |
| SonarQube + quality gate | No | No | Yes |
| Image scan | No | No | Yes |
| Manual approval | No | No | Yes |
| Reports archived | No | No | Yes |
