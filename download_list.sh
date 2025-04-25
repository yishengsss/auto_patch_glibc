#!/bin/bash

LIST_FILE="list"
DL_SCRIPT="./download"

# 检查是否存在 list 文件
if [ ! -f "$LIST_FILE" ]; then
  echo "没有找到 list 文件！"
  exit 1
fi

# 检查 download 脚本是否存在
if [ ! -x "$DL_SCRIPT" ]; then
  echo "没有找到可执行的 download 脚本！"
  exit 1
fi

# 开始下载
echo "开始批量下载 glibc deb 包..."

while read -r line; do
  if [[ -n "$line" ]]; then
    echo "下载：$line"
    $DL_SCRIPT "$line"
  fi
done < "$LIST_FILE"

echo "下载完成！"
