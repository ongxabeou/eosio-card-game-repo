#!/usr/bin/env bash

# change to script's directory
cd "$(dirname "$0")/eosio_docker"
# thư mục [PROJECT]/eosio_docker/data/initialized để đánh giấu Bockchain đã được cài đặt
if [ -e "data/initialized" ]
then
  # nếu đã được cài đặt thì chỉ bât/chạy lại hệ thông bockchain nodeos
  script="./scripts/continue_blockchain.sh"
else
  # nếu chưa được cài đặt thì thực hiện cài đặt mới blockchain nodeos bao gồm:
  # 1. bật nodeos
  # 2. tạo ví mới trên keosd(nodeos)
  # 3. tạo tài khoản cho hợp đồng thông minh thuộc keosd(nodeos)
  # 4. triển khai hợp đồng thông minh lên Eos.cdt
  # 5. tạo các tài khoản người dùng keosd(nodeos)
  script="./scripts/init_blockchain.sh"
fi
# cài đặt docker contrainer từ image đã được cài đặt từ first_time_settup và thực hiện một số cấu hình:
# 1. remote container cũ nếu có vào tạo một container mới.
# 2. mở các cổng dịch vụ tương ứng: 8888 là của Nodeos; 9876 là của Eos.cdt
# 3. chuyển các thư mục source code vào các chư mục hệ thống của docker
# 4. chạy kịch bản đã chuẩn bị ở bước trên
echo "=== run docker container from the eosio-cardgame:eos2.0.5-cdt1.6.3 image ==="
docker run --rm --name eosio_cardgame_container -d \
-p 8888:8888 -p 9876:9876 \
--mount type=bind,src="$(pwd)"/../contracts,dst=/opt/eosio/bin/contracts \
--mount type=bind,src="$(pwd)"/scripts,dst=/opt/eosio/bin/scripts \
--mount type=bind,src="$(pwd)"/data,dst=/mnt/dev/data \
-w "/opt/eosio/bin/" eosio-cardgame:eos2.0.5-cdt1.6.3 /bin/bash -c "$script"

# nếu không có tham số nolog thì bật chức năng ghi log cho docker
if [ "$1" != "--nolog" ]
then
  echo "=== follow eosio_cardgame_container logs ==="
  docker logs eosio_cardgame_container --follow
fi
