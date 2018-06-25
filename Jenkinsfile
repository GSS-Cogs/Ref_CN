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
                sh 'make'
            }
        }
        stage('Publish results') {
            steps {
                script {
                    configFileProvider([configFile(fileId: 'pmd', variable: 'configfile')]) {
                        def config = readJSON(text: readFile(file: configfile))
                        String PMD = config['pmd_api']
                        String credentials = config['credentials']
                        def drafts = drafter.listDraftsets(PMD, credentials, 'owned')
                        def jobDraft = drafts.find { it['display-name'] == env.JOB_NAME }
                        if (jobDraft) {
                            drafter.deleteDraftset(PMD, credentials, jobDraft.id)
                        }
                        def newJobDraft = drafter.createDraftset(PMD, credentials, env.JOB_NAME)
                        for (int y = 2012; y <= 2016; y++) {
                            String graph = "https://trade.ec.europa.eu/def/cn_${y}"
                            drafter.deleteGraph(PMD, credentials, newJobDraft.id, graph)
                            drafter.addData(PMD, credentials, newJobDraft.id,
                                            readFile(file: "CN_${y}.ttl", encoding: 'UTF-8'),
                                            'text/turtle;charset=UTF-8', graph)
                        }
                        drafter.publishDraftset(PMD, credentials, newJobDraft.id)
                    }
                }
            }
        }
    }
    post {
        always {
            archiveArtifacts '*.ttl'
        }
    }
}
