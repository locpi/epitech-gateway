#!/usr/bin/env groovy
import groovy.json.JsonOutput
import groovy.transform.Field

def gitCommit = ""
def author = ""
def errorString
def commit
MAVEN_OPTS = "-B -V -U -e -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn "
MAVEN_OPTS_NO_FORCE_UPDATE = "-B -V -e -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn "
MAVEN_SKIP_TESTS = "-DskipTests"
MAVEN_SKIP_TESTS_WITH_OPTS = "${MAVEN_OPTS} ${MAVEN_SKIP_TESTS}"
node {
    try {
        timestamps {
            stage('Checkout') {
                checkout scm
                gitCommit = sh(script: "git log -1 --pretty=%B", returnStdout: true).trim().replace("'", "")
                commit = sh(returnStdout: true, script: 'git rev-parse HEAD')
                author = sh(returnStdout: true, script: "git --no-pager show -s --format='%an' ${commit}").trim()

                gitBranch = scm.branches[0].name.replaceAll("/", "_")
                echo "My branch is: ${env.BRANCH_NAME}"

            }
            stage('Clean') {
                    sh "mvn clean ${MAVEN_OPTS}"

            }


            stage('Build') {
                    sh "mvn verify failsafe:integration-test surefire:test  install -P-webpack ${MAVEN_OPTS}"

            }


            stage('Docker Images') {
                parallel 'eyrh-legacy': {
                    app = docker.build("${tomcatPrimoboxEyrhLegacy}", '--pull -f deploy/images/Dockerfile . ')
                    docker.withRegistry('https://harbor.primobox.net', 'jenkins_harbor') {
                        app.push()
                        app.push(commit)
                    }
                }, 'eyrh': {
                    docker.withRegistry('https://harbor.primobox.net', 'jenkins_harbor') {
                        withDockerContainer(image: "maven:3.6-openjdk-16-slim", args: '-v /data/.npm:/.npm -v /data/.m2:/home/jenkins/.m2 -v /home/jenkins/settings.xml:/settings.xml') {
                            gitlabCommitStatus(name: 'Build image eyrh') {
                                sh "mvn -pl eyrh/presentation ${MAVEN_OPTS_NO_FORCE_UPDATE} ${MAVEN_SKIP_TESTS}  -Pprod package com.google.cloud.tools:jib-maven-plugin:3.0.0:build -Djib.to.image=harbor.primobox.net/${tomcatPrimoboxImageEyrh} -Djib.to.tags=${commit}"
                            }
                        }
                    }
                }
            }
        }
    } catch (hudson.AbortException ae) {
        echo "hudson.AbortException"
        currentBuild.result = currentBuild.result == null ? 'FAILURE' : currentBuild.result
    } catch (e) {
        currentBuild.result = 'FAILURE'
        def stringWriter = new StringWriter()
        e.printStackTrace(new PrintWriter(stringWriter))
        errorString = stringWriter.toString()
        echo "Error : ${errorString}"
    }

    currentBuild.result = currentBuild.result == null ? 'SUCCESS' : currentBuild.result
    def jobName = "${env.JOB_NAME}"
    def buildColor = "danger"
    def buildStatus = "Failed"
    if (currentBuild.result == null || currentBuild.result == "SUCCESS") {
        buildColor = "good"
        buildStatus = "Success"
    } else if (currentBuild.result == "UNSTABLE") {
        buildColor = "warning"
        buildStatus = "Unstable"
    } else if (currentBuild.result == "ABORTED") {
        buildColor = "#E8E9EB"
        buildStatus = "Aborted"
    }
}



