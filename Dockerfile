FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/*

COPY website/ /var/www/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]