#!groovy
 pipeline {

     agent {
         label 'ci-slave-docker-01'
     }

     environment {

         def config = readYaml file: "${WORKSPACE}/build/build.yaml"

         // Registry infos
         registryUrl = "${config.registry.url}"
         registryCredentialsId = "${config.registry.credentialsId}"

         // Master information
         masterImageName = "${config.registry.home}/${config.registry.namespace}/${config.app.name}"
         masterSrcPackageName = "${config.app.name}-src"
         masterBinPackageName = "${config.app.name}-bin"

         // Push to registry ?
         pushFeatureToRegistry = "${config.delivery.features.pushToRegistry}"
         pushRCToRegistry = "${config.delivery.realeaseCandidate.pushToRegistry}"
         pushSnapshotToRegistry = "${config.delivery.snapshot.pushToRegistry}"
         pushMasterToRegistry = "${config.delivery.master.pushToRegistry}"

     }

     stages {


         stage('Setting build environement') {
             steps {

             echo sh(script: 'env|sort', returnStdout: true)

                 script{

                     versionfile = "${WORKSPACE}/build/version.yaml"
                     versiondata = readYaml file: versionfile

                     if ( env.BRANCH_NAME.startsWith("feature") ) {
                         echo 'handle features'
                         branchName = "${env.BRANCH_NAME}"
                         branchVersion = branchName.replaceAll('/','_')

                         version = "${versiondata.version.major}.${versiondata.version.minor}"

                         featureVersion = "${version}-${branchVersion}"

                         env.buildTag = "${env.masterImageName}:v${featureVersion}"
                         env.pushToRegistry = "${env.pushFeatureToRegistry}"
                     }

                     if ( env.BRANCH_NAME == "develop" ) {
                         echo 'handle develop'

                         version = "${versiondata.version.major}.${versiondata.version.minor}"

                         snapshotVersion = "${version}-SNAPSHOT"

                         env.buildTag = "${env.masterImageName}:v${snapshotVersion}"
                         env.pushToRegistry = "${env.pushSnapshotToRegistry}"
                     }
                     if ( env.BRANCH_NAME.startsWith("release") ) {
                         echo 'handle release'

                         branchName = "${env.BRANCH_NAME}"
                         branchVersion = branchName.replaceAll('/','_')

                         version = "${versiondata.version.major}.${versiondata.version.minor}"

                         rcVersion = "${version}-RC"

                         env.buildTag = "${env.masterImageName}:v${rcVersion}"
                         env.pushToRegistry = "${env.pushRCToRegistry}"

                     }
                     if ( env.BRANCH_NAME == "master" ) {
                         echo 'handle master'

                         version = "${versiondata.version.major}.${versiondata.version.minor}"

                         env.buildTag = "${env.masterImageName}:v${version}"
                         env.pushToRegistry = "${env.pushMasterToRegistry}"

                     }

                     sh 'echo ${BRANCH_NAME}'
                     sh 'echo ${pushToRegistry}'

                 }
             }
         }

         stage('Build docker image') {
             when {
                 expression { "${env.pushToRegistry}" == "true" }
             }

             steps {
                 script {
                     withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: env.registryCredentialsId,
                         usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {

                         sh "docker login ${env.registryUrl} -u ${USERNAME} -p ${PASSWORD}"
                         sh "docker build -t ${env.buildTag} ."
                         sh "docker push ${env.buildTag}"

                     }
                 }
             }
         }
     }
     /*
     post {
         success {
             rocketSend channel: 'c4-platine', message: 'Pipeline is in success', emoji:':thumbsup:'
         }

         failure {
             rocketSend channel: 'c4-platine', message: 'Pipeline is in failure', emoji:':thumbsdown:'
         }

         unstable {
             sh 'echo "Unstable !"'
         }

         always {
             cleanWs()
         }
     }
     */

  }
