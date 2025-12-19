FROM ruby:3.3.5

RUN apt-get update -qq && \
    apt-get install -y build-essential default-mysql-client vim

WORKDIR /rails

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

# MySQL クライアント設定: SSL検証を無効化 (MariaDB クライアント用)
# 環境変数を使用するため、実行時に設定ファイルを生成
# パスワードはdatabase.ymlから渡されるため、.my.cnfには含めない
RUN echo '#!/bin/bash\n\
cat > /root/.my.cnf <<EOF\n\
[client]\n\
ssl=0\n\
EOF\n\
exec "$@"' > /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["rails", "server", "-b", "0.0.0.0"]