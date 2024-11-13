# Use NGINX Unprivileged as the base image
FROM nginxinc/nginx-unprivileged:stable-bookworm AS builder

RUN mkdir /tmp/required_libs -p && \
    find /lib/ -name libcrypt.so.1 -exec cp {} /tmp/required_libs/ \; && \
    find /lib/ -name libpcre2-8.so.0 -exec cp {} /tmp/required_libs/ \; && \
    find /lib/ -name libssl.so.3 -exec cp {} /tmp/required_libs/ \; && \
    find /lib/ -name libcrypto.so.3 -exec cp {} /tmp/required_libs/ \; && \
    find /lib/ -name libz.so.1 -exec cp {} /tmp/required_libs/ \; && \
    rm /etc/nginx/conf.d/default.conf

# Base image for final runtime
FROM gcr.io/distroless/base-debian12:nonroot AS final

# Common files
COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx
COPY --from=builder /etc/nginx /etc/nginx
COPY --from=builder /usr/share/nginx/html /usr/share/nginx/html

# Cache and log directories with permissions
COPY --chown=nonroot:nonroot --from=builder /var/cache/nginx /var/cache/nginx
COPY --chown=nonroot:nonroot --from=builder /var/log/nginx /var/log/nginx

# Custom configuration files with ownership change
COPY --chown=nonroot:nonroot nginx/nginx.conf /etc/nginx/nginx.conf
COPY --chown=nonroot:nonroot nginx/default.conf /etc/nginx/conf.d/default.conf

# HTML files with ownership change
COPY --chown=nonroot:nonroot webroot/50x.html /usr/share/nginx/html/50x.html
COPY --chown=nonroot:nonroot webroot/index.html /usr/share/nginx/html/index.html

# Required libraries
COPY --chown=nonroot:nonroot --chmod=444 --from=builder /tmp/required_libs/* /usr/lib/

# COPY --from=builder /lib/x86_64-linux-gnu/libcrypt.so.1 \
#     /lib/x86_64-linux-gnu/libpcre2-8.so.0 \
#     /lib/x86_64-linux-gnu/libssl.so.3 \
#     /lib/x86_64-linux-gnu/libcrypto.so.3 \
#     /lib/x86_64-linux-gnu/libz.so.1 \
#     /usr/lib/

# Set the user to run NGINX and expose the NGINX port
USER nonroot
EXPOSE 80

# Start NGINX
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
