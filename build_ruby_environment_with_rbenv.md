
# UbuntuでRails環境を用意する場合 (in Docker)

## パッケージのアップデート

```
apt update

```


## rbenvのインストールに必要なパッケージのインストール

```
# 以下コマンドを実行
apt install autoconf \
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

```
# おそらく以下のような内容が出力される
# Load rbenv automatically by appending
# the following to ~/.bashrc:

eval "$(rbenv init - bash)"
```


## postgresql依存ライブラリをインストール

```
apt install libpq-dev

```

## RMagick依存ライブラリをインストール

```
# RMagickインストール時に必要?
apt install pkg-config

apt install imagemagick
# => Asia
# => Tokyo
# 上記のように回答する項目がある

# ImageMagickのdevelパッケージ?
# このパッケージをインストールすると MagickCore.pc というファイルがインストールされそう｡
apt install libmagickwand-dev


# sqliteに必要
apt install libsqlite3-dev

```

# Rubyのインストール

## rbenvでインストールできるRubyバージョン一覧を取得する

```
rbenv install --list

# 上記コマンドで以下のような一覧が表示される模様
2.6.9
2.7.5
3.0.3
3.1.0
jruby-9.3.3.0
mruby-3.0.0
rbx-5.0
truffleruby-22.0.0.2
truffleruby+graalvm-22.0.0.2

Only latest stable releases for each Ruby implementation are shown.
Use 'rbenv install --list-all / -L' to show all local versions.

# すべてのバージョンがみたい場合は
rbenv install --list-all

```

## 任意のバージョンのRubyをインストールする

```
rbenv install 3.0.3 # => ここでは3.0.3をインストールしてみる
```

## 任意のディレクトリに移動してRailsをインストールする

```

cd ~

gem install rails

rails new application

cd application

rails s -b 0.0.0.0

# 上記コマンドでrailsサーバーを起動後
# ホスト側OSで http://localhost:3---- (※dockerと連携する任意のポート)
```

上記でDockerでRailsアプリケーションの構築が完了する


