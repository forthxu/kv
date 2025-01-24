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
#编译目标
ACTION=$(MAKECMDGOALS)
#系统
OS?=$(shell uname|tr A-Z a-z)
ifeq ($(ACTION), mac)
	OS=darwin
else ifeq ($(ACTION), darwin)
	OS=darwin
else ifeq ($(ACTION), dylib)
	OS=darwin
else ifeq ($(ACTION), docker)
	OS=linux
else ifeq ($(ACTION), linux)
	OS=linux
else ifeq ($(ACTION), so)
	OS=linux
else ifeq ($(ACTION), windows)
	OS=windows
endif
#架构
ARCH?=$(shell uname -m | tr A-Z a-z | sed 's/x86_64/amd64/')
ifeq ($(ARCH), arm64)
	ARCH=arm64
else
	ARCH=amd64
endif
#执行后缀
ifeq ($(OS), darwin)
	SUFFIX=appx
	DYNAMIC=dylib
else ifeq ($(OS), linux)
	SUFFIX=bin
	DYNAMIC=so
else ifeq ($(OS), windows)
	SUFFIX=exe
	DYNAMIC=dll
endif
#docker仓库
REGISTRY=forthxu

#忽略目录
.PHONY: $(PACKAGE)

#默认
default: $(OS)
	@[ -f "$(WORKSPACE)cmd/main.go" ] && $(TARGET)$(PACKAGE).$(ARCH).$(SUFFIX) || exit 0

#帮助
help:
	@echo "make $(OS) ARCH=$(ARCH) TARGET=./build"
#显示系统
system:
	@echo "目标: $(ACTION)"
	@echo "目标系统架构: $(OS)-$(ARCH)"
	@echo "目标后缀：程序.$(SUFFIX) 动态库.$(DYNAMIC)"
#拷贝资源
resource:
	@mkdir -p $(TARGET)
	@[ -d "$(WORKSPACE)cmd" ] && find $(WORKSPACE)cmd/* -maxdepth 0 -not -regex '.*\.go$$'  -not -regex '.*\.sh$$' |xargs -I {} cp -r {} $(TARGET)/ || exit 0
#生成protobuf
protobuf:
	@[ -d "$(WORKSPACE)proto" ] && find $(WORKSPACE) -maxdepth 1 -type d -name  proto |xargs -I {} find {} -depth 1 | xargs -I {} protoc {} -I $(WORKSPACE) --go_out=$(WORKSPACE) --go-grpc_out=$(WORKSPACE) --experimental_allow_proto3_optional || exit 0
	@[ -d "$(WORKSPACE)proto" ] && find $(WORKSPACE) -regex ".*.pb.go" -print | xargs sed -i "" -e "s/,omitempty//g" || exit 0

#编译程序
mac: darwin
darwin: program
linux: program
windows: program 
program: system resource protobuf
	@[ -f "$(WORKSPACE)cmd/main.go" ] && GOOS=${OS} GOARCH=${ARCH} $(GOBUILD) --ldflags=${LDFLAGS} -o $(TARGET)$(PACKAGE).$(ARCH).${SUFFIX} $(WORKSPACE)cmd/main.go || exit 0
#编译动态库
dylib: dynamic
so: dynamic
dll: dynamic
dynamic: system protobuf
	@[ -d "$(WORKSPACE)plugin" ] && GOOS=${OS} GOARCH=${ARCH} $(GOBUILD) --ldflags=${LDFLAGS}  -buildmode=plugin -o $(TARGET)$(PACKAGE).$(ARCH).$(DYNAMIC) $(WORKSPACE)/plugin/*.go || exit 0
#打包docker镜像
docker: dynamic linux
ifneq ($(wildcard $(WORKSPACE)cmd/Dockerfile),)
	@cp $(TARGET)$(PACKAGE).$(ARCH).${SUFFIX} $(TARGET)$(PACKAGE).${SUFFIX}
	docker build -t $(REGISTRY)/$(PACKAGE):latest-$(ARCH) -f $(TARGET)Dockerfile --build-arg ARCH=$(ARCH) $(TARGET)
	@rm $(TARGET)$(PACKAGE).${SUFFIX}
endif
