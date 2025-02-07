# 简易KV系统

该项目主要举例 golang项目结构设置、Makefile程序编译、Docker镜像打包、跨平台编译、amd64和arm64不同cpu架构编译、github action流程（发布release、发布package）

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
MacBook Pro Apple M3 Max 36 GB

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
make docker ARCH=amd64
```

## 下载

https://github.com/forthxu/kv/releases

## docker

### 编译docker镜像

```
make docker
make docker ARCH=arm64
make docker ARCH=amd64
```
### 启动docker容器

https://github.com/forthxu/kv/pkgs/container/kv

```
docker pull ghcr.io/forthxu/kv:v1.0.0-amd64

docker run --name kv -d -p 6378:6378 \
ghcr.io/forthxu/kv:latest-amd64
```

# github action

release.app.yaml 编译golang程序并发布到github release，方便使用者直接下载

release.images.yaml 编译golang程序并打包成docker镜像发布

程序和docker镜像同时发布amd64和arm64两个版本，并且程序有mac、linux、windows三个版本