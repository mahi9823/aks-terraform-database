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

        stage('Terraform Validate') {
            steps {
                sh '/tmp/terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([
                    string(credentialsId: 'azure-client-id', variable: 'ARM_CLIENT_ID'),
                    string(credentialsId: 'azure-client-secret', variable: 'ARM_CLIENT_SECRET'),
                    string(credentialsId: 'azure-tenant-id', variable: 'ARM_TENANT_ID'),
                    string(credentialsId: 'azure-subscription-id', variable: 'ARM_SUBSCRIPTION_ID')
                ]) {
                    sh '/tmp/terraform plan -input=false -var-file=/tmp/terraform.tfvars'
                }
            }
        }
        stage('Approve Terraform Apply') {
            steps {
                input message: 'Do you approve creating Azure resources?', ok: 'Approve'
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([
                    string(credentialsId: 'azure-client-id', variable: 'ARM_CLIENT_ID'),
                    string(credentialsId: 'azure-client-secret', variable: 'ARM_CLIENT_SECRET'),
                    string(credentialsId: 'azure-tenant-id', variable: 'ARM_TENANT_ID'),
                    string(credentialsId: 'azure-subscription-id', variable: 'ARM_SUBSCRIPTION_ID')
                ]) {
                    sh '/tmp/terraform apply -input=false -auto-approve -var-file=/tmp/terraform.tfvars'
                }
            }
        }

    }
}
