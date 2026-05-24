# Jobe image for docker_moodle_coderunner that bakes in local workspace changes.
FROM docker.io/ubuntu:24.04

ARG TZ=Pacific/Auckland
ENV APACHE_RUN_USER=www-data
ENV APACHE_RUN_GROUP=www-data
ENV APACHE_LOG_DIR=/var/log/apache2
ENV APACHE_LOCK_DIR=/var/lock/apache2
ENV APACHE_PID_FILE=/var/run/apache2.pid
ENV LANG=C.UTF-8

COPY jobeinabox/000-jobe.conf /
COPY jobeinabox/container-test.sh /
COPY jobe /var/www/html/jobe

RUN ln -snf /usr/share/zoneinfo/"$TZ" /etc/localtime && \
    echo "$TZ" > /etc/timezone && \
    apt-get update && \
    apt-get --no-install-recommends install -yq \
        acl \
        apache2 \
        build-essential \
        cabal-install \
        fp-compiler \
        ghc \
        libapache2-mod-php \
        nano \
        nodejs \
        octave \
        default-jdk \
        php \
        php-cli \
        php-mbstring \
        php-intl \
        python3 \
        python3-pip \
        python3-setuptools \
        pylint \
        sqlite3 \
        sudo \
        swi-prolog \
        tzdata \
        unzip && \
    pylint --reports=no --score=n --generate-rcfile > /etc/pylintrc && \
    ln -sf /proc/self/fd/1 /var/log/apache2/access.log && \
    ln -sf /proc/self/fd/1 /var/log/apache2/error.log && \
    sed -i "s/export LANG=C/export LANG=$LANG/" /etc/apache2/envvars && \
    sed -i '1 i ServerName localhost' /etc/apache2/apache2.conf && \
    sed -i 's/ServerTokens\ OS/ServerTokens \Prod/g' /etc/apache2/conf-enabled/security.conf && \
    sed -i 's/ServerSignature\ On/ServerSignature \Off/g' /etc/apache2/conf-enabled/security.conf && \
    rm /etc/apache2/sites-enabled/000-default.conf && \
    mv /000-jobe.conf /etc/apache2/sites-enabled/ && \
    mkdir -p /var/crash && \
    chmod 777 /var/crash && \
    echo '<!DOCTYPE html><html lang="en"><title>Jobe</title><h1>Jobe</h1></html>' > /var/www/html/index.html && \
    printf '%s\n%s\n' '<?php' 'require __DIR__ . "/public/index.php";' > /var/www/html/jobe/index.php && \
    apache2ctl start && \
    cd /var/www/html/jobe && \
    /usr/bin/python3 /var/www/html/jobe/install --max_uid=500 && \
    rm -f /tmp/jobe_language_cache_file && \
    chown -R ${APACHE_RUN_USER}:${APACHE_RUN_GROUP} /var/www/html && \
    apt-get -y autoremove --purge && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 80

HEALTHCHECK --interval=1m --timeout=2s \
    CMD /usr/bin/python3 /var/www/html/jobe/minimaltest.py || exit 1

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
