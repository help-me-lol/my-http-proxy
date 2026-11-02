
FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y squid nginx curl && rm -rf /var/lib/apt/lists/*

# Download Bore
RUN curl -L https://github.com/ekzhang/bore/releases/download/v0.5.0/bore-v0.5.0-x86_64-unknown-linux-musl.tar.gz | tar -xz -C /usr/local/bin

COPY nginx.conf /etc/nginx/nginx.conf

# Configure Squid
RUN sed -i 's/http_access deny all/http_access allow all/' /etc/squid/squid.conf && \
    echo "visible_hostname my-proxy-node" >> /etc/squid/squid.conf

# Start services
RUN printf '#!/bin/bash\n\
squid\n\
while true; do\n\
    echo "Starting Bore on fixed port 49133..."\n\
    bore local 3128 --to bore.pub --port 49133\n\
    echo "Bore disconnected. Retrying in 5 seconds..."\n\
    sleep 5\n\
done &\n\
nginx -g "daemon off;"\n' > /start.sh && chmod +x /start.sh

EXPOSE 8080
CMD ["/start.sh"]
