# nginx_distroless

Contains Dockerfile's to build amd64 or arm64 distroless Nginx that runs as a nonroot user.

For a pre-built public docker image, see:

[Nginx Distroless on Docker Hub](https://hub.docker.com/repository/docker/hasecuritysolutions/nginx_distroless)

This image does not have a default.conf inside /etc/nginx/conf.d. You will need to map one to your container.