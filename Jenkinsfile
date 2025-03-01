pipeline {
    agent any

    stages {        

        stage('Run PowerShell Script') {
            steps {
                script {
                    // This step runs the PowerShell script and captures the exit code
                    // If "returnStatus" is set to true, the step returns the script's exit code instead of failing the build automatically.
                    def scriptExitCode = powershell (
                        script: '''
                            .\\RemoteServiceControl.ps1 `
                                -ComputerName "myServer.domain.local" `
                                -Username "kcf\\Administrator" `
                                -Password "SomePassword" `
                                -ServiceName "Spooler" `
                                -Action "Stop"
                        ''',
                        returnStatus: true                        
                    )

                    // If exit code != 0, mark build as failed
                    if (scriptExitCode != 0) {
                        error "winservice.ps1 failed with exit code: ${scriptExitCode}"
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
        success {
            echo 'The script completed successfully.'
        }
        failure {
            echo 'The script encountered an error.'
        }
    }
}
