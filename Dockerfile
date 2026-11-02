FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive

# Install Squid, Nginx, and curl
RUN apt-get update && apt-get install -y squid nginx curl && rm -rf /var/lib/apt/lists/*

# Download and install the bore CLI binary
RUN curl -L https://github.com/ekzhang/bore/releases/download/v0.5.0/bore-v0.5.0-x86_64-unknown-linux-musl.tar.gz | tar -xz -C /usr/local/bin

# Copy configuration files
COPY nginx.conf /etc/nginx/nginx.conf
RUN sed -i 's/http_access deny all/http_access allow all/' /etc/squid/squid.conf

# Startup script to boot Nginx on 8080, Squid, and Bore
RUN echo '#!/bin/bash' > /start.sh && \
    echo 'service nginx start' >> /start.sh && \
    echo 'squid' >> /start.sh && \
    echo 'bore local 3128 --to bore.pub' >> /start.sh && \
    chmod +x /start.sh

EXPOSE 8080 3128
CMD ["/start.sh"]
