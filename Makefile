include .env
# 変数定義 ------------------------

# SERVER_ID: .env内で定義

# 問題によって変わる変数
BIN_NAME:=isucondition

USER:=isucon


DB_PATH:=/etc/mysql
NGINX_PATH:=/etc/nginx
SYSTEMD_PATH:=/etc/systemd/system

SERVICE_FILE_NAME:=$(BIN_NAME).go.service


# 実際に呼び出すコマンド ------------------------

# サーバーの環境構築　ツールのインストール、gitまわりのセットアップ
.PHONY: setup
setup: install-tools git-setup

# 設定ファイルなどを取得してgit管理下に配置する
.PHONY: get-conf
get-conf: check-server-id get-db-conf get-nginx-conf get-service-file get-envsh

# リポジトリ内の設定ファイルをそれぞれ配置する
.PHONY: deploy-conf
deploy-conf: check-server-id deploy-db-conf deploy-nginx-conf deploy-service-file deploy-envsh


# 主要コマンドの構成要素 ------------------------

.PHONY: install-tools
install-tools:
	sudo apt update
	sudo apt upgrade
	sudo apt install -y percona-toolkit dstat git unzip snapd graphviz tree ssh-keygen

	# alpのインストール
	wget https://github.com/tkuchiki/alp/releases/download/v1.0.9/alp_linux_amd64.zip
    unzip alp_linux_amd64.zip
    sudo install alp /usr/local/bin/alp
    rm alp_linux_amd64.zip alp

.PHONY: git-setup
git-setup:
	# git用の設定は適宜変更して良い
	git config --global user.email "isucon@example.com"
	git config --global user.name "isucon"

	# deploykeyの作成
	ssh-keygen -f ~/.ssh/deploykey -t ed25519

.PHONY: check-server-id
check-server-id:
	ifdef SERVER_ID
		@echo "SERVER_ID=$(SERVER_ID)"
	else
		@echo "SERVER_ID is unset"
		@exit 1
	endif

.PHONY: set-as-s1
set-as-s1:
	echo "SERVER_ID=s1" >> .env

.PHONY: set-as-s2
set-as-s2:
	echo "SERVER_ID=s2" >> .env

.PHONY: set-as-s3
set-as-s3:
	echo "SERVER_ID=s3" >> .env

.PHONY: get-db-conf
get-db-conf:
	sudo cp -R $(DB_PATH)/* ~/$(SERVER_ID)/etc/mysql
	sudo chown $(USER) -R ~/$(SERVER_ID)/etc/mysql
	sudo chgrap $(USER) -R ~/$(SERVER_ID)/etc/mysql

.PHONY: get-nginx-conf
get-nginx-conf:
	sudo cp -R $(NGINX_PATH)/* ~/$(SERVER_ID)/etc/nginx
	sudo chown $(USER) -R ~/$(SERVER_ID)/etc/nginx
	sudo chgrap $(USER) -R ~/$(SERVER_ID)/etc/nginx

.PHONY: get-service-file
get-service-file:
	sudo cp $(SYSTEMD_PATH)/$(SERVICE_FILE_NAME) ~/$(SERVER_ID)/etc/systemd/system/$(SERVICE_FILE_NAME)
	sudo chown $(USER) ~/$(SERVER_ID)/etc/systemd/system/$(SERVICE_FILE_NAME)
	sudo chgrap $(USER) ~/$(SERVER_ID)/etc/systemd/system/$(SERVICE_FILE_NAME)

.PHONY: get-envsh
get-envsh:
	cp ~/env.sh ~/$(SERVER_ID)/home/isucon/env.sh

.PHONY: deploy-db-conf
deploy-db-conf:
	sudo cp -R ~/$(SERVER_ID)/etc/mysql/* $(DB_PATH)

.PHONY: deploy-nginx-conf
deploy-nginx-conf:
	sudo cp -R ~/$(SERVER_ID)/etc/nginx/* $(NGINX_PATH)

.PHONY: deploy-service-file
deploy-service-file:
	cp ~/$(SERVER_ID)/etc/systemd/system/$(SERVICE_FILE_NAME) $(SYSTEMD_PATH)/$(SERVICE_FILE_NAME)

.PHONY: deploy-envsh
deploy-envsh:
	cp ~/$(SERVER_ID)/home/isucon/env.sh ~/env.sh