# Creates docker image for the OpenIG sample server.jar referenced in the OpenIG gateway guide
#FROM openjdk:8
FROM openjdk:8-alpine


WORKDIR /var/tmp

ADD Dockerfile /

# Gets the current server.jar from Maven
RUN apk add --update curl && \
        rm -rf /var/cache/apk/* && \
        curl -o server.jar \
  http://maven.forgerock.org/repo/snapshots/org/forgerock/openig/openig-doc/5.0.0-SNAPSHOT/openig-doc-5.0.0-SNAPSHOT-jar-with-dependencies.jar

EXPOSE 8081 8444

ENTRYPOINT ["java", "-jar", "server.jar"]