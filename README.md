# 简易KV系统

## redis通讯协议

[http://forthxu.com/blog/article/58.html](http://forthxu.com/blog/article/58.html)

已实现命令

```
set x y
get x
keys *
version
```

## 压测

```
redis-benchmark -h 127.0.0.1 -p 6378 -t set -n 1000000 -q

SET: 103928.50 requests per second, p50=0.239 msec
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