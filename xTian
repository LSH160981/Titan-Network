#!/bin/bash

# 检查是否以root用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以root用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到root用户，然后再次运行此脚本。"
    exit 1
fi

install_node() {

# 身份码
id="B9AF3196-E4E4-4A50-BDE3-8F0C3B882428"
# 容器数量
container_count=1
# 默认的开启端口
start_rpc_port=30000
# 默认存储路径
custom_storage_path=""
# 每一个容器的大小
storage_gb=25

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
docker pull nezha123/titan-edge:1.7_amd64

# 创建用户指定数量的容器
for i in $(seq 1 $container_count)
do
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
    container_id=$(docker run -d --restart always -v "$storage_path:/root/.titanedge/storage" --name "titan$i" --net=host nezha123/titan-edge:1.7_amd64)

    echo "节点 titan$i 已经启动 容器ID $container_id"

    sleep 30

        # 修改宿主机上的config.toml文件以设置StorageGB值
docker exec $container_id bash -c "\
    sed -i 's/^[[:space:]]*#StorageGB = .*/StorageGB = $storage_gb/' /root/.titanedge/config.toml && \
    echo '容器 titan'$i' 的存储空间已设置为 $storage_gb GB'"
   
    # 进入容器并执行绑定和其他命令
    docker exec $container_id bash -c "\
        titan-edge bind --hash=$id https://api-test1.container1.titannet.io/api/v2/device/binding"
done

echo "==============================所有节点均已设置并启动===================================."

}


install_node
