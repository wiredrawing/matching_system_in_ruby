# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...


# UbuntuでRails環境を用意する場合

## パッケージのアップデート

```
sudo apt update

```


## rbenvのインストールに必要なパッケージのインストール

```
# 以下コマンドを実行
sudo apt install autoconf \
bison \
build-essential \
libssl-dev \
libyaml-dev \
libreadline6-dev \
zlib1g-dev \
libncurses5-dev \
libffi-dev \
libgdbm6 \
libgdbm-dev \
libdb-dev

```

## rbenvのリポジトリをクローンしてくる

```
git clone https://github.com/rbenv/rbenv.git ~/.rbenv

```

## ruby-buildツールのリポジトリをクローンしてくる

```
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

```

## rbenvへのPATHを通す

```
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc

```

## rbenvの初期化を実行

```
~/.rbenv/bin/rbenv init

```

## ターミナルに表示された内容を ~/.bashrc に追記する



## postgresql依存ライブラリをインストール

```
sudo apt install libpg-dev

```

## RMagick依存ライブラリをインストール

```
# RMagickインストール時に必要?
sudo apt install pgk-config

sudo apt install imagemagick

# ImageMagickのdevelパッケージ?
# このパッケージをインストールすると MagickCore.pc というファイルがインストールされそう｡
sudo apt install libmagickwand-dev

```


## nodejsをインストール

```
# npmのインストール
sudo apt install nodejs npm
# yarnをnpm経由でインストール
sudo npm install --global yarn

```


## rails secret コマンドを実行

```
rails secret

# 51b350bea...........6c83
# キーが出力される
# config/secrets.ymlを作成して
# production:
#   secret_key_base: ~~
# と上記を追記する
vi config/secrets.yml

```

## フロントエンドをビルド

```
rails assets:precompile RAILS_ENV=production

rails webpacker:install
rails webpacker:compile

```

## production環境での静的ファイルの許可をする

**config/environments/production.rbに下記を追加する**
**config.public_file_server.enabled = true**



## Railsの起動

```
# プロダクション環境での実行コマンド
rails s --binding=0.0.0.0 --environment production

```

