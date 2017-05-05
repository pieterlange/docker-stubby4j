FROM openjdk:8-jre-alpine

RUN apk update && apk upgrade && apk add curl inotify-tools su-exec bash ruby && \
    curl -o /stubby4j.jar https://repo1.maven.org/maven2/io/github/azagniotov/stubby4j/5.0.0/stubby4j-5.0.0.jar && \
    adduser -D -H unpriv && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

ADD entrypoint.sh /

CMD ["/entrypoint.sh"]
