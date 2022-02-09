# RockyLinuxにrbenvをインストールする


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
```

## rbenvの初期化コマンドを実行

```
~/.rbenv/bin/rbenv init

```

# コンパイル時依存ツール

## bzip2のインストール

```
dnf install bzip2
```

## Cコンパイラをインストール

```
dnf install gcc
```

## makeコマンドのインストール

```
dnf install make

```

## opensslのインストール

```
dnf install openssl-devel
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
```
