#!/bin/bash

if [ 0"$RABBITMQ_NODE_TYPE" != "0" ];then
    set -ex
    if [ -e "/var/lib/rabbitmq/is_not_first_time" ]; then
        exec "$@"
    else
        if [ $RABBITMQ_NODE_TYPE == "stats" ];then
            touch /var/lib/rabbitmq/is_not_first_time
            exec "$@"
        elif [ $RABBITMQ_NODE_TYPE == "ram" ];then
            docker-entrypoint.sh rabbitmq-server -detached # 先按官方入口文件启动且是后台运行
            rabbitmqctl stop_app # 停止应用
            rabbitmqctl join_cluster --ram $RABBITMQ_CLUSTER_NODE_NAME # 加入rmqha_node0集群
            rabbitmqctl start_app # 启动应用
            rabbitmqctl stop # 停止所有服务
        elif [ $RABBITMQ_NODE_TYPE == "disc" ];then
            docker-entrypoint.sh rabbitmq-server -detached # 先按官方入口文件启动且是后台运行
            rabbitmqctl stop_app # 停止应用
            rabbitmqctl join_cluster --disc $RABBITMQ_CLUSTER_NODE_NAME # 加入rmqha_node0集群
            rabbitmqctl start_app # 启动应用
            rabbitmqctl stop # 停止所有服务
        else
            echo "[Error] please check the RABBITMQ_NODE_TYPE, it should be 'ram', 'disc' or 'stats'!"
        fi
        touch /var/lib/rabbitmq/is_not_first_time
        sleep 1s
        exec "$@"
    fi
fi
exec "$@"
