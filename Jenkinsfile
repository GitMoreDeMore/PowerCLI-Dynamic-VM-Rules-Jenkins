pipeline {
  agent any
  
  parameters {
    choice(
        name: 'vcenter',
        choices: "192.168.1.159\n10.0.0.22",
        description: 'vCenter IP' )
  }
  
  triggers {
    cron('@daily')
    pollSCM('H/2 * * * *')
  }
  
  stages {
    stage('Dry Run') {
      steps {
        withCredentials([
		    usernamePassword(credentialsId: 'vCenterCreds', usernameVariable: 'vcuser', passwordVariable: 'vcpassword'),
		    usernamePassword(credentialsId: 'EmailCreds', usernameVariable: 'smtpuser', passwordVariable: 'smtppass')
	    	]) 
        {
        sh 'rm -rf ./fail_tag'
        pwsh './Main.ps1 -vCenter $env:vcenter -VCUser $env:vcuser -VCPassword $env:vcpassword -SMTPUser $env:smtpuser -SMTPPass $env:smtppass -Confirmation no'
        }
        script{
        if (fileExists('fail_tag'))
          {
          fail_tag = 'true'
		  echo "Fail tag exists"
		  } 
        else
          {
		  fail_tag = 'false'
          }
	    }
      }
    }
	
    stage('Error Approval'){
	options {timeout(time: 1, unit: 'MINUTES')}
      when { expression { fail_tag == 'true' } }
        steps {
        input message: 'Errors Detected: Procced?'
        echo "Proceeding with errors..."
        }
     }

    stage('Deploy') {
      steps
        {
        withCredentials([
		    usernamePassword(credentialsId: 'vCenterCreds', usernameVariable: 'vcuser', passwordVariable: 'vcpassword'),
		    usernamePassword(credentialsId: 'EmailCreds', usernameVariable: 'smtpuser', passwordVariable: 'smtppass')
	    	])
        {
        pwsh './Main.ps1 -vCenter $env:vcenter -VCUser $env:vcuser -VCPassword $env:vcpassword -SMTPUser $env:smtpuser -SMTPPass $env:smtppass -Confirmation yes'
        }
        }
    }
  }
  
}