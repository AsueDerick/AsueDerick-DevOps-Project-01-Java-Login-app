# ======== Stage 1: Build WAR using Maven ========
FROM maven:3.9.9-eclipse-temurin-17 AS builder
WORKDIR /app

# Copy Maven descriptor first to cache dependencies
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy source and build
COPY src ./src
RUN mvn clean package -DskipTests

# ======== Stage 2: Deploy WAR to Tomcat ========
FROM tomcat:9.0
LABEL maintainer="you@example.com"

# Remove default ROOT app if you want to replace it
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR from build stage
COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/dptweb.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
# Healthcheck to ensure Tomcat is running
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s \
  CMD curl -f http://localhost:8080/dptweb/ || exit 1