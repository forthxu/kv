# 简易KV系统

redis通讯协议

已实现

```
set x y
get x
keys *
version
```

## 编译

```
make mac
make linux ARCH=arm64
make windows ARCH=amd64
```

## docker

### 编译docker镜像

```
make docker ARCH=arm64
```
### 启动docker容器

```
docker run --name kv -d -p 6378:6378 \
-v /workspace:/workspace \
forthxu/kv:latest
```