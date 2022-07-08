include .env
# SERVER_ID: .env内で定義

# 変数定義

# 実際に呼び出すコマンド
.PHONY: setup
setup: install-tools git-setup


# ------------------------
# 主要コマンドの構成要素

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
