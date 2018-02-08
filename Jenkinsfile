pipeline {
  agent {
      label 'master'
  }
  stages {
    stage('Transform') {
      agent {
        dockerfile {
          args "-v ${env.WORKSPACE}:/workspace"
          reuseNode true
        }
      }
      steps {
        sh 'make CN_2015_20180206_105537.ttl'
      }
    }
  }
}