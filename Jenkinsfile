pipeline {
    agent any

    stages {
        stage('Clone') {
            steps {
                git 'https://github.com/Kabesh-M/devops_pro.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t devops-app .'
            }
        }

        stage('Run Container') {
            steps {
                sh 'docker run -d -p 3001:3000 devops-app'
            }
        }
    }
}