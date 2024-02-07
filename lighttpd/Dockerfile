FROM alpine:latest
RUN apk add lighttpd php83-cgi php83-pdo_sqlite php83-fileinfo
CMD lighttpd -D -f /etc/lighttpd.conf
