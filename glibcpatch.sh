#!/bin/bash

# ====== glibcpatch ======
VERSION_INPUT="$1"
BASE_DIR="/root/PWN/tools/glibc-all-in-one"
LIBS_DIR="$BASE_DIR/libs"

if [[ -z "$VERSION_INPUT" ]]; then
  echo "用法: glibcpatch <glibc版本号>，如 glibcpatch 2.23"
  exit 1
fi

# 识别 ELF 文件
ELF_CANDIDATES=($(file * 2>/dev/null | grep ELF | cut -d: -f1))
if [ ${#ELF_CANDIDATES[@]} -eq 0 ]; then
  echo "❌ 当前目录无 ELF 文件"
  exit 1
elif [ ${#ELF_CANDIDATES[@]} -eq 1 ]; then
  ELF="${ELF_CANDIDATES[0]}"
else
  echo "🔍 检测到多个 ELF 文件，请选择："
  select f in "${ELF_CANDIDATES[@]}"; do
    if [[ -n "$f" ]]; then ELF="$f"; break; fi
  done
fi

# 判断 ELF 架构
ARCH=$(file "$ELF" | grep -o 'ELF 32-bit\|ELF 64-bit')
if [[ "$ARCH" == "ELF 32-bit" ]]; then
  ARCH_SUFFIX="i386"
  LD_NAME="ld-linux.so.2"
elif [[ "$ARCH" == "ELF 64-bit" ]]; then
  ARCH_SUFFIX="amd64"
  LD_NAME="ld-linux-x86-64.so.2"
else
  echo "❌ 无法识别 ELF 架构"
  exit 1
fi

# 优先处理当前目录提供的 glibc 文件
FOUND_LIBC=0
FOUND_LD=0

# libc.so.6 或 libc-*.so
if [[ -f "./libc.so.6" ]]; then
  echo "使用已有 libc.so.6"
  FOUND_LIBC=1
elif ls libc-*.so 1>/dev/null 2>&1; then
  cp $(ls libc-*.so | head -n1) ./libc.so.6
  echo "使用并重命名 libc-*.so → libc.so.6"
  FOUND_LIBC=1
fi

# ld.so 或 ld-*.so
if [[ -f "./ld.so" ]]; then
  echo "使用已有 ld.so"
  FOUND_LD=1
elif ls ld-*.so 1>/dev/null 2>&1; then
  cp $(ls ld-*.so | head -n1) ./ld.so
  echo "使用并重命名 ld-*.so → ld.so"
  FOUND_LD=1
fi

# ====== 如果缺失则从本地 glibc-all-in-one 提取补全 ======
if [[ $FOUND_LIBC -eq 0 || $FOUND_LD -eq 0 ]]; then
  echo "🔍 使用本地 glibc 补全缺失项..."
  MATCHED=$(find "$LIBS_DIR" -maxdepth 1 -type d -name "${VERSION_INPUT}*${ARCH_SUFFIX}" | sort | head -n1)
  if [[ -z "$MATCHED" ]]; then
    echo "❌ 未找到本地 glibc 目录: $VERSION_INPUT*${ARCH_SUFFIX}"
    exit 1
  fi
  [[ $FOUND_LIBC -eq 0 ]] && cp "$MATCHED/libc.so.6" ./libc.so.6 && echo "✅ 补全 libc.so.6"
  [[ $FOUND_LD -eq 0 ]] && cp "$MATCHED/$LD_NAME" ./ld.so && echo "✅ 补全 ld.so"
fi

# ====== patch ELF ======
patchelf --set-interpreter ./ld.so "$ELF"
patchelf --set-rpath . "$ELF"

echo "✅ [$ELF] patch 成功！已使用 glibc: $VERSION_INPUT，架构: $ARCH_SUFFIX"
