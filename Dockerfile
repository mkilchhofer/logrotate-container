FROM alpine:3.10.2

USER root
RUN apk --update add --no-cache logrotate && \
    rm -f /etc/logrotate.d/*
ADD logrotate.conf /etc/logrotate.conf

USER 1000
CMD ["/usr/sbin/logrotate", "-v", "-f", "--state","/tmp/logrotate.status", "/etc/logrotate.conf"]
