
FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y squid nginx curl apache2-utils && rm -rf /var/lib/apt/lists/*

# Download Bore
RUN curl -L https://github.com/ekzhang/bore/releases/download/v0.5.0/bore-v0.5.0-x86_64-unknown-linux-musl.tar.gz | tar -xz -C /usr/local/bin

COPY nginx.conf /etc/nginx/nginx.conf

# Configure authenticated Squid proxy
RUN cat > /etc/squid/squid.conf <<'EOF'
http_port 3128

auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/passwd
auth_param basic realm Private Proxy
auth_param basic credentialsttl 2 hours

acl authenticated proxy_auth REQUIRED
acl SSL_ports port 443
acl Safe_ports port 80 21 443 70 210 1025-65535 280 488 591 777
acl CONNECT method CONNECT

http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports
http_access allow authenticated
http_access deny all

cache deny all
visible_hostname my-proxy-node
EOF

# Startup script
RUN cat > /start.sh <<'EOF'
#!/bin/bash
set -e

if [ -z "$SQUID_USERNAME" ] || [ -z "$SQUID_PASSWORD" ]; then
    echo "ERROR: SQUID_USERNAME and SQUID_PASSWORD must be set"
    exit 1
fi

printf '%s\n' "$SQUID_PASSWORD" | htpasswd -B -c -i /etc/squid/passwd "$SQUID_USERNAME"
chown proxy:proxy /etc/squid/passwd
chmod 640 /etc/squid/passwd

squid

while true; do
    echo "Starting Bore on fixed port 49133..."
    bore local 3128 --to bore.pub --port 49133
    echo "Bore disconnected. Retrying in 5 seconds..."
    sleep 5
done &

nginx -g "daemon off;"
EOF

RUN chmod +x /start.sh

EXPOSE 8080
CMD ["/start.sh"]
