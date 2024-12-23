FROM library/maven:3.9.6-eclipse-temurin-21-alpine AS builder
WORKDIR /app
COPY pom.xml /app/
# Comment out this line for faster builds if you are heavily modifying pom.xml
RUN mvn dependency:go-offline dependency:resolve-plugins -X -Dmaven.artifact.threads=30 -B
COPY . /app
RUN mvn -X package -DskipTests && \
    java -Djarmode=layertools -jar target/*.jar extract

FROM builder AS tester
RUN mkdir -p /tests
# This is needed for WSL2
#ENV TESTCONTAINERS_HOST_OVERRIDE=host.docker.internal
CMD mvn test && cp target/surefire-reports/TEST*.xml /tests/

FROM azul/zulu-openjdk-debian:21-jre AS deployment
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8
WORKDIR /app
# Find what layers a jar has by running:
# java -Djarmode=layertools -jar target/*.jar list
COPY --from=builder /app/dependencies/ ./
COPY --from=builder /app/spring-boot-loader/ ./
COPY --from=builder /app/snapshot-dependencies/ ./
COPY --from=builder /app/application/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher", "-XX:+UseG1GC"]
EXPOSE 8080
