pipeline {
    agent any

    tools {
        terraform 'Terraform'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'GitHub checkout successful'
            }
        }

        stage('Terraform Version') {
            steps {
                sh '/tmp/terraform version'
            }
        }
    }
}