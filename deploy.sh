#!/bin/sh

# 使用说明，用来提示输入参数
usage() {
	echo "Usage: sh 执行脚本.sh [port|build|base|core|biz|stop|rm]"

	exit 1
}

# 开启所需端口
port(){
	firewall-cmd --add-port=80/tcp --permanent
	firewall-cmd --add-port=8080/tcp --permanent
	firewall-cmd --add-port=8848/tcp --permanent
	firewall-cmd --add-port=9848/tcp --permanent
	firewall-cmd --add-port=9849/tcp --permanent
	firewall-cmd --add-port=6379/tcp --permanent
	firewall-cmd --add-port=3306/tcp --permanent
	firewall-cmd --add-port=9100/tcp --permanent
	firewall-cmd --add-port=9200/tcp --permanent
	firewall-cmd --add-port=9201/tcp --permanent
	firewall-cmd --add-port=9202/tcp --permanent
	firewall-cmd --add-port=9203/tcp --permanent
	firewall-cmd --add-port=9300/tcp --permanent
	service firewalld restart
}

# 构建镜像
build(){
    docker build -t ruoyi/ruoyi-monitor:1.8.0 ruoyi-visual/ruoyi-monitor/.
    docker build -t ruoyi/ruoyi-nacos:1.8.0 ruoyi-visual/ruoyi-nacos/.
    docker build -t ruoyi/ruoyi-seata-server:1.8.0 ruoyi-visual/ruoyi-seata-server/.
    docker build -t ruoyi/ruoyi-sentinel-dashboard:1.8.0 ruoyi-visual/ruoyi-sentinel-dashboard/.
    docker build -t ruoyi/ruoyi-xxl-job-admin:1.8.0 ruoyi-visual/ruoyi-xxl-job-admin/.
    docker build -t ruoyi/ruoyi-gateway:1.8.0 ruoyi-gateway/.
    docker build -t ruoyi/ruoyi-auth:1.8.0 ruoyi-auth/.
    docker build -t ruoyi/ruoyi-system:1.8.0 ruoyi-modules/ruoyi-system/.
    docker build -t ruoyi/ruoyi-gen:1.8.0 ruoyi-modules/ruoyi-gen/.
    docker build -t ruoyi/ruoyi-job:1.8.0 ruoyi-modules/ruoyi-job/.
    docker build -t ruoyi/ruoyi-resource:1.8.0 ruoyi-modules/ruoyi-resource/.
}

# 启动基础环境（必须）
base(){
    cd docker
	docker-compose up -d mysql nginx-web redis minio
}

# mysql启动后，需要创建nacos配置相关的DB和表。
# 配置完成启动nacos，再将nacos配置粘贴到相应的配置文件中
# 之后启动剩余模块
nacos(){
    cd docker
    docker-compose up -d nacos
}

# 环境模块
core(){
    cd docker
    docker-compose up -d seata-server sentinel ruoyi-monitor ruoyi-xxl-job-admin
}

# 启动程序模块（必须）
biz(){
    cd docker
	docker-compose up -d ruoyi-gateway ruoyi-auth ruoyi-system ruoyi-resource
}

# 关闭所有环境/模块
stop(){
	docker-compose stop
}

# 删除所有环境/模块
rm(){
	docker-compose rm
}

# 根据输入参数，选择执行对应方法，不输入则执行使用说明
case "$1" in
"port")
	port
;;
"build")
	build
;;
"base")
	base
;;
"core")
	core
;;
"biz")
	biz
;;
"stop")
	stop
;;
"rm")
	rm
;;
*)
	usage
;;
esac
