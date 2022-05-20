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
                sh """
                    echo 'Show running user'
                    whoami                
                    echo 'Test and Setup'
                    echo 'Show Java version'
                    sudo java --version
                    echo 'Show Docker version'
                    sudo docker --version
                    echo 'Show PWD'
                    sudo pwd
                    echo 'Show dir contents'
                    sudo ls -la
                """                

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
