FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y squid nginx curl && rm -rf /var/lib/apt/lists/*

# Download bore
RUN curl -L https://github.com/ekzhang/bore/releases/download/v0.5.0/bore-v0.5.0-x86_64-unknown-linux-musl.tar.gz | tar -xz -C /usr/local/bin

COPY nginx.conf /etc/nginx/nginx.conf

# Configure Squid to allow all traffic and handle internal requests smoothly
RUN sed -i 's/http_access deny all/http_access allow all/' /etc/squid/squid.conf && \
    echo "visible_hostname my-proxy-node" >> /etc/squid/squid.conf

# Run Nginx on port 8080 (for Render/UptimeRobot), Squid on 3128, and Bore
RUN echo '#!/bin/bash' > /start.sh && \
    echo 'squid' >> /start.sh && \
    echo 'bore local 3128 --to bore.pub &' >> /start.sh && \
    echo 'nginx -g "daemon off;"' >> /start.sh && \
    chmod +x /start.sh

EXPOSE 8080
CMD ["/start.sh"]
