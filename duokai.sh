#!/bin/bash

# 更新软件包索引
sudo apt-get update -y

# 安装xray
install_xray() {
    
    # 下载并执行 Xray 安装脚本
    XRAY_INSTALL_SCRIPT="https://github.com/233boy/Xray/raw/main/install.sh"
    if ! wget -qO- "$XRAY_INSTALL_SCRIPT" | bash; then
        echo "Xray 安装脚本执行失败，请检查网络连接或安装脚本链接。"
        exit 1
    fi
    
    # 添加 Xray 配置
    XRAY_UUID="1483c30c-ae2c-4130-f643-c6139d199c42"
    XRAY_PORT="7000"
    xray add tcp "$XRAY_PORT" "$XRAY_UUID"
    
    # 检查当前 IP
    CURRENT_IP=$(curl -s ipv4.ip.sb)
    if [ -n "$CURRENT_IP" ]; then
        echo "当前服务器的 IPv4 地址是: $CURRENT_IP"
    else
        echo "无法获取 IPv4 地址，请检查网络连接。"
    fi
}

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
    storage_gb=21

    if ! command -v docker &> /dev/null
    then
        echo "未检测到 Docker，正在安装..."
        sudo apt-get install ca-certificates curl gnupg lsb-release -y
        sudo apt-get install docker.io -y
    else
        echo "Docker 已安装。"
    fi

    sudo docker pull nezha123/titan-edge:1.7

    for ((i=1; i<=container_count; i++))
    do
        current_rpc_port=$((start_rpc_port + i - 1))
        storage_path="$PWD/titan_storage_$i"

        # 检查是否存在同名容器
        existing_container=$(sudo docker ps -a -q -f name="titan$i")
        if [ -n "$existing_container" ]; then
            echo "检测到同名容器 titan$i，正在停止并删除..."
            sudo docker stop $existing_container
            sudo docker rm $existing_container
        fi

        sudo mkdir -p "$storage_path"

        container_id=$(sudo docker run -d --restart always -v "$storage_path:/root/.titanedge/storage" --name "titan$i" --net=host nezha123/titan-edge:1.7)

        echo "节点 titan$i 已经启动 容器ID $container_id"

        sleep 20

        sudo docker exec $container_id bash -c "\
            sed -i 's/^[[:space:]]*#StorageGB = .*/StorageGB = $storage_gb/' /root/.titanedge/config.toml && \
            sed -i 's/^[[:space:]]*#ListenAddress = \"0.0.0.0:1234\"/ListenAddress = \"0.0.0.0:$current_rpc_port\"/' /root/.titanedge/config.toml"

        sudo docker restart $container_id

        sudo docker exec $container_id bash -c "\
            titan-edge bind --hash=$id https://api-test1.container1.titannet.io/api/v2/device/binding"
        echo "节点 titan$i 已绑定."
    done

    echo "===XL===FeSo4================所有节点均已设置并启动================================"

}

install_node
install_xray
