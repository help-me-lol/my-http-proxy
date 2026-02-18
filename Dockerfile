FROM nginx:alpine
# Copy our custom config into the image
COPY nginx.conf /etc/nginx/nginx.conf
# Expose the port we defined in the config
EXPOSE 8080
