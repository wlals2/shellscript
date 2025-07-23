#!/bin/bash

src="/home/ubuntu"
dest="/home/ubuntu/backup"
mkdir -p $dest
cp -a $src/Documents $dest/
cp -a $src/Pictures $dest/
echo "백업 완료: $dest"


