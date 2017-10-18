# "ported" by Adam Miller <maxamillion@fedoraproject.org> from
#   https://github.com/fedora-cloud/Fedora-Dockerfiles
#
# Originally written for Fedora-Dockerfiles by
#   "Scott Collier" <scollier@redhat.com>

FROM centos:centos6
MAINTAINER The CentOS Project <cloud-ops@centos.org>

# update the repo
RUN rpm -Uvh https://mirror.webtatic.com/yum/el6/latest.rpm
RUN yum -y update && yum -y install epel-release
RUN yum -y update && yum -y install httpd mysql bash-completion pwgen supervisor sendmail mysql56u libmemcached10 \
                                    php56w php56w-common php56w-cli php56w-bcmath php56w-dba php56w-xml php56w-process \
                                    php56w-xmlrpc php56w-gd php56w-mysqlnd php56w-mcrypt php56w-mbstring php56w-soap \
                                    php56w-pecl-memcached php56w-pecl-geoip php56w-pecl-xdebug php-pear-XML-Parser \
                                    php-pear-Mail php-pear-Mail-Mime php-pear-DB php-pear-HTML-Common \
                                    php-pear-Auth-SASL php-pear-phing php-pear-Pager perl-IPC-Signal \
                                    perl-Proc-WaitStat  perl-mime-construct liblockfile lockfile-progs \
                                    logcheck mod_ssl openssl install tar zip php56w-intl

COPY files/wkhtmltox-0.12.2.1_linux-centos6-amd64.rpm /tmp/wkhtmltox-0.12.2.1_linux-centos6-amd64.rpm
COPY files/xcache-3.2.0-2.tar /tmp/xcache-3.2.0-2.tar

RUN yum -y localinstall /tmp/wkhtmltox-0.12.2.1_linux-centos6-amd64.rpm

# install xcache 3.2.0 which works with php5.6, unfortunately, have to compile yourself
RUN yum -y groupinstall 'Development Tools' 'Development Libraries' && yum -y install php56w-devel
RUN tar xf /tmp/xcache-3.2.0-2.tar && \
     pushd /xcache-3.2.0/ && phpize && popd &>/dev/null \
     && pushd /xcache-3.2.0/ && ./configure --enable-xcache && popd &>/dev/null \
     && pushd /xcache-3.2.0/ && make install && popd &>/dev/null \
     && mkdir /var/www/xcache && cp -rf /xcache-3.2.0/htdocs/* /var/www/xcache/ \
     && rm -rf /xcache-3.2.0

RUN yum clean all

RUN touch /tmp/propelpdo.log && chmod 777 /tmp/propelpdo.log
RUN touch /var/log/cron.log && chmod 777 /var/log/cron.log
COPY files/geoip/* /usr/share/GeoIP/

# add website apache configs.
COPY configs/apache-configs/httpd.conf /etc/httpd/conf/httpd.conf

# Add custom ini files
COPY ini/xcache.ini /etc/php.d/xcache.ini
COPY ini/php.ini /etc/php.ini

RUN rm /etc/httpd/conf.d/ssl.conf && mkdir -p /var/www/jackfruit

# Simple startup script to avoid some issues observed with container restart
ADD run-httpd.sh /usr/bin/run-httpd.sh

CMD ["/usr/bin/run-httpd.sh"]