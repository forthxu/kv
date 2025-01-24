FROM alpine:latest
LABEL maintainer="forthxu <forthxu@gmail.com>"

# 环境变量
ENV APP=kv
ENV VERSION=0.0.1
ENV USAGE=http://forthxu.com

# 镜像信息
ARG BUILD_DATE
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.description="service ${APP}" \
      org.label-schema.name="${APP}" \
      org.label-schema.schema-version="${VERSION}" \
      org.label-schema.usage="${USAGE}"


# 初始化环境
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk add --no-cache tzdata \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && apk del tzdata
    
# 创建工作目录和创建用户
RUN mkdir -p /usr/local/app

# 使用工作目录
USER root
WORKDIR /app

# 拷贝程序
COPY ${APP}.bin .

# 暴露端口
EXPOSE 6378

# 运行程序
ENTRYPOINT ["/bin/sh", "-c", "./${APP}.bin"]