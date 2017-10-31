FROM docker.elastic.co/elasticsearch/elasticsearch:5.6.3

ARG ES_PLUGINS_INSTALL="discovery-ec2,repository-s3"

WORKDIR /usr/share/elasticsearch
RUN for plugins in $(echo $ES_PLUGINS_INSTALL | tr ',' '\n'); do elasticsearch-plugin install --batch "$plugins"; done

USER root
# Add nginx official repository
ADD nginx.repo /etc/yum.repos.d/nginx.repo

RUN yum update -y && \
    yum install -y epel-release && \
    yum install -y nginx supervisor && \
    yum clean all && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

ADD etc/supervisord.conf /etc/supervisord.conf
ADD etc/supervisord.conf.d /etc/supervisord.conf.d/
ADD etc/nginx.conf /etc/nginx/nginx.conf
ADD etc/default.conf /etc/nginx/conf.d/default.conf

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
