# tools
1、准备工作：有个域名以及对应的https证书

2、由于国内iphone小火箭下架，旧版的IPA文件不支持websocket（新版不存在这个问题），所以我在脚本中启用了2个容器，一个给旧版小火箭用，端口是8080，协议是TLS+TCP，配置文件是docker/v2ray/config.json；一个给支持websocket的客户端使用，部署方式是nginx +TLS + 反向代理，端口是443,配置文件是docker/v2ray/v2ray_nginx_server.json。配置文件地址：https://github.com/thirdcountry/tools/blob/master/docker.tar.gz
脚本文件地址：https://github.com/thirdcountry/tools/blob/master/deploy_v2ray.sh

3、运行脚本之前，上传配置文件到/root 目录下，当然你也可以根据需要自行修改脚本

