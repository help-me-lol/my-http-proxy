FROM ubuntu:latest

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install Squid and Nginx
RUN apt-get update && apt-get install -y squid nginx && rm -rf /var/lib/apt/lists/*

# Copy configuration files
COPY nginx.conf /etc/nginx/nginx.conf
RUN sed -i 's/http_access deny all/http_access allow all/' /etc/squid/squid.conf

# Expose Nginx web port and Squid proxy port
EXPOSE 8080 3128

# Custom startup script to run both services concurrently
RUN echo '#!/bin/bash\nservice squid start\nnginx -g "daemon off;"' > /start.sh && chmod +x /start.sh

CMD ["/start.sh"]
