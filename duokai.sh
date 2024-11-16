function install_node() {

    # 固定身份码
    id="123456"
    echo "身份码已固定为: $id"

    # 固定创建容器数量
    container_count=5
    echo "节点数量已固定为: $container_count"

    # 固定起始 RPC 端口号
    start_rpc_port=30000
    echo "起始 RPC 端口已固定为: $start_rpc_port"

    # 让用户输入想要分配的空间大小
    read -p "请输入你想要分配每个节点的存储空间大小（GB），单个上限2T, 网页生效较慢，等待20分钟后，网页查询即可: " storage_gb

    # 固定存储路径为空
    custom_storage_path=""
    echo "节点存储路径已固定为: 默认路径"

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

        # 使用默认路径
        storage_path="$PWD/titan_storage_$i"

        # 确保存储路径存在
        mkdir -p "$storage_path"

        # 运行容器，并设置重启策略为always
        container_id=$(docker run -d --restart always -v "$storage_path:/root/.titanedge/storage" --name "titan$i" --net=host nezha123/titan-edge:1.7)

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
