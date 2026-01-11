FROM nginx:alpine

LABEL maintainer="jenkins-demo"

# Remove default nginx page
RUN rm -rf /usr/share/nginx/html/*

# Copy our custom HTML
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80
