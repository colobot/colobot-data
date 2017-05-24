#!/usr/bin/env groovy
if (env.BRANCH_NAME.startsWith('PR-')) {
    properties([[$class: 'BuildDiscarderProperty', strategy: [$class: 'LogRotator', artifactNumToKeepStr: '1']]])
} else {
    properties([[$class: 'BuildDiscarderProperty', strategy: [$class: 'LogRotator', artifactDaysToKeepStr: '30', artifactNumToKeepStr: '5']]])
}

node('master') {
    stage('Pull changes') {
        checkout scm
    }

    stage('Build data') {
        sh 'mkdir -p build'
        dir('build') {
            sh '''
                cmake -DCMAKE_INSTALL_PREFIX=/install -DCOLOBOT_INSTALL_DATA_DIR=/install/data ..
                make
                rm -rf install
                DESTDIR=. make install
            '''
        }
    }

    stage('Archive data') {
        sh 'rm -f data.zip'
        zip zipFile: 'data.zip', archive: true, dir: 'build/install'
    }

    // Clean workspace after building pull requests
    // to save disk space on the Jenkins host
    if (env.BRANCH_NAME.startsWith('PR-')) {
        cleanWs()
    }
}
