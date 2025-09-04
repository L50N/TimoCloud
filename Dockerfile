FROM maven:3.9.4-eclipse-temurin-17-alpine AS builder

WORKDIR /build

COPY TimoCloud-API/pom.xml TimoCloud-API/
COPY TimoCloud-Universal/pom.xml TimoCloud-Universal/
COPY TimoCloud-Staging/pom.xml TimoCloud-Staging/

RUN mvn dependency:go-offline -B

RUN mvn clean package -B -DskipTests \
    && ls -la TimoCloud-Universal/target/ \
    && cp TimoCloud-Universal/target/TimoCloud.jar /build/TimoCloud.jar

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

COPY --chown=timocloud:timocloud TimoCloud-Universal/src/main/resources/core/ ./core/
COPY --chown=timocloud:timocloud TimoCloud-Universal/src/main/resources/base/ ./base/
COPY --chown=timocloud:timocloud TimoCloud-Universal/src/main/resources/cord/ ./cord/

RUN chmod +x TimoCloud.jar \
    && chown timocloud:timocloud TimoCloud.jar

USER timocloud

ENV TIMOCLOUD_MODULE=CORE \
    JAVA_OPTS="-Xmx1g -Xms256m -XX:+UseG1GC -XX:+UseStringDeduplication" \
    TZ=Europe/Berlin

RUN echo '#!/bin/bash\nif pgrep -f "TimoCloud.jar" > /dev/null; then exit 0; else exit 1; fi' > healthcheck.sh \
    && chmod +x healthcheck.sh

EXPOSE 7777 7778 7779 7780 25565

RUN echo '#!/bin/bash\n\
    echo "$TIMOCLOUD_MODULE"\n\
    echo "Java Options: $JAVA_OPTS"\n\
    \n\
    mkdir -p /home/timocloud/${TIMOCLOUD_MODULE,,}\n\
    mkdir -p /home/timocloud/logs\n\
    mkdir -p /home/timocloud/storage\n\
    \n\
    exec java $JAVA_OPTS -jar /home/timocloud/TimoCloud.jar --module=$TIMOCLOUD_MODULE\n\
    ' > start.sh && chmod +x start.sh

CMD ["./start.sh"]
