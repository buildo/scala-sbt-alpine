FROM eclipse-temurin:17.0.7_7-jre-alpine@sha256:7cbe01fd3d515407f1fda1e68068831aa6ae4b6930d76cdaa43736dc810bbd1b7

ARG SCALA_VERSION=2.12.17
ARG SBT_VERSION=1.8.2
ENV SCALA_HOME=/usr/share/scala

RUN apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
  apk add --no-cache bash && \
  cd "/tmp" && \
  wget "https://downloads.typesafe.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz" && \
  tar xzf "scala-${SCALA_VERSION}.tgz" && \
  mkdir "${SCALA_HOME}" && \
  rm "/tmp/scala-${SCALA_VERSION}/bin/"*.bat && \
  mv "/tmp/scala-${SCALA_VERSION}/bin" "/tmp/scala-${SCALA_VERSION}/lib" "${SCALA_HOME}" && \
  ln -s "${SCALA_HOME}/bin/"* "/usr/bin/" && \
  apk del .build-dependencies && \
  rm -rf "/tmp/"*

RUN \
  apk add --no-cache --virtual=.build-dependencies bash curl bc ca-certificates && \
  cd "/tmp" && \
  update-ca-certificates && \
  scala -version && \
  scalac -version && \
  curl -fsL https://github.com/sbt/sbt/releases/download/v$SBT_VERSION/sbt-$SBT_VERSION.tgz | tar xfz - -C /usr/local && \
  $(mv /usr/local/sbt-launcher-packaging-$SBT_VERSION /usr/local/sbt || true) && \
  ln -s /usr/local/sbt/bin/* /usr/local/bin/ && \
  apk del .build-dependencies && \
  rm -rf "/tmp/"*

RUN \
  sbt -Dsbt.rootdir=true -batch sbtVersion && \
  rm -rf project target

WORKDIR /root
