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
                //sh 'sudo docker --version'
            }
        }
        
        stage('Remove Existing Sphinx Containers') {
            steps {
                sh """
                    sudo docker container rm sphinx
                """
            }
        }
        
        stage('Sphinx Doc Setup') {
            steps {
                sh """
                    sudo ls -la
                    sudo rm /docs/* -R
                    sudo cp ./* /docs/ -R
                    sudo ls -la /docs/
                """
            }
        }
        
        stage('Run Sphinx') {
            steps {
                sh """
                    sudo docker run --rm -v /docs:/docs localhost:5000/sphinx-latexpdf:4.5.0 make html
                """
            }
        }      
    }
}
