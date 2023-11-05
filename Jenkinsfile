pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                // Checkout your source code from your version control system (e.g., Git)
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                // Install Node.js and npm (if not already installed)
                sh 'nvm install 14'  // You may need to adjust the Node.js version
                sh 'npm install'
            }
        }

        stage('Run Tests') {
            steps {
                // Run your React app's tests
                sh 'npm test'
            }
        }

        stage('Build') {
            steps {
                // Build your React app for production
                sh 'npm run build'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube Server') {
                    sh """
                    npm install -g sonarqube-scanner
                    sonar-scanner \
                        -Dsonar.host.url=${env.SONARQUBE_URL} \
                        -Dsonar.login=${env.SONARQUBE_TOKEN} \
                        -Dsonar.projectKey=your-project-key \
                        -Dsonar.javascript.lcov.reportPaths=coverage/lcov-report/lcov.info
                    """
                }
            }
        }

        stage('Publish to Artifactory') {
            steps {
                script {
                    def server = Artifactory.newServer url: env.ARTIFACTORY_SERVER, credentialsId: 'your-credentials-id'
                    def uploadSpec = """{
                        "files": [
                            {
                                "pattern": "build/**",
                                "target": "${env.ARTIFACTORY_REPO}/your-artifact-directory/",
                                "props": "build.name=${env.JOB_NAME};build.number=${env.BUILD_NUMBER}"
                            }
                        ]
                    }"""
                    def buildInfo = server.upload spec: uploadSpec
                    echo "Published to Artifactory: ${env.ARTIFACTORY_REPO}/your-artifact-directory/"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Define the Docker image name and tag
                    def dockerImage = 'your-react-app-image:latest'

                    // Build the Docker image using the Dockerfile in the project root
                    sh "docker build -t ${dockerImage} ."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    // Define the Docker image name and tag
                    def dockerImage = 'your-react-app-image:latest'

                    // Login to your Docker registry (if needed)
                    sh "docker login -u your-username -p your-password your-docker-registry"

                    // Push the Docker image to your registry
                    sh "docker push ${dockerImage}"
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                // Load the Kubernetes configuration from a secret
                withCredentials([file(credentialsId: 'kube-config-credentials-id', variable: 'KUBE_CONFIG_FILE')]) {
                    sh "echo '$KUBE_CONFIG_FILE' > ~/.kube/config"
                }

                // Apply the Kubernetes manifest files
                sh "kubectl apply -f your-react-app-deployment.yaml"
                sh "kubectl apply -f your-react-app-service.yaml"
                sh "kubectl apply -f your-react-app-ingress.yaml"
            }
        }
    
    }

    post {
        success {
            // Archive test reports, build artifacts, or other reports
            archiveArtifacts artifacts: 'build/**', allowEmptyArchive: true
        }

        always {
            // Clean up any temporary build artifacts
            deleteDir()
        }
    }
}
