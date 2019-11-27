#!/bin/bash
set -eux

# объявляю переменную
export APP_DIR=${HOME}/reddit

# клонируем репку в директорию и инсталим приложение
git clone -b monolith https://github.com/express42/reddit.git $APP_DIR
cd $APP_DIR
bundle install

# переносим файл с переменной в текущую директорию '$APP_DIR/puma.env'
sudo mv /tmp/puma.env $APP_DIR/puma.env

# Вывожу содержимое шаблона,
# заменаю переменные на объявленные через envsubst и заливаю в новоиспеченный юнит системд
cat /tmp/puma.service.tmpl | envsubst | sudo tee /etc/systemd/system/puma.service
# Конструкция выше нагуглена, но не мог не поюзать и взять на вооружение. Далее все банально.
sudo systemctl start puma
sudo systemctl enable puma
