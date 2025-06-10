# Stage 1: Build the application
FROM eclipse-temurin:17-jdk-focal as builder

WORKDIR /app

# Copy Maven wrapper files to leverage Docker cache for dependencies
COPY .mvn/ .mvn
COPY mvnw pom.xml ./

# Download dependencies in a separate layer
RUN ./mvnw dependency:go-offline -B

# Copy the rest of the source code
COPY src/ ./src

# Build the JAR
RUN ./mvnw clean install -DskipTests

# Stage 2: Create the final image
FROM eclipse-temurin:17-jre-focal

WORKDIR /app

# Copy the built JAR from the builder stage
COPY --from=builder /app/target/*.jar app.jar

# Expose the port your Spring Boot app runs on (default 8080)
EXPOSE 9000

# Command to run the application
ENTRYPOINT ["java","-jar","app.jar"]