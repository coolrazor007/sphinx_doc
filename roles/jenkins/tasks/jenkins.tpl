credentials:
  system:
    domainCredentials:
    - credentials:
      - basicSSHUserPrivateKey:
          id: "private-project"
          privateKeySource:
            directEntry:
              privateKey: "${privateKeyVar}" #Terraform catches on this if you put the correct syntax.  ##Use Bash/Sed to edit after##  Trying TF to put in the correct var
          scope: GLOBAL
          username: "ubuntu"
jenkins:
  numExecutors: 0
  labelAtoms:
  - name: "built-in"
  - name: "pipeline"
  nodes:
  - permanent:
      labelString: "pipeline"
      launcher:
        ssh:
          credentialsId: "private-project"
          host: "${pipelineIP}"
          port: 22
          sshHostKeyVerificationStrategy: "nonVerifyingKeyVerificationStrategy"
      name: "pipeline"
      remoteFS: "/home/ubuntu/agent"
      retentionStrategy: "always"
unclassified:
  location:
    adminAddress: "test <nobody@nowhere>"
    url: "http://localhost:8080/"
