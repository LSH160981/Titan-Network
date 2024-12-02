#!/bin/bash

# 检查是否以root用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以root用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到root用户，然后再次运行此脚本。"
    exit 1
fi

# 安装必要的依赖
function install_dependencies() {
    echo "安装必要的依赖..."
    sudo apt update && sudo apt upgrade -y
    sudo apt install curl wget git -y
}

# 安装 Python
function install_python() {
    # 判断一下是否已经安装了 Python
    if command -v python3.11 >/dev/null; then
        echo "Python 已经安装，跳过安装步骤。"
        return
    fi

    echo "安装 Python 3 ..."
    add-apt-repository ppa:deadsnakes/ppa -y
    sudo apt install python3.11 python3.11-venv python3.11-dev python3-pip -y

    echo "验证 Python 版本..."
    python3.11 --version
}

install_dependencies
install_python

# 下载GitHub的代码
git clone https://github.com/LSH160981/grass-code

# 进入代码目录
cd grass-code

# 创建虚拟环境
python -m venv grass

# 激活虚拟环境
source grass/bin/activate

# 安装依赖
python -m pip install -r requirements.txt

# 在后台运行脚本
nohup python main.py &

