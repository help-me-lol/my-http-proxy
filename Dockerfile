FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# Install Squid, curl, and networking tools
RUN apt-get update && apt-get install -y squid curl && rm -rf /var/lib/apt/lists/*

# Download and install the bore CLI binary
RUN curl -L https://github.com/ekzhang/bore/releases/download/v0.5.0/bore-v0.5.0-x86_64-unknown-linux-musl.tar.gz | tar -xz -C /usr/local/bin

# Configure Squid to allow all proxy traffic
RUN sed -i 's/http_access deny all/http_access allow all/' /etc/squid/squid.conf

# Create a startup script that launches Squid and tunnels the Squid port (3128) via bore
RUN echo '#!/bin/bash' > /start.sh && \
    echo 'squid' >> /start.sh && \
    echo 'bore local 3128 --to bore.pub' >> /start.sh && \
    chmod +x /start.sh

EXPOSE 3128

CMD ["/start.sh"]
