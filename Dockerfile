FROM almalinux


# Rubyビルドに必要なライブラリ
RUN dnf install -y epel-release && \
dnf -y update && \
dnf install -y git which bzip2 gcc-c++ openssl-devel sqlite sqlite-devel && \
dnf install -y postgresql-devel && \
dnf install -y dnf-plugins-core && \
dnf config-manager --set-enabled powertools && \
dnf repolist | grep powertools && \
dnf install -y ImageMagick ImageMagick-devel
RUN dnf install -y make


WORKDIR /root
# rbenvのインストール
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv && \
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build && \
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc

RUN echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
#RUN rbenv init
#RUN source .bashrc
#RUN rbenv init  >> ~/.bash_profile  2>&1
RUN echo 'eval "$(rbenv init - bash)"' >> ~/.bash_profile
RUN echo '---------------------'
ENV PATH /root/.rbenv/shims:/root/.rbenv/bin:$PATH
RUN echo $PATH
RUN echo '---------------------'
#RUN source .bash_profile
#RUN which git
#RUN which make
RUN which rbenv
# rbenvのインストール完了をチェック
#RUN rbenv install --list
#RUN rbenv instlal --list-all

# 任意のバージョンのRubyをインストール
RUN ~/.rbenv/bin/rbenv install 2.7.1
RUN ~/.rbenv/bin/rbenv global 2.7.1

# gemを使ってRailsをインストール
RUN gem install rails

# bashを実行
CMD ["/bin/bash"]

