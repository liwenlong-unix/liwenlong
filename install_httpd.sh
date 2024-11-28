#!/bin/bash
#Author: 李余生-N46 
#httpd source code install

#下载源码包
version=2.4.46
target_dir=/usr/local/src
install_dir=/usr/local/httpd
rpm -qa | grep wget || yum install -y wget
wget -O $target_dir/httpd-${version}.tar.bz2 https://downloads.apache.org/httpd/httpd-${version}.tar.bz2

#安装依赖包
yum install -y gcc make apr-devel apr-util-devel pcre-devel openssl-devel redhat-rpm-config

#添加apache用户
id apache &> /dev/null || useradd -r -u 80 -d /var/www -s /sbin/nologin apache

#解压源码包
tar xf $target_dir/httpd-${version}.tar.bz2 -C $target_dir
cd $target_dir/httpd-${version}

#编译安装
./configure --prefix=$install_dir --sysconfdir=/etc/httpd --enable-ssl
make -j`lscpu | grep "^CPU(s)" | awk '{print $NF}'` && make install

#设置环境变量
echo 'PATH='$install_dir'/bin:$PATH'  > /etc/profile.d/httpd.sh
source /etc/profile.d/httpd.sh

#修改配置文件
sed -ri 's#(User )daemon#\1apache#' /etc/httpd/httpd.conf
sed -ri 's#(Group )daemon#\1apache#' /etc/httpd/httpd.conf

#启动httpd服务
apachectl start

#检查firewalld状态
firewall_status=`systemctl status firewalld.service | grep "Active" | awk '{print $2}'`
if [ $firewall_status = active ];then
    echo "防火墙已启用，开放端口"
    firewall-cmd --permanent --add-service=http --add-service=https
    firewall-cmd --reload
fi
