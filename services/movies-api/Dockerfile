FROM gradle:8.2.1-jdk17 AS build

# copy the pom and src code to the container
COPY . ./
# build our application code
RUN gradle clean assemble

# the second stage of our build will use open jdk 11 on jre-slim
FROM openjdk:17-jdk-slim
 # copy only the artifacts we need from the first stage and discard the rest
COPY --from=build /home/gradle/build/libs/movies-api-0.0.1-SNAPSHOT.jar /movies-api.jar

ENV PORT 8080
ENV HOST 0.0.0.0
# set the startup command to execute the jar
CMD ["java", "-jar", "/movies-api.jar"]