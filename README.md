# sgremyachikh_microservices
sgremyachikh microservices repository

-----------------------------
# HW: Docker контейнеры. Docker под капотом.
Технология контейнеризации. Введение в Docker.

## Прежде всего:
```
git chechout -b docker-2
wget https://bit.ly/otus-travis-yaml-2019-05 -O .travis.yml
travis encrypt "devops-team-otus:TOCKEN_OF_PLUGIN" --add notifications.slack
mkdir .github && cd .github
wget http://bit.ly/otus-pr-template -O PULL_REQUEST_TEMPLATE.md
```
В слаке на канале интеграций:
```
/github subscribe Otus-DevOps-2019-08/sgremyachikh_microservices commits:all
```

## Ставлю докер/композ/машин по гайдам с https://docs.docker.com/:
```
sudo dnf remove -y docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine
sudo dnf -y install dnf-plugins-core

sudo dnf config-manager \
    --add-repo \
    https://download.docker.com/linux/fedora/docker-ce.repo

sudo dnf install docker-ce docker-ce-cli containerd.io docker-compose

sudo systemctl start docker
sudo systemctl enable docker

sudo usermod -aG docker your_user # чтоб без судо жить с докером

base=https://github.com/docker/machine/releases/download/v0.16.0 &&
  curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine &&
  sudo mv /tmp/docker-machine /usr/local/bin/docker-machine &&
  chmod +x /usr/local/bin/docker-machine
```
## Для новых редхатов:
current version of RH switched to using cgroupsV2 by default, which is not yet supported by the container runtimes (and kubernetes); work is in progress on this, but not yet complete, and not yet production ready. To disable v2 cgroups, run:
open /etc/default/grub as admin
Append value of GRUB_CMDLINE_LINUX with systemd.unified_cgroup_hierarchy=0
sudo grub2-mkconfig > /boot/efi/EFI/fedora/grub.cfg or
sudo grub2-mkconfig > /boot/grub2/grub.cfg
reboot

Директория docker-monolith

Запустил 
```
docker run hello-world 
```

Список всех запущенных контейнеров
```
docker ps
```

Список всех контейнеров
```
docker ps -a
```

Список сохраненных образов
```
docker images
```

Если не указывать флаг --rm при запуске docker run, то после остановки контейнер вместе с содержимым остается на диске

start запускает остановленный(уже созданный) контейнер
attach подсоединяет терминал к созданному контейнеру
```
> docker start <u_container_id>
> docker attach <u_container_id>
```
## Docker run vs start

docker run = docker create + docker start + docker attach при наличии опции -i, -d – запускает контейнер в background режиме, -t создает TTY

docker create используется, когда не нужно стартовать контейнер сразу

## Docker exec

Запускает новый процесс внутри контейнера
Пример:
```
>docker exec -it <u_container_id> bash
root@<u_container_id>:/#
ps axf
 PID TTY STAT TIME COMMAND
 12 ? Ss 0:00 bash
 22 ? R+ 0:00 \_ ps axf
 1 ? Ss+ 0:00 /bin/bash
root@<u_container_id>:/# exit
```

## Docker commit

Создает image из контейнера, контейнер при этом остается запущенным
```
> docker commit <u_container_id> yourname/ubuntu-tmp-file
sha256:c9b7e0f6b390a8c964bc4af7736e7f1015f4ce8da8648d95d1b88917742c8773
> docker images
REPOSITORY TAG IMAGE ID CREATED SIZE
yourname/ubuntu-tmp-file latest c9b7e0f6b390 3 seconds ago 
```

Создан файл docker-1.log путем:
```
docker images > docker-1.log
```

## Задание со *

```
REPOSITORY           TAG                 IMAGE ID            CREATED             SIZE
sgremyachikh/nginx   latest              7edbbd60bf27        57 seconds ago      126MB
ubuntu               16.04               5f2bf26e3524        3 days ago          123MB
nginx                latest              540a289bab6c        12 days ago         126MB
hello-world          latest              fce289e99eb9        10 months ago       1.84kB

Сравните вывод двух следующих команд
>docker inspect <u_container_id>
>docker inspect <u_image_id>
Контейнер представляет собой среду созданную на основе образа. Образ это совокупность слоев абстракций, об ъединенных воедино + метаданные. 
Чтобы создать контейнер, докер берет образ, добавляет доступный для записи верхний слой и инициализирует различные 
параметры (сетевые порты, имя контейнера, идентификатор и лимиты ресурсов).
```

## Docker kill:
```
docker ps -q - коротко посмотреть списк запущенных контейнеров
docker kill $(docker ps -q) - убить все запущенные
```

## docker system df

 - Отображает сколько дискового пространства
занято образами, контейнерами и volume’ами
 - Отображает сколько из них не используется и
возможно удалить
```
docker system df
TYPE                TOTAL               ACTIVE              SIZE                RECLAIMABLE
Images              4                   3                   248.8MB             126.2MB (50%)
Containers          6                   0                   7B                  7B (100%)
Local Volumes       0                   0                   0B                  0B
Build Cache         0                   0                   0B                  0B

```
## Docker rm & rmi

 - rm удаляет контейнер, можно добавить флаг -f,
чтобы удалялся работающий container(будет
послан sigkill)
 - rmi удаляет image, если от него не зависят
запущенные контейнеры
```
docker rm $(docker ps -a -q) # удалит все незапущенные контейнеры
docker rmi $(docker images -q) # удалит все загруженные образы
```
## Docker-контейнеры. GCE.

Создал новый проект в GCE docker-258020

GCloud SDK уже установлен. но вообще устанавливается вот так:
https://cloud.google.com/sdk/install
А для меня вот так:
https://cloud.google.com/sdk/docs/downloads-yum
```
sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-sdk]
name=Google Cloud SDK
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM
```
```
yum install google-cloud-sdk
```
```
gcloud init
```
Сменил конфигурацию на новый проект GCE.

## Docker machine
```
export GOOGLE_PROJECT=docker-258020
```
```
docker-machine create --driver google \
 --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
 --google-machine-type n1-standard-1 \
 --google-zone europe-west1-b \
 docker-host
```
Проверяю, докер хост создан:
```
 sgremyachikh@Thinkpad  ~/OTUS/sgremyachikh_microservices   docker-2 ●  docker-machine ls
NAME          ACTIVE   DRIVER   STATE     URL                        SWARM   DOCKER     ERRORS
docker-host   -        google   Running   tcp://35.195.52.110:2376           v19.03.4
```
Переключаю докер-машин на данное окружение:
```
eval $(docker-machine env docker-host)
```

## Повторение практики из демо на лекции

Для реализации Docker-in-Docker можно использовать https://github.com/jpetazzo/dind
Дока по user namespace: https://docs.docker.com/engine/security/userns-remap/

Сравнение вывода команд:
```
docker run --rm -ti tehbilly/htop
docker run --rm --pid host -ti tehbilly/htop
```
во втором случае докер-контейнер имеет доступ к процессам хоста
во втором случае по процессам вижу, что докер запустился на виртуалке в гугле

## Структура репозитория

db_config  docker-1.log  Dockerfile  mongod.conf  start.sh

заполнили все файлы гистами, запустили билд докер-образа:
```
docker build -t reddit:latest .
```
Точка в конце обязательна, она указывает на путь
до Docker-контекста
Флаг -t задает тег для собранного образа

Запуск этого контейнера:
```
docker run --name reddit -d --network=host reddit:latest
```
Правило фаера для 9292:
```
gcloud compute firewall-rules create reddit-app \
 --allow tcp:9292 \
 --target-tags=docker-machine \
 --description="Allow PUMA connections" \
 --direction=INGRESS
```
Запушил на докерхаб:
```
docker tag reddit:latest decapapreta/otus-reddit:1.0
```
Запуск локально происходит при выполнении
```
docker run --name reddit -d -p 9292:9292 decapapreta/otus-reddit:1.0
```
### Проверки:

docker logs reddit -f - посмотреть логи контейнера

docker exec -it reddit bash - запустить баш в контейнере

ps aux - глянем что внутри в процессах

killall5 1 - убьем процесс с пидом 1

docker start reddit - создадим контейнер из образа

docker stop reddit && docker rm reddit - остановим и удалим контейнер. не удаляя образа

docker run --name reddit --rm -it decapapreta/otus-reddit:1.0 bash - запустить контейнер без запуска приложения + прицепимся туда TTY

ps aux - убедимся, что ничто не заработало

exit - выйдем

docker inspect decapapreta/otus-reddit:1.0 - смотрю сведения об образе

docker inspect decapapreta/otus-reddit:1.0 -f '{{.ContainerConfig.Cmd}}' - смотрю какой процесс в CMD, который основной: [/bin/sh -c #(nop)  CMD ["/start.sh"]]

docker image history image_name - смотрю историю сборки образа

docker run --name reddit -d -p 9292:9292 decapapreta/otus-reddit:1.0 - запуск на локалхосте с биндом порта приложения на 9292 локалхоста

docker exec -it reddit bash - зайти консольно в запущенный контейнер

mkdir /test1234 - создадим директорию

touch /test1234/testfile - создадим файл

rmdir /opt удалим опт

exit

docker diff reddit - покажет все изменения к контейнере относительно исходника:
```
C /root
A /root/.bash_history
C /var
C /var/log
A /var/log/mongod.log
C /var/lib
C /var/lib/mongodb
A /var/lib/mongodb/_tmp
A /var/lib/mongodb/journal
A /var/lib/mongodb/journal/j._0
A /var/lib/mongodb/journal/prealloc.1
A /var/lib/mongodb/journal/prealloc.2
A /var/lib/mongodb/local.0
A /var/lib/mongodb/local.ns
A /var/lib/mongodb/mongod.lock
A /test1234
A /test1234/testfile
C /tmp
A /tmp/mongodb-27017.sock
D /opt
```
Видимо А-изменено, С-создано, D-удалено.

docker stop reddit && docker rm reddit остановим и удалим контейнер

docker run --name reddit --rm -it decapapreta/otus-reddit:1.0 bash -запустим заново без приложения

ls / - убедимся, что все чисто и следов от предыдущих действий нет

## За собой прибираемся в GCE:
из той консоли, где у нас был запил docker-machine:
```
docker-machine rm docker-host -f
eval $(docker-machine env --unset)
```
## Второе задание со звездочной * отложил, но с функционалом поигрался:)

______________________
# HW: Docker образы. Микросервисы.
```
git checkout -b docker-3
```
В качестве линтера использую плагин к VSCode

Для игр с докером разверну вновь докер-машину.
```
export GOOGLE_PROJECT=docker-258020
```
```
docker-machine create --driver google \
 --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
 --google-machine-type n1-standard-1 \
 --google-zone europe-west1-b \
 docker-host
```
Переключаю докер-машин на данное окружение:
```
eval $(docker-machine env docker-host)
```
Проверяю, докер хост создан:
```
docker-machine ls
NAME          ACTIVE   DRIVER   STATE     URL                         SWARM   DOCKER     ERRORS
docker-host   *        google   Running   tcp://104.155.127.31:2376           v19.03.4   

```
## Скачал, распаковал и переименовал репозиторий в src

В файлах Dockerfile содержатся инструкции по созданию образа. С них, набранных заглавными буквами, начинаются строки этого файла. После инструкций идут их аргументы. Инструкции, при сборке образа, обрабатываются сверху вниз.
Слои в итоговом образе создают только инструкции FROM, RUN, COPY, и ADD.

- FROM — задаёт базовый (родительский) образ.

- LABEL — описывает метаданные. Например — сведения о том, кто создал и поддерживает образ.

- ENV — устанавливает постоянные переменные среды.

- RUN — выполняет команду и создаёт слой образа. Используется для установки в контейнер пакетов.

- COPY — копирует в контейнер файлы и папки.

- ADD — копирует файлы и папки в контейнер, может распаковывать локальные .tar-файлы, можно использовать для curl.

- CMD — описывает команду с аргументами, которую нужно выполнить когда контейнер будет запущен. Аргументы могут быть переопределены при запуске контейнера. В файле может присутствовать лишь одна инструкция CMD.

- WORKDIR — задаёт рабочую директорию для следующей инструкции.

- ARG — задаёт переменные для передачи Docker во время сборки образа.

- ENTRYPOINT — предоставляет команду с аргументами для вызова во время выполнения контейнера. Аргументы не переопределяются.

- EXPOSE — указывает на необходимость открыть порт.

- VOLUME — создаёт точку монтирования для работы с постоянным хранилищем.

### post-py - сервис отвечающий за написание постов:

Гист с граблями был:
```
FROM python:3.6.0-alpine

WORKDIR /app
ADD . /app

# без gcc видел "unable to execute 'gcc': No such file or directory" при сборке.
# По этому поставлю, а потом удалю после requirements

RUN apk add --no-cache --virtual .build-deps gcc musl-dev \
    && pip install -r /app/requirements.txt \
    && apk del --virtual .build-deps gcc musl-dev

ENV POST_DATABASE_HOST post_db
ENV POST_DATABASE posts

CMD ["python3", "post_app.py"]
```

### Comment - сервис отвечающий за написание комментариев
Перегруппирую содержимое и объединю лишние RUN, добавлю apt-get clean:
```
FROM ruby:2.2

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN apt-get update -qq && apt-get install -y build-essential && apt-get clean && bundle install
ADD . $APP_HOME

ENV COMMENT_DATABASE_HOST comment_db
ENV COMMENT_DATABASE comments

CMD ["puma"]

```
### UI - веб-интерфейс, работающий с другими сервисами
Перегруппирую содержимое и объединю лишние RUN, добавлю apt-get clean
```
FROM ubuntu:16.04

ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292
ENV APP_HOME /app

RUN mkdir $APP_HOME
WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/

RUN apt-get update \
    && apt-get install -y ruby-full ruby-dev build-essential \
    && gem install bundler --no-ri --no-rdoc && apt-get clean \
    && bundle install

ADD . $APP_HOME

CMD ["puma"]

```
### База данных MongoDB
docker pull mongo:latest

### Собираю:
```
docker pull mongo:latest
docker build -t decapapreta/post:1.0 ./post-py
docker build -t decapapreta/comment:1.0 ./comment
docker build -t decapapreta/ui:1.0 ./ui
```
Сборка ui:1.0 началась не с первого шага. Так как перекачивать заново исходный образ руби не потребовалось.
### Запускаю:
```
docker network create reddit
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post decapapreta/post:1.0
docker run -d --network=reddit --network-alias=comment decapapreta/comment:1.0
docker run -d --network=reddit -p 9292:9292 decapapreta/ui:1.0
```
- Создали bridge-сеть для контейнеров, так как сетевые алиасы не
работают в сети по умолчанию
- Запустили наши контейнеры в этой сети
- Добавили сетевые алиасы контейнерам

http://<docker-host-ip>:9292/
Работает!

## Задание со *:

Запустите контейнеры с другими сетевыми алиасами:
При запуске контейнеров (docker run) задайте им
переменные окружения соответствующие новым сетевым
алиасам, не пересоздавая образ:
```
docker run -d --network=reddit --network-alias=post_db_1 --network-alias=comment_db_1 mongo:latest
docker run -d --env POST_DATABASE_HOST=post_db_1 --env POST_DATABASE=posts_1 --network=reddit --network-alias=post_1 decapapreta/post:1.0
docker run -d --env COMMENT_DATABASE_HOST=comment_db_1 --env COMMENT_DATABASE=comments_1 --network=reddit --network-alias=comment_1 decapapreta/comment:1.0
docker run -d --env POST_SERVICE_HOST=post_1 --env COMMENT_SERVICE_HOST=comment_1 --network=reddit -p 9292:9292 decapapreta/ui:1.0
```
Проверьте работоспособность сервиса:
http://<docker-host-ip>:9292/
Работает!

### Задание со *:

Попробуйте собрать образ на основе Alpine Linux
Придумайте еще способы уменьшить размер образа
Можете реализовать как только для UI сервиса, так и для
остальных (post, comment)
Все оптимизации проводите в Dockerfile сервиса.
Дополнительные варианты решения уменьшения размера
образов можете оформить в виде файла Dockerfile.<цифра> в
папке сервиса

До ковыряния докерфайлов:
```
docker images                          
REPOSITORY                TAG                 IMAGE ID            CREATED             SIZE
decapapreta/ui            2.0                 a1f9587f1062        19 seconds ago      459MB
decapapreta/comment       1.0                 4ee44c300916        About a minute ago   781MB
decapapreta/post          1.0                 a9280dcaf533        4 minutes ago        109MB
```

ui
-------------------------------
Результат - 158мб на основе Dockerfile.3
```
FROM ruby:2.2-alpine

ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292
ENV APP_HOME /app

RUN mkdir $APP_HOME
WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/

RUN apk add --no-cache --virtual .build-deps build-base \
    && bundle install \
    && bundle clean \
    && apk del .build-deps

ADD . $APP_HOME

CMD ["puma"]
```

post
-----------------------
Результат - без изменений. Исходный гист был с ошибкой, которая была исправлена, а так - этот образ хорош вполне: 109мб
```
FROM python:3.6.0-alpine

ENV POST_DATABASE_HOST post_db
ENV POST_DATABASE posts

WORKDIR /app
ADD . /app

RUN apk add --no-cache --virtual .build-deps gcc musl-dev \
    && pip install -r /app/requirements.txt \
    && apk del --virtual .build-deps gcc musl-dev

CMD ["python3", "post_app.py"]
```

comment
-------------------------
Результат - 158мб
```
FROM ruby:2.2-alpine

ENV COMMENT_DATABASE_HOST comment_db
ENV COMMENT_DATABASE comments
ENV APP_HOME /app

RUN mkdir $APP_HOME
WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/

RUN apk add --no-cache --virtual .build-deps build-base \
    && bundle install \
    && bundle clean \
    && apk del .build-deps

ADD . $APP_HOME

CMD ["puma"]
```
Итого:
```
decapapreta/ui            3.0                 fdecc477e68a        17 seconds ago      158MB
decapapreta/post          1.0                 a9280dcaf533        33 minutes ago      109MB
decapapreta/comment       3.0                 0b486bc1f578        8 minutes ago       156MB
```
### Запустим новые контейнеры:
```
docker kill $(docker ps -q)
docker network create reddit
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post decapapreta/post:1.0
docker run -d --network=reddit --network-alias=comment decapapreta/comment:3.0
docker run -d --network=reddit -p 9292:9292 decapapreta/ui:3.0
# при убиении контейнеров посты не сохраняются.
# создам волюм к монге
docker volume create reddit_db
# убью существующие
docker kill $(docker ps -q)
# создам заново. но подключу волиум к монге через параметр -v
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit --network-alias=post decapapreta/post:1.0
docker run -d --network=reddit --network-alias=comment decapapreta/comment:3.0
docker run -d --network=reddit -p 9292:9292 decapapreta/ui:3.0
```
При перезапуске и убиении данных контейнеров мы уже не теряем посты - бд в волиуме и мы не теряем ее, а переподключаем при создании контейнеров из образов.

### ЕСЛИ вдруг играл на своей машине, то:
```
docker kill $(docker ps -q)
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
# волиумы посмотрим:
docker volume ls
# тож можно поубивать
docker volume rm $(docker volume ls -f dangling=true -q)
```
Если же играл в докер-машине облачной, то:
docker-machine rm docker-host -f
eval $(docker-machine env --unset)

______________________
# HW: Сетевое взаимодействие Docker контейнеров. Docker Compose. Тестирование образов.

### Создадим среду для домашки
```
git checkout -b docker-4
```
В качестве линтера использую плагин к VSCode

Для игр с докером разверну вновь докер-машину.
```
export GOOGLE_PROJECT=docker-258020
```
```
docker-machine create --driver google \
 --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
 --google-machine-type n1-standard-1 \
 --google-zone europe-west1-b docker-host
```
```
eval $(docker-machine env docker-host)
```
```
docker-machine ls
NAME          ACTIVE   DRIVER   STATE     URL                         SWARM   DOCKER     ERRORS
docker-host   *        google   Running   tcp://104.155.127.31:2376           v19.03.4   
```
## Автоматизация подготовки среды для домашки:

### Terraform: 
Вообще все в облаке должно быть в коде.
В директории terraform есть bucket_creation - там создание бакета в проекте GCE. В корне директории terraform код создает стейт инфраструктуры в бакете, созданное правило для 22 порта в облаке для провижена, ключи для ssh в GCE,. Так как все должнобыть *aaC.
### docker-machine:
В директории docker-machine-scripts скрипт развертыввния среды разработки ДЗ и скрипт свертывания. 

## Работа с сетью в Docker

!!!! Не забыть добавить креды в гитигнор
