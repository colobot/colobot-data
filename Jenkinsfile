#!/usr/bin/env groovy

pipeline {
    agent { label 'colobot-build' }
    options {
        buildDiscarder(logRotator(artifactDaysToKeepStr: '30', artifactNumToKeepStr: '5'))
    }
    stages {
        stage('Check pull request target') {
            when { changeRequest() }
            steps {
                script {
                    if (env.CHANGE_TARGET == 'master') {
                        throw "This pull request targets the wrong branch. Please reopen the pull request targetting the dev branch."
                    }
                }
            }
        }
        stage('Build data') {
            steps {
                sh '''
                    cmake -DCMAKE_INSTALL_PREFIX=/install -DCOLOBOT_INSTALL_DATA_DIR=/install/data ..
                    make
                    rm -rf install
                    DESTDIR=. make install
                '''
            }
        }

        stage('Archive data') {
            steps {
                sh 'rm -f data.zip'
                zip zipFile: 'data.zip', archive: true, dir: 'build/install'
            }
        }
    }
}
