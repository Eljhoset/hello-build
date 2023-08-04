FROM centos:8

RUN sed -i -e "s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g" /etc/yum.repos.d/CentOS-*

RUN dnf -y install epel-release && \
    dnf -y install mock rpmdevtools nginx && \
    dnf clean all

RUN dnf -y update

RUN rpmdev-setuptree

COPY rpm.sh srpm.sh update_nginx_redirect.sh /usr/local/bin/
COPY epel-8-x86_64.cfg /etc/mock/epel-8-x86_64.cfg
COPY lib-repo.repo /etc/yum.repos.d/lib-repo.repo
COPY redirect.conf /etc/nginx/conf.d/redirect.conf

ENV PATH="/usr/local/bin:${PATH}"


WORKDIR /home
COPY entrypoint.sh .

ENTRYPOINT ["/home/entrypoint.sh"]