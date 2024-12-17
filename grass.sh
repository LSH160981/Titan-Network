#!/bin/bash

# 安装必要的依赖
function install_dependencies() {
}

# 安装 Python
function install_python() {
    # 判断一下是否已经安装了 Python
    if command -v python3.11 >/dev/null; then
        echo "Python 已经安装，跳过安装步骤。"
        return
    fi

    echo "安装 Python 3 ..."
    sudo add-apt-repository ppa:deadsnakes/ppa -y
    sudo apt install python3.11 python3.11-venv python3.11-dev python3-pip -y

    echo "验证 Python 版本..."
    python3.11 --version
}

install_dependencies
install_python

# 下载GitHub的代码
sudo git clone https://github.com/LSH160981/grass-code

# 进入代码目录
cd grass-code

# 创建虚拟环境
sudo python3 -m venv grass

# 修改虚拟环境目录权限，以便当前用户可以使用
sudo chown -R $USER:$USER grass

# 激活虚拟环境
source grass/bin/activate

# 安装依赖
sudo python3 -m pip install -r requirements.txt

# 在后台运行脚本
nohup sudo python3 main.py > output.log 2>&1 &
