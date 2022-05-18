pipeline {
    agent any
    options {
        timeout(time: 20, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '25'))
    }

    environment {
        TIMESTAMP = "$BUILD_TIMESTAMP"               
    }

    stages {
        stage('Test and Debug Info') {
            steps {
                echo 'Test and Setup'
                echo 'Show Docker version'
                sh 'docker --version'
            }
        }
        stage('Remove Existing Sphinx Containers') {
            steps {
                sh """
                    docker container rm sphinx
                """
            }      
        stage('Sphinx Doc Setup') {
            steps {
                sh """
                    ls -la
                    rm /docs/* -R
                    cp ./* /docs/ -R
                    ls -la /docs/
                """
            }
        }
        stage('Run Sphinx') {
            steps {
                sh """
                    docker run --rm -v /docs:/docs localhost:5000/sphinx-latexpdf:4.5.0 make html
                """
            }
        }      
    }
}
