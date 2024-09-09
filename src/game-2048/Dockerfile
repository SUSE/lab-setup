FROM registry.suse.com/suse/nginx:1.21
WORKDIR /usr/share/nginx/html
COPY . .
COPY .docker/nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
