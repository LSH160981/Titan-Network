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
    apt update && apt upgrade -y
    apt install curl wget git -y
}

# 安装 Python 3.11 
function install_python() {
    echo "安装 Python 3.11..."
    add-apt-repository ppa:deadsnakes/ppa -y
    apt install python3.11 python3.11-venv python3.11-dev python3-pip -y

    echo "验证 Python 版本..."
    python3.11 --version
}

install_dependencies
install_python

# 下载GitHub的代码
git clone https://github.com/LSH160981/grass-code

# 进入代码目录
cd grass-code

# 安装依赖
python -m pip install -r requirements.txt

# 在后台运行脚本
nohup python main.py &

