FROM alpine:3.6

RUN apk add --no-cache make libxslt raptor2

VOLUME /workspace
WORKDIR /workspace
