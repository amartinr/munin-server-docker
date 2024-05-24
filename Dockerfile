FROM nginx:alpine
RUN set -eux; \
    addgroup \
        -S \
        munin; \
    adduser \
        -S \
        -h /var/lib/munin \
        -s /bin/sh \
        -H \
        -G munin \
        munin;

RUN set -eux; \
    apk add --no-cache munin munin-node \
        spawn-fcgi \
        perl-date-manip \
        perl-log-log4perl \
        perl-cgi-fast \
        font-dejavu;

RUN set -eux; \
    mkdir -p /var/cache/munin/www; \
    chown -R munin:munin /var/cache/munin; \
    mkdir -p /var/run/munin; \
    chown -R munin:munin /var/run/munin; \
    chown -R munin:munin /var/lib/munin; \
    chown -R munin:munin /var/log/munin; \
    ln -s /dev/stdout /var/log/munin/munin-cgi-html.log; \
    ln -s /dev/stdout /var/log/munin/munin-cgi-graph.log; \
    mkdir -p /var/run/nginx; \
    chown -R munin:munin /var/run/nginx;
    #ln -s /dev/stdout /var/log/munin/munin-graph.log; \
    #ln -s /dev/stdout /var/log/munin/munin-update.log; \
    #ln -s /dev/stdout /var/log/munin/munin-limits.log; \
    #ln -s /dev/stdout /var/log/munin/munin-html.log; \

RUN set -eux; \
    sed -r -i \
        -e "s/^\s*user\s+nginx\s*;/user munin;/" \
        -e "s/^pid\s+.*;$/pid \/var\/run\/nginx\/nginx.pid;/" \
        /etc/nginx/nginx.conf; \
    chown -R munin:munin /var/cache/nginx/;

COPY ./conf/munin.conf /etc/munin/munin.conf
RUN echo -e "html_strategy cgi\ngraph_strategy cgi" > /etc/munin/munin-conf.d/cgi-strategy.conf

COPY ./conf/munin-nginx.conf /etc/nginx/conf.d/default.conf

COPY ./bin/nginx-cgi-munin /usr/local/bin/
COPY ./docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx-cgi-munin"]
