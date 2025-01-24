# 简易KV系统

## redis通讯协议

[http://forthxu.com/blog/article/58.html](http://forthxu.com/blog/article/58.html)

已实现命令

```
~ redis-cli -p 6378
127.0.0.1:6378> set x y
OK
127.0.0.1:6378> get x
"y"
127.0.0.1:6378> keys *
1) "key:__rand_int__"
2) "x"
127.0.0.1:6378> version
forthxuKV version 1.0
```

## 压测

```
~ redis-benchmark -h 127.0.0.1 -p 6378 -t set -n 1000000  -P 1000 -q

SET: 1248120.38 requests per second, p50=0.367 msec

~ redis-benchmark -h 127.0.0.1 -p 6378 -t get -n 1000000  -P 1000 -q

GET: 3436426.00 requests per second, p50=0.647 msec
```

## 编译

```
make mac
make linux ARCH=arm64
make windows ARCH=amd64
```

## 下载

https://github.com/forthxu/kv/releases

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