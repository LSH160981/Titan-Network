#!/bin/bash

# 安装节点
install_node() {

    # 身份码
    id="B9AF3196-E4E4-4A50-BDE3-8F0C3B882428"
    # 容器数量
    container_count=5
    # 默认的开启端口
    start_rpc_port=30000
    # 默认存储路径
    custom_storage_path=""
    # 每一个容器的大小
    storage_gb=5

    # 去除输入中的回车符   这两行代码 特殊使用
    # read -p "请输入你想要分配每个节点的存储空间大小（GB），单个上限2T, 网页生效较慢，等待20分钟后，网页查询即可: " storage_gb
    # storage_gb=$(echo "$storage_gb" | tr -d '\r')

    apt update

    if ! command -v docker &> /dev/null
    then
        echo "未检测到 Docker，正在安装..."
        apt-get install ca-certificates curl gnupg lsb-release -y
        apt-get install docker.io -y
    else
        echo "Docker 已安装。"
    fi

    docker pull nezha123/titan-edge:1.7

    for ((i=1; i<=container_count; i++))
    do
        current_rpc_port=$((start_rpc_port + i - 1))
        storage_path="$PWD/titan_storage_$i"

        # 检查是否存在同名容器
        existing_container=$(docker ps -a -q -f name="titan$i")
        if [ -n "$existing_container" ]; then
            echo "检测到同名容器 titan$i，正在停止并删除..."
            docker stop $existing_container
            docker rm $existing_container
        fi

        mkdir -p "$storage_path"

        container_id=$(docker run -d --restart always -v "$storage_path:/root/.titanedge/storage" --name "titan$i" --net=host nezha123/titan-edge:1.7)

        echo "节点 titan$i 已经启动 容器ID $container_id"

        sleep 20

        docker exec $container_id bash -c "\
            sed -i 's/^[[:space:]]*#StorageGB = .*/StorageGB = $storage_gb/' /root/.titanedge/config.toml && \
            sed -i 's/^[[:space:]]*#ListenAddress = \"0.0.0.0:1234\"/ListenAddress = \"0.0.0.0:$current_rpc_port\"/' /root/.titanedge/config.toml"

        docker restart $container_id

        docker exec $container_id bash -c "\
            titan-edge bind --hash=$id https://api-test1.container1.titannet.io/api/v2/device/binding"
        echo "节点 titan$i 已绑定."
    done

    echo "===XiaoLiao===========FeSo4================所有节点均已设置并启动==================================="

}

install_node





