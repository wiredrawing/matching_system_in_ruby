# RockyLinuxにrbenvをインストールする

# まずコンパイル時依存ツールをインストールする

## パッケージのアップデート

**epel-releaseのインストール**

```
dnf install -y epel-release && dnf update -y

```

## Rubyのビルドに必要なパッケージをインストール


```
dnf install -y git \
which \
bzip2 \
gcc-c++ \
make \
openssl-devel \
sqlite sqlite-devel

```
## Gem pgをインストールするためpostgresqlの開発用パッケージをインストール

**Postgresqlへの接続に必要なため**

```
dnf install -y postgresql-devel

```

## Rmagick用依存ライブラリのインストール

```
dnf install ImageMagick ImageMagick-devel

# どうもRMagickをインストールするためにはPowerToolsが必要らしい...
# https://ja.linuxcapable.com/enable-powertools-repository-on-rocky-linux-8/

```


## PowerToolsのインストール

> 必要な依存関係をインストールする
> PowerToolsリポジトリを正常に有効にするには、次の依存関係が必要です。
> これはデフォルトですでにインストールされているはずですが、
> コマンドを実行して確認してください。

```
dnf install -y dnf-plugins-core
# 上記をインストールすることで
# dnf config-manager というコマンドを実行できるようになる


＃ 上記コマンド実行後､以下コマンドを実行する
dnf config-manager --set-enabled powertools

＃ 続いて､powertoolsが有効なことを確認する
dnf repolist | grep powertools

# [root@387a48353afb ~]# dnf repolist | grep powertools
# powertools         Rocky Linux 8 - PowerTools
# リポジトリが有効になっていることを確認

＃ 以上を実行した上で､再度 ImageMagickの開発用パッケージをインストールする
dnf install -y ImageMagick ImageMagick-devel

```

## PowerTools リポジトリを設定してインストール

**参考例**
**https://tech-blog.s-yoshiki.com/entry/206**

```
cd /etc/yum.repos.d/

cat Rocky-PowerTools.repo

# # Rocky-PowerTools.repo
# #
# # The mirrorlist system uses the connecting IP address of the client and the
# # update status of each mirror to pick current mirrors that are geographically
# # close to the client.  You should use this for Rocky updates unless you are
# # manually picking other mirrors.
# #
# # If the mirrorlist does not work for you, you can try the commented out
# # baseurl line instead.
#
# [powertools]
# name=Rocky Linux $releasever - PowerTools
# mirrorlist=https://mirrors.rockylinux.org/mirrorlist?arch=$basearch&repo=PowerTools-$releasever
# #baseurl=http://dl.rockylinux.org/$contentdir/$releasever/PowerTools/$basearch/os/
# gpgcheck=1
# enabled=0
# gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial

# 上記のような内容が記載されているため､
# enabled=0 => enabled=1
# と修正する

dnf install epel-release

dnf update

# 上の通りコマンドを実行する
# 以上で,ImageMagick-develがインストールできるようになる

```


# rbenv関係

## rbenvのリポジトリをクローン

```
git clone https://github.com/rbenv/rbenv.git ~/.rbenv

```

## ruby-buildツールのリポジトリをクローンする

```
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

```

## インストールしたrbenvにパスを通す

```
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc

# ~/.bashrcの変更を反映させる
source ~/.bashrc

```

## rbenvの初期化コマンドを実行

```
~/.rbenv/bin/rbenv init

# Load rbenv automatically by appending
# the following to ~/.bash_profile:

eval "$(rbenv init - bash)"

```
上記のような出力内容が表示される｡
メッセージの通り .bash_profileに追記する｡

```
rbenv init  >> ~/.bash_profile  2>&1

source ~/.bash_profile
# 上記コマンドで rbenv init の実行結果が追記される

```

## rbenvでインストール可能なRubyのバージョンを確認

```
rbenv install --list

# 上記コマンドでインストール可能なRubyバージョンが
# 出力される

rbenv install --list-all

# 上記コマンドでより細かいバージョン一覧を出力できる
```
## Rubyのインストール
```
rbenv install 2.7.5

# [root@db0bfd4632c7 ~]# rbenv install 2.7.5
# Downloading ruby-2.7.5.tar.bz2...
# -> https://cache.ruby-lang.org/pub/ruby/2.7/ruby-2.7.5.tar.bz2
# Installing ruby-2.7.5...
# Installed ruby-2.7.5 to /root/.rbenv/versions/2.7.5

# 上記の様にエラーがなければrubyインストールの完了


# グローバルに使用するRubyバージョンに決定する
rbenv global 2.7.5

```

# 次にRailsのインストールを行う

```
gem install rails

# 上記コマンドでrails自体はすんなりインストールできる

rails new something-application

# だた上記コマンドでアプリケーションの作成を試みると

An error occurred while installing sqlite3 (1.4.2), and Bundler cannot continue.
Make sure that `gem install sqlite3 -v '1.4.2' --source 'https://rubygems.org/'` succeeds before bundling.

In Gemfile:
  sqlite3
         run  bundle binstubs bundler
Could not find gem 'sqlite3 (~> 1.4)' in any of the gem sources listed in your Gemfile.
       rails  importmap:install
Could not find gem 'sqlite3 (~> 1.4)' in any of the gem sources listed in your Gemfile.
Run `bundle install` to install missing gems.
       rails  turbo:install stimulus:install
Could not find gem 'sqlite3 (~> 1.4)' in any of the gem sources listed in your Gemfile.
Run `bundle install` to install missing gems.

上記のようなエラーが生じる
```

以下コマンドでエラーを解消させる

```
dnf install sqlite sqlite-devel

```

sqlite3関連のインストールが終わったら
再度､以下コマンドでrailsをインストールする

```
rails new something-app

# 問題なくアプリ生成が完了したら

rails s -b 0.0.0.0

# 上記コマンドでrailsを起動させる

```

