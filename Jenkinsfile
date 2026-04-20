pipeline {
    agent any

    environment {
        APP_NAME = 'devops-webapp'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        IMAGE_REPO = 'docker.io/your-dockerhub-user/devops-webapp'
        K8S_NAMESPACE = 'devops-prod'
        TF_DIR = 'terraform'
    }

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Image') {
            steps {
                sh 'docker build -t ${IMAGE_REPO}:${IMAGE_TAG} -t ${IMAGE_REPO}:latest .'
            }
        }

        stage('Push Image') {
            when {
                expression { return env.DOCKER_PUSH == 'true' }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin'
                    sh 'docker push ${IMAGE_REPO}:${IMAGE_TAG}'
                    sh 'docker push ${IMAGE_REPO}:latest'
                }
            }
        }

        stage('Terraform Provision') {
            when {
                expression { return env.RUN_TERRAFORM == 'true' }
            }
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform init'
                    sh 'terraform plan -out=tfplan'
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            when {
                expression { return env.RUN_K8S_DEPLOY == 'true' }
            }
            steps {
                sh 'kubectl apply -f kubernetes/namespace.yaml'
                sh 'sed -e "s|IMAGE_PLACEHOLDER|${IMAGE_REPO}:${IMAGE_TAG}|g" kubernetes/deployment.yaml | kubectl apply -f -'
                sh 'kubectl apply -f kubernetes/service.yaml'
                sh 'kubectl apply -f kubernetes/ingress.yaml'
            }
        }

        stage('Deploy Monitoring Stack') {
            when {
                expression { return env.RUN_MONITORING == 'true' }
            }
            steps {
                sh 'helm repo add prometheus-community https://prometheus-community.github.io/helm-charts'
                sh 'helm repo update'
                sh 'kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -'
                sh 'helm upgrade --install kube-prom-stack prometheus-community/kube-prometheus-stack -n monitoring -f monitoring/prometheus-values.yaml'
                sh 'kubectl apply -f monitoring/servicemonitor.yaml'
                sh 'kubectl apply -f monitoring/grafana-dashboard-configmap.yaml'
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'monitoring/*.json,docs/*.md,kubernetes/*.yaml,terraform/*.tf,terraform/*.tfvars.example', fingerprint: true
        }
    }
}