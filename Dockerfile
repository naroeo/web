FROM whyour/qinglong:debian


LABEL maintainer="winijesen"


USER root



# ==================================================
# 安装扩展组件
#
# sshpass
# jq
# curl
# wget
# git
# openssh-client
# 网络工具
# ==================================================

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



# ==================================================
# 安装最新版 rclone
# ==================================================

RUN curl https://rclone.org/install.sh | bash && \
    rclone version && \
    sshpass -V



# ==================================================
# 时区
# ==================================================

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone



# ==================================================
# 工作目录
# ==================================================

WORKDIR /ql



# ==================================================
# 数据目录
# ==================================================

VOLUME ["/ql/data"]



# ==================================================
# 自定义启动入口
# ==================================================

COPY entrypoint.sh /usr/local/bin/entrypoint.sh


RUN chmod 755 /usr/local/bin/entrypoint.sh



# ==================================================
# Blitz 使用青龙端口
# ==================================================

EXPOSE 5700



USER root



ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
