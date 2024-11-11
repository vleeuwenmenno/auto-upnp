FROM alpine:latest

LABEL maintainer="Menno van Leeuwen <menno@vleeuwen.me>"
LABEL description="A flexible UPnP port forwarding container that handles automatic port mapping and renewal"
LABEL repository="https://github.com/vleeuwenmenno/docker-auto-upnp"

RUN apk --no-cache add \
    bash \
    miniupnpc \
    jq

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
