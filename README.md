# auto_patch_glibc

------

## 项目简介：

本项目旨在，更加便捷的使用glibc-all-in-one(https://github.com/matrix1001/glibc-all-in-one)对赛题进行patch，目前只支持amd64、i386程序的自动化patch

------

## 使用方法：

在赛题目录输入需要patch的libc版本如：

```bash
❯ ls
glibcpatch.sh  libc-2.23.so  ret2libc3
❯ ./glibcpatch.sh 2.23
🔍 检测到多个 ELF 文件，请选择：
1) libc-2.23.so
2) ret2libc3
#? 2
使用并重命名 libc-*.so → libc.so.6
🔍 使用本地 glibc 补全缺失项...
✅ 补全 ld.so
✅ [ret2libc3] patch 成功！已使用 glibc: 2.23，架构: i386
```

### 有三种情况：

1. 题目给了libc文件没给ld文件，则从glibc-all-in-one中获取ld文件
2. 题目给了libc文件和ld文件，则直接使用题目的文件
3. 题目只给了一个ELF文件，则从glibc-all-in-one中获取所有的

------

## 注意：

### 本项目依赖glibc-all-in-one请确定其部署完毕：

​	确定执行了下载脚本，将libc文件下载到glibc-all-in-one目录下的libs中

​	glib-all-in-one使用方法：https://github.com/matrix1001/glibc-all-in-one

------

## 部署方法：

### 部署glibc-all-in-one:

```shell
#从github上拉取glibc-all-in-one
git clone https://github.com/matrix1001/glibc-all-in-one.git
cd glibc-all-in-one
#更新libc列表
python3 ./update_list
#拉取本项目：
git clone https://github.com/yishengsss/auto_patch_glibc.git
#复制到对应目录
cp ./auto_patch_glibc/download_list.sh ./
#赋予执行权限
chmod 755 ./download_list.sh
bash ./download_list.sh
```

### 使用glibcpatch:

```bash
#进入到本项目文件夹给予权限：
cd auto_patch_glibc/
chmod 755 ./glibcpatch
#编辑脚本头部的BASE_DIR为你自己的安装位置：
vim ./glibcpatch
# ==================== vim ========================
#!/bin/bash
VERSION_INPUT="$1"

BASE_DIR="目录路径"

LIBS_DIR="$BASE_DIR/libs"
if [[ -z "$VERSION_INPUT" ]]; then
  echo "用法: glibcpatch <glibc版本号>，如 glibcpatch 2.23"
  exit 1
fi
# ==================== vim ========================
#记得输入:wq退出

#让glibcpatch全局使用：
cp ./glibcpatch.sh /usr/local/bin/
#部署完毕了，愉快地使用吧
```

------

## 使用示范：

![image-20250425113220300](/Users/keason/Library/Application Support/typora-user-images/image-20250425113220300.png)

![image-20250425113257697](/Users/keason/Library/Application Support/typora-user-images/image-20250425113257697.png)

![image-20250425113341905](/Users/keason/Library/Application Support/typora-user-images/image-20250425113341905.png)

