FROM java:8-jdk-alpine

COPY ./target/zuul.jar /usr/app/

WORKDIR /usr/app


ENTRYPOINT ["java","-jar","/usr/app/zuul.jar"]