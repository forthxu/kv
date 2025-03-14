#编译配置
MAKEFLAGS += --no-print-directory
#工作目录
WORKSPACE=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))
#包名
PACKAGE=$(shell basename $(WORKSPACE))
#编译
TARGET?=$(WORKSPACE)build/
GOBUILD=go build
#版本信息
GITCOMMIT=`git describe --always`
VERSION=$$(git describe 2>/dev/null || echo "0.0.1")
GITDATE=`TZ=UTC git show -s --date=iso-strict-local --format=%cd HEAD`
BUILDDATE=`date -u +"%Y-%m-%dT%H:%M:%S%:z"`
LDFLAGS="-X foshou/librarys/version.Version=${VERSION} -X foshou/librarys/version.BuildDate=${BUILDDATE} -X foshou/librarys/version.GitCommit=${GITCOMMIT} -X foshou/librarys/version.GitDate=${GITDATE}"
CGO_ENABLED=0
#编译目标
ACTION=$(MAKECMDGOALS)
#系统
OS?=$(shell uname|tr A-Z a-z)
ifeq ($(ACTION), mac)
	OS=darwin
	SUFFIX=app
else ifeq ($(ACTION), darwin)
	OS=darwin
	SUFFIX=app
else ifeq ($(ACTION), dylib)
	OS=darwin
	SUFFIX=dylib
	CGO_ENABLED=1
else ifeq ($(ACTION), docker)
	OS=linux
	SUFFIX=bin
else ifeq ($(ACTION), linux)
	OS=linux
	SUFFIX=bin
	CGO_ENABLED=0
else ifeq ($(ACTION), so)
	OS=linux
	SUFFIX=so
	CGO_ENABLED=1
else ifeq ($(ACTION), windows)
	OS=windows
	SUFFIX=exe
else ifeq ($(ACTION), dll)
	OS=windows
	SUFFIX=dll
	CGO_ENABLED=1
endif
ifeq ($(OS), darwin)
	CC=gcc
	CXX=g++
	LD=ld
else ifeq ($(OS), linux)
	CC=gcc
	CXX=g++
	LD=ld
else ifeq ($(OS), windows)
	CC=clang
	CXX=clang++
	LD=ld
endif
#架构
ARCHORIGIN=$(shell uname -m | tr A-Z a-z | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/')
ARCH?=ARCHORIGIN
ifeq ($(ARCH), arm64)
	ARCH=arm64
	ifeq ($(ARCHORIGIN), amd64)
		ifeq ($(OS), linux)
			CC=aarch64-linux-musl-gcc
			CXX=aarch64-linux-musl-g++
			LD=aarch64-linux-musl-ld
		endif
	endif
else
	ARCH=amd64
	ifeq ($(ARCHORIGIN), arm64)
		ifeq ($(OS), linux)
			CC=x86_64-linux-musl-gcc
			CXX=x86_64-linux-musl-g++
			LD=x86_64-linux-musl-ld
		endif
	endif
endif
#docker仓库
REGISTRY=forthxu

#忽略目录
.PHONY: $(PACKAGE)

#默认
default: $(OS)
	@[ -f "$(WORKSPACE)cmd/main.go" ] && $(TARGET)$(PACKAGE).$(ARCH).$(SUFFIX) || exit 0

#帮助
help: info
	@printf "命令格式：\n\tmake $(OS) ARCH=$(ARCH) TARGET=./build\n"
info:
	@printf "目标：\t\t$(PACKAGE)\n"
	@printf "目标后缀：\t$(SUFFIX)\n"
	@printf "目标系统: \t$(OS)\n"
	@printf "目标架构: \t$(ARCH)\n"
	@printf "工作目录:\t$(WORKSPACE)\n"
	@printf "编译目录: \t$(abspath $(TARGET))/\n"
#拷贝资源
resource:
	@mkdir -p $(TARGET)
	@[ -d "$(WORKSPACE)cmd" ] && find $(WORKSPACE)cmd/* -maxdepth 0 -not -regex '.*\.go$$'  -not -regex '.*\.sh$$' |xargs -I {} cp -r {} $(TARGET)/ || exit 0
#生成protobuf
protobuf:
	@[ -d "$(WORKSPACE)proto" ] && find $(WORKSPACE) -maxdepth 1 -type d -name  proto |xargs -I {} find {} -type f -maxdepth 1 | xargs -I {} protoc {} -I $(WORKSPACE) --go_out=$(WORKSPACE) --go-grpc_out=$(WORKSPACE) --experimental_allow_proto3_optional || exit 0
	@[ -d "$(WORKSPACE)proto" ] && find $(WORKSPACE) -regex ".*.pb.go" -exec sh -c 'sed -i".bak" "s/,omitempty//g" "{}" && rm -f "{}.bak"' \; || exit 0

#编译程序
mac: darwin
darwin: program
linux: program
windows: program 
program: info resource protobuf
	@[ -f "$(WORKSPACE)cmd/main.go" ] && CGO_ENABLED=${CGO_ENABLED} CC=${CC} CXX=${CXX} LD=${LD} GOOS=${OS} GOARCH=${ARCH} $(GOBUILD) --ldflags=${LDFLAGS} -o $(TARGET)$(PACKAGE).$(ARCH).${SUFFIX} $(WORKSPACE)cmd/main.go || exit 0
#编译动态库
dylib: dynamic
so: dynamic
dll: dynamic
dynamic: info protobuf
	@[ -d "$(WORKSPACE)plugin" ] && CGO_ENABLED=${CGO_ENABLED} CC=${CC} CXX=${CXX} LD=${LD} GOOS=${OS} GOARCH=${ARCH} $(GOBUILD) --ldflags=${LDFLAGS}  -buildmode=plugin -o $(TARGET)$(PACKAGE).$(ARCH).$(SUFFIX) $(WORKSPACE)/plugin/*.go || exit 0
#打包docker镜像
docker: linux
ifneq ($(wildcard $(WORKSPACE)cmd/Dockerfile),)
	@docker build --platform=linux/$(ARCH) -t $(REGISTRY)/$(PACKAGE):latest-$(ARCH) -f $(TARGET)Dockerfile --build-arg arch=$(ARCH) $(TARGET)
endif
