FROM enmasseproject/java-base:11-0

ARG version
ARG maven_version
ARG commit

ENV VERSION=${version} COMMIT=${commit} MAVEN_VERSION=${maven_version}
ADD target/mqtt-lwt-${MAVEN_VERSION}.jar /mqtt-lwt.jar

CMD ["/opt/run-java/launch_java.sh", "/mqtt-lwt.jar"]
