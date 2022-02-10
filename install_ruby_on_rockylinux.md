# RockyLinuxにrbenvをインストールする

# まずコンパイル時依存ツールをインストールする

## パッケージのアップデート

```
dnf update
# epel-releaseのインストール
dnf install epel-release

```

## gitコマンドのインストール

### rockylinuxのdockerコンテナはビルド直後はgitがインストールされていないためインストールをおこなう

```
dnf install git

# ついでにwhichコマンドもインストールする

dnf install which

```

## bzip2のインストール

```
# rubyのビルドに必要なため
dnf install bzip2
```

## Cコンパイラをインストール

```
# こちらもrubyのコンパイルに必要なため
dnf install gcc
```

## makeコマンドのインストール

```
# 同じくmake処理に必要なため
dnf install make

```

## opensslのインストール

```
# ビルドが失敗し､ビルドログに
# `require': cannot load such file -- openssl (LoadError)
# 上記の様なエラーがでていた場合は､以下コマンドを実行

dnf install openssl-devel

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
rbenv init  >> .bash_profile  2>&1

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

