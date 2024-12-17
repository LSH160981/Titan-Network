
# S-Titan 使用文档

该脚本用于安装并启动多个 Titan Network 节点容器。通过以下参数配置节点，若未指定某个参数，则使用默认值。

## 使用示例

### 使用默认参数
如果不传递任何参数，脚本会使用默认配置：
```bash
wget -O duokai.sh https://raw.githubusercontent.com/LSH160981/Titan-Network/main/duokai.sh && chmod +x duokai.sh && ./duokai.sh
```

## 参数说明

### `-i` 身份码
指定身份码，用于绑定设备。默认值为：
```
B9AF3196-E4E4-4A50-BDE3-8F0C3B882428
```

### `-c` 容器数量
指定要启动的容器数量。默认值为：
```
5
```

### `-p` 启动端口
指定第一个容器的 RPC 启动端口，后续容器会依次递增。默认值为：
```
30000
```

### `-s` 存储路径
指定存储容器数据的路径。若不指定，则使用当前工作目录下的 `titan_storage_*` 作为存储路径。

### `-g` 每个容器的大小
指定每个容器的存储大小（单位为 GB）。默认值为：
```
21
```

### 使用自定义参数
如果需要自定义配置，可以使用命令行传递参数：
```bash
wget -O duokai.sh https://raw.githubusercontent.com/LSH160981/Titan-Network/main/duokai.sh && chmod +x duokai.sh && ./duokai.sh -i "NewID" -c 10 -p 30010 -s "/path/to/storage" -g 30
```
以上命令会将身份码设置为 `"NewID"`，容器数量为 `10`，启动端口为 `30010`，存储路径为 `/path/to/storage`，每个容器的大小为 `30 GB`。


# S-grass
```
wget -O grass.sh https://raw.githubusercontent.com/LSH160981/Titan-Network/main/grass.sh && chmod +x grass.sh && ./grass.sh
```


 
