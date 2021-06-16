FROM alpine:3.10

USER root
RUN apk --update add --no-cache logrotate && \
    rm -f /etc/logrotate.d/*
ADD logrotate.conf /etc/logrotate.conf
RUN chmod 0400 /etc/logrotate.conf

CMD ["/usr/sbin/logrotate", "-v", "-f", "--state","/tmp/logrotate.status", "/etc/logrotate.conf"]
