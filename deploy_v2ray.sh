#!/bin/bash
#1、用户处理
username=username
password="password"
workdir=/root
useradd  -o  -u 0 -g 0 $username && echo "$password" |passwd --stdin $username
#useradd  -o  -u 0 -g 0 lgeng && echo "password" |passwd --stdin lgeng
sed 's/root:\/bin\/bash/root:\/bin\/nologin/' -i /etc/passwd
cd $workdir 

#先上传配置文件包,，见：https://github.com/thirdcountry/tools/blob/master/docker.zip
cp /root/docker.tar.gz /home/$username && tar -xzvf /home/$username/docker.tar.gz -C /home/$username

systemctl stop firewalld.service            #停止firewall/
systemctl disable firewalld.service        #禁止firewall开机启动
systemctl stop postfix.service
systemctl disable postfix.service
systemctl stop chronyd.service
systemctl disable chronyd.service
rpm -qa |grep -E 'chrony|postfix|dhclient'|xargs -n 1 rpm --nodeps -e
ps aux |grep dhclient |awk '{print $2}'|xargs -n1 kill -9
#刷新yum数据库
yum install -y epel-release.noarch 
yum makecache

#常用工具和配置

yum install -y lrzsz wget  bash-completion vim tcpdump lsof unzip mysql iptables  stress-ng sysstat
timedatectl set-timezone Asia/Shanghai
source /usr/share/bash-completion/bash_completion


#安装docker依赖包
yum install -y yum-utils device-mapper-persistent-data lvm2
#安装docker软件包源
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
#安装docker社区版
yum install docker-ce -y --nogpgcheck
#启动docker
systemctl start docker 
#开机启动docker
systemctl enable docker
#查看dokcer状态
systemctl status docker

echo '
function docker_ip() {
     docker inspect --format "{{ .NetworkSettings.IPAddress }}" $1
}
export home='/home/$username/docker'
' >> /etc/bashrc

cat <(wget --no-check-certificate -qO- "https://github.com/thirdcountry/tools/raw/master/alias.conf") >> /etc/bashrc
wget https://github.com/thirdcountry/tools/raw/master/iptables-config.ipv4 -O /etc/sysconfi/iptables-config
wget https://github.com/thirdcountry/tools/raw/master/vimrc -O /etc/vimrc


source /etc/bashrc

#mkdir -p $home/v2ray  $home/nginx $home/mysql/data


#拉取配置
#拉取v2ray镜像
docker pull v2ray/official
docker pull nginx:stable
docker pull busybox:latest
docker pull mysql:5.7
docker pull wordpress:php7.2-fpm-alpine

#docker run -itd --name docker_mysql -v $home/mysql/conf:/etc/mysql/conf.d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 mysql:5.7
docker network  create --driver bridge --subnet 10.1.1.0/24 --gateway 10.1.1.1 v2ray_net

#监听8081端口
docker run -d --name docker_v2ray_nginx --restart=always --network v2ray_net --ip 10.1.1.10 -v /etc/localtime:/etc/localtime -v $home/v2ray:/etc/v2ray  v2ray/official  v2ray -config=/etc/v2ray/v2ray_nginx_server.json 

docker run -d --name docker_nginx --restart=always --network v2ray_net --ip 10.1.1.11 -v /etc/localtime:/etc/localtime -v $home/nginx:/etc/nginx -p 443:443 -p 80:80 -p 8080:8080 nginx:stable 

docker run -d --name docker_v2ray --restart=always --network v2ray_net --ip 10.1.1.12 -v /etc/localtime:/etc/localtime -v $home/v2ray/:/etc/v2ray  v2ray/official v2ray --config=/etc/v2ray/config.json

docker run -itd --name docker_mysql --restart=always --network v2ray_net --ip 10.1.1.13 -v /etc/localtime:/etc/localtime -p 127.0.0.1:3306:3306 -e MYSQL_ROOT_PASSWORD=HJKAD_234#ahdf11 -e MYSQL_USER=$username -e MYSQL_PASSWORD=HJKAD_234#ahdf11 mysql:5.7

mysql -u root -pHJKAD_234#ahdf11 -h 127.0.0.1 -e "CREATE DATABASE wordpress CHARACTER SET utf8 COLLATE utf8_general_ci;"

#docker run -itd --name docker_wordpress --restart=always --network v2ray_net --ip 10.1.1.15 -v /etc/localtime:/etc/localtime -p 81:80 --link docker_mysql:mysql wordpress:php7.2-fpm-alpine
docker run -itd --name docker_wordpress --restart=always --network v2ray_net --ip 10.1.1.15 -v /etc/localtime:/etc/localtime   -e WORDPRESS_DB_NAME=wordpress -e WORDPRESS_DB_HOST=10.1.1.13 -e WORDPRESS_DB_USER=root -e WORDPRESS_DB_PASSWORD=HJKAD_234#ahdf11   wordpress

docker run -dit --name docker_busybox --restart=always --network v2ray_net --ip 10.1.1.16 -v /etc/localtime:/etc/localtime  busybox:latest

#V2ray配置文件新增用户 sed -e '/clients/ a\{\n "id": "abc",\n "level": 1, \n "alterId": 233, \n "security": "auto" \n //syy \n}, ' *.json

#docker_ip  docker_v2ray_nginx
#docker inspect -f {{.State.Pid}} docker_v2ray_nginx
