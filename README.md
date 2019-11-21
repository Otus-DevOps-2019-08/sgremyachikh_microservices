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
-------------------------------
## Автоматизация подготовки среды для домашки:

### Terraform: 
Вообще все в облаке должно быть в коде.
В директории terraform есть bucket_creation - там создание бакета в проекте GCE. В корне директории terraform код создает стейт инфраструктуры в бакете, созданное правило для 22 порта в облаке для провижена, ключи для ssh в GCE,. Так как все должнобыть *aaC.
### docker-machine:
В директории docker-machine-scripts скрипт развертыввния среды разработки ДЗ и скрипт свертывания. 

------------------------------

## Разобраться с работой сети в Docker
• none
• host
• bridge

### None network driver

Запустим контейнер с использованием none-драйвера:
```
docker pull joffotron/docker-net-tools

docker run -ti --rm --network none joffotron/docker-net-tools -c ifconfig 
lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```
В результате, видим:
• что внутри контейнера из сетевых интерфейсов существует только loopback.

```
docker run -ti --rm --network none joffotron/docker-net-tools -c 'ping localhost'
PING localhost (127.0.0.1): 56 data bytes
64 bytes from 127.0.0.1: seq=0 ttl=64 time=0.030 ms
64 bytes from 127.0.0.1: seq=1 ttl=64 time=0.101 ms
64 bytes from 127.0.0.1: seq=2 ttl=64 time=0.034 ms
64 bytes from 127.0.0.1: seq=3 ttl=64 time=0.102 ms
^C
--- localhost ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 0.030/0.066/0.102 ms
```
Сетевой стек самого контейнера работает (ping localhost),
но без возможности контактировать с внешним миром. 

Значит, можно даже запускать сетевые сервисы внутри
такого контейнера, но лишь для локальных
экспериментов (тестирование, контейнеры для
выполнения разовых задач и т.д.)

### Host network driver
```
docker run -ti --rm --network host joffotron/docker-net-tools -c ifconfig 
### Результат - вывод конфигурации всех интерфейсов локальной хост-машины
```
Запустите несколько раз (2-4)
> docker run --network host -d nginx

Что выдал docker ps? Как думаете почему?
Выдал, что запущен 1 инстанс докера с nginx, т.к. первый сразу же занял 80 порт, а послежующие по этой причине упали с кодом 1.

>  docker kill $(docker ps -q)

### Docker networks

network namespaces
> sudo ln -s /var/run/docker/netns /var/run/netns

на docker-host создан симлинк, позволяющий видеть неймспейсы командой 
```
sudo ip netns
```
список неймспейсов без запущенных контейнеров
```
sudo ip netns
default
```
#### список неймспейсов при запущенном контейнере с сетью none
```
docker run --network none -d nginx
docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
d9d1cbd8bd53        nginx               "nginx -g 'daemon of…"   27 seconds ago      Up 24 seconds                           epic_booth
```
на docker-machine
```
sudo ip netns
2bd83d1d615b
default
```
видим, что появился новый namespace, запускаем ещё один контейнер
```
docker run --network none -d nginx
da07adeb676ea5b4dec31b9a002f539ffcec53fde230ed00e5245b4f070fd6ba

docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
da07adeb676e        nginx               "nginx -g 'daemon of…"   33 seconds ago      Up 32 seconds                           gracious_chatterjee
d9d1cbd8bd53        nginx               "nginx -g 'daemon of…"   2 minutes ago       Up 2 minutes                            epic_booth
```
на docker-machine
```
sudo ip netns
3fe460539474
2bd83d1d615b
default
```
видим 2 неймспейса

убьем все
```
docker kill $(docker ps -q)
```
#### Сеть host
```
docker run --network host -d nginx
3e15989e170047ad9d6466aebd38e486624d73706855730a9d1392b154deb821
```
На docker-machine
```
sudo ip netns
default
```
неймспейсы не создавались, используется хостовый.

убили все контейнеры 
```
docker kill $(docker ps -q)
```
### Bridge network driver

Создадим bridge-сеть в docker
```
sudo docker network create reddit --driver bridge
7cf6b4acf1bbd8ac60fe56ba9d0cba3bd635a3f104b2bf01192b041b97729314
```
Собираю образы шельником в корне src/build_all_4.sh: 
```
docker pull mongo:latest
docker build -t decapapreta/post:1.0 ./post-py
docker build -t decapapreta/comment:1.0 ./comment
docker build -t decapapreta/ui:1.0 ./ui
```
Чтоб не билдить в другой раз заново, решил закоммитить каждый образ и запушить на докерхаб:

> docker commit container_id username/imagename:tag
> docker push username/imagename:tag

```
docker ps
docker commit 558caa816369 decapapreta/ui:1.0
docker push decapapreta/ui:1.0
docker ps
docker commit 2d0e66ae7967 decapapreta/comment:1.0
docker push decapapreta/comment:1.0
docker ps
docker commit 37938786611e decapapreta/post:1.0
docker push decapapreta/post:1.0
```

Запускаю шельником в корне src/run_all_4.sh::
```
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post decapapreta/post:1.0
docker run -d --network=reddit --network-alias=comment decapapreta/comment:1.0
docker run -d --network=reddit -p 9292:9292 decapapreta/ui:1.0
```
Реально:
```
./run_all_4.sh 
09e1850797c6cd4f48af4fa9ba6952bd6414f4329addb4135819752bdd2fb081
37938786611e6221db861e002c9411a0f8fd86a29a9454ab8f8ae8b6b6c4e9bb
2d0e66ae796774b8a7dcb8bb80a984db23719be3fcc59fea4bc7071603cb5d87
558caa816369325352a4e8787c0542226cf000d0691b727fe6a2f39fbbfd3e54
```
```
docker ps
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS              PORTS                    NAMES
558caa816369        decapapreta/ui:1.0        "puma"                   2 minutes ago       Up 2 minutes        0.0.0.0:9292->9292/tcp   gifted_kapitsa
2d0e66ae7967        decapapreta/comment:1.0   "puma"                   2 minutes ago       Up 2 minutes                                 nostalgic_antonelli
37938786611e        decapapreta/post:1.0      "python3 post_app.py"    2 minutes ago       Up 2 minutes                                 inspiring_bouman
09e1850797c6        mongo:latest              "docker-entrypoint.s…"   2 minutes ago       Up 2 minutes        27017/tcp                jolly_brown
```
Создал bridge-сеть для контейнеров, запустил наши контейнеры в этой сети
Добавил сетевые алиасы контейнерам, задание о которых увидел позже.
http://HOSTNAME:9292/
Работает!

```
 docker kill $(docker ps -q)
```
### Давайте запустим наш проект в 2-х bridge сетях. Так , чтобы сервис ui не имел доступа к базе данных

Создадим docker-сети
```
docker network create back_net --subnet=10.0.2.0/24 \ 
&& docker network create front_net --subnet=10.0.1.0/24   

ca398bfa986f03fd7c355ffe1e357367b60c0f33180ee80a1d139b4a0526cb2d
042aa1a3bf38b3c33715eb07e6a64cd2e695a33766166d3b0675c25786658bf4
```
Запустим контейнеры
```
docker run -d --network=front_net -p 9292:9292 --name ui decapapreta/ui:1.0 \
 && docker run -d --network=back_net --name comment decapapreta/comment:1.0 \
 && docker run -d --network=back_net --name post decapapreta/post:1.0 \
 && docker run -d --network=back_net --name mongo_db --network-alias=post_db --network-alias=comment_db mongo:latest

b55250b315934efe1496b3856d0e4a8f54b9d1021c28309cbc931dc7ae2e521c
40fe22b4ed1c222be0722e3968303430a90b00f13ff962beef7932c62878c4d0
892c5853ab09e7943d5dfed4814f1879e2ed09f28a141dde76ef975231898045
6b1729e58353e0a2c2a5ed0a67be6642c202aa4466ddec5b22c47811c68242f2
```
Подключим сеть фронта к 2-м контейнерам:
```
docker network connect front_net post \
 && docker network connect front_net comment
```
http://HOSTNAME:9292/
Работает!

```
docker kill $(docker ps -q) && docker network remove back_net && docker network remove front_net
```
### Давайте посмотрим как выглядит сетевой стек Linux в текущий момент

ssh 
```
docker-machine ssh docker-host
```
Поставлю сетевые пакеты:
```
sudo apt-get update && sudo apt-get install bridge-utils
```
Я должен было увидеть список сетей проекта:
```
docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
88e602bcb8a5        back_net            bridge              local
05f7b71a5de9        bridge              bridge              local
b8362a5f8051        front_net           bridge              local
bc60eec2e4c6        host                host                local
92c135628d1c        none                null                local
```
К проекту относятся:
>88e602bcb8a5        back_net            bridge              local
>b8362a5f8051        front_net           bridge              local

Список бриджей иначе:
```
ifconfig | grep br
br-88e602bcb8a5 Link encap:Ethernet  HWaddr 02:42:3a:ac:49:9a  
br-b8362a5f8051 Link encap:Ethernet  HWaddr 02:42:a8:17:a4:71
```
Информация о интерфейсе одного из бриджей, предварительно создав там докер-контейнер с подключением к бриджу:
```
brctl show br-88e602bcb8a5
bridge name	bridge id		STP enabled	interfaces
br-88e602bcb8a5		8000.02423aac499a	no		vethd5b48af
```
Отображаемые veth-интерфейсы принадлежат докер контейнерам.

Посмотрим на iptables:
```
sudo iptables -nL -t nat
Chain PREROUTING (policy ACCEPT)
target     prot opt source               destination         
DOCKER     all  --  0.0.0.0/0            0.0.0.0/0            ADDRTYPE match dst-type LOCAL

Chain INPUT (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         
DOCKER     all  --  0.0.0.0/0           !127.0.0.0/8          ADDRTYPE match dst-type LOCAL

Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination         
MASQUERADE  all  --  10.0.2.0/24          0.0.0.0/0           
MASQUERADE  all  --  10.0.1.0/24          0.0.0.0/0           
MASQUERADE  all  --  172.17.0.0/16        0.0.0.0/0           
MASQUERADE  tcp  --  10.0.1.2             10.0.1.2             tcp dpt:9292

Chain DOCKER (2 references)
target     prot opt source               destination         
RETURN     all  --  0.0.0.0/0            0.0.0.0/0           
RETURN     all  --  0.0.0.0/0            0.0.0.0/0           
RETURN     all  --  0.0.0.0/0            0.0.0.0/0           
DNAT       tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:9292 to:10.0.1.2:9292
```
Доступ в внешние сети дают правила построутинга:
```
MASQUERADE  all  --  10.0.2.0/24          0.0.0.0/0           
MASQUERADE  all  --  10.0.1.0/24          0.0.0.0/0           
MASQUERADE  all  --  172.17.0.0/16        0.0.0.0/0
```
> DNAT       tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:9292 to:10.0.1.2:9292
отвечает за перенаправление трафика на адреса уже конкретных
контейнеров

Этот процесс в данный момент слушает сетевой tcp-порт 9292:
```
ps ax | grep docker-proxy
 7149 ?        Sl     0:00 /usr/bin/docker-proxy -proto tcp -host-ip 0.0.0.0 -host-port 9292 -container-ip 10.0.1.2 -container-port 9292
 8266 pts/0    S+     0:00 grep --color=auto docker-proxy
```
## Docker-compose

Проблемы:

- Одно приложение состоит из множества контейнеров/
сервисов
- Один контейнер зависит от другого
- Порядок запуска имеет значение
- docker build/run/create … (долго и много)

Плюшки композа:

- Отдельная утилита
- Декларативное описание docker-инфраструктуры в YAMLформате
- Управление многоконтейнерными приложениями

### Установка dockercompose

Linux - (https://docs.docker.com/compose/install/#installcompose)
либо
> pip install docker-compose

В директории с проектом reddit-microservices, папка
src, из предыдущего домашнего задания создайте
файл docker-compose.yml

docker-compose поддерживает интерполяцию
(подстановку) переменных окружения

Остановим контейнеры, запущенные на предыдущих шагах
> docker kill $(docker ps -q)

```
export USERNAME=decapapreta

sudo docker-compose up -d
Creating network "src_reddit" with the default driver
Creating src_ui_1      ... done
Creating src_post_1    ... done
Creating src_comment_1 ... done
Creating src_post_db_1 ... done

docker-compose ps
    Name                  Command             State           Ports         
----------------------------------------------------------------------------
src_comment_1   puma                          Up                            
src_post_1      python3 post_app.py           Up                            
src_post_db_1   docker-entrypoint.sh mongod   Up      27017/tcp             
src_ui_1        puma                          Up      0.0.0.0:9292->9292/tcp
```
### Свой композ:

В помощь https://docs.docker.com/compose/compose-file/

в файл docker-compose.yml.env вынес:
```
MONGO_VER=3.2
USERNAME=decapapreta
UI_VER=1.0
POST_VER=1.0
COMMENT_VER=1.0
UI_PORT=80
```
В самом yml использовал вариант ${VARIABLE:-default} evaluates to default if VARIABLE is unset or empty in the environment.

```
version: '3.3'
services:
  post_db:
    image: mongo:${MONGO_VER:-3.2}
    volumes:
      - post_db:/data/db
    networks:
      back_net:
        aliases:
          - post_db
  ui:
    build: ./ui
    image: ${USERNAME:-decapapreta}/ui:${UI_VER:-1.0}
    ports:
    - protocol: tcp
      published: ${UI_PORT:-80}
      target: 9292
    networks:
      front_net:
        aliases:
          - ui
  post:
    build: ./post-py
    image: ${USERNAME:-decapapreta}/post:${POST_VER:-1.0}
    networks:
      back_net:
        aliases:
          - post
      front_net:
        aliases:
          - post
  comment:
    build: ./comment
    image: ${USERNAME:-decapapreta}/comment:${COMMENT_VER:-1.0}
    networks:
      back_net:
        aliases:
          - comment
      front_net:
        aliases:
          - comment

volumes:
  post_db:

networks:
  front_net:
  back_net:

```
По умолчанию, все контэйнеры, которые запускаются с помощью docker-compose, используют название текущей директории как префикс. Название этой директории может отличаться в рабочих окружениях у разных разработчиков. Этот префикс (app_) используется, когда мы хотим сослаться на контейнер из основного docker-compose файла. Чтобы зафиксировать этот префикс, нужно создать файл .env в той директории, из которой запускается docker-compose:


COMPOSE_PROJECT_NAME=app
