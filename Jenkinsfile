pipeline {
    agent {
        label 'master'
    }
    stages {
        stage('Test uploading UTF-8') {
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
                        String graph = "http://foo.bar.com/"
                        drafter.deleteGraph(PMD, credentials, newJobDraft.id, graph)
                        drafter.addData(PMD, credentials, newJobDraft.id,
                                        readFile(file: "cubed.ttl"),
                                        'text/turtle; text/turtle; charset="UTF-8"', graph)
                        drafter.publishDraftset(PMD, credentials, newJobDraft.id)
                    }
                }
            }
        }
    }
}
