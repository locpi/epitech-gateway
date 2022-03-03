FROM adoptopenjdk/openjdk11:latest

COPY ./target/zuul.jar /usr/app/

WORKDIR /usr/app


ENTRYPOINT ["java","-jar","/usr/app/zuul.jar"]
