FROM openjdk:12-alpine

ENV CROWD_USER=crowd
ENV CROWD_VERSION=3.0.0
ENV CROWD_INSTALL_DIR=/CROWD
ENV CROWD_HOME=${CROWD_INSTALL_DIR}/crowd-home

WORKDIR ${CROWD_INSTALL_DIR}

RUN addgroup --gid 1111 ${CROWD_USER} \
&& adduser -D -u 1111 -G ${CROWD_USER} ${CROWD_USER} \
&& apk add tar curl \
&& curl --output atlassian-crowd-${CROWD_VERSION}.tar.gz https://product-downloads.atlassian.com/software/crowd/downloads/atlassian-crowd-${CROWD_VERSION}.tar.gz \
&& tar -xzf atlassian-crowd-${CROWD_VERSION}.tar.gz \
&& rm -rf atlassian-crowd-${CROWD_VERSION}.tar.gz

RUN apk add iputils bash

COPY entrypoint.sh ${CROWD_INSTALL_DIR}

RUN mkdir -p ${CROWD_HOME} \
&& sed -i -e 's!#crowd.home=/var/crowd-home!crowd.home=/CROWD/crowd-home!' ${CROWD_INSTALL_DIR}/atlassian-crowd-${CROWD_VERSION}/crowd-webapp/WEB-INF/classes/crowd-init.properties \
&& chown -R ${CROWD_USER}:${CROWD_USER} ${CROWD_INSTALL_DIR} \
&& chmod -R 766 ${CROWD_INSTALL_DIR} \
&& cat ${CROWD_INSTALL_DIR}/atlassian-crowd-${CROWD_VERSION}/crowd-webapp/WEB-INF/classes/crowd-init.properties \
&& ls -la ${CROWD_INSTALL_DIR}/atlassian-crowd-${CROWD_VERSION}

ENTRYPOINT ["./entrypoint.sh"]

VOLUME ${CROWD_INSTALL_DIR}/crowd-home

USER ${CROWD_USER}

