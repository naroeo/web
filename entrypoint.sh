#!/bin/bash


echo "🔥 ENTRYPOINT VERSION: 2026-09-27-QINGLONG-2.22.0-BLITZ-V1 🔥"


set -e



export PATH="$HOME/bin:$PATH"



################################################
# 基础变量
################################################

QL_DIR=${QL_DIR:-/ql}

dir_shell="$QL_DIR/shell"



echo "HOME=$HOME"
echo "USER=$(whoami)"




################################################
# 加载青龙环境
################################################


if [ -f "$dir_shell/share.sh" ]; then

    . "$dir_shell/share.sh"

else

    echo "⚠️ share.sh 不存在"

fi




if [ -f "$dir_shell/env.sh" ]; then


    load_ql_envs || true


    export BACK_PORT="${ql_port}"

    export GRPC_PORT="${ql_grpc_port}"



    . "$dir_shell/env.sh"



    import_config "$@" || true


    fix_config || true



fi





################################################
# rclone配置
################################################


echo
echo "====================== rclone 配置 ======================"



if [ -n "$RCLONE_CONF" ]; then


    mkdir -p "$HOME/.config/rclone"


    echo "$RCLONE_CONF" \
    > "$HOME/.config/rclone/rclone.conf"



    chmod 600 "$HOME/.config/rclone/rclone.conf"



    echo "✔ rclone 配置完成"



else


    echo "没有检测到 RCLONE_CONF"



fi





################################################
# 数据恢复
################################################


if [ -n "$RCLONE_CONF" ] && [ -n "$REMOTE_FOLDER" ]; then


echo
echo "====================== rclone 数据恢复 ======================"



DATA_EMPTY=false



if [ ! -d "$QL_DIR/data" ]; then

    DATA_EMPTY=true

else


    COUNT=$(find "$QL_DIR/data" -type f | wc -l)


    if [ "$COUNT" -eq 0 ]; then

        DATA_EMPTY=true

    fi


fi





if [ "$DATA_EMPTY" = true ]; then



    echo "检测到空数据目录，开始恢复"



    mkdir -p "$QL_DIR/data"



    rclone copy \
    "$REMOTE_FOLDER" \
    "$QL_DIR/data" \
    --progress



    echo "✔ 数据恢复完成"



else



    echo "检测到已有数据，跳过恢复"



fi



else


echo "未配置 rclone 恢复"



fi






################################################
# 固定青龙端口
################################################


if [ -f "$QL_DIR/.env" ]; then


    sed -i \
    "s/^PORT=.*/PORT=5700/" \
    "$QL_DIR/.env"



    echo "✔ 青龙端口固定 5700"



fi





################################################
# 启动 PM2
################################################


echo

echo "====================== 启动 QingLong ======================"



reload_pm2





################################################
# 等待青龙
################################################


echo

echo "等待青龙启动..."



for i in {1..40}

do



    if curl -sf \
    http://127.0.0.1:5700/api/health \
    >/dev/null 2>&1

    then


        echo "✔ 青龙启动完成"


        break


    fi



    sleep 2



done






################################################
# 管理员初始化
################################################


sleep 5



if [ -n "$ADMIN_USERNAME" ] && \
   [ -n "$ADMIN_PASSWORD" ]

then



echo

echo "########## 初始化管理员 ##########"



curl -s \
"http://127.0.0.1:5700/api/user/init?t=$(date +%s)" \
-X PUT \
-H "Content-Type: application/json;charset=UTF-8" \
--data \
"{\"username\":\"$ADMIN_USERNAME\",\"password\":\"$ADMIN_PASSWORD\"}" \
| jq



else


echo "未设置管理员变量"



fi






################################################
# 通知
################################################


if [ -n "$NOTIFY_CONFIG" ]; then



echo

echo "########## 启动通知 ##########"



python /notify.py || true



sleep 5



source "$QL_DIR/shell/api.sh"



notify_api \
"青龙服务启动通知" \
"Blitz QingLong 已启动"



else


echo "没有通知配置"



fi





################################################
# 状态检查
################################################


echo

echo "########## 端口检测 ##########"



(ss -tlnp 2>/dev/null || true) \
| grep 5700 || true





echo

echo "================================"

echo "QingLong Blitz 启动完成"

echo "================================"




# 保持容器运行

tail -f /dev/null
