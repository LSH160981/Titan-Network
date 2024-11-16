#!/bin/bash

# 检查是否以root用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以root用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到root用户，然后再次运行此脚本。"
    exit 1
fi

function install_node() {

# 固定身份码  B9AF3196-E4E4-4A50-BDE3-8F0C3B882428
id=B9AF3196-E4E4-4A50-BDE3-8F0C3B882428
echo "当前使用的身份码为: $id"

# 让用户输入想要创建的容器数量
container_count=5
echo "创建的容器数量: $container_count"

# 让用户输入起始 RPC 端口号
start_rpc_port=30000
echo "创建的容器 RPC 起始端口号: $start_rpc_port"

read -p "请输入每个节点的存储空间大小（GB，1-2048）: " storage_gb

# ---用户存储路径（可选）
custom_storage_path

apt update

# 检查 Docker 是否已安装
if ! command -v docker &> /dev/null
then
    echo "未检测到 Docker，正在安装..."
    apt-get install ca-certificates curl gnupg lsb-release -y
    
    # 安装 Docker 最新版本
    apt-get install docker.io -y
else
    echo "Docker 已安装。"
fi

# 拉取Docker镜像
docker pull nezha123/titan-edge:1.7

# 创建用户指定数量的容器
for ((i=1; i<=container_count; i++))
do
    current_rpc_port=$((start_rpc_port + i - 1))

    # 判断用户是否输入了自定义存储路径
    if [ -z "$custom_storage_path" ]; then
        # 用户未输入，使用默认路径
        storage_path="$PWD/titan_storage_$i"
    else
        # 用户输入了自定义路径，使用用户提供的路径
        storage_path="$custom_storage_path"
    fi

    # 确保存储路径存在
    mkdir -p "$storage_path"

    # 运行容器，并设置重启策略为always
    container_id=$(docker run -d --restart always -v "$storage_path:/root/.titanedge/storage" --name "titan$i" --net=host  nezha123/titan-edge:1.7)

    echo "节点 titan$i 已经启动 容器ID $container_id"

    sleep 30

    # 修改宿主机上的config.toml文件以设置StorageGB值和端口
    docker exec $container_id bash -c "\
        sed -i 's/^[[:space:]]*#StorageGB = .*/StorageGB = $storage_gb/' /root/.titanedge/config.toml && \
        sed -i 's/^[[:space:]]*#ListenAddress = \"0.0.0.0:1234\"/ListenAddress = \"0.0.0.0:$current_rpc_port\"/' /root/.titanedge/config.toml && \
        echo '容器 titan'$i' 的存储空间设置为 $storage_gb GB，RPC 端口设置为 $current_rpc_port'"

    # 重启容器以让设置生效
    docker restart $container_id

    # 进入容器并执行绑定命令
    docker exec $container_id bash -c "\
        titan-edge bind --hash=$id https://api-test1.container1.titannet.io/api/v2/device/binding"
    echo "节点 titan$i 已绑定."

done

echo "==============================所有节点均已设置并启动==================================="

}
install_node
