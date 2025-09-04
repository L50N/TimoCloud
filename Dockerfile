FROM alpine:3.18 AS builder

RUN apk add --no-cache wget

WORKDIR /build

RUN wget -O TimoCloud.jar https://jenkins.timo.cloud/job/TimoCloud/job/master/lastSuccessfulBuild/artifact/TimoCloud-Universal/target/TimoCloud.jar \
    && ls -la TimoCloud.jar

FROM eclipse-temurin:17-jre-alpine AS runner

RUN apk add --no-cache \
    curl \
    bash \
    screen \
    && addgroup -g 1000 timocloud \
    && adduser -D -s /bin/bash -G timocloud -u 1000 timocloud

RUN mkdir -p /home/timocloud/{storage,logs,templates,temporary,core,base,cord} \
    && chown -R timocloud:timocloud /home/timocloud

WORKDIR /home/timocloud

COPY --from=builder /build/TimoCloud.jar ./TimoCloud.jar

RUN chmod +x TimoCloud.jar \
    && chown timocloud:timocloud TimoCloud.jar

USER timocloud

ENV TZ=Europe/Berlin \
    JAVA_OPTS_CORE="-Xmx1g -Xms256m -XX:+UseG1GC -XX:+UseStringDeduplication" \
    JAVA_OPTS_BASE="-Xmx512m -Xms128m -XX:+UseG1GC -XX:+UseStringDeduplication" \
    JAVA_OPTS_CORD="-Xmx256m -Xms64m -XX:+UseG1GC -XX:+UseStringDeduplication"

EXPOSE 7777 7778 7779 7780 25565

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD pgrep -f "TimoCloud.jar" > /dev/null || exit 1

CMD screen -dm -S core bash -c "java \$JAVA_OPTS_CORE -jar /home/timocloud/TimoCloud.jar --module=CORE" && \
    screen -dm -S base bash -c "java \$JAVA_OPTS_BASE -jar /home/timocloud/TimoCloud.jar --module=BASE" && \
    screen -dm -S cord bash -c "java \$JAVA_OPTS_CORD -jar /home/timocloud/TimoCloud.jar --module=CORD" && \
    tail -f /dev/null