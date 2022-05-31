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
                    echo 'Test and Setup'
                    echo 'Show running user'
                    whoami                
                    echo 'Show Java version'
                    java --version
                    echo 'Show Docker version'
                    docker --version
                    echo 'Show PWD'
                    pwd
                    echo 'Show dir contents'
                    ls -la
                """                

            }
        }
        
        stage('Remove Existing Sphinx Containers') {
            steps {
                sh """
                    sudo docker container stop sphinx || true
                    sudo docker container rm sphinx || true 
                    # the 'true' makes this pass every time
                    # So if the container isn't present and these commands fail it doesn't break the build
                """
            }
        }
        
        stage('Sphinx Doc Setup') {
            steps {
                sh """
                    ls -la
                    sudo rm /docs/* -R || true #true - won't fail if non-existent
                    sudo mkdir /docs || true
                    sudo chmod 777 /docs
                    sudo cp ./* /docs/ -R
                    ls -la /docs/
                """
            }
        }
        
        stage('Build Sphinx Artifacts') {
            steps {
                sh """
                    sudo docker run --rm -v /docs:/docs --name sphinx localhost:5000/sphinx-latexpdf:4.5.0 make html
                    sudo docker run --rm -v /docs:/docs --name sphinx localhost:5000/sphinx-latexpdf:4.5.0 make latexpdf
                    sudo cp /docs/_build/latex/devopscapstoneproject.pdf /docs/_build/html/devopscapstoneproject.pdf
                """
            }
        }
        stage('Reload Apache') {
            steps {
                sh """
                    sudo docker container restart sphinx-html
                """
            }            
        }
        stage('Run Automated Tests') {
            steps {
                sh """
                    sudo python3 automated_testing.py
                """
            }
        }
        stage('PROD: Sphinx Doc Setup') {
            steps {
                sh """
                    ls -la
                    sudo rm /PROD-docs/* -R || true #true - won't fail if non-existent
                    sudo mkdir /PROD-docs || true
                    sudo chmod 777 /PROD-docs
                    sudo cp /docs/* /PROD-docs/ -R
                    ls -la /PROD-docs/
                """
            }
        }        
        stage('PROD: Reload Apache') {
            steps {
                sh """
                    sudo docker container restart prod-sphinx-html
                """
            }
        }          
    }


    //I'm not sure how this will play with existing terraform deployed objects.  Like it may make Terraform deploy new ones each time since it doesn't save the state
    // post {
    //     always {
    //         echo 'Cleaning Up Workspace'
    //         deleteDir() /* clean up our workspace */
    //     }
    // }
}
