pipeline {
    agent any
 
    environment {
        DEPLOY_DIR = '/var/lib/jenkins/bootcamp-labs/scripts'
    }
 
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/hlande13/DevOpsBootcamp.git'
                sh 'ls -la'
            }
        }
 
        stage('Script Validation') {
            steps {
                sh '''
                    echo "=== Script Validation ==="
                    for script in *.sh; do
                        if [ -f "$script" ]; then
                            echo "Checking syntax: $script"
                            bash -n "$script" && echo "OK: $script" || exit 1
                        fi
                    done
                '''
            }
        }
 
        stage('Test Scripts') {
            steps {
                sh '''
                    echo "=== Testing Scripts ==="
                    chmod +x *.sh
                    if [ -f "health-check.sh" ]; then
                        ./health-check.sh
                    fi
                '''
            }
        }
 
        stage('Deploy Scripts') {
            steps {
                sh '''
                    echo "=== Deploying Scripts to $DEPLOY_DIR ==="
                    mkdir -p "$DEPLOY_DIR"
                    cp *.sh "$DEPLOY_DIR"/
                    chmod +x "$DEPLOY_DIR"/*.sh
                    ls -la "$DEPLOY_DIR"
                '''
            }
        }
    }
 
    post {
        always  { archiveArtifacts artifacts: '*.sh', allowEmptyArchive: true }
        success { echo 'Bootcamp Pipeline succeeded!' }
        failure { echo 'Bootcamp Pipeline failed!' }
    }
}
