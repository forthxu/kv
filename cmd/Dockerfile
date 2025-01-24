FROM alpine:latest
LABEL maintainer="forthxu <forthxu@gmail.com>"

# 外部变量
ARG ARCH
ARG BUILD_DATE

# 环境变量
ENV APP=kv
ENV VERSION=0.0.1
ENV USAGE=http://forthxu.com

# 镜像信息
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.description="service ${APP}" \
      org.label-schema.name="${APP}" \
      org.label-schema.schema-version="${VERSION}" \
      org.label-schema.usage="${USAGE}"

# 设置架构变量，优先使用外部传入值
RUN DETECTED_ARCH=$(uname -m | tr 'A-Z' 'a-z' | sed 's/x86_64/amd64/') && \
    FINAL_ARCH=${ARCH:-$DETECTED_ARCH} && \
    echo "FINAL_ARCH=$FINAL_ARCH" >> /etc/environment

# 加载环境变量
RUN source /etc/environment && echo "Using architecture: $FINAL_ARCH"

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
COPY ${APP}.${FINAL_ARCH}.bin .

# 暴露端口
EXPOSE 6378

# 运行程序
ENTRYPOINT ["/bin/sh", "-c", "./${APP}.${FINAL_ARCH}.bin"]
