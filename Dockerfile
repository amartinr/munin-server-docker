FROM nginx:alpine
RUN set -eux; \
    addgroup \
        -S \
        munin; \
    adduser \
        -S \
        -h /var/lib/munin \
        -s /bin/false \
        -H \
        -G munin \
        munin;

RUN set -eux; \
    apk add --no-cache munin munin-node font-dejavu \
        spawn-fcgi \
        perl-date-manip \
        perl-log-log4perl \
        perl-cgi-fast;

RUN set -eux; \
    mkdir -p /var/cache/munin/www; \
    chown munin:munin /var/cache/munin; \
    mkdir -p /var/run/munin; \
    chown -R munin:munin /var/run/munin; \
    chown -R munin:munin /var/lib/munin; \
    chown -R munin:munin /var/log/munin; \
    ln -s /dev/stdout /var/log/munin/munin-update.log; \
    ln -s /dev/stdout /var/log/munin/munin-limits.log; \
    ln -s /dev/stdout /var/log/munin/munin-html.log; \
    ln -s /dev/stdout /var/log/munin/munin-graph.log; \
    ln -s /dev/stdout /var/log/munin/munin-cgi-html.log; \
    ln -s /dev/stdout /var/log/munin/munin-cgi-graph.log; \
    mkdir -p /var/run/nginx; \
    chown -R munin:munin /var/run/nginx;

RUN set -eux; \
    sed -r -i \
        -e "/^\s*user\s+nginx\s*;/d" \
        -e "s/^pid\s+.*;$/pid \/var\/run\/nginx\/nginx.pid;/" \
        /etc/nginx/nginx.conf; \
    mkdir -p /var/log/nginx; \
    chown -R munin:munin /var/cache/nginx/;

COPY ./conf/munin.conf /etc/munin/munin.conf
RUN echo -e "html_strategy cgi\ngraph_strategy cgi" > /etc/munin/munin-conf.d/cgi-strategy.conf
COPY ./conf/munin-nginx.conf /etc/nginx/conf.d/default.conf

COPY ./docker-entrypoint.d/40-munin-init.sh /docker-entrypoint.d/
COPY ./docker-entrypoint.d/50-spawn-fcgi.sh /docker-entrypoint.d/

ENTRYPOINT ["/docker-entrypoint.sh"]
USER munin
CMD ["nginx", "-g", "daemon off;"]
