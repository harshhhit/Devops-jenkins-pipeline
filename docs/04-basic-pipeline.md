# Basic Pipeline

Status: `Jenkinsfile` created in the repo root. The Jenkins job itself is not set up yet.

A declarative pipeline defined in a `Jenkinsfile` in the repo (pipeline as code). It checks out, scans with Trivy, then deploys.

## Jenkinsfile

```groovy
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
```

## Create

1. **New Item**, name `website-pipeline`, type **Pipeline**.
2. **Pipeline**: *Pipeline script from SCM*, Git, repo URL, script path `Jenkinsfile`.
3. Commit the `Jenkinsfile`, then **Build Now**.

Prerequisite: Trivy installed in Jenkins (see [setup](01-setup.md)).

`--exit-code 0` makes the scan report only. Change it to `1` to fail the build on findings.
