#!/usr/bin/groovy
pipeline {
    parameters {
        choice choices: ['windows', 'linux', 'darwin'], description: 'GO OS build', name: 'GOOS'
        choice choices: ['amd64', '386'], description: 'Platform ARCH', name: 'GOARCH'
    }

    agent {
        label "node"
    }
    stages {
        stage("fetch from scm") {
            steps {
                echo "======== Git fetching========"
                git "https://github.com/ayoubelmaaradi/golang-ci.git"
            }
            post {
                always {
                    echo "========always========"
                }
                success {
                    echo "========A executed successfully========"
                }
                failure {
                    echo "========A execution failed========"
                }
            }
        }
        stage("Build") {
            steps {
                echo "======== Executing go build in docker ========"
                sh "docker build -t xen0077/golang-ci:${GOARCH}_${GOOS} --build-arg GOARCHARG=${GOARCH} GOOSARG=${GOOS} ."
            }
            post {
                always {
                    echo "========always========"
                }
                success {
                    echo "======== push to registry========"
                    withCredentials([usernamePassword(credentialsId: 'DOCKER_HUB_CREDS_AYOUB', passwordVariable: 'docker_password', usernameVariable: 'docker_username')]) {
                        sh "docker login -u ${docker_username} -p ${docker_password}"
                        sh "docker push xen0077/golang-ci:${GOOS}_${GOARCH}"
                    }

                }
                failure {
                    echo "========A execution failed========"
                }
            }
        }
    }
    post {
        success {
            echo "========pipeline executed successfully ========"
            sh "docker run --name golang-ci-${GOOS}_${GOARCH} -v output:/app/golan-app xen0077/golang-ci:${GOOS}_${GOARCH}"
            sh "sudo docker cp golang-ci:${GOOS}_${GOARCH}:/app/artifacts ."
        }
        failure {
            echo "========pipeline execution failed========"
        }
    }
}
