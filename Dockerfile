FROM ubuntu:latest
RUN apt-get update && apt-get install -y squid
# Allow all traffic (Note: This makes it public!)
RUN sed -i 's/http_access deny all/http_access allow all/' /etc/squid/squid.conf
EXPOSE 3128
CMD ["squid", "-N"]
