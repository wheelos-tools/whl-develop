#!/bin/bash
set -euo pipefail

# 检查参数：用户名和密码
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <new_username> <password>"
    exit 1
fi

NEW_USER="$1"
PASSWORD="$2"

# 检查用户是否已存在
if id "$NEW_USER" &>/dev/null; then
    echo "Error: User '$NEW_USER' already exists!"
    exit 1
fi

# 创建用户并自动生成 home 目录和 bash 作为默认 shell
sudo useradd -m -s /bin/bash "$NEW_USER"

# 设置用户密码（非交互式）
echo "$NEW_USER:$PASSWORD" | sudo chpasswd

# 获取当前用户目录（假设当前用户有环境配置文件）
CURRENT_HOME="/home/$(whoami)"

# 定义需要复制的配置文件
for file in .bashrc .profile; do
    if [ -f "$CURRENT_HOME/$file" ]; then
        sudo cp "$CURRENT_HOME/$file" "/home/$NEW_USER/"
    fi
done

# 修改新用户的 home 目录的所有者
sudo chown -R "$NEW_USER:$NEW_USER" "/home/$NEW_USER"

# 将用户添加到 sudo 组，以便拥有管理员权限
sudo usermod -aG sudo "$NEW_USER"

echo "User '$NEW_USER' created, password set, added to sudo group, and environment configured."

