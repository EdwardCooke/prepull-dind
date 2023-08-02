# syntax=docker/dockerfile:1-labs

FROM docker:dind

COPY install.sh /opt/install.sh
RUN --security=insecure /opt/install.sh
