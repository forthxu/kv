# 基础系统
FROM alpine:3.16

# 外部变量
ARG app=kv
ARG version=0.0.1
ARG usage=http://forthxu.com
ARG arch=amd64
ARG date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# 环境变量
ENV APP=${app}
ENV VERSION=${version}
ENV USAGE=${usage}
ENV ARCH=${arch}
ENV DATE=${date}

# 标签
LABEL maintainer="forthxu <forthxu@gmail.com>"

# 镜像信息
# LABEL org.label-schema.build-date=${date} \
#       org.label-schema.description="service ${app}" \
#       org.label-schema.name=${app} \
#       org.label-schema.schema-version=${version} \
#       org.label-schema.usage=${usage}
# 
# LABEL org.opencontainers.image.source=${usage} \
#       org.opencontainers.image.description="service ${app}" \
#       org.opencontainers.image.licenses=MIT

# 初始化环境
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk add --no-cache tzdata \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && apk del tzdata

# 创建工作目录和创建用户
RUN mkdir -p /app

# 使用工作目录
USER root
WORKDIR /app

# 拷贝程序
COPY ${app}.${arch}.bin .

# 暴露端口
EXPOSE 6378

# 运行程序
ENTRYPOINT ["/bin/sh", "-c", "./${app}.${arch}.bin"]
