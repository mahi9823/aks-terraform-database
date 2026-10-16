
pipeline {
    agent any

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

        stage('Terraform Init') {
            steps {
                sh '/tmp/terraform init -backend=false'
            }
        }
        stage('Terraform Plan') {
            steps {
                sh '/tmp/terraform plan -input=false'
            }
        }
        stage('Terraform Validate') {
            steps {
                sh '/tmp/terraform validate'
            }
        }
    }
}
