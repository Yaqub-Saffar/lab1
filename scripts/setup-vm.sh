#!/usr/bin/env bash
# 实验一 · openEuler 虚拟机一次性环境准备
# 用法：bash setup-vm.sh [共享文件夹名]     默认共享名 lab1
set -euo pipefail

SHARE_NAME="${1:-lab1}"
echo "== 1/5 安装 VMware 工具与开发依赖 =="
sudo dnf install -y open-vm-tools open-vm-tools-desktop fuse git \
    gcc gcc-c++ make cmake openssl-devel wget curl tar

echo "== 2/5 打开 fuse user_allow_other =="
if ! grep -q '^user_allow_other' /etc/fuse.conf; then
    echo 'user_allow_other' | sudo tee -a /etc/fuse.conf >/dev/null
fi

echo "== 3/5 终端学号水印 PS1（写入 ~/.bashrc，重开终端生效）=="
if ! grep -q 'LAB1_PS1' ~/.bashrc 2>/dev/null; then
    printf "%s\n" "# LAB1_PS1" "PS1='[20241422穆弈涵 \\u@\\h \\W]\\$ '" >> ~/.bashrc
fi

echo "== 4/5 挂载 VMware 共享文件夹 =="
sudo mkdir -p /mnt/hgfs
if ! mountpoint -q /mnt/hgfs; then
    sudo vmhgfs-fuse .host:/ /mnt/hgfs -o allow_other,uid=$(id -u),gid=$(id -g)
fi
if [ -d "/mnt/hgfs/$SHARE_NAME" ] && [ ! -e "$HOME/lab1" ]; then
    ln -s "/mnt/hgfs/$SHARE_NAME" "$HOME/lab1"
fi

echo "== 5/5 版本核对 =="
openssl version
git --version
cmake --version | head -1
gcc --version | head -1
echo "--- 共享目录内容 ---"
ls /mnt/hgfs 2>/dev/null || echo "（看不到共享：先到 VMware 设置里添加共享 '$SHARE_NAME'）"
echo "完成。重开一个终端标签页，PS1 应带学号前缀 [20241422穆弈涵 ...]。"
