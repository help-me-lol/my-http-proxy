FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y squid nginx curl && rm -rf /var/lib/apt/lists/*

# Download bore
RUN curl -L https://github.com/ekzhang/bore/releases/download/v0.5.0/bore-v0.5.0-x86_64-unknown-linux-musl.tar.gz | tar -xz -C /usr/local/bin

COPY nginx.conf /etc/nginx/nginx.conf
RUN sed -i 's/http_access deny all/http_access allow all/' /etc/squid/squid.conf

# Run Nginx in the foreground so Render detects a live web service on 8080
RUN echo '#!/bin/bash' > /start.sh && \
    echo 'squid' >> /start.sh && \
    echo 'bore local 3128 --to bore.pub &' >> /start.sh && \
    echo 'nginx -g "daemon off;"' >> /start.sh && \
    chmod +x /start.sh

EXPOSE 8080 3128
CMD ["/start.sh"]
