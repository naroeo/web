FROM whyour/qinglong:debian

LABEL maintainer="winijesen"

USER root

# 安装依赖
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    sshpass \
    jq \
    curl \
    wget \
    git \
    openssh-client \
    tzdata \
    procps \
    unzip \
    net-tools \
    iproute2 \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 安装最新版 rclone
RUN curl -fsSL https://rclone.org/install.sh | bash && \
    rclone version && \
    sshpass -V

# 设置时区
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

WORKDIR /ql

VOLUME ["/ql/data"]

# 自定义启动脚本
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod 755 /usr/local/bin/entrypoint.sh

EXPOSE 5700

USER root

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
