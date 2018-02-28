FROM unicon/shibboleth-sp@sha256:e54cc2f47bd4d7529497bde778fa50b7392c78feb0b16610e0b3ad6b5ad8aafe

RUN yum -y update \
    && yum -y install php mod_ssl mod_substitute mod_proxy_ajp

COPY etc-shibboleth /etc/shibboleth/
COPY etc-httpd/ /etc/httpd/
COPY var-www-html/ /var/www/html/
