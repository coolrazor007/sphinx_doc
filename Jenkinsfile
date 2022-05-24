pipeline {
    agent any
    options {
        timeout(time: 20, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '25'))
    }

    // parameters {
    //     string(name: 'VMNAME', defaultValue: 'NewGenericVM', description: 'Name for the new VM')
    //     // Parameters automatically become environment variables FYI.  No need to declare them in environment block
    // }

    environment {
        TIMESTAMP = "$BUILD_TIMESTAMP"
        _7zipPass  = credentials('Archive-Pass')
        //AWS_ACCESS_KEY_ID     = credentials('lab_access_key')
        //AWS_SECRET_ACCESS_KEY = credentials('lab_secret_key')
        //AWS_TOKEN = credentials('lab_token')
        //AWS_Creds_File = credentials('AWS_CalTech_creds')                
    }

    stages {
        stage('Test and Setup') {
            steps {
                echo 'Test and Setup'
                echo 'Show AWS CLI version'
                sh 'aws --version'
                echo 'Show Terraform version'
                sh 'terraform -version'
                echo 'Show Packer version'
                sh 'packer -version'
                echo 'Show Ansible version'
                sh 'ansible --version'
            }
        }
        stage('Terraform AWS Creds') {
            steps {
                sh """
                    cd lab-project
                    7z e -p${_7zipPass} Archive.7z -aoa -o./
                    7z e -p${_7zipPass} ArchiveAWSssh.7z -aoa -o./ 
                    ls -la
                """
            }
        }
        stage('Terraform Init') {
            steps {
                sh """
                    cd lab-project
                    terraform init
                """
            }
        }
        stage('Terraform Validate') {
            steps {
                sh """
                    cd lab-project
                    terraform validate
                """
            }
        }
        stage('Terraform Deploy EC2 Instance') {
            steps {
                sh """
                    cd lab-project
                    terraform apply -auto-approve
                """
            }
        }
        stage('Terraform Elastic IP') {
            steps {
                sh """
                    cd lab-project
                    terraform apply -auto-approve
                """
            }
        }        
        stage('Run Ansible') {
            steps {
                sh """
                    cd lab-project
                    echo "Checking inventory"
                    cat inventory.cfg
                    ansible-playbook -i inventory.cfg main.yml --key-file "Caltech-Lab-AWS-Key"
                """
            }
        }        
        stage('Terraform AWS Creds Cleanup') {
            steps {
                sh """
                    cd lab-project
                    #ls -la
                    rm provider.tf Caltech-Lab-AWS-Key
                    #ls -la
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
