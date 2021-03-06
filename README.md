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

```
docker-compose -f docker-compose.yml config
networks:
  back_net: {}
  front_net: {}
services:
  comment:
    build:
      context: /home/sgremyachikh/OTUS/sgremyachikh_microservices/src/comment
    image: decapapreta/comment:1.0
    networks:
      back_net:
        aliases:
        - comment
      front_net:
        aliases:
        - comment
  post:
    build:
      context: /home/sgremyachikh/OTUS/sgremyachikh_microservices/src/post-py
    image: decapapreta/post:1.0
    networks:
      back_net:
        aliases:
        - post
      front_net:
        aliases:
        - post
  post_db:
    image: mongo:3.2
    networks:
      back_net:
        aliases:
        - post_db
    volumes:
    - post_db:/data/db:rw
  ui:
    build:
      context: /home/sgremyachikh/OTUS/sgremyachikh_microservices/src/ui
    image: decapapreta/ui:1.0
    networks:
      front_net:
        aliases:
        - ui
    ports:
    - protocol: tcp
      published: 80
      target: 9292
version: '3.3'
volumes:
  post_db: {}
```

# HW:19 Устройство Gitlab CI. Построение процесса непрерывной интеграции.
```
git checkout -b gitlab-ci-1
```
Цель задания
• Подготовить инсталляцию Gitlab CI
• Подготовить репозиторий с кодом приложения
• Описать для приложения этапы пайплайна
• Определить окружения

## Terraform

В директории terraform файлы для содания структур под ДЗ, связанные с гитлабом, перемещу for_gitlabci_homeworks, где опишу инфраструктуру

мы можем переиспользовать описание инфраструктуры из infra, изменив бэкенд для хранения стейта в бакете, переиспользуем модуль vpc, подправив его возможности, переиспользуем модуль создания виртуалки.

## Ansible

В случае vagrant и terraform нам нужен провижинг машины чтоб не ставить руками.
В корне репозитория создам директорию ansible/playboks
gitlabci.yml описывает деплой гитлаба на виртуалку, созданную терраформом
```
---
- name: install gitlab
  hosts: gitlabci-homework
  become: true

  roles:
    - role: nephelaiio.gitlab
      gitlab_package_state: latest
    - role: geerlingguy.docker
...

```

Использованы роли
> https://galaxy.ansible.com/nephelaiio/gitlab
> https://galaxy.ansible.com/geerlingguy/docker

```
ansible-galaxy install nephelaiio.gitlab
ansible-galaxy install geerlingguy.docker
```
Инвентори у нас динамический конечно.
```
ansible-inventory --graph
@all:
  |--@_gitlabci_homework:
  |  |--gitlabci-homework
  |--@gitlabci:
  |  |--gitlabci-homework
  |--@ungrouped:
```
а в самом инвенторифайле конфиг таков:
```
plugin: gcp_compute
projects: # имя проекта в GCP
  - docker-258020 
regions: # регионы моих виртуалок
  - europe-west1
keyed_groups: # на основе чего хочу группировать
    - key: name
groups: # хочу свои группы с блэкджеком и пилить их буду на основании присутствия частичек нужных в именах
  gitlabci: "'gitlab' in name"
hostnames: #хостнейм приятнее айпишника, НО без compose не взлетало
  # List host by name instead of the default public ip
  - name
compose: #
  # Тутустанвливается параметр сопоставления публичного IP и хоста
  # Для ip из LAN использовать "networkInterfaces[0].networkIP"
  ansible_host: networkInterfaces[0].accessConfigs[0].natIP
filters: []
auth_kind: serviceaccount # тип авторизации
service_account_file: ~/.gcp/docker-258020-84d2d673efa5.json # мой секретный ключ от сервисного акка
```
```
cd ansible
ansible-playbook ./playbooks/gitlabci.yml
```
после этого на 80 порту нашей виртуалки засияет веб-мордочка гитлаба.

### Продолжаем основную HW

Поставил пароль руту.
Зашел в админку и отключил регистрацию внешних пользователей.

Создадим приватную группу homeworks.

Создадим проект в группе. Назовем example, тип бланк, приватный.

### Важный момент:

https://docs.gitlab.com/omnibus/settings/configuration.html

In order for GitLab to display correct repository clone links to your users it needs to know the URL under which it is reached by your users, e.g. http://gitlab.systemctl.tech. Add or edit the following line in :

> external_url "http://gitlab.systemctl.tech"

потом
```
sudo gitlab-ctl reconfigure
```

### В профиле полльзователя добавляю свои SSH ключи.
Чтоб пушить в гитлаб без ввода логина и пароля.
http://VM_IP/profile/keys

Настрою внешний репозиторий gitlab для работы с ним по SSH. Далее запущу код в репу гитлаба.
```
git remote add gitlab git@VM_IP:homeworks/example.git
git push gitlab gitlab-ci-1
```
### Создам  .gitlab-ci.yml и запушу его.

```
stages:
  - build
  - test
  - deploy

build_job:
  stage: build
  script:
    - echo 'Building'

test_unit_job:
  stage: test
  script:
    - echo 'Testing 1'

test_integration_job:
  stage: test
  script:
    - echo 'Testing 2'

deploy_job:
  stage: deploy
  script:
    - echo 'Deploy'
```
Теперь в http://35.240.36.198/homeworks/example/pipelines я вижу пайплайн.
Но находится в статусе pending / stuck так как у нас нет runner.

### Runner

Запустим Runner и зарегистрируем его в интерактивном
режиме.

Перед тем, как запускать и регистрировать runner
нужно получить токен.

Settings - CI/CD - Runner Settings

Нужно скопировать, токен пригодится нам при
регистрации

НАДО БЫЛО НАЙТИ РОЛЬКУ ДЛЯ РАННЕРА, н дело было вечером и сонное...
зашел в шелл виртуалки:
```
sudo docker run -d --name gitlab-runner --restart always \
-v /srv/gitlab-runner/config:/etc/gitlab-runner \
-v /var/run/docker.sock:/var/run/docker.sock \
gitlab/gitlab-runner:latest 

sudo docker exec -it gitlab-runner gitlab-runner register --run-untagged --locked=false
Runtime platform                                    arch=amd64 os=linux pid=12 revision=577f813d version=12.5.0
Running in system-mode.                            
                                                   
Please enter the gitlab-ci coordinator URL (e.g. https://gitlab.com/):
http://104.155.106.203/
Please enter the gitlab-ci token for this runner:
a1Sugikn4kTQ_hA_zYLe
Please enter the gitlab-ci description for this runner:
[34275fb2e57d]: my-runner
Please enter the gitlab-ci tags for this runner (comma separated):
linux,xenial,ubuntu,docker
Registering runner... succeeded                     runner=a1Sugikn
Please enter the executor: docker, docker-ssh, parallels, virtualbox, docker-ssh+machine, kubernetes, custom, shell, ssh, docker+machine:
docker
Please enter the default Docker image (e.g. ruby:2.6):
alpine:latest
Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded!
```
В итоге вы увидим в вегб-гуе что наш раннер появился и мы можем его использовать.

Позже переконфигурировал раннер на использование ruby:latest вместо alpine:latest, как сделано на одном из скриншотов. т.к. нне проходили команды для руби*

### CI/CD Pipeline

После добавления Runner вижу, что пайплайн выполнился успешно.

Добавим исходный код reddit в репозиторий

> git clone https://github.com/express42/reddit.git && rm -rf ./reddit/.git
> git add reddit/
> git commit -m “Add reddit app”
> git push gitlab gitlab-ci-1

далее сделаю изменения в скрипте пайплайна:

```
stages:
  - build
  - test
  - deploy

variables:
  DATABASE_URL: 'mongodb://mongo/user_posts'

before_script:
    - cd reddit
    - bundle install 

build_job:
  stage: build
  script:
    - echo 'Building'

test_unit_job:
  stage: test
  services:
    - mongo:latest
  script:
    - ruby simpletest.rb

test_integration_job:
  stage: test
  script:
    - echo 'Testing 2'

deploy_job:
  stage: deploy
  script:
    - echo 'Deploy'
```
В описании pipeline мы добавили вызов теста в файле simpletest.rb,
нужно создать его в папке reddit

```
require_relative './app'
require 'test/unit'
require 'rack/test'

set :environment, :test

class MyAppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

#  def test_get_request
#   get '/'
#    assert last_response.ok?
#  end
end

```
Последним шагом нам нужно добавить библиотеку
для тестирования в reddit/Gemfile приложения.
Добавим gem 'rack-test'
Теперь на каждое изменение в коде приложения
будет запущен тест

ВАЖНО. переконфигурировал раннер на использование ruby:latest вместо alpine:latest, как сделано на одном из скриншотов. т.к. нне проходили команды для руби:
```
sudo docker exec -it gitlab-runner gitlab-runner register --run-untagged --locked=false
Runtime platform                                    arch=amd64 os=linux pid=25 revision=577f813d version=12.5.0
Running in system-mode.                            
                                                   
Please enter the gitlab-ci coordinator URL (e.g. https://gitlab.com/):
http://104.155.106.203/
Please enter the gitlab-ci token for this runner:
a1Sugikn4kTQ_hA_zYLe
Please enter the gitlab-ci description for this runner:
[f5aa9387f7cb]: my-runner-ubuntu
Please enter the gitlab-ci tags for this runner (comma separated):
linux,xenial,ubuntu,docker
Registering runner... succeeded                     runner=a1Sugikn
Please enter the executor: virtualbox, docker+machine, docker-ssh+machine, docker, parallels, shell, kubernetes, custom, docker-ssh, ssh:
docker
Please enter the default Docker image (e.g. ruby:2.6):
ruby:latest
Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded!
```

после успешного завешения пайплайна с
определением окружения перейти в OPERATIONS >
Environments, то там появится определение первого
окружения. (в методичке ошибка)

В прохождении юнит-теста, который был в simpletest.rb я закомментировал несколько строк - см. выше чтоб проходился тест:) 


### Staging и Production
Если на dev мы можем выкатывать последнюю версию кода, то к
production окружению это может быть неприменимо, если,
конечно, вы не стремитесь к continuous deployment.
Определим два новых этапа: stage и production, первый будет
содержать job имитирующий выкатку на staging окружение, второй
на production окружение.
Определим эти job таким образом, чтобы они запускались с кнопки:
```
stages:
  - build
  - test
  - review

variables:
  DATABASE_URL: 'mongodb://mongo/user_posts'

before_script:
    - cd reddit
    - bundle install

build_job:
  stage: build
  script:
    - echo 'Building'

test_unit_job:
  stage: test
  services:
    - mongo:latest
  script:
    - ruby simpletest.rb

test_integration_job:
  stage: test
  script:
    - echo 'Testing 2'

deploy_dev_job:
  stage: review
  script:
    - echo 'Deploy'
  environment:
    name: dev
    url: http://dev.example.com/

staging:
  stage: stage
  when: manual
  script:
    - echo 'Deploy'
  environment:
    name: stage
    url: https://beta.example.com 

poduction:
  stage: production
  when: manual
  script:
    - echo 'Deploy'
  environment:
    name: production
    url: https://example.com
```
На странице окружений должны появиться
оружения staging и production, а у пайплайна должы появиться 2 ручных стейджа.

### Условия и ограничения

Обычно, на production окружение выводится
приложение с явно зафиксированной версией
(например, 2.4.10).
Добавим в описание pipeline директиву, которая не
позволит нам выкатить на staging и production код,
не помеченный с помощью тэга в git.

Директива only описывает список
условий, которые должны быть
истинны, чтобы job мог
запуститься.
Регулярное выражение означает, что должен стоять
semver тэг в git, например, 2.4.10
```
...
staging:
  stage: stage
  when: manual
  only:
    - /^\d+\.\d+\.\d+/
  script:
    - echo 'Deploy'
  environment:
    name: stage
    url: https://beta.example.com 
...
```
Изменение, помеченное тэгом в git запустит полный пайплайн
```
git commit -a -m ‘#4 add logout button to profile page’
git tag 2.4.10
git push gitlab gitlab-ci-1 --tags
```
### Динамические окружения

Gitlab CI позволяет определить динамические
окружения, это мощная функциональность
позволяет вам иметь выделенный стенд для,
например, каждой feature-ветки в git.
Определяются динамические окружения с
помощью переменных, доступных в .gitlab-ci.yml

```
...
deploy_dev_job:
  stage: review
  script:
    - echo  "Deploy to $CI_ENVIRONMENT_SLUG"
  environment:
    name: branch/$CI_COMMIT_REF_NAME
    url: http://$CI_ENVIRONMENT_SLUG.example.com
  only:
    - branches
  except:
    - master
...
```
Этот job определяет
динамическое окружение
для каждой ветки в
репозитории, кроме ветки
master

Теперь, на каждую ветку в git отличную от master
Gitlab CI будет определять новое окружение.

## Задачи со *

1. Продумайте автоматизацию развертывания и регистрации
Gitlab CI Runner. В больших организациях количество Runners
может превышать 50 и более, сетапить их руками становится
проблематично.
Реализацию функционала добавьте в репозиторий в папку
gitlab-ci.

Для установки раннеров воспользуюсь ролью ansible:
https://galaxy.ansible.com/riemers/gitlab-runner


Установлю ее:
```
ansible-galaxy install riemers.gitlab-runner
```
Для провижинга ранеров в гуглооблаке использую динамик инвентори:
```
plugin: gcp_compute
projects:
  - docker-258020 
regions:
  - europe-west1
keyed_groups:
    - key: name
groups:
  gitlabci: "'gitlab' in name"
  runners: "'runner' in name"
hostnames:
  - name
compose: #
  ansible_host: networkInterfaces[0].accessConfigs[0].natIP
filters: []
auth_kind: serviceaccount
service_account_file: ~/.gcp/docker-258020-84d2d673efa5.json
```
Напишу плейбук gitlab_runners.yml

```
---
- name: install gitlab runners
  hosts: runners
  become: true
  vars_files:
    - vars/main.yml

  roles:
    - { role: riemers.gitlab-runner }
...

```
А к нему vars/main.yml

```
gitlab_runner_registration_token: 'a1Sugikn4kTQ_hA_zYLe'
gitlab_runner_coordinator_url: 'http://104.155.106.203/'
gitlab_runner_runners:
  - name: 'Example Docker GitLab Runner'
    executor: docker
    docker_image: 'ubuntu:16.04'
    tags:
      - linux
      - xential
      - ubuntu
      - docker
    docker_volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
      - "/cache"
    extra_configs:
      runners.docker:
        memory: 512m
        allowed_images: ["ruby:*", "python:*", "php:*"]
      runners.docker.sysctls:
        net.ipv4.ip_forward: "1" 

```
2. Настройте интеграцию вашего Pipeline с тестовым Slack-чатом,
который вы использовали ранее. Для этого перейдите в Project
Settings > Integrations > Slack notifications. Нужно установить
active, выбрать события и заполнить поля с URL вашего Slack
webhook.
Добавьте ссылку на канал в слаке, в котором можно проверить
работу оповещений, в файл README.md

Пошел в гитлаб.https://docs.gitlab.com/ee/user/project/integrations/slack.html
Потом в  https://hooks.slack.com/services, где благополучно настроил сервис.
Настроил в гитлабе.
Ссылка на канал в слаке:
https://devops-team-otus.slack.com/archives/CNC16UC4C

### В завершение 
для приличия создал docker-compose.yml, как того требует задание.


# HW: Введение в мониторинг. Модели и принципы работы систем мониторинга.

План
• Prometheus: запуск, конфигурация, знакомство с
Web UI
• Мониторинг состояния микросервисов
• Сбор метрик хоста с использованием экспортера
• Задания со *

## Подготовка окружения 

### Terraform:

Вообще все в облаке должно быть в коде.
В sgremyachikh_microservices/terraform/bucket_creation/ - там создание бакета в проекте GCE. 
<<<<<<< HEAD

=======
>>>>>>> af1b618a91fe56a609193a0cb968771e36140838
В sgremyachikh_microservices/terraform/for_docker_homeworks/ - код проапгрейжен модулем firewall, создаст стейт инфраструктуры в бакете, созданные правила для 22, 9090, 9292 портов в облаке для провижена, ключи для ssh в GCE,. Так как все должнобыть *aaC.

### docker-machine:

В директории docker-machine-scripts скрипт развертыввния среды разработки ДЗ и скрипт свертывания. 

## Запуск Prometheus

Систему мониторинга Prometheus будем запускать внутри
Docker контейнера. Для начального знакомства воспользуемся
готовым образом с DockerHub.

> sudo docker run --rm -p 9090:9090 -d --name prometheus prom/prometheus:v2.1.0
ВАЖНО! Даже не смотря на eval $(docker-machine env docker-host) если запускать конструкцию выше с sudo, то докер-контейнер запустится ЛОКАЛЬНО! Это нужно помнить, пытаясь повысить превилегии - т.к. у рута локального eval имеет другое значение.

```
ocker ps
CONTAINER ID        IMAGE                    COMMAND                  CREATED             STATUS              PORTS                    NAMES
bec179be4d87        prom/prometheus:v2.1.0   "/bin/prometheus --c…"   2 minutes ago       Up 2 minutes        0.0.0.0:9090->9090/tcp   prometheus
```
### Откроем веб интерфейс

http://35.205.170.226:9090/graph

По умолчанию сервер слушает на порту 9090, а IP адрес созданной VM
можно узнать, используя команду:
$ docker-machine ip docker-host

Expression - Строка ввода выражений для получения и
анализа информации мониторинга
(метрик) из хранилища

Insert metric cursor- Выбор имеющихся метрик

Execute - выполнить запрос

Console - Вкладка Console, которая сейчас активирована, выводит численное значение
выражений. Вкладка Graph, левее от нее, строит график изменений значений
метрик со временем

Если кликнем по "insert metric at cursor", то увидим, что
Prometheus уже собирает какие-то метрики. По умолчанию он
собирает статистику о своей работе. Выберем, например,
метрику prometheus_build_info и нажмем Execute, чтобы
посмотреть информацию о версии.

> prometheus_build_info{branch="HEAD",goversion="go1.9.2",instance="localhost:9090",job="prometheus",revision="85f23d82a045d103ea7f3c89a91fba4a93e6367a",version="2.1.0"} 1

prometheus_build_info - название метрики - идентификатор собранной информации.

branch, goversion, instance, job, revision - лейбл - добавляет метаданных метрике, уточняет ее.
Использование лейблов дает нам возможность не ограничиваться
лишь одним названием метрик для идентификации получаемой
информации. Лейблы содержаться в {} скобках и представлены
наборами "ключ=значение".

1 - значение метрики - численное значение метрики, либо NaN, если
значение недоступно

### Targets

Status -> Targets (цели) - представляют собой системы или процессы, за
которыми следит Prometheus. Помним, что Prometheus является
pull системой, поэтому он постоянно делает HTTP запросы на
имеющиеся у него адреса (endpoints). Посмотрим текущий список
целей
```
Targets
prometheus (1/1 up)
Endpoint 	State 	Labels 	Last Scrape 	Error
http://localhost:9090/metrics   up 	instance="localhost:9090" 	14.581s ago 	
```
В Targets сейчас мы видим только сам Prometheus. У каждой
цели есть свой список адресов (endpoints), по которым
следует обращаться для получения информации.

В веб интерфейсе мы можем видеть состояние каждого
endpoint-а (up); лейбл (instance="someURL"), который
Prometheus автоматически добавляет к каждой метрике,
получаемой с данного endpoint-а; а также время,
прошедшее с момента последней операции сбора
информации с endpoint-а.

Также здесь отображаются ошибки при их наличии и можно
отфильтровать только неживые таргеты.

Обратите внимание на endpoint, который мы с вами видели на
предыдущем слайде.

Мы можем открыть страницу в веб браузере по данному HTTP
пути (host:port/metrics), чтобы посмотреть, как выглядит та
информация, которую собирает Prometheus.

http://35.205.170.226:9090/metrics

```
# HELP go_gc_duration_seconds A summary of the GC invocation durations.
# TYPE go_gc_duration_seconds summary
go_gc_duration_seconds{quantile="0"} 1.2247e-05
go_gc_duration_seconds{quantile="0.25"} 1.7725e-05
go_gc_duration_seconds{quantile="0.5"} 2.6948e-05
go_gc_duration_seconds{quantile="0.75"} 3.6049e-05
go_gc_duration_seconds{quantile="1"} 4.397e-05
go_gc_duration_seconds_sum 0.000595079
go_gc_duration_seconds_count 22
# HELP go_goroutines Number of goroutines that currently exist.
# TYPE go_goroutines gauge
...
```
### Остановим контейнер

> docker stop prometheus

### Переупорядочим структуру директорий
До перехода к следующему шагу приведем структуру каталогов в более
четкий/удобный вид:
1. Создадим директорию docker в корне репозитория и перенесем в нее
директорию docker-monolith и файлы из src: docker-compose.* и все .env (.env
должен быть в .gitgnore), в репозиторий закоммичен .env.example, из
которого создается .env
2. Создадим в корне репозитория директорию monitoring. В ней будет
хранится все, что относится к мониторингу
3. Не забываем про .gitgnore и актуализируем записи при необходимости
P.S. С этого момента сборка сервисов отделена от docker-compose,
поэтому инструкции build можно удалить из docker-compose.yml

### Создание Docker образа

Познакомившись с веб интерфейсом Prometheus и его
стандартной конфигурацией, соберем на основе готового
образа с DockerHub свой Docker образ с конфигурацией для
мониторинга наших микросервисов.

Создайте директорию monitoring/prometheus. Затем в этой
директории создайте простой Dockerfile, который будет
копировать файл конфигурации с нашей машины внутрь
контейнера, а рядом prometheus.yml(Мы определим простой конфигурационный файл
для сбора метрик с наших микросервисов).

monitoring/prometheus/Dockerfile

```
FROM prom/prometheus:v2.1.0
ADD prometheus.yml /etc/prometheus/
```
### Конфигурация

Вся конфигурация Prometheus, в отличие от многих
других систем мониторинга, происходит через
файлы конфигурации и опции командной строки.

prometheus.yml

>---
>global:
>  scrape_interval: '5s' - С какой частотой собирать метрики
>
>scrape_configs:
>  - job_name: 'prometheus' - Джобы объединяют в группы endpoint-ы, выполняющие одинаковую функцию
>    static_configs:
>      - targets:
>        - 'localhost:9090' - Адреса для сбора метрик (endpoints)
>
>  - job_name: 'ui'
>    static_configs:
>      - targets:
>        - 'ui:9292'
>
>  - job_name: 'comment'
>    static_configs:
>      - targets:
>        - 'comment:9292'

### Создаем образ

директории prometheus собираем Docker образ:

> export USER_NAME=decapapreta
> docker build -t $USER_NAME/prometheus .

Где USER_NAME - ВАШ логин от DockerHub.
В конце занятия нужно будет запушить на DockerHub
собранные вами на этом занятии образы. 

### Образы микросервисов

В коде микросервисов есть healthcheck-и для
проверки работоспособности приложения.
Сборку образов теперь необходимо производить
при помощи скриптов docker_build.sh, которые есть
в директории каждого сервиса. С его помощью мы
добавим информацию из Git в наш healthcheck. 

docker_build.sh в директории каждого сервиса.
/src/ui $ bash docker_build.sh
/src/post-py $ bash docker_build.sh
/src/comment $ bash docker_build.sh

### docker-compose.yml

Будем поднимать наш Prometheus совместно с микросервисами. Определите в вашем
docker/docker-compose.yml файле новый сервис

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
          - comment_db
  ui:
    image: ${USERNAME:-decapapreta}/ui:${UI_VER:-1.0}
    ports:
    - protocol: tcp
      published: ${UI_PORT:-9292}
      target: 9292
    networks:
      front_net:
        aliases:
          - ui
  post:
    image: ${USERNAME:-decapapreta}/post:${POST_VER:-1.0}
    networks:
      back_net:
        aliases:
          - post
      front_net:
        aliases:
          - post
  comment:
    image: ${USERNAME:-decapapreta}/comment:${COMMENT_VER:-1.0}
    networks:
      back_net:
        aliases:
          - comment
      front_net:
        aliases:
          - comment
  prometheus:
    image: ${USERNAME}/prometheus
    networks:
      back_net:
        aliases:
          - prom
      front_net:
        aliases:
          - prom
    ports:
      - '9090:9090'
    volumes:
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention=1d'

volumes:
  prometheus_data:
  post_db:

networks:
  front_net:
  back_net:

```
в command передаем - Передаем доп. параметры в командной строке, Задаем время хранения метрик в 1 день

сборка Docker образов с данного момента производится через скрипт
docker_build.sh. 

Самостоятельно добавьте секцию networks в
определение сервиса Prometheus в docker/dockercompose.yml - сделано.

ВАЖНО!!! Добавил алиас comment_db монге

### Запуск микросервисов

Поднимем сервисы, определенные в docker/dockercompose.yml

> docker-compose up -d

Проверьте, что приложение работает и Prometheus
запустился.

Все ок.

### Список endpoint-ов

Посмотрим список endpoint-ов, с которых собирает
информацию Prometheus. Помните, что помимо самого
Prometheus, мы определили в конфигурации мониторинг ui и
comment сервисов. Endpoint-ы должны быть в состоянии UP. 

Все ок.

### Healthchecks

Healthcheck-и представляют собой проверки того, что
наш сервис здоров и работает в ожидаемом режиме. В
нашем случае healthcheck выполняется внутри кода
микросервиса и выполняет проверку того, что все
сервисы, от которых зависит его работа, ему доступны.

Если требуемые для его работы сервисы здоровы, то
healthcheck проверка возвращает status = 1, что
соответсвует тому, что сам сервис здоров.

Если один из нужных ему сервисов нездоров или
недоступен, то проверка вернет status = 0

### Состояние сервиса UI

В веб интерфейсе Prometheus выполните поиск по
названию метрики ui_health

Обратим внимание, что, помимо имени метрики и ее значения, мы
также видим информацию в лейблах о версии приложения, комите
и ветке кода в Git-е. 

P.S. Если у вас статус не равен 1, проверьте какой сервис
недоступен (слайд 32), и что у вас заданы все aliases для DB  - алиас

### Остановим post сервис

Мы говорили, что условились считать сервис
здоровым, если все сервисы, от которых он зависит
также являются здоровыми.
Попробуем остановить сервис post на некоторое
время и проверим, как изменится статус ui сервиса,
который зависим от post. 

$ docker-compose stop post
Stopping starthealthchecks_post_1 ... done

Обновим наш график

Метрика изменила свое значение на 0, что означает, что UI
сервис стал нездоров/

### Поиск проблемы

Помимо статуса сервиса, мы также собираем статусы сервисов, от
которых он зависит. Названия метрик, значения которых соответствует
данным статусам, имеет формат ui_health_<service-name>.

Посмотрим, не случилось ли чего плохого с сервисами, от которых
зависит UI сервис.

Наберем в строке выражений ui_health_ и Prometheus нам предложит
дополнить названия метрик. 

Проверим comment сервис, видим, что сервис свой статус не менял в данный промежуток
времени
А с post сервисом все плохо. 
Проблему мы обнаружили и знаем, как ее поправить (ведь мы
же ее и создали :)). Поднимем post сервис. 
```
$ docker-compose start post
Starting post ... done
```
Post сервис поправился.
UI сервис тоже.

## Сбор метрик хоста.

### Exporters

Экспортер похож на вспомогательного агента для
сбора метрик. 

В ситуациях, когда мы не можем реализовать
отдачу метрик Prometheus в коде приложения, мы
можем использовать экспортер, который будет
транслировать метрики приложения или системы в
формате доступном для чтения Prometheus.

Exporters
• Программа, которая делает метрики доступными
для сбора Prometheus
• Дает возможность конвертировать метрики в
нужный для Prometheus формат
• Используется когда нельзя поменять код
приложения
• Примеры: PostgreSQL, RabbitMQ, Nginx, Node
exporter, cAdvisor

### Node exporter

Воспользуемся Node экспортер для сбора
информации о работе Docker хоста (виртуалки, где у
нас запущены контейнеры) и предоставлению этой
информации в Prometheus. 

docker-compose.yml
Node экспортер будем запускать также в контейнере. Определим еще один
сервис в docker/docker-compose.yml файле.
Не забудьте также добавить определение сетей для сервиса node-exporter,
чтобы обеспечить доступ Prometheus к экспортеру. 

```
node-exporter:
    image: prom/node-exporter:v0.15.2
    networks:
      back_net:
        aliases:
          - node-exporter
      front_net:
        aliases:
          - node-exporter
    user: root
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.ignored-mount-points="^/(sys|proc|dev|host|etc)($$|/)"'
```

### prometheus.yml
Чтобы сказать Prometheus следить за еще одним сервисом, нам
нужно добавить информацию о нем в конфиг.
Добавим еще один job: 

```
  - job_name: 'node'
    static_configs:
      - targets:
        - 'node-exporter:9100'
```
посмотрим, список endpoint-ов Prometheus - должен
появится еще один endpoint.

Не забудем собрать новый Docker для Prometheus:
monitoring/prometheus $ docker build -t $USER_NAME/prometheus .

### Пересоздадим наши сервисы
$ docker-compose down
$ docker-compose up -d 

посмотрим, список endpoint-ов Prometheus - должен
появится еще один endpoint.

Получим информацию о всем чем можно из железа - данных с барметаллла node снимает - МИЛЛИОН!!111

Вводим в экспрешн node и офигеваем от длинны списка на реальном железе. 

### Завершение работы

запушил все в докер-хаб
https://hub.docker.com/u/decapapreta

## Задание со *

Добавьте в Prometheus мониторинг MongoDB с
использованием необходимого экспортера

Проект dcu/mongodb_exporter не самый лучший вариант,
т.к. у него есть проблемы с поддержкой (не обновляется) 

Версию образа экспортера нужно фиксировать на
последнюю стабильную

Посмотрел https://github.com/prometheus/prometheus/wiki/Default-port-allocations
Выбор пал на https://github.com/percona/mongodb_exporter
Вендор известный и крупный.

По ридми https://github.com/percona/mongodb_exporter/blob/master/README.md:

cd ./monitoring
git clone https://github.com/percona/mongodb_exporter.git
cd mongodb_exporter
make docker
...
Successfully built 04a4999784df
Successfully tagged mongodb-exporter:master

но это не фиксирует версию.
тогда я зашел в мейкфайл, подхачил его:

DOCKER_IMAGE_NAME   ?= decapapreta/mongodb-exporter
DOCKER_IMAGE_TAG    ?= v2019.12.14

затем:
make docker
...
Successfully built 04a4999784df
Successfully tagged decapapreta/mongodb-exporter:v2019.12.14

docker push decapapreta/mongodb-exporter:v2019.12.14
таким образом у меня есть докер-образ с фиксированной стабильной версией экспортера.

Добавлю мониторинг в docker/docker-compose.yml как еще один сервис:

```
  mongodb-exporter:
    image: ${USERNAME:-decapapreta}/mongodb-exporter:${MONGODB_EXPORTER_VERSION:-v2019.12.14}
    networks:
      - back_net
    environment:
      MONGODB_URI: "mongodb://post_db:27017"
```
А прому добавлю джоб для экспортера монги:
```
scrape_config:
  ...
  - job_name: "post_db"
    static_configs:
      - targets:
        - "mongodb-exporter:9216"
```
Не забудем собрать новый Docker для Prometheus:
monitoring/prometheus $ docker build -t $USER_NAME/prometheus .

Для проверки 
```
docker-compose up -d
```
В гуе прома вводим mongodb и смотрим сколько всего теперь доступно для снятия метрик.

Так же показательно что mongodb_exporter_build_info{branch="",goversion="go1.11.13",instance="mongodb-exporter:9216",job="post_db",revision="",version=""} имеет велью 1 - данные есть:)
В .gitignore добавлена строка

monitoring/mongodb_exporter

## Задание со *
Добавьте в Prometheus мониторинг сервисов comment, post, ui с
помощью blackbox экспортера. 
Данное задание оставляю на потом по причине отставания и необходимости нагнать программу.

## Задание со *
Как вы могли заметить, количество компонент, для которых необходимо
делать билд образов, растет. И уже сейчас делать это вручную не очень
удобно.
Можно было бы конечно написать скрипт для автоматизации таких действий.
Но гораздо лучше для этого использовать Makefile. 
Данное задание оставляю на потом по причине отставания и необходимости нагнать программу.

# HW 21. Мониторинг приложения и инфраструктуры 
Мониторинг приложения и инфраструктуры

Создадим Docker хост в GCE и настроим локальное окружение на
работу с ним.

## Подготовка окружения 

### Terraform:

Вообще все в облаке должно быть в коде.
В sgremyachikh_microservices/terraform/bucket_creation/ - там создание бакета в проекте GCE. 

В sgremyachikh_microservices/terraform/for_docker_homeworks/ - код проапгрейжен модулем firewall, создаст стейт инфраструктуры в бакете, созданные правила для 22, 9090, 9292 портов в облаке для провижена, ключи для ssh в GCE,. Так как все должнобыть *aaC.

### docker-machine:

В директории docker-machine-scripts скрипт развертыввния среды разработки ДЗ и скрипт свертывания. 

## Мониторинг Docker контейнеров
Разделим файлы Docker Compose:
В данный момент и мониторинг и приложения у нас описаны в
одном большом docker-compose.yml. С одной стороны это просто,
а с другой - мы смешиваем различные сущности, и сам файл быстро
растет.
Оставим описание приложений в docker-compose.yml, а
мониторинг выделим в отдельный файл docker-composemonitoring.yml.
Для запуска приложений будем как и ранее использовать
docker-compose up -d, а для мониторинга - docker-compose -f
docker-compose-monitoring.yml up -d

Листинги:
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
          - comment_db

  ui:
    image: ${USERNAME:-decapapreta}/ui:${UI_VER:-1.0}
    ports:
    - protocol: tcp
      published: ${UI_PORT:-9292}
      target: 9292
    networks:
      front_net:
        aliases:
          - ui

  post:
    image: ${USERNAME:-decapapreta}/post:${POST_VER:-1.0}
    networks:
      back_net:
        aliases:
          - post
      front_net:
        aliases:
          - post

  comment:
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
и
```
version: '3.3'
services:
  prometheus:
    image: ${USERNAME}/prometheus
    networks:
      back_net:
        aliases:
          - prom
      front_net:
        aliases:
          - prom
    ports:
      - '9090:9090'
    volumes:
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention=1d'

  node-exporter:
    image: prom/node-exporter:v0.15.2
    networks:
      back_net:
        aliases:
          - node-exporter
      front_net:
        aliases:
          - node-exporter
    user: root
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.ignored-mount-points="^/(sys|proc|dev|host|etc)($$|/)"'

  mongodb-exporter:
    image: ${USERNAME:-decapapreta}/mongodb-exporter:${MONGODB_EXPORTER_VERSION:-v2019.12.14}
    networks:
      - back_net
    environment:
      MONGODB_URI: "mongodb://post_db:27017"

volumes:
  prometheus_data:

networks:
  front_net:
  back_net:

```
Сделал это и проверил на всякий случай. что работают нормально.

## cAdvisor
Мы будем использовать для
наблюдения за состоянием наших Docker
контейнеров.
cAdvisor собирает информацию о ресурсах потребляемых
контейнерами и характеристиках их работы.
Примерами метрик являются:
процент использования контейнером CPU и памяти, выделенные
для его запуска,
объем сетевого трафика
и др.

### В Файл docker-compose-monitoring.yml
cAdvisor также будем запускать в контейнере. Для этого
добавим новый сервис в наш компоуз файл мониторинга dockercompose-monitoring.yml ( ).
Поместите данный сервис в одну сеть с Prometheus, чтобы тот
мог собирать с него метрики.

```
services:
...
  cadvisor:
    image: google/cadvisor:v0.29.0
    networks:
      back_net:
        aliases:
          - cadvisor
      front_net:
        aliases:
          - cadvisor
    volumes:
      - '/:/rootfs:ro'
      - '/var/run:/var/run:rw'
      - '/sys:/sys:ro'
      - '/var/lib/docker/:/var/lib/docker:ro'
    ports:
      - '8080:8080'
```
### Файл prometheus.yml
Добавим информацию о новом сервисе в конфигурацию
Prometheus, чтобы он начал собирать метрики:
Пересоберем образ Prometheus с обновленной конфигурацией:
scrape_configs:
...
- job_name: 'cadvisor'
static_configs:
- targets:
- 'cadvisor:8080'
$ export USER_NAME=username # где username - ваш логин на Docker Hub
$ docker build -t $USER_NAME/prometheus .

### cAdvisor UI
Запустим сервисы:
cAdvisor имеет UI, в котором отображается собираемая о
контейнерах информация.
Откроем страницу Web UI по адресу http://<docker-machinehost-ip>:8080

### cAdvisor UI

Полазил. посмотрел, классно.

Нажмите ссылку Docker Containers (внизу слева) для просмотра
информации по контейнерам
В UI мы можем увидеть: список контейнеров, запущенных на хосте
информацию о хосте (секция Driver Status)
информацию об образах контейнеров (секция Images)

Нажмем на название одного из контейнеров, чтобы посмотреть
информацию о его работе:
```
Subcontainers
dockermicroservices_mongodb-exporter_1 (/docker/586bbe5ce2e6c19663b578b8421cd32d0cc023c8dc45afeaa380d7d26b69997b)
dockermicroservices_post_1 (/docker/af2b365ffa86fe10b3403b453e050ab06bbb5c6995df86d6ced9e3e134ddde5c)
dockermicroservices_cadvisor_1 (/docker/df32f7ba62c9f286d7379446dc190a78792271f29fd45402955a332a369392cb)
dockermicroservices_post_db_1 (/docker/f17c928f2a7c3e49eccdd62b7c6dfc56d5a030bb1c77449771321b4019b35e8a)
dockermicroservices_comment_1 (/docker/7b2c417263d40dbb71dd64c2263a681276c05c5204d8704c1a40b10c856b58be)
dockermicroservices_node-exporter_1 (/docker/0edc9754bdfbb63e2fcea0e41262213b348a891bb18e3e7e10b162ff20e85ee0)
dockermicroservices_ui_1 (/docker/252f323206d24e052690b26ca9adacf7fd90f57b64b6df64506a235c77824527)
dockermicroservices_prometheus_1 (/docker/d8df91f6378f7ecbe73a8fc0aed33857ea0f6ee4b1307142297b23c57a4d81db)
```
По пути /metrics все собираемые метрики публикуются для
сбора Prometheus:
```
# HELP cadvisor_version_info A metric with a constant '1' value labeled by kernel version, OS version, docker version, cadvisor version & cadvisor revision.
# TYPE cadvisor_version_info gauge
cadvisor_version_info{cadvisorRevision="aaaa65d",cadvisorVersion="v0.29.0",dockerVersion="19.03.5",kernelVersion="5.3.15-300.fc31.x86_64",osVersion="Alpine Linux v3.4"} 1
# HELP container_cpu_load_average_10s Value of container cpu load average over the last 10 seconds.
# TYPE container_cpu_load_average_10s gauge
container_cpu_load_average_10s{container_label_com_docker_compose_config_hash="",container_label_com_docker_compose_container_number="",container_label_com_docker_compose_oneoff="",container_label_com_docker_compose_project="",container_label_com_docker_compose_service="",container_label_com_docker_compose_version="",container_label_maintainer="",id="/",image="",name=""} 0
...
```
Видим, что имена метрик контейнеров начинаются со слова container

### Проверим, что метрики контейнеров собираются Prometheus.
Введем, слово container и посмотрим, что он предложит
дополнить, а будет там дофига.

### Визуализация метрик: Grafana

Тормозну мониторинг 
```
docker-compose -f docker-compose-monitoring.yml down 
```
Используем инструмент Grafana для визуализации данных из
Prometheus.
Добавим новый сервис в docker-compose-monitoring.yml

```
services:
...
  grafana:
    image: grafana/grafana:5.0.0
    networks:
      back_net:
        aliases:
          - grafana
    volumes:
      - grafana_data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=secret
    depends_on:
      - prometheus
    ports:
      - '3000:3000'
...
volumes:
  prometheus_data:
  grafana_data:
```
### Grafana: Web UI
Запустим новый сервис мониторинга:
```
docker-compose -f docker-compose-monitoring.yml up -d 
```
Откроем страницу Web UI Grafana по адресу http://<dockermachine-host-ip>:3000 и используем для входа логин и пароль
администратора, которые мы передали через переменные
окружения
>      - GF_SECURITY_ADMIN_USER=admin
>      - GF_SECURITY_ADMIN_PASSWORD=secret
Grafana: Добавление источника данных
Нажмем Add data source (Добавить источник данных)

### Grafana: Добавление источника данных
Зададим нужный тип и параметры подключения:
Name: Prometheus Server
Type: Prometheus
URL: http://<IP>:9090/
Access: Proxy
И затем нажмем Add

### Дашборды
Перейдем на https://grafana.com/dashboards, где можно найти и скачать большое
количество уже созданных официальных и комьюнити дашбордов
для визуализации различного типа метрик для разных систем
мониторинга и баз данных
Дашборды

Выберем в качестве источника данных нашу систему
мониторинга (Prometheus) и выполним поиск по категории Docker.
Затем выберем популярный дашборд

Нажмем Загрузить JSON. В директории monitoring создайте
директории grafana/dashboards, куда поместите скачанный
дашборд. Поменяйте название файла дашборда на
DockerMonitoring.json

Импорт дашборда
Снова откроем веб-интерфейс
Grafana и выберем импорт шаблона
(Import)
Загрузите скачанный дашборд. При загрузке укажите источник
данных для визуализации (Prometheus Server)
Должен появиться набор графиков с информацией о состоянии
хостовой системы и работе контейнеров

### Мониторинг работы приложения
В качестве примера метрик приложения в сервис UI 
https://github.com/express42/reddit/commit/e443f6ab4dcf25f343f2a50c01916d750fc2d096:
счетчик ui_request_count, который считает каждый приходящий
HTTP-запрос (добавляя через лейблы такую информацию как
HTTP метод, путь, код возврата, мы уточняем данную метрику)
гистограмму ui_request_latency_seconds, которая позволяет
отслеживать информацию о времени обработки каждого запроса

Мониторинг работы приложения
В качестве примера метрик приложения в сервис Post
https://github.com/express42/reddit/commit/d8a0316c36723abcfde367527bad182a8e5d9cf2:
Гистограмму post_read_db_seconds, которая позволяет
отследить информацию о времени требуемом для поиска поста в
БД

Зачем?
Созданные метрики придадут видимости работы нашего
приложения и понимания, в каком состоянии оно сейчас находится.
Например, время обработки HTTP запроса не должно быть
большим, поскольку это означает, что пользователю приходится
долго ждать между запросами, и это ухудшает его общее
впечатление от работы с приложением. Поэтому большое время
обработки запроса будет для нас сигналом проблемы.
Отслеживая приходящие HTTP-запросы, мы можем, например,
посмотреть, какое количество ответов возвращается с кодом
ошибки. Большое количество таких ответов также будет служить
для нас сигналом проблемы в работе приложения.

### prometheus.yml
Добавим информацию о post-сервисе в конфигурацию
Prometheus, чтобы он начал собирать метрики и с него:
```
scrape_configs:
...
- job_name: 'post'
  static_configs:
    - targets:
      - 'post:5000'
```
Пересоберем образ Prometheus с обновленной конфигурацией
```
docker build -t decapapreta/prometheus .
docker push decapapreta/prometheus
docker-compose -f docker-compose-monitoring.yml down
docker-compose -f docker-compose-monitoring.yml up -d
```
И добавим несколько постов в приложении и несколько
комментов, чтобы собрать значения метрик приложения.

### Построим графики собираемых метрик приложения
Построим графики собираемых метрик приложения. Выберем
создать новый дашборд:
Снова откроем вебинтерфейс Grafana и
выберем создание
шаблона (Dashboard)

1. Выбираем "Построить график" (New Panel ➡ Graph)
2. Жмем один раз на имя графика (Panel Title), затем выбираем Edit

Построим для начала простой график изменения счетчика
HTTP-запросов по времени. Выберем источник данных и в поле
запроса введем название метрики  ui_request_count:
Далее достаточно нажать мышкой на любое место UI, чтобы
убрать курсор из поля запроса, и Grafana выполнит запрос и
построит график

В правом верхнем углу мы можем уменьшить временной
интервал, на котором строим график, и настроить автообновление
данных

Сейчас мы с вами получили график различных HTTP запросов,
поступающих UI сервису
```
rate(ui_request_count{job="ui"}[1m])
```
Изменим заголовок графика и описание

Сохраним созданный дашборд UI HTTP Requests

### Построим график запросов, которые возвращают код ошибки
Построим график запросов, которые возвращают код ошибки
на этом же дашборде. Добавим еще один график на наш дашборд:
Переходим в режим правки графика

В поле запросов запишем выражение для поиска всех http
запросов, у которых код возврата начинается либо с 4 либо с 5
(используем регулярное выражения для поиска по лейблу). Будем
использовать функцию rate(), чтобы посмотреть не просто значение
счетчика за весь период наблюдения, но и скорость увеличения
данной величины за промежуток времени (возьмем, к примеру 1-
минутный интервал, чтобы график был хорошо видим)
```
rate(ui_request_count{http_status=~"^[45].*"}[1m])
```
График ничего не покажет, если не было запросов с ошибочным
кодом возврата. Для проверки правильности нашего запроса
обратимся по несуществующему HTTP пути, например,
http://IP:9292/nonexistent, чтобы получить код ошибки 404 в ответ на
наш запрос
Проверим график (временной промежуток можно уменьшить
для лучшей видимости графика)
Добавьте заголовок и описание графика и нажмите сохранить
изменения дашборда

### Grafana поддерживает версионирование дашбордов
Grafana поддерживает версионирование дашбордов, именно
поэтому при сохранении нам предлагалось ввести сообщение,
поясняющее изменения дашборда. Вы можете посмотреть историю
изменений своего

### Гистограмма
Гистограмма представляет собой графический способ
представления распределения вероятностей некоторой случайной
величины на заданном промежутке значений. Для построения
гистограммы берется интервал значений, который может
принимать измеряемая величина и разбивается на промежутки
(обычно одинаковой величины), данные промежутки помечаются на
горизонтальной оси X. Затем над каждым интервалом рисуется
прямоугольник, высота которого соответствует числу измерений
величины, попадающих в данный интервал.
Простым примером гистограммы может быть распределение
оценок за контрольную в классе, где учится 21 ученик. Берем
промежуток возможных значений (от 1 до 5) и разбиваем на равные
интервалы. Затем на каждом интервале рисуем столбец, высота
которого соответсвует частоте появлению данной оценки.

В Prometheus есть тип метрик histogram. Данный тип метрик в
качестве своего значение отдает ряд распределения измеряемой
величины в заданном интервале значений. Мы используем данный
тип метрики для измерения времени обработки HTTP запроса
нашим приложением.

Histogram метрика
Рассмотрим пример гистограммы в Prometheus. Посмотрим
информацию по времени обработки запроса приходящих на
главную страницу приложения.
ui_request_latency_seconds_bucket{path="/"}

Эти значения означают, что запросов с временем обработки <=
0.025s было 3 штуки, а запросов 0.01 <= 0.01s было 7 штук (в этот
столбец входят 3 запроса из предыдущего столбца и 4 запроса из
промежутка [0.025s; 0.01s], такую гистограмму еще называют
кумулятивной). Запросов, которые бы заняли > 0.01s на обработку
не было, поэтому величина всех последующих столбцов равна 7

### Процентиль
Числовое значение в наборе значений
Все числа в наборе меньше процентиля, попадают в границы
заданного процента значений от всего числа значений в
наборе.

#### Пример процентиля
В классе 20 учеников. Ваня занимает 4-е место по росту в
классе. Тогда рост Вани (180 см) является 80-м процентилем. Это
означает, что 80 % учеников имеют рост менее 180 см.

#### 95-й процентиль
Часто для анализа данных мониторинга применяются значения
90, 95 или 99-й процентиля.
Мы вычислим 95-й процентиль для выборки времени обработки
запросов, чтобы посмотреть какое значение является
максимальной границей для большинства (95%) запросов. Для
этого воспользуемся встроенной функцией histogram_quantile()

Добавьте третий по счету график на ваш дашборд. В поле
запроса введите следующее выражение для вычисления 95
процентиля времени ответа на запрос (gist)
```
histogram_quantile(0.95, sum(rate(ui_request_response_time_bucket[5m]))by(le))
```
Мой вариант отличается от того, что на скрине.


Сохраним изменения дашборда и эспортируем его в JSON файл,
который загрузим на нашу локальную машину

## Сбор метрик бизнеслогики

### Мониторинг бизнес-логики
В качестве примера метрик бизнес логики мы в наше
приложение мы добавили счетчики количества постов и
комментариев
post_count
comment_count
Мы построим график скорости роста значения счетчика за
последний час, используя функцию rate(). Это позволит нам
получать информацию об активности пользователей приложения

1. Создайте новый дашборд, назовите его Business_Logic_Monitoring
и постройте график функции rate(post_count[1h])

2. Постройте еще один график для счетчика comment,
экспортируйте дашборд и сохраните в директории
monitoring/grafana/dashboards под названием
Business_Logic_Monitoring.json.

## Алертинг

### Правила алертинга
Мы определим несколько правил, в которых зададим условия
состояний наблюдаемых систем, при которых мы должны получать
оповещения, т.к. заданные условия могут привести к недоступности
или неправильной работе нашего приложения.
P.S. Стоит заметить, что в самой Grafana тоже есть alerting. Но по
функционалу он уступает Alertmanager в Prometheus.

### Alertmanager
Alertmanager - дополнительный компонент для системы
мониторинга Prometheus, который отвечает за первичную
обработку алертов и дальнейшую отправку оповещений по
заданному назначению.
Создайте новую директорию monitoring/alertmanager. В этой
директории создайте Dockerfile со следующим содержимым:
FROM prom/alertmanager:v0.14.0
ADD config.yml /etc/alertmanager/

Настройки Alertmanager-а как и Prometheus задаются через
YAML файл или опции командой строки. В директории
monitoring/alertmanager создайте файл config.yml, в котором
определите отправку нотификаций в ВАШ тестовый слак канал.
Для отправки нотификаций в слак канал потребуется создать
СВОЙ https://api.slack.com/messaging/webhooks в monitoring/alertmanager/config.yml

```
global:
  slack_api_url: 'https://hooks.slack.com/services/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'

route:
  receiver: 'slack-notifications'

receivers:
- name: 'slack-notifications'
  slack_configs:
  - channel: '#svetozar_gremyachikh'
```

1. Соберем образ alertmanager:
2. Добавим новый сервис в компоуз файл мониторинга. Не забудьте
добавить его в одну сеть с сервисом Prometheus:
```
monitoring/alertmanager $ docker build -t decapapreta/alertmanager . && docker push decapapreta/alertmanager
```
```
services:
...
  alertmanager:
    image: ${USERNAME}/alertmanager
    networks: 
      front_net:
        aliases: 
          - alertmanager
    command:
      - '--config.file=/etc/alertmanager/config.yml'
    ports:
      - "9093:9093"
```
### Alert rules
Создадим файл alerts.yml в директории prometheus, в котором
определим условия при которых должен срабатывать алерт и
посылаться Alertmanager-у. Мы создадим простой алерт, который
будет срабатывать в ситуации, когда одна из наблюдаемых систем
(endpoint) недоступна для сбора метрик (в этом случае метрика up с
лейблом instance равным имени данного эндпоинта будет равна
нулю). Выполните запрос по имени метрики up в веб интерфейсе
Prometheus, чтобы убедиться, что сейчас все эндпоинты доступны
для сбора метрик

Все инстансы отдают -1 , а соответственно доступны.

Запилим:
в monitoring/prometheus/alerts.yml 
```
groups:
  - name: alert.rules
    rules:
    - alert: InstanceDown
      expr: up == 0
      for: 1m
      labels:
        severity: page
      annotations:
        description: '{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 1 minute'
        summary: 'Instance {{ $labels.instance }} down'
```
Добавим операцию копирования данного файла в Dockerfile:
```
monitoring/prometheus/Dockerfile
FROM prom/prometheus:v2.1.0
ADD prometheus.yml /etc/prometheus/
ADD alerts.yml /etc/prometheus/
```
#### Далее в prometheus.yml
Добавим информацию о правилах, в конфиг Prometheus
```
rule_files:
  - "alerts.yml"

alerting:
  alertmanagers:
  - scheme: http
    static_configs:
    - targets:
      - "alertmanager:9093"

```
пересобираем образ прома
```
docker build -t decapapreta/prometheus .
docker push decapapreta/prometheus
```
### Проверка алерта
Пересоздадим нашу Docker инфраструктуру мониторинга:
```
docker-compose -f docker-compose-monitoring.yml down
docker-compose -f docker-compose-monitoring.yml up -d
```
Алерты можно посмотреть в веб интерфейсе Prometheus:


InstanceDown (0 active)
alert: InstanceDown
expr: up == 0
for: 1m
labels:
  severity: page
annotations:
  description: '{{ $labels.instance }} of job {{ $labels.job }} has been down for
    more than 1 minute'
  summary: Instance {{ $labels.instance }} down

### Проверка алерта
Остановим один из сервисов
```
docker-compose stop post
```
подождем одну минуту

В канал должно придти сообщение:
```
prometheusAPP 12:36 AM
[FIRING:1] InstanceDown (post:5000 post page)
```
У Alertmanager также есть свой веб интерфейс, доступный на
порту 9093, который мы прописали в компоуз файле.
P.S. Проверить работу вебхуков слака можно обычным curl, но не потребовалось.

### Завершение работы
Запушьте собранные вами образы на DockerHub:
```
$ docker login
Login Succeeded
$ docker push $USER_NAME/ui
$ docker push $USER_NAME/comment
$ docker push $USER_NAME/post
$ docker push $USER_NAME/prometheus
$ docker push $USER_NAME/alertmanager
```
https://hub.docker.com/u/decapapreta

### Задания со *

Задания со звездочками откладываю от нехватки времени к сожалению на потом.

------------------------------------------------------------
# HW 23. Применение системы логирования в инфраструктуре на основе Docker

План

Сбор неструктурированных логов
Визуализация логов
Сбор структурированных логов
Распределенная трасировка

## Подготовка

Код микросервисов обновился для добавления функционала логирования

Обновите код в директории **/src** вашего репозитория из кода по ссылке выше.
Если вы используется python-alpine, добавьте в **/src/post-py/Dockerfile** установку
пакетов gcc и musl-dev
Выполните сборку образов при помощи скриптов docker_build.sh в директории
каждого сервиса.

```
export USER_NAME=decapapreta

# in /src/comment
chmod +x ./docker_build.sh
./docker_build.sh
docker push decapapreta/comment:logging

# in /src/post
chmod +x ./docker_build.sh
./docker_build.sh
docker push decapapreta/post:logging

# in /src/ui
chmod +x ./docker_build.sh
./docker_build.sh
docker push decapapreta/ui:logging
```
## Подготовка окружения

```
export GOOGLE_PROJECT=docker-258020
docker-machine create --driver google \
    --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
    --google-machine-type n1-standard-1 \
    --google-open-port 5601/tcp \
    --google-open-port 9292/tcp \
    --google-open-port 9411/tcp \
    logging

# configure local env
eval $(docker-machine env logging)

# узнаем IP адрес
docker-machine ip logging
```
## Логирование Docker контейнеров

### ElasticSearch (TSDB и поисковый движок для хранения данных)

Как упоминалось на лекции хранить все логи стоит
централизованно: на одном (нескольких) серверах. В этом ДЗ мы
рассмотрим пример системы централизованного логирования на
примере Elastic стека (ранее известного как ELK): который включает
в себя 3 осовных компонента:

* ElasticSearch (TSDB и поисковый движок для хранения данных)
* Logstash (для агрегации и трансформации данных)
* Kibana (для визуализации)

Однако для агрегации логов вместо Logstash мы будем
использовать Fluentd, таким образом получая еще одно
популярное сочетание этих инструментов, получившее название
EFK

#### docker-compose-logging.yml

Создадим отдельный compose-файл для нашей системы
логирования в папке docker/

```
version: '3'
services:
  fluentd:
    image: ${USERNAME}/fluentd
    ports:
      - "24224:24224"
      - "24224:24224/udp"

  elasticsearch:
    image: elasticsearch:7.4.0
    expose:
      - 9200
    ports:
      - "9200:9200"

  kibana:
    image: kibana:7.4.0
    ports:
      - "5601:5601"
```
### Fluentd

Fluentd инструмент, который может использоваться для
отправки, агрегации и преобразования лог-сообщений. Мы будем
использовать Fluentd для агрегации (сбора в одной месте) и
парсинга логов сервисов нашего приложения

Создадим образ Fluentd с нужной нам конфигурацией.

Создайте в вашем проекте microservices директорию
logging/fluentd

В созданной директорий, создайте простой Dockerfile со
следущим содержимым:

```
FROM fluent/fluentd:v0.12
RUN gem install fluent-plugin-elasticsearch --no-rdoc --no-ri --version 1.9.5
RUN gem install fluent-plugin-grok-parser --no-rdoc --no-ri --version 1.0.0
ADD fluent.conf /fluentd/etc
```
В директории logging/fluentd создайте файл конфигурации:
logging/fluentd/fluent.conf

```
<source>
  @type forward
  port 24224
  bind 0.0.0.0
</source>

<match *.**>
  @type copy
  <store>
    @type elasticsearch
    host elasticsearch
    port 9200
    logstash_format true
    logstash_prefix fluentd
    logstash_dateformat %Y%m%d
    include_tag_key true
    type_name access_log
    tag_key @log_name
    flush_interval 1s
  </store>
  <store>
    @type stdout
  </store>
</match>
```
Соберите docker image для fluentd
Из директории logging/fluentd

```
docker build -t $USER_NAME/fluentd .
docker push decapapreta/fluentd
```
#### Структурированные логи

Логи должны иметь заданную (единую) структуру и содержать
необходимую для нормальной эксплуатации данного сервиса
информацию о его работе
Лог-сообщения также должны иметь понятный для выбранной
системы логирования формат, чтобы избежать ненужной траты
ресурсов на преобразование данных в нужный вид.
Структурированные логи мы рассмотрим на примере сервиса post

Правим .env файл и меняем теги нашего приложения на logging
Запустите сервисы приложения

```
docker-compose up -d
docker-compose -f docker-compose-monitoring.yml up -d
docker-compose logs -f post
```
Внимание! Среди логов можно наблюдать проблемы с
доступностью Zipkin, у нас он пока что и правда не установлен.
Ошибки можно игнорировать.

Каждое событие, связанное с работой нашего приложения
логируется в JSON формате и имеет нужную нам структуру: тип
события (event), сообщение (message), переданные функции
параметры (params), имя сервиса (service) и др.

#### Отправка логов во Fluentd

Как отмечалось на лекции, по умолчанию Docker контейнерами
используется json-file драйвер для логирования информации,
которая пишется сервисом внутри контейнера в stdout (и stderr).

Для отправки логов во Fluentd используем docker драйвер fluentd
подробнее на https://docs.docker.com/config/containers/logging/fluentd/

Определим драйвер для логирования для сервиса post внутри
compose-файла:

```
version: '3.3'
services:
...
  post:
    image: ${USERNAME:-decapapreta}/post:${POST_VER:-1.0}
    environment:
      - POST_DATABASE_HOST=post_db
      - POST_DATABASE=posts
    networks:
      back_net:
        aliases:
          - post
      front_net:
        aliases:
          - post
    depends_on:
      - post_db
    ports:
      - "5000:5000"
    logging:
      driver: "fluentd"
      options:
        fluentd-address: localhost:24224
        tag: service.post
...
```
#### Сбор логов Post сервиса

Поднимем инфраструктуру централизованной системы
логирования и перезапустим сервисы приложения Из каталога
docker

### Kibana (для визуализации)

Kibana - инструмент для визуализации и анализа логов от
компании Elastic.
Откроем WEB-интерфейс Kibana для просмотра собранных в
ElasticSearch логов Post-сервиса (kibana слушает на порту 5601)

Кибана не поднялась и писала 
```
Kibana server is not ready yet
```
посмотрел в
```
docker-compose -f docker-compose-logging.yml logs -f kibana
```
увидел, что кибана не может в эластик:
```
kibana_1         | {"type":"log","@timestamp":"2019-12-24T21:26:39Z","tags":["warning","elasticsearch","admin"],"pid":6,"message":"No living connections"}
kibana_1         | {"type":"log","@timestamp":"2019-12-24T21:26:41Z","tags":["warning","elasticsearch","admin"],"pid":6,"message":"Unable to revive connection: http://elasticsearch:9200/"}
```
тормознул композ и логгинга и основной. запустил только логгинг без -d чтоб видеть логи и увидел, как упал флюентд:
```
elasticsearch_1  | ERROR: [2] bootstrap checks failed
elasticsearch_1  | [1]: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
elasticsearch_1  | [2]: the default discovery settings are unsuitable for production use; at least one of [discovery.seed_hosts, discovery.seed_providers, cluster.initial_master_nodes] must be configured
elasticsearch_1  | {"type": "server", "timestamp": "2019-12-24T21:41:12,893Z", "level": "INFO", "component": "o.e.n.Node", "cluster.name": "docker-cluster", "node.name": "4861c37ce902", "message": "stopping ..." }
elasticsearch_1  | {"type": "server", "timestamp": "2019-12-24T21:41:12,918Z", "level": "INFO", "component": "o.e.n.Node", "cluster.name": "docker-cluster", "node.name": "4861c37ce902", "message": "stopped" }
elasticsearch_1  | {"type": "server", "timestamp": "2019-12-24T21:41:12,919Z", "level": "INFO", "component": "o.e.n.Node", "cluster.name": "docker-cluster", "node.name": "4861c37ce902", "message": "closing ..." }
elasticsearch_1  | {"type": "server", "timestamp": "2019-12-24T21:41:13,003Z", "level": "INFO", "component": "o.e.n.Node", "cluster.name": "docker-cluster", "node.name": "4861c37ce902", "message": "closed" }
elasticsearch_1  | {"type": "server", "timestamp": "2019-12-24T21:41:13,013Z", "level": "INFO", "component": "o.e.x.m.p.NativeController", "cluster.name": "docker-cluster", "node.name": "4861c37ce902", "message": "Native controller process has stopped - no new native processes can be started" }
dockermicroservices_elasticsearch_1 exited with code 78

```
Некрасиво, но действенно:
```
docker-machine ssh logging
sudo su
sysctl -w vm.max_map_count=262144
```
перезапустил чисто композ логгирования для проверки по stdout-у, но беда не пришла одна:

```
elasticsearch_1  | ERROR: [1] bootstrap checks failed
elasticsearch_1  | [1]: the default discovery settings are unsuitable for production use; at least one of [discovery.seed_hosts, discovery.seed_providers, cluster.initial_master_nodes] must be configured
elasticsearch_1  | {"type": "server", "timestamp": "2019-12-24T22:08:36,581Z", "level": "INFO", "component": "o.e.n.Node", "cluster.name": "docker-cluster", "node.name": "bc7b59b8ac0a", "message": "stopping ..." }
elasticsearch_1  | {"type": "server", "timestamp": "2019-12-24T22:08:36,634Z", "level": "INFO", "component": "o.e.n.Node", "cluster.name": "docker-cluster", "node.name": "bc7b59b8ac0a", "message": "stopped" }
elasticsearch_1  | {"type": "server", "timestamp": "2019-12-24T22:08:36,635Z", "level": "INFO", "component": "o.e.n.Node", "cluster.name": "docker-cluster", "node.name": "bc7b59b8ac0a", "message": "closing ..." }
elasticsearch_1  | {"type": "server", "timestamp": "2019-12-24T22:08:36,702Z", "level": "INFO", "component": "o.e.n.Node", "cluster.name": "docker-cluster", "node.name": "bc7b59b8ac0a", "message": "closed" }
elasticsearch_1  | {"type": "server", "timestamp": "2019-12-24T22:08:36,705Z", "level": "INFO", "component": "o.e.x.m.p.NativeController", "cluster.name": "docker-cluster", "node.name": "bc7b59b8ac0a", "message": "Native controller process has stopped - no new native processes can be started" }
dockermicroservices_elasticsearch_1 exited with code 78
```
гугл:
https://discuss.elastic.co/t/problems-with-access-to-elasticsearch-form-outside-machine/172450
https://www.elastic.co/blog/a-new-era-for-cluster-coordination-in-elasticsearch
https://www.elastic.co/guide/en/elasticsearch/reference/current/discovery-settings.html
https://docs.fluentd.org/container-deployment/docker-compose

допил композа енвайронметом эластика

```
...
  elasticsearch:
    image: elasticsearch:7.4.0
    expose:
      - 9200
    ports:
      - "9200:9200"
    environment: 
      - discovery.type=single-node
...
```
Слышал, что народ обновлял версию эластика и плагинов, но не стал играть с этим.

#### Открыл http://35.222.122.106:5601/app/kibana#/home?_g=() и увидел что кибане хорошо)

Далее по наитию(методичка не актуальна):

SPACES
Organize your dashboards and other saved objects into meaningful categories.
Manage spaces

там

Kibana
Index Patterns
Create index pattern
Kibana uses index patterns to retrieve data from Elasticsearch indices for things like visualizations
Step 1 of 2: Define index pattern
```
fluentd-*
```
и на следующем шаге Time Filter field name: @timestamp

Теперь при нажатии Discover можно увидеть много интересного.
В лефой колонке сделал фильтр container_name is dockermicroservices_post_1 чтоб отфильтровать сообщения данного контейнера в логах.

Видим лог-сообщение, которые мы недавно наблюдали в
терминале. Теперь эти лог-сообщения хранятся централизованно в
ElasticSearch. Также видим доп. информацию о том, откуда поступил
данный лог.

```
Expanded document
View surrounding documents
View single document

Table

JSON
	t@log_name	service.post
	@timestamp	Dec 25, 2019 @ 02:07:26.000
	t_id	w_4qOm8BETWVmJddSFwD
	t_index	fluentd-20191224
	#_score	 - 
	t_type	access_log
	tcontainer_id	7ef9d291009e0f52ee7b05414ba63f448924b62037feb46398b836fc85809bd6
	tcontainer_name	/dockermicroservices_post_1
	tlog	{"event": "post_create", "level": "info", "message": "Successfully created a new post", "params": {"link": "https://www.linux.org.ru/forum/general/14663042", "title": "23452345"}, "request_id": "eafaff97-a7d0-4783-a1fc-f64c3274a35f", "service": "post", "timestamp": "2019-12-24 23:07:26"}
	tsource	stdout
```
Обратим внимание на то, что наименования в левом столбце,
называются полями. По полям можно производить поиск для
быстрого нахождения нужной информации

Для того чтобы посмотреть некоторые примеры поиска, можно
ввести в поле поиска произвольное выражение, например 
```
log :Successfully*
```
получу в результатах:
```
Dec 25, 2019 @ 02:07:26.000	container_name:/dockermicroservices_post_1 log:{"event": "post_create", "level": "info", "message": "Successfully created a new post", "params": ............

Dec 25, 2019 @ 02:07:26.000	container_name:/dockermicroservices_post_1 log:{"event": "find_all_posts", "level": "info", "message": "Successfully retrieved all posts from the database", "params": ...............

Dec 25, 2019 @ 02:07:20.000	log:{"event": "post_create", "level": "info", "message": "Successfully created a new post", "params": {"link":....................
```
#### Фильтры

Заметим, что поле log содержит в себе JSON объект, который
содержит много интересной нам информации.

Нам хотелось бы выделить эту информацию в поля, чтобы иметь
возможность производить по ним поиск. Например, для того чтобы
найти все логи, связанные с определенным событием (event) или
конкретным сервисов (service).
Мы можем достичь этого за счет использования фильтров для
выделения нужной информации

Добавим фильтр для парсинга json логов, приходящих от post
сервиса, в конфиг fluentd

logging/fluentd/fluent.conf

```
<source>
  @type forward
  port 24224
  bind 0.0.0.0
</source>

<filter service.post>
  @type parser
  format json
  key_name log
</filter>

<match *.**>
  @type copy
  <store>
    @type elasticsearch
    host elasticsearch
    port 9200
    logstash_format true
    logstash_prefix fluentd
    logstash_dateformat %Y%m%d
    include_tag_key true
    type_name access_log
    tag_key @log_name
    flush_interval 1s
  </store>
  <store>
    @type stdout
  </store>
</match> 
```

>logging/fluentd $ docker build -t $USER_NAME/fluentd
>docker/ $ docker-compose -f docker-compose-logging.yml up -d fluentd

После этого персоберите образ и перезапустите сервис fluentd
Создадим пару новых постов, чтобы проверить парсинг логов

Взглянем на одно из сообщений и увидим, что вместо одного
поля log появилось множество полей с нужной нам информацией

Выполним для пример поиск по событию создания нового поста

event:post_create и найдем данные логи

### Неструктурированные логи

Неструктурированные логи отличаются отсутствием четкой
структуры данных. Также часто бывает, что формат лог-сообщений
не подстроен под систему централизованного логирования, что
существенно увеличивает затраты вычислительных и временных
ресурсов на обработку данных и выделение нужной информации.

На примере сервиса ui мы рассмотрим пример логов с
неудобным форматом сообщений.

#### Логирование UI сервиса

По аналогии с post сервисом определим для ui сервиса драйвер
для логирования fluentd в compose-файле

```

  ui:
    image: ${USERNAME:-decapapreta}/ui:${UI_VER:-1.0}
    environment:
      - POST_SERVICE_HOST=post
      - POST_SERVICE_PORT=5000
      - COMMENT_SERVICE_HOST=comment
      - COMMENT_SERVICE_PORT=9292
    ports:
    - protocol: tcp
      published: ${UI_PORT:-9292}
      target: 9292
    networks:
      front_net:
        aliases:
          - ui
    depends_on:
      - post
    logging:
      driver: "fluentd"
      options:
        fluentd-address: localhost:24224
        tag: service.ui
```
Перезапустим ui сервис Из каталога docker

```
docker-compose stop ui
docker-compose rm ui
docker-compose up -d
```

Посмотрим на формат собираемых сообщений

для этого фильтрану-ка их по @log_name : service.ui

посмотрел на контейнер-нем и лог

#### Парсинг

Когда приложение или сервис не пишет структурированные
логи, приходится использовать старые добрые регулярные
выражения для их парсинга в /docker/fluentd/fluent.conf

Следующее регулярное выражение нужно, чтобы успешно
выделить интересующую нас информацию из лога UI-сервиса в
поля:

```
<filter service.ui>
  @type parser
  format /\[(?<time>[^\]]*)\]  (?<level>\S+) (?<user>\S+)[\W]*service=(?<service>\S+)[\W]*event=(?<event>\S+)[\W]*(?:path=(?<path>\S+)[\W]*)?request_id=(?<request_id>\S+)[\W]*(?:remote_addr=(?<remote_addr>\S+)[\W]*)?(?:method= (?<method>\S+)[\W]*)?(?:response_status=(?<response_status>\S+)[\W]*)?(?:message='(?<message>[^\']*)[\W]*)?/
  key_name log
</filter>
```
тут конечно мы пересоюираем образ:

```
docker build -t $USER_NAME/fluentd .
docker push $USER_NAME/fluentd
```
а далее:

#### Перезапускаем кибану

```
docker-compose -f docker-compose-logging.yml down
docker-compose -f docker-compose-logging.yml up -d
```
парсинг.

Результат должен выглядить следующим образом:

```
{
  "_index": "fluentd-20191225",
  "_type": "access_log",
  "_id": "PNkNP28B4s2MUJnQpqk2",
  "_version": 1,
  "_score": null,
  "_source": {
    "addr": "172.23.0.4",
    "event": "request",
    "level": "info",
    "method": "GET",
    "path": "/healthcheck?",
    "request_id": "294b8039-68d2-426c-9956-1d18958cac53",
    "response_status": 200,
    "service": "post",
    "timestamp": "2019-12-25 21:54:16",
    "@timestamp": "2019-12-25T21:54:16+00:00",
    "@log_name": "service.post"
  },
  "fields": {
    "@timestamp": [
      "2019-12-25T21:54:16.000Z"
    ]
  },
  "sort": [
    1577310856000
  ]
}
```
#### ГРОКИ!

Созданные регулярки могут иметь ошибки, их сложно менять и
невозможно читать. Для облегчения задачи парсинга вместо
стандартных регулярок можно использовать grok-шаблоны. По-сути
grok’и - это именованные шаблоны регулярных выражений (очень
похоже на функции). Можно использовать готовый regexp, просто
сославшись на него как на функцию docker/fluentd/fluent.conf

```
<filter service.ui>
  @type parser
  format grok
  grok_pattern %{RUBY_LOGGER}
  key_name log
</filter>
```
Это grok-шаблон, зашитый в плагин для fluentd. В развернутом
виде он выглядит вот так:
```
%{RUBY_LOGGER} [(?<timestamp>(?>\d\d){1,2}-(?:0?[1-9]|1[0-2])-(?:(?:0[1-9])|(?:[12][0-9])|
(?:3[01])|[1-9])[T ](?:2[0123]|[01]?[0-9]):?(?:[0-5][0-9])(?::?(?:(?:[0-5]?[0-9]|60)(?:
[:.,][0-9]+)?))?(?:Z|[+-](?:2[0123]|[01]?[0-9])(?::?(?:[0-5][0-9])))?) #(?<pid>\b(?:[1-9]
[0-9]*)\b)\] *(?<loglevel>(?:DEBUG|FATAL|ERROR|WARN|INFO)) -- +(?<progname>.*?): (?
<message>.*)
```
часть логов нужно еще
распарсить. Для этого используем несколько Grok-ов по-очереди:

```
<source>
  @type forward
  port 24224
  bind 0.0.0.0
</source>

<filter service.post>
  @type parser
  format json
  key_name log
</filter>

<filter service.ui>
  @type parser
  key_name log
  format grok
  grok_pattern %{RUBY_LOGGER}
</filter>

<filter service.ui>
  @type parser
  format grok
  grok_pattern service=%{WORD:service} \| event=%{WORD:event} \| request_id=%{GREEDYDATA:request_id} \| message='%{GREEDYDATA:message}'
  key_name message
  reserve_data true
</filter>

<match *.**>
  @type copy
  <store>
    @type elasticsearch
    host elasticsearch
    port 9200
    logstash_format true
    logstash_prefix fluentd
    logstash_dateformat %Y%m%d
    include_tag_key true
    type_name access_log
    tag_key @log_name
    flush_interval 1s
  </store>
  <store>
    @type stdout
  </store>
</match>
```
#### В итоге получим в Kibana (если совершаем действия в uiсервисе):

```
t@log_name	service.ui
	@timestamp	Dec 26, 2019 @ 23:50:13.000
	t_id	QBH5Q28BI0sgBIptZfj6
	t_index	fluentd-20191226
	#_score	 - 
	t_type	access_log
	tevent	show_post
	tloglevel	INFO
	tmessage	Successfully showed the post
	tpid	1
	tprogname	
	trequest_id	1399798a-d47d-42bf-906c-9acf164a50ee
	tservice	ui
	ttimestamp	2019-12-26T20:50:13.700335
```

### Распределенный трейсинг

#### Zipkin

Добавьте в compose-файл для сервисов логирования сервис
распределенного трейсинга Zipkin

Правим наш docker/docker-compose-logging.yml

Zipkin должен быть в одной сети с приложениями, поэтому, если
вы выполняли задание с сетями, вам нужно объявить эти сети в
docker-compose-logging.yml и добавить в них zikpkin

```
version: '3.3'
services:

  fluentd:
    image: ${USERNAME}/fluentd
    ports:
      - "24224:24224"
      - "24224:24224/udp"
    networks:
      back_net:
        aliases:
          - fluentd
      front_net:
        aliases:
          - fluentd

  elasticsearch:
    image: elasticsearch:7.4.0
    expose:
      - 9200
    ports:
      - "9200:9200"
    environment: 
      - discovery.type=single-node
    networks:
      back_net:
        aliases:
          - elasticsearch
      front_net:
        aliases:
          - elasticsearch

  kibana:
    image: kibana:7.4.0
    ports:
      - "5601:5601"
    networks:
      back_net:
        aliases:
          - kibana
      front_net:
        aliases:
          - kibana

  zipkin:
    image: openzipkin/zipkin
    ports:
      - "9411:9411"
    networks:
      back_net:
        aliases:
          - zipkin
      front_net:
        aliases:
          - zipkin

networks:
  front_net:
  back_net:
```

Правим наш docker/docker-compose.yml
Добавьте для каждого сервиса поддержку ENV переменных и
задайте параметризованный параметр ZIPKIN_ENABLED"

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
          - comment_db

  ui:
    image: ${USERNAME:-decapapreta}/ui:${UI_VER:-1.0}
    environment:
      POST_SERVICE_HOST: post
      POST_SERVICE_PORT: 5000
      COMMENT_SERVICE_HOST: comment
      COMMENT_SERVICE_PORT: 9292
      ZIPKIN_ENABLED: ${ZIPKIN_ENABLED}
    ports:
    - protocol: tcp
      published: ${UI_PORT:-9292}
      target: 9292
    networks:
      front_net:
        aliases:
          - ui
    depends_on:
      - post
    logging:
      driver: "fluentd"
      options:
        fluentd-address: localhost:24224
        tag: service.ui

  post:
    image: ${USERNAME:-decapapreta}/post:${POST_VER:-1.0}
    environment:
      POST_DATABASE_HOST: post_db
      POST_DATABASE: posts
      ZIPKIN_ENABLED: ${ZIPKIN_ENABLED}
    networks:
      back_net:
        aliases:
          - post
      front_net:
        aliases:
          - post
    depends_on:
      - post_db
    ports:
      - "5000:5000"
    logging:
      driver: "fluentd"
      options:
        fluentd-address: localhost:24224
        tag: service.post

  comment:
    image: ${USERNAME:-decapapreta}/comment:${COMMENT_VER:-1.0}
    environment: 
      ZIPKIN_ENABLED: ${ZIPKIN_ENABLED}
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
Как видно, я изменил оформление энвайронмента с

```
  environment: 
    - ZIPKIN_ENABLED=${ZIPKIN_ENABLED}
```
на
```
    environment: 
      ZIPKIN_ENABLED: ${ZIPKIN_ENABLED}
```
подсмотрел на СО, но так читается переменная,  для этого надо поднять версию композа 3.3 в ямле логгирования, 
а раз запускаю их вместе, то в ОБОИХ до 3,3 с 3 в обоих файлах!

#### Пересоздадим наши сервисы с zipkin

```
docker-compose -f docker-compose-logging.yml -f docker-compose.yml up -d
```

Откроем Zipkin WEB UI http://35.225.35.160:9411/zipkin/

Откроем главную страницу приложения и обновим ее несколько
раз.
Заглянув затем в UI Zipkin (страницу потребуется обновить), мы
должны найти несколько трейсов (следов, которые оставили
запросы проходя через систему наших сервисов).

Нажмем на один из трейсов, чтобы посмотреть, как я запилил коммент и запрос пошел
через нашу систему микросервисов и каково общее время
обработки запроса у нашего приложения при запросе главной
страницы

Увиденное проще описать так:

```
[
  {
    "traceId": "22cb816af0811770",
    "id": "22cb816af0811770",
    "kind": "SERVER",
    "name": "get",
    "timestamp": 1577402551268866,
    "duration": 88691,
    "localEndpoint": {
      "serviceName": "ui_app",
      "ipv4": "192.168.144.8",
      "port": 9292
    },
    "tags": {
      "http.path": "/post/5e052e60580935000ed773f9"
    }
  },
  {
    "traceId": "22cb816af0811770",
    "parentId": "22cb816af0811770",
    "id": "d39cffa57c74459b",
    "kind": "CLIENT",
    "name": "get",
    "timestamp": 1577402551269599,
    "duration": 15122,
    "localEndpoint": {
      "serviceName": "ui_app",
      "ipv4": "192.168.144.8",
      "port": 9292
    },
    "remoteEndpoint": {
      "serviceName": "post",
      "ipv4": "192.168.144.7",
      "port": 5000
    },
    "tags": {
      "http.path": "/post/5e052e60580935000ed773f9",
      "http.status": "200"
    }
  },
  {
    "traceId": "22cb816af0811770",
    "parentId": "22cb816af0811770",
    "id": "a080e512ca6eba95",
    "kind": "CLIENT",
    "name": "get",
    "timestamp": 1577402551285086,
    "duration": 3790,
    "localEndpoint": {
      "serviceName": "ui_app",
      "ipv4": "192.168.144.8",
      "port": 9292
    },
    "remoteEndpoint": {
      "serviceName": "comment",
      "ipv4": "192.168.144.4",
      "port": 9292
    },
    "tags": {
      "http.path": "/5e052e60580935000ed773f9/comments",
      "http.status": "200"
    }
  }
]
```
Повторим немного терминологию: синие полоски со временем
называются span и представляют собой одну операцию, которая
произошла при обработке запроса. Набор span-ов называется
трейсом. Суммарное время обработки нашего запроса равно
верхнему span-у, который включает в себя время всех span-ов,
расположенных под ним.

### Задание со *

1. UI-сервис шлет логи в нескольких форматах.

```
service=ui | event=request | path=/post/5e051cff35afb8000eb226eb/comment | request_id=e8987a5d-9357-4c57-bb16-fbebed2eb8f2 | remote_addr=193.31.192.159 | method= POST | response_status=303
```
Такой лог остался неразобранным. Составьте конфигурацию
fluentd так, чтобы разбирались оба формата логов UI-сервиса (тот,
что сделали до этого и текущий) одновременно.

ВАЖНО! В составе кибаны есть редактор-линтер-дебагер и вообще швейцарский нож:
https://www.elastic.co/guide/en/kibana/current/devtools-kibana.html
https://www.elastic.co/guide/en/kibana/current/console-kibana.html
https://www.elastic.co/guide/en/kibana/current/xpack-grokdebugger.html

по теме гроков погуглено и покурено:
https://docs.fluentd.org/parser
https://github.com/fluent/fluent-plugin-grok-parser
готовые шаблоны:
https://github.com/fluent/fluent-plugin-grok-parser/tree/master/patterns

Результат:
```
<source>
  @type forward
  port 24224
  bind 0.0.0.0
</source>

<filter service.post>
  @type parser
  format json
  key_name log
</filter>

<filter service.ui>
  @type parser
  key_name log
  format grok
  grok_pattern %{RUBY_LOGGER}
</filter>

<filter service.ui>
  @type parser
  format grok
  <grok>
    grok_pattern service=%{WORD:service} \| event=%{WORD:event} \| request_id=%{GREEDYDATA:request_id} \| message='%{GREEDYDATA:message}'
  </grok>
  <grok>
    grok_pattern service=%{WORD:service} \| event=%{WORD:event} \| path=%{URIPATH:path} \| request_id=%{GREEDYDATA:request_id} \| remote_addr='%{IP:remote_addr} \| method=%{WORD:method} \| response_status=%{INT:response_status}'
  </grok>
  key_name message
  reserve_data true
</filter>

<match *.**>
  @type copy
  <store>
    @type elasticsearch
    host elasticsearch
    port 9200
    logstash_format true
    logstash_prefix fluentd
    logstash_dateformat %Y%m%d
    include_tag_key true
    type_name access_log
    tag_key @log_name
    flush_interval 1s
  </store>
  <store>
    @type stdout
  </store>
</match>

```
Пример парсинга лога в красоту:

```
t@log_name	service.post
	@timestamp	Dec 27, 2019 @ 01:01:51.000
	t_id	5zg6RG8BNhH7NLv_9SH1
	t_index	fluentd-20191226
	#_score	 - 
	t_type	access_log
	taddr	192.168.32.4
	tevent	request
	tlevel	info
	tmethod	GET
	tpath	/healthcheck?
	?request_id	 - 
	#response_status	200
	tservice	post
	ttimestamp	2019-12-26 22:01:51
```
или

```
t@log_name	service.ui
	@timestamp	Dec 27, 2019 @ 01:04:17.000
	t_id	DDg9RG8BNhH7NLv_MCKQ
	t_index	fluentd-20191226
	#_score	 - 
	t_type	access_log
	tevent	show_all_posts
	?loglevel	INFO
	tmessage	Successfully showed the home page with posts
	?pid	1
	?progname	
	?request_id	a335bb3b-2d24-428f-919a-3f0fb397b165
	tservice	ui
	ttimestamp	2019-12-26T22:04:17.096516
```

2. Самостоятельное задание со звездочкой
С нашим приложением происходит что-то странное.
Пользователи жалуются, что при нажатии на пост они вынуждены
долго ждать, пока у них загрузится страница с постом. Жалоб на
загрузку других страниц не поступало. Нужно выяснить, в чем
проблема, используя Zipkin.

Отложил.

### The end
```
docker-machine rm logging -f
eval $(docker-machine env --unset)
```
# HW 25. Введение в Kubernetes

Цели

- Разобрать на практике все компоненты Kubernetes, развернуть их
вручную используя The Hard Way;
- Ознакомиться с описанием основных примитивов нашего
приложения и его дальнейшим запуском в Kubernetes.

## Создание примитивов

Опишем приложение в контексте Kubernetes с помощью
manifest-ов в YAML-формате. Основным примитивом будет
Deployment. Основные задачи сущности Deployment:

- Создание Replication Controller-а (следит, чтобы число запущенных
Pod-ов соответствовало описанному);
- Ведение истории версий запущенных Pod-ов (для различных
стратегий деплоя, для возможностей отката);
- Описание процесса деплоя (стратегия, параметры стратегий).

По ходу курса эти манифесты будут обновляться, а также
появляться новые. Текущие файлы нужны для создания структуры
и проверки работоспособности kubernetes-кластера.

### Пример Deployment post-deployment.yml

```
---
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: post-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: post
  template:
    metadata:
      name: post
      labels:
        app: post
    spec:
      containers:
      - image: chromko/post
        name: post
```

### Задание

Создайте директорию kubernetes в корне репозитория;
Внутри директории kubernetes создайте директорию reddit;
Сохраните файл post-deployment.yml в директории
kubernetes/reddit;

Создайте собственные файлы с Deployment манифестами
приложений и сохраните в папке kubernetes/reddit:
- ui-deployment.yml
- comment-deployment.yml
- mongo-deployment.yml
P.S. Эту директорию и файлы в ней в дальнейшем мы будем
развивать (пока это нерабочие экземпляры).

## Kubernetes The Hard Way.

В качестве домашнего задания предлагается пройти https://github.com/kelseyhightower/kubernetes-the-hard-way
разработанный инженером Google Kelsey Hightower
Туториал представляет собой:
Пошаговое руководство по ручной инсталляции основных
компонентов Kubernetes кластера;
Краткое описание необходимых действий и объектов.

### Задание

- Создать отдельную директорию the_hard_way в директории
kubernetes;
- Пройти Kubernetes The Hard Way;
- Проверить, что kubectl apply -f <filename> проходит по созданным
до этого deployment-ам (ui, post, mongo, comment) и поды
запускаются;
- Удалить кластер после прохождения THW;
- Все созданные в ходе прохождения THW файлы (кроме бинарных)
поместить в папку kubernetes/the_hard_way репозитория
(сертификаты и ключи тоже можно коммитить, но только после
удаления кластера).

### Возможные проблемы 

Если на шаге Bootstrapping the etcd Cluster у вас не работает
команда 
```
sudo systemctl start etcd
```
то, вероятно, Вы не используете параллельный ввод с помощью tmux, а выполняете
команды для каждого сервера отдельно. Для того, чтобы команда
выполнилась успешно, установите etcd на каждый необходимый
инстанс и одновременно запустите её на всех инстансах.


Если в процессе выполнения команд возникает ошибка
```
(gcloud.compute.addresses.describe) argument --region:
expected one argument
```
то убедитесь, что Вы выполняете команду
в нужном месте!
Обычно это происходит, когда команду
необходимо выполнять на локальной машине, а она выполняется
на каком то из инстансов. Если команда точно выполняется
локально, то выполните:
```
{
gcloud config set compute/region us-west1
gcloud config set compute/zone us-west1-c
}
```
## Начну пилить кубер по Hard-way
------------------------------------------------------------------------
https://github.com/kelseyhightower/kubernetes-the-hard-way
------------------------------------------------------------------------

Весь Хард-вей засунул в отдельный [README.md](https://github.com/Otus-DevOps-2019-08/sgremyachikh_microservices/blob/kubernetes-1/kubernetes/the_hard_way/README.md)


## Проверить, что kubectl apply -f <filename> проходит по созданным до этого deployment-ам (ui, post, mongo, comment) и поды запускаются

```
kubectl apply -f mongo-deployment.yml
kubectl apply -f post-deployment.yml
kubectl apply -f comment-deployment.yml
kubectl apply -f ui-deployment.yml
```
проверяю состояние подов
```
kubectl get pods
NAME                                 READY   STATUS             RESTARTS   AGE
busybox                              1/1     Running            1          71m
comment-deployment-6c495b4b6-lwfzc   0/1     ImagePullBackOff   0          5m21s
mongo-deployment-86d49445c4-rv6vs    1/1     Running            0          5m51s
nginx-554b9c67f9-jmlrh               1/1     Running            0          32m
post-deployment-5b67b9755d-4njx9     0/1     ImagePullBackOff   0          5m29s
ui-deployment-6ff946d48b-sfpdz       0/1     ImagePullBackOff   0          5m14s
```
Как видим - все грустно.

Гуглим [ImagePullBackOff](https://managedkube.com/kubernetes/k8sbot/troubleshooting/imagepullbackoff/2019/02/23/imagepullbackoff.html)

Надо понять - что не так:
```
kubectl describe pod comment-deployment-6c495b4b6-lwfzc
Name:           comment-deployment-6c495b4b6-lwfzc
Namespace:      default
Priority:       0
Node:           worker-2/10.240.0.22
Start Time:     Sun, 05 Jan 2020 00:52:07 +0300
Labels:         app=comment
                pod-template-hash=6c495b4b6
Annotations:    <none>
Status:         Pending
IP:             10.200.2.4
IPs:            <none>
Controlled By:  ReplicaSet/comment-deployment-6c495b4b6
Containers:
  comment:
    Container ID:   
    Image:          decapapreta/comment
    Image ID:       
    Port:           <none>
    Host Port:      <none>
    State:          Waiting
      Reason:       ImagePullBackOff
    Ready:          False
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-sjnz9 (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             False 
  ContainersReady   False 
  PodScheduled      True 
Volumes:
  default-token-sjnz9:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-sjnz9
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type     Reason     Age                   From               Message
  ----     ------     ----                  ----               -------
  Normal   Scheduled  7m5s                  default-scheduler  Successfully assigned default/comment-deployment-6c495b4b6-lwfzc to worker-2
  Normal   Pulling    5m40s (x4 over 7m4s)  kubelet, worker-2  Pulling image "decapapreta/comment"
  Warning  Failed     5m39s (x4 over 7m4s)  kubelet, worker-2  Failed to pull image "decapapreta/comment": rpc error: code = Unknown desc = failed to resolve image "docker.io/decapapreta/comment:latest": docker.io/decapapreta/comment:latest not found
  Warning  Failed     5m39s (x4 over 7m4s)  kubelet, worker-2  Error: ErrImagePull
  Normal   BackOff    5m2s (x7 over 7m3s)   kubelet, worker-2  Back-off pulling image "decapapreta/comment"
  Warning  Failed     111s (x20 over 7m3s)  kubelet, worker-2  Error: ImagePullBackOff
```
фикшу ямлы и применяю деплойменты еще раз

```
kubectl apply -f post-deployment.yml
kubectl apply -f comment-deployment.yml
kubectl apply -f ui-deployment.yml
```
чек:
```
kubectl get pods
NAME                                  READY   STATUS    RESTARTS   AGE
busybox                               1/1     Running   1          80m
comment-deployment-5865bc6dbf-ft8tz   1/1     Running   0          111s
mongo-deployment-86d49445c4-rv6vs     1/1     Running   0          14m
nginx-554b9c67f9-jmlrh                1/1     Running   0          41m
post-deployment-79885fc5df-zn2zl      1/1     Running   0          13s
ui-deployment-bb9f4ccb9-ndkdl         1/1     Running   0          66s

```
все хорошо

# HW 26. Kubernetes. Запуск кластера и приложения. Модель безопасности.

План
• Развернуть локальное окружение для работы с
Kubernetes
• Развернуть Kubernetes в GKE
• Запустить reddit в Kubernetes

## Разворачиваем Kubernetes локально

Для дальнейшей работы нам нужно подготовить
локальное окружение, которое будет состоять из:

1) kubectl - фактически, главной утилиты для работы
c Kubernetes API (все, что делает kubectl, можно
сделать с помощью HTTP-запросов к API k8s)

2) Директории ~/.kube - содержит служебную инфу
для kubectl (конфиги, кеши, схемы API)

3) minikube - утилиты для разворачивания локальной
инсталляции Kubernetes. 

### Kubectl

Необходимо [установить kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-linux):

Все способы установки доступны по https://kubernetes.io/docs/tasks/tools/install-kubectl/

### Установка Minikube

Для работы Minukube вам понадобится локальный
гипервизор:
1. Для OS X: или xhyve driver, или VirtualBox, или VMware
Fusion.
2. Для Linux: VirtualBox или KVM.
3. Для Windows: VirtualBox или Hyper-V.

Инструкция по установке Minikube для разных ОС:
https://kubernetes.io/docs/tasks/tools/install-minikube/

#### Fedora 31.

```
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-1.6.2.rpm \
 && sudo rpm -ivh minikube-1.6.2.rpm
```
Hypervisor Setup
Verify that your system has virtualization support enabled:

```
egrep -q 'vmx|svm' /proc/cpuinfo && echo yes || echo no
```

If the above command outputs “no”:
If you are running within a VM, your hypervisor does not allow nested virtualization. You will need to use the None (bare-metal) driver
If you are running on a physical machine, ensure that your BIOS has hardware virtualization enabled

#### VirtualBox

Requirements
VirtualBox 5.2 or higher

Usage

Start a cluster using the virtualbox driver:
```
minikube start --vm-driver=virtualbox

😄  minikube v1.6.2 on Fedora 31
✨  Selecting 'virtualbox' driver from user configuration (alternates: [none])
💿  Downloading VM boot image ...
    > minikube-v1.6.0.iso.sha256: 65 B / 65 B [--------------] 100.00% ? p/s 0s
    > minikube-v1.6.0.iso: 150.93 MiB / 150.93 MiB [] 100.00% 10.52 MiB p/s 14s
🔥  Creating virtualbox VM (CPUs=2, Memory=2000MB, Disk=20000MB) ...
🐳  Preparing Kubernetes v1.17.0 on Docker '19.03.5' ...
💾  Downloading kubeadm v1.17.0
💾  Downloading kubelet v1.17.0
🚜  Pulling images ...
🚀  Launching Kubernetes ... 
⌛  Waiting for cluster to come online ...
🏄  Done! kubectl is now configured to use "minikube"

```

To make virtualbox the default driver:
```
minikube config set vm-driver virtualbox

These changes will take effect upon a minikube delete and then a minikube start
```
Getting to know Kubernetes
Once started, you can use any regular Kubernetes command to interact with your minikube cluster. For example, you can see the pod states by running:

```
kubectl get po -A

NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
kube-system   coredns-6955765f44-vcgqg           1/1     Running   0          3m11s
kube-system   coredns-6955765f44-xslxq           1/1     Running   0          3m11s
kube-system   etcd-minikube                      1/1     Running   0          2m57s
kube-system   kube-addon-manager-minikube        1/1     Running   0          2m57s
kube-system   kube-apiserver-minikube            1/1     Running   0          2m57s
kube-system   kube-controller-manager-minikube   1/1     Running   0          2m57s
kube-system   kube-proxy-sfjln                   1/1     Running   0          3m11s
kube-system   kube-scheduler-minikube            1/1     Running   0          2m57s
kube-system   storage-provisioner                1/1     Running   0          3m9s

```

Increasing memory allocation

minikube only allocates 2GB of RAM by default, which is only enough for trivial deployments. For larger deployments, increase the memory allocation using the --memory flag, or make the setting persistent using:
```
sgremyachikh@Thinkpad  ~/Загрузки  minikube config set memory 4096

⚠️  These changes will take effect upon a minikube delete and then a minikube start

sgremyachikh@Thinkpad  ~/Загрузки  minikube delete

🔥  Deleting "minikube" in virtualbox ...
💔  The "minikube" cluster has been deleted.
🔥  Successfully deleted profile "minikube"

sgremyachikh@Thinkpad  ~/Загрузки  minikube start                 

😄  minikube v1.6.2 on Fedora 31
✨  Selecting 'virtualbox' driver from user configuration (alternates: [none])
🔥  Creating virtualbox VM (CPUs=2, Memory=4096MB, Disk=20000MB) ...
🐳  Preparing Kubernetes v1.17.0 on Docker '19.03.5' ...
🚜  Pulling images ...
🚀  Launching Kubernetes ... 
⌛  Waiting for cluster to come online ...
🏄  Done! kubectl is now configured to use "minikube"

```
Where to go next?
Visit the [examples](https://minikube.sigs.k8s.io/docs/examples) page to get an idea of what you can do with minikube.

### возврат к методичке.

Понимаю, что чуть опередил запустил миникуб.

Но есть пара нюансов при выполнении
```
minikube start
```
P.S. Если нужна конкретная версия kubernetes, указывайте флаг
--kubernetes-version <version> (v1.8.0)
P.P.S.По-умолчанию используется VirtualBox. Если у вас другой гипервизор, то ставьте флаг
--vm-driver=<hypervisor> 

Наш Minikube-кластер развернут. При этом автоматически был
настроен конфиг kubectl.
Проверим, что это так: 

```
sgremyachikh@Thinkpad  ~/Загрузки  kubectl get nodes

NAME       STATUS   ROLES    AGE     VERSION
minikube   Ready    master   8m32s   v1.17.0
```
### Конфигурация kubectl - это контекст.

Контекст - это комбинация:
1) cluster - API-сервер
2) user - пользователь для подключения к кластеру
3) namespace - область видимости (не обязательно, поумолчанию default)
Информацию о контекстах kubectl сохраняет в файле
~/.kube/config

Файл ~/.kube/config - это такой же манифест
kubernetes в YAML-формате (есть и Kind, и ApiVersion). 

```
cat ~/.kube/config 
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURvRENDQW9p......(обрезал)
    server: https://34.82.11.99:6443
  name: kubernetes-the-hard-way
- cluster:
    certificate-authority: /home/sgremyachikh/.minikube/ca.crt
    server: https://192.168.99.101:8443
  name: minikube
contexts:
- context:
    cluster: kubernetes-the-hard-way
    user: admin
  name: kubernetes-the-hard-way
- context:
    cluster: minikube
    user: minikube
  name: minikube
current-context: minikube
kind: Config
preferences: {}
users:
- name: admin
  user:
    client-certificate: /home/sgremyachikh/work/yandex.d/OTUS/sgremyachikh_microservices/kubernetes/the_hard_way/admin.pem
    client-key: /home/sgremyachikh/work/yandex.d/OTUS/sgremyachikh_microservices/kubernetes/the_hard_way/admin-key.pem
- name: minikube
  user:
    client-certificate: /home/sgremyachikh/.minikube/client.crt
    client-key: /home/sgremyachikh/.minikube/client.key
```

#### Кластер (cluster) - это:

1) server - адрес kubernetes API-сервера
2) certificate-authority - корневой сертификат (которым
подписан SSL-сертификат самого сервера), чтобы
убедиться, что нас не обманывают и перед нами тот
самый сервер
+ name (Имя) для идентификации в конфиге

```
- cluster:
    certificate-authority: /home/sgremyachikh/.minikube/ca.crt
    server: https://192.168.99.101:8443
  name: minikube
```

#### Пользователь (user) - это:

1) Данные для аутентификации (зависит от того, как настроен
сервер). Это могут быть:
• username + password (Basic Auth
• client key + client certificate
• token
• auth-provider config (например GCP)
+ name (Имя) для идентификации в конфиге


client key + client certificate + name
```
- name: minikube
  user:
    client-certificate: /home/sgremyachikh/.minikube/client.crt
    client-key: /home/sgremyachikh/.minikube/client.key
```

#### Контекст (контекст) - это:

1) cluster - имя кластера из списка clusters
2) user - имя пользователя из списка users
3) namespace - область видимости по-умолчанию (не
обязательно)
+ name (Имя) для идентификации в конфиге

```
- context:
    cluster: minikube
    user: minikube
  name: minikube
```

### Обычно порядок конфигурирования kubectl следующий:

1) Создать cluster:
```
$ kubectl config set-cluster … cluster_name
```
2) Создать данные пользователя (credentials)
```
$ kubectl config set-credentials … user_name
```
3) Создать контекст
```
$ kubectl config set-context context_name \
--cluster=cluster_name \
--user=user_name
```
4) Использовать контекст
```
$ kubectl config use-context context_name
```

Таким образом kubectl конфигурируется для подключения к
разным кластерам, под разными пользователями.
Текущий контекст можно увидеть так:
```
kubectl config current-context
minikube
```
Список всех контекстов можно увидеть так: 
```
kubectl config get-contexts

CURRENT   NAME                      CLUSTER                   AUTHINFO   NAMESPACE
          kubernetes-the-hard-way   kubernetes-the-hard-way   admin      
*         minikube                  minikube                  minikube   

```

### Запустим приложение

Для работы в приложения kubernetes, нам необходимо
описать их желаемое состояние либо в YAML-манифестах,
либо с помощью командной строки.
Всю конфигурацию поместите в каталог ./kubernetes/reddit
внутри вашего репозитория.

#### Deployment

Основные объекты - это ресурсы Deployment.
Как помним из предыдущего занятия, основные его задачи:

• Создание ReplicationSet (следит, чтобы число запущенных
Pod-ов соответствовало описанному)
• Ведение истории версий запущенных Pod-ов (для
различных стратегий деплоя, для возможностей отката)
• Описание процесса деплоя (стратегия, параметры
стратегий)

#### ui-deployment.yml

```
---
apiVersion: apps/v1beta2
kind: Deployment 
metadata: --------------------Блок метаданных деплоя
  name: ui
  labels:
    app: reddit
    component: ui
spec: ------------------------Блок спецификации деплоя
  replicas: 3
  selector: --------------!!!selector описывает, как ему отслеживать POD-ы. В данном случае - контроллер будет считать POD-ы с метками: app=reddit И component=ui
    matchLabels:
      app: reddit
      component: ui
  template: ------------------Блок описания POD-ов
    metadata:
      name: ui-pod
      labels: ------------!!! Поэтому важно в описании POD-а задать нужные метки (labels) 
        app: reddit-------!!! P.S. Для более гибкой выборки вводим 2 метки (app и component).
        component: ui
    spec:
      containers:
      - image: decapapreta/ui:1.0
        name: ui

```

#### Запустим в Minikube ui-компоненту.
```
kubectl apply -f ui-deployment.yml 
error: unable to recognize "ui-deployment.yml": no matches for kind "Deployment" in version "apps/v1beta2"
```
А все почему? А по тому что в методичке кривой версии апи написан и по тому нельзя тупо копипастить!
Исправляем api:
```
---
apiVersion: apps/v1
kind: Deployment
...
```
и еще раз:
```
kubectl apply -f ui-deployment.yml
deployment.apps/ui created
```
Убедитесь, что во 2,3,4 и 5 столбцах стоит число 3 (число реплик ui):
```
kubectl get deployment

NAME   READY   UP-TO-DATE   AVAILABLE   AGE
ui     3/3     3            3           57m
```

P.S. kubectl apply -f <filename> может принимать не только
отдельный файл, но и папку с ними. Например:
```
sgremyachikh@Thinkpad  ~/work/yandex.d/OTUS/sgremyachikh_microservices/kubernetes/reddit   kubernetes-2 ●  kubectl apply -f ./

deployment.apps/comment created
deployment.apps/mongo created
deployment.apps/post created
deployment.apps/ui unchanged
```

#### UI

Пока что мы не можем использовать наше приложение полностью,
потому что никак не настроена сеть для общения с ним.
Но kubectl умеет пробрасывать сетевые порты POD-ов на локальную
машину
Найдем, используя selector, POD-ы приложения :
```
kubectl get pods --selector component=ui

NAME                 READY   STATUS    RESTARTS   AGE
ui-55b8d6654-nrs67   1/1     Running   0          71m
ui-55b8d6654-qjzh9   1/1     Running   0          71m
ui-55b8d6654-xd4mz   1/1     Running   0          71m

kubectl port-forward ui-55b8d6654-nrs67 8080:9292
Forwarding from 127.0.0.1:8080 -> 9292
Forwarding from [::1]:8080 -> 9292
```
Зайдем в браузере на
http://localhost:8080

UI работает, подключим остальные компоненты

```
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: comment
  labels:
    app: reddit
    component: comment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: reddit
      component: comment
  template:
    metadata:
      name: comment-pod
      labels:
        app: reddit
        component: comment
    spec:
      containers:
      - image: decapapreta/comment:1.0
        name: comment
```
```
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: post
  labels:
    app: reddit
    component: post
spec:
  replicas: 3
  selector:
    matchLabels:
      app: reddit
      component: post
  template:
    metadata:
      name: post-pod
      labels:
        app: reddit
        component: post
    spec:
      containers:
      - image: decapapreta/post:1.0
        name: post
```
Монга. Также примонтируем стандартный Volume для
хранения данных вне контейнера:

```
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongo
  labels:
    app: reddit
    component: mongo
spec:
  replicas: 3
  selector:
    matchLabels:
      app: reddit
      component: mongo
  template:
    metadata:
      name: mongo-pod
      labels:
        app: reddit
        component: mongo
    spec:
      containers:
      - image: mongo:3.2
        name: mongo
        volumeMounts: -------------------------указываем волиумы контейнера
          - name: mongo-persistent-storage
            mountPath: /data/db -----------------------------Точка монтирования в контейнере (не в POD-е)
      volumes: --------------------------------указываем волиумы
        - name: mongo-persistent-storage ------------------------------ Ассоциированные с POD-ом Volume-ы
          emptyDir: {}
```

Проверка подов:

```
sgremyachikh@Thinkpad  ~/work/yandex.d/OTUS/sgremyachikh_microservices/kubernetes/reddit   kubernetes-2 ●  kubectl get pods

NAME                       READY   STATUS    RESTARTS   AGE
comment-7d859ddc94-cmkck   1/1     Running   0          25m
comment-7d859ddc94-frtqm   1/1     Running   0          25m
comment-7d859ddc94-qcz8l   1/1     Running   0          25m
mongo-7d5db556f9-4wdrd     1/1     Running   0          24s
mongo-7d5db556f9-knfdh     1/1     Running   0          22s
mongo-7d5db556f9-xwt5s     1/1     Running   0          20s
post-5d86c4f986-5vwmg      1/1     Running   0          25m
post-5d86c4f986-nt8rt      1/1     Running   0          25m
post-5d86c4f986-s6hl7      1/1     Running   0          25m
ui-55b8d6654-nrs67         1/1     Running   0          90m
ui-55b8d6654-qjzh9         1/1     Running   0          90m
ui-55b8d6654-xd4mz         1/1     Running   0          90m

```

### Service

В текущем состоянии приложение не будет
работать, так его компоненты ещё не знают как
найти друг друга
Для связи компонент между собой и с внешним
миром используется объект Service - абстракция,
которая определяет набор POD-ов (Endpoints) и
способ доступа к ним

Для связи ui с post и comment нужно создать им по
объекту Service. 

```
---
apiVersion: v1
kind: Service
metadata:
  name: comment
  labels:
    app: reddit
    component: comment
spec:
  ports:
  - port: 9292
    protocol: TCP
    targetPort: 9292
  selector:
    app: reddit
    component: comment
```
тут в методичке гора ошибок

Когда объект service будет создан:
1) В DNS появится запись для comment
2) При обращении на адрес comment:9292
изнутри любого из POD-ов текущего
namespace нас переправит на 9292
порт одного из POD-ов приложения comment,
выбранных по label-ам

По label-ам должны были быть найдены соответствующие
POD-ы. Посмотреть можно с помощью: (тут опять ошибки в методичке)

```
kubectl describe service comment | grep Endpoints

Endpoints:         172.17.0.10:9292,172.17.0.11:9292,172.17.0.2:9292
```
До следующего шага я напилил сервисы всем оставшимся компонентам по аналогии, порты глянул в /sgremyachikh_microservices/docker/docker-compose.yml
Задеплоил:
```
kubectl apply -f ./                   
deployment.apps/comment unchanged
service/comment unchanged
deployment.apps/mongo unchanged
service/mongo created
deployment.apps/post unchanged
service/post created
deployment.apps/ui unchanged
service/ui created
```

А изнутри любого POD-а, в котором есть `bind-utils` должно разрешаться  kubectl exec -ti <pod-name> nslookup <label-name>:
```
kubectl get pods
# я хочу увидеть поды
NAME                       READY   STATUS    RESTARTS   AGE
comment-7d859ddc94-b8fhm   1/1     Running   0          3h6m
comment-7d859ddc94-ff64n   1/1     Running   0          3h6m
comment-7d859ddc94-thcbp   1/1     Running   0          3h6m
mongo-7d5db556f9-str2g     1/1     Running   0          3h6m
mongo-7d5db556f9-wfvn7     1/1     Running   0          3h6m
mongo-7d5db556f9-xmsk5     1/1     Running   0          3h6m
post-5d86c4f986-bz2lv      1/1     Running   0          3h6m
post-5d86c4f986-mxztb      1/1     Running   0          3h6m
post-5d86c4f986-r9wx4      1/1     Running   0          3h6m
ui-55b8d6654-hbxjn         1/1     Running   0          3h6m
ui-55b8d6654-tx5xh         1/1     Running   0          3h6m
ui-55b8d6654-w9qlv         1/1     Running   0          3h6m

kubectl exec -ti post-5d86c4f986-bz2lv nslookup mongo
# выбрал лукапнуть монгу из пода с постом, который сам собирал
nslookup: can't resolve '(null)': Name does not resolve
Name:      mongo
Address 1: 10.96.56.160 mongo.default.svc.cluster.local

kubectl exec -ti mongo-7d5db556f9-str2g nslookup comment
# а вот лукапнуть коммент из мнги не выйдет - bind-utils нет в составе и мы видим вывод
OCI runtime exec failed: exec failed: container_linux.go:346: starting container process caused "exec: \"nslookup\": executable file not found in $PATH": unknown
command terminated with exit code 126
```
#### Проверка функциональности приложения

Проверяем:
пробрасываем порт на ui pod:
kubectl port-forward <pod-name> 9292:9292

```
kubectl get pods | grep ui
# я хочу увидеть поды
ui-55b8d6654-hbxjn         1/1     Running   0          3h18m
ui-55b8d6654-tx5xh         1/1     Running   0          3h18m
ui-55b8d6654-w9qlv         1/1     Running   0          3h18m

kubectl port-forward ui-55b8d6654-hbxjn 9292:9292
```
И ничего не работает. НЕ ПОЧИТАВ МЕТОДИЧКУ ДАЛЕЕ, начинаю копать и думать.
В docker-compose.yml есть указание алиасов:

```
  post_db:
    image: mongo:${MONGO_VER:-3.2}
    volumes:
      - post_db:/data/db
    networks:
      back_net:
        aliases:
          - post_db
          - comment_db
...
  post:
    image: ${USERNAME:-decapapreta}/post:${POST_VER:-1.0}
    environment:
      POST_DATABASE_HOST: post_db
...
```
У коммента не указано, но за то есть в докерфайле дефолтное:

```
ENV COMMENT_DATABASE_HOST comment_db
ENV COMMENT_DATABASE comments
```

это говорит нам, что надо обозначить монгу 2!!! разными способами для 2 сервисов!
Далее уже я листнул методичку и обнаружил. что тема раскрывалась более и решил забегать подальше прежде чем плясать на граблях:

#### Посмотрим в логи, например, comment: 

 kubectl logs

D, [2017-11-23T11:58:14.036381 #1] DEBUG -- : MONGODB | Topology type 'unknown' initializing.
D, [2017-11-23T11:58:14.036584 #1] DEBUG -- : MONGODB | Server comment_db:27017 initializing.
D, [2017-11-23T11:58:14.041398 #1] DEBUG -- : MONGODB | getaddrinfo: Name does not resolve
D, [2017-11-23T11:58:14.090421 #1] DEBUG -- : MONGODB | getaddrinfo: Name does not resolve 

хотя у меня все было загажено хелсчеками. за которыми таких сообщений не было видно. ЕЛК надо для таких дел.

Приложение ищет совсем другой адрес: comment_db, а не mongodb
Аналогично и сервис post ищет post_db.

Эти адреса заданы в их Dockerfile-ах в виде переменных
окружения:

post/Dockerfile
…
ENV POST_DATABASE_HOST=post_db

comment/Dockerfile
…
ENV COMMENT_DATABASE_HOST=comment_db

#### В docker-compose проблема доступа к одному ресурсу под разными именами решалась с помощью сетевых алиасов. 

В Kubernetes такого функционала нет.
Мы эту проблему можем решить с помощью тех же
Service-ов. 

#### Сделаем Service для БД comment.
comment-mongodb-service.yml

```
---
apiVersion: v1
kind: Service
metadata:
  name: comment-db -------------- В имени нельзя использовать “_”
  labels:
    app: reddit
    component: mongo
    comment-db: "true" -----------добавим метку, чтобы различать сервисы
spec:
  ports:
  - port: 27017
    protocol: TCP
    targetPort: 27017
  selector:
    app: reddit
    component: mongo
    comment-db: "true" ----------- Отдельный лейбл для comment-db
```
булевые значения
обязательно указывать в кавычках

#### Так же придется обновить файл deployment для mongodb, чтобы новый Service смог найти нужный POD

```
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongo
  labels:
    app: reddit
    component: mongo
    comment-db: "true" ----------Лейбл в deployment чтобы было понятно,что развернуто
spec:
  replicas: 1
  selector:
    matchLabels:
      app: reddit
      component: mongo
  template:
    metadata:
      name: mongo-pod
      labels:
        app: reddit
        component: mongo
        comment-db: "true" ----------- label в pod, который нужно найти
    spec:
      containers:
      - image: mongo:3.2
        name: mongo
        volumeMounts:
          - name: mongo-persistent-storage
            mountPath: /data/db
      volumes:
        - name: mongo-persistent-storage
          emptyDir: {}
```
#### Зададим pod-ам comment переменную окружения для обращения к базе

```
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: comment
  labels:
    app: reddit
    component: comment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: reddit
      component: comment
  template:
    metadata:
      name: comment-pod
      labels:
        app: reddit
        component: comment
    spec:
      containers:
      - image: decapapreta/comment:1.0
        name: comment
        env:
          - name:  COMMENT_DATABASE_HOST
            value: comment-db
```
#### Мы сделали базу доступной для comment. аналогичные же действия для postсервиса. Название сервиса должно post-db.
post-db-mongo-service.yml

```
---
apiVersion: v1
kind: Service
metadata:
  name: post-db
  labels:
    app: reddit
    component: mongo
    post-db: "true"
spec:
  ports:
  - port: 27017
    protocol: TCP
    targetPort: 27017
  selector:
    app: reddit
    component: mongo
    post-db: "true" 

```
mongo-deployment.yml
```
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongo
  labels:
    app: reddit
    component: mongo
    comment-db: "true"
    post-db: "true"
spec:
  replicas: 1
  selector:
    matchLabels:
      app: reddit
      component: mongo
  template:
    metadata:
      name: mongo-pod
      labels:
        app: reddit
        component: mongo
        comment-db: "true"
        post-db: "true"
    spec:
      containers:
      - image: mongo:3.2
        name: mongo
        volumeMounts:
          - name: mongo-persistent-storage
            mountPath: /data/db
      volumes:
        - name: mongo-persistent-storage
          emptyDir: {}
```
После этого снова сделайте port-forwarding на UI и
убедитесь, что приложение запустилось без
ошибок и посты создаются

Получилось.

#### Удалите объект mongodb-service 

```
kubectl delete -f mongo-service.yml 
service "mongodb" deleted
```
### Нам нужно как-то обеспечить доступ к ui-сервису снаружи

Для этого нам понадобится Service для UI-компоненты
Главное отличие -
тип сервиса NodePort!

```
 
---
apiVersion: v1
kind: Service
metadata:
  name: ui
  labels:
    app: reddit
    component: ui
spec:
  type: NodePort
  ports:
    - port: 9292
      protocol: TCP
      targetPort: 9292
  selector:
    app: reddit
    component: ui
```
По-умолчанию все сервисы имеют тип ClusterIP - это значит, что сервис
распологается на внутреннем диапазоне IP-адресов кластера. Снаружи до него
нет доступа. 

Тип NodePort - на каждой ноде кластера открывает порт из диапазона
30000-32767 и переправляет трафик с этого порта на тот, который указан в
targetPort Pod (похоже на стандартный expose в docker)

Теперь до сервиса можно дойти по <Node-IP>:<NodePort>
Также можно указать самим NodePort (но все равно из диапазона): 

``` 
---
apiVersion: v1
kind: Service
metadata:
  name: ui
  labels:
    app: reddit
    component: ui
spec:
  type: NodePort
  ports:
    - nodePort: 32092
      port: 9292
      protocol: TCP
      targetPort: 9292
  selector:
    app: reddit
    component: ui
```
Т.е. в описании service
NodePort - для доступа снаружи кластера
port - для доступа к сервису изнутри кластера

### Minikube может выдавать web-странцы с сервисами

Minikube может выдавать web-странцы с сервисами
которые были помечены типом NodePort
Попробуйте:

```
minikube service ui

|-----------|------|-------------|-----------------------------|
| NAMESPACE | NAME | TARGET PORT |             URL             |
|-----------|------|-------------|-----------------------------|
| default   | ui   |             | http://192.168.99.106:32092 |
|-----------|------|-------------|-----------------------------|
🎉  Opening service default/ui in default browser...
```

Minikube может перенаправлять на web-странцы с сервисами
которые были помечены типом NodePort
Посмотрите на список сервисов: 

```
minikube service list 
|-------------|------------|-----------------------------|-----|
|  NAMESPACE  |    NAME    |         TARGET PORT         | URL |
|-------------|------------|-----------------------------|-----|
| default     | comment    | No node port                |
| default     | comment-db | No node port                |
| default     | kubernetes | No node port                |
| default     | mongodb    | No node port                |
| default     | post       | No node port                |
| default     | post-db    | No node port                |
| default     | ui         | http://192.168.99.106:32092 |
| kube-system | kube-dns   | No node port                |
|-------------|------------|-----------------------------|-----|
```

### Minikube также имеет в комплекте несколько стандартных аддонов

Minikube также имеет в комплекте несколько стандартных аддонов
(расширений) для Kubernetes (kube-dns, dashboard, monitoring,…).
Каждое расширение - это такие же PODы и сервисы, какие
создавались нами, только они еще общаются с API самого Kubernetes 

```
minikube addons list
- addon-manager: enabled
- dashboard: disabled
- default-storageclass: enabled
- efk: disabled
- freshpod: disabled
- gvisor: disabled
- helm-tiller: disabled
- ingress: disabled
- ingress-dns: disabled
- logviewer: disabled
- metrics-server: disabled
- nvidia-driver-installer: disabled
- nvidia-gpu-device-plugin: disabled
- registry: disabled
- registry-creds: disabled
- storage-provisioner: enabled
- storage-provisioner-gluster: disabled

```

Интересный аддон - dashboard. Это UI для работы с
kubernetes. По умолчанию в новых версиях он включен.
Как и многие kubernetes add-on'ы, dashboard запускается в
виде pod'а. 

Если мы посмотрим на запущенные pod'ы с помощью
команды kubectl get pods, то обнаружим только наше
приложение. 

Потому что поды и сервисы для dashboard-а были запущены
в namespace (пространстве имен) kube-system.
Мы же запросили пространство имен default.

## Namespaces

Namespace - это, по сути, виртуальный кластер Kubernetes
внутри самого Kubernetes. Внутри каждого такого кластера
находятся свои объекты (POD-ы, Service-ы, Deployment-ы и
т.д.), кроме объектов, общих на все namespace-ы (nodes,
ClusterRoles, PersistentVolumes)

В разных namespace-ах могут находится объекты с
одинаковым именем, но в рамках одного namespace имена
объектов должны быть уникальны. 

#### При старте Kubernetes кластер уже имеет 3 namespace:

- default - для объектов для которых не определен другой
Namespace (в нем мы работали все это время)
- kube-system - для объектов созданных Kubernetes’ом и
для управления им
- kube-public - для объектов к которым нужен доступ из
любой точки кластера

Для того, чтобы выбрать конкретное пространство имен, нужно указать
флаг -n <namespace> или --namespace <namespace> при запуске kubectl

#### Найдем же объекты нашего dashboard 

```
kubectl get all -n kube-system --selector k8s-app=kubernetes-dashboard
No resources found in kube-system namespace.
```
А почему? А потому!
```
minikube addons list
- addon-manager: enabled
- dashboard: disabled
- default-storageclass: enabled
- efk: disabled
- freshpod: disabled
- gvisor: disabled
- helm-tiller: disabled
- ingress: disabled
- ingress-dns: disabled
- logviewer: disabled
- metrics-server: disabled
- nvidia-driver-installer: disabled
- nvidia-gpu-device-plugin: disabled
- registry: disabled
- registry-creds: disabled
- storage-provisioner: enabled
- storage-provisioner-gluster: disabled

```
> - dashboard: disabled

https://kubernetes.io/ru/docs/tutorials/hello-minikube/#%d0%b4%d0%be%d0%b1%d0%b0%d0%b2%d0%bb%d0%b5%d0%bd%d0%b8%d0%b5-%d0%b0%d0%b4%d0%b4%d0%be%d0%bd%d0%be%d0%b2

```
minikube addons enable dashboard
✅  dashboard was successfully enabled

#А далее:
minikube dashboard            
🤔  Verifying dashboard health ...
🚀  Launching proxy ...
🤔  Verifying proxy health ...
🎉  Opening http://127.0.0.1:45387/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/ in your default browser...
```
Потрогали. И что?

```
kubectl get all -n kube-system --selector k8s-app=kubernetes-dashboard
No resources found in kube-system namespace.
# Удивительно. но еще чуток посмотрим

kubectl get all -n kube-system                              
NAME                                   READY   STATUS    RESTARTS   AGE
pod/coredns-6955765f44-6n6q6           1/1     Running   0          46m
pod/coredns-6955765f44-g8s27           1/1     Running   0          46m
pod/etcd-minikube                      1/1     Running   0          46m
pod/kube-addon-manager-minikube        1/1     Running   0          46m
pod/kube-apiserver-minikube            1/1     Running   0          46m
pod/kube-controller-manager-minikube   1/1     Running   0          46m
pod/kube-proxy-lw2xb                   1/1     Running   0          46m
pod/kube-scheduler-minikube            1/1     Running   0          46m
pod/storage-provisioner                1/1     Running   1          46m

NAME               TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
service/kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   46m

NAME                        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                 AGE
daemonset.apps/kube-proxy   1         1         1       1            1           beta.kubernetes.io/os=linux   46m

NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/coredns   2/2     2            2           46m

NAME                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/coredns-6955765f44   2         2         2       46m
```
В методичке немного не так)

#### В самом Dashboard можно:

• отслеживать состояние кластера и рабочих нагрузок в нем
• создавать новые объекты (загружать YAML-файлы)
• Удалять и изменять объекты (кол-во реплик, yaml-файлы)
• отслеживать логи в Pod-ах
• при включении Heapster-аддона смотреть нагрузку на Podах
• и т.д.

#### Используем же namespace в наших целях.

 Отделим среду для
разработки приложения от всего остального кластера.
Для этого создадим свой Namespace dev 

dev-namespace.yml

```
---
apiVersion: v1
kind: Namespace
metadata:
  name: dev 

```
```
kubectl apply -f dev-namespace.yml
namespace/dev created

kubectl apply -n dev -f ui-deployment.yml 
deployment.apps/ui created

kubectl -n dev get pods                  
NAME                 READY   STATUS    RESTARTS   AGE
ui-55b8d6654-pkjb8   1/1     Running   0          22s
ui-55b8d6654-tl87j   1/1     Running   0          22s
ui-55b8d6654-vpjss   1/1     Running   0          22s
```

Если возник конфликт портов у ui-service, то убираем из
описания значение NodePort 

```
kubectl apply -n dev -f ui-service.yml   
service/ui created

minikube service ui -n dev            
|-----------|------|-------------|-----------------------------|
| NAMESPACE | NAME | TARGET PORT |             URL             |
|-----------|------|-------------|-----------------------------|
| dev       | ui   |             | http://192.168.99.106:30292 |
|-----------|------|-------------|-----------------------------|
🎉  Opening service dev/ui in default browser...
```

#### Давайте добавим инфу об окружении внутрь контейнера UI 

```
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ui
  labels:
    app: reddit
    component: ui
spec:
  replicas: 3
  selector:
    matchLabels:
      app: reddit
      component: ui
  template:
    metadata:
      name: ui-pod
      labels:
        app: reddit
        component: ui
    spec:
      containers:
      - image: decapapreta/ui:1.0
        name: ui
        env:
        - name: ENV ------------------------ Извлекаем значения из контекста запуска
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
```
```
kubectl apply -f ui-deployment.yml -n dev
```
И видим на гуе dev

## Разворачиваем Kubernetes

Мы подготовили наше приложение в локальном окружении.
Теперь самое время запустить его на реальном кластере
Kubernetes.

В качестве основной платформы будем использовать
### Google Kubernetes Engine.

- Зайдите в свою gcloud console, перейдите в “kubernetes
clusters”
- Нажмите “создать Cluster”

Укажите следующие настройки кластера:

• Тип машины - небольшая машина (1,7 ГБ) (для экономии
ресурсов)
• Размер - 2 
• Базовая аутентификация - отключена
• Устаревшие права доступа - отключено
• Панель управления Kubernetes - отключено
• Размер загрузочного диска - 20 ГБ (для экономии)

#### Компоненты управления кластером запускаются в container engine и
управляются Google:
• kube-apiserver
• kube-scheduler
• kube-controller-manager
• etcd 

Рабочая нагрузка (собственные POD-ы), аддоны, мониторинг,
логирование и т.д. запускаются на рабочих нодах

Рабочие ноды - стандартные ноды Google compute engine. Их
можно увидеть в списке запущенных узлов.
На них всегда можно зайти по ssh
Их можно остановить и запустить.

#### Подключимся к GKE для запуска нашего приложения.

На кластере нажимаю "подключиться".
В появившемся окне копирую:
```
gcloud container clusters get-credentials your-first-cluster-1 --zone us-central1-a --project docker-258020
Fetching cluster endpoint and auth data.
kubeconfig entry generated for your-first-cluster-1.
```
Введите в консоли скопированную команду.
В результате в файл ~/.kube/config будут добавлены
user, cluster и context для подключения к кластеру в GKE.
Также текущий контекст будет выставлен для подключения к
этому кластеру.
Убедиться можно, введя:

```
kubectl config current-context
gke_docker-258020_us-central1-a_your-first-cluster-1
```

### Запустим наше приложение в GKE
Создадим dev namespace 

```
kubectl apply -f ./dev-namespace.yml 
namespace/dev created
```
Задеплою в этот неймспейс все компонеты приложения:

```
kubectl apply -f ./ -n dev          
deployment.apps/comment created
service/comment-db created
service/comment created
namespace/dev unchanged
deployment.apps/mongo created
service/mongodb created
service/post-db created
deployment.apps/post created
service/post created
deployment.apps/ui created
service/ui created
```
#### Откроем Reddit для внешнего мира:
- Зайдите в “правила брандмауэра”
- Нажмите “создать правило брандмауэра”

Откроем диапазон портов kubernetes для публикации
сервисов
Настройте:
• Название - произвольно, но понятно
• Целевые экземпляры - все экземпляры в сети
• Диапазоны IP-адресов источников  - 0.0.0.0/0
Протоколы и порты - Указанные протоколы и порты
tcp:30000-32767

Создать

#### Найдите внешний IP-адрес любой ноды из кластера
либо в веб-консоли, либо External IP в выводе:
```
kubectl get nodes -o wide
NAME                                            STATUS   ROLES    AGE   VERSION          INTERNAL-IP   EXTERNAL-IP     OS-IMAGE                             KERNEL-VERSION   CONTAINER-RUNTIME
gke-your-first-cluster-1-pool-1-11fb21ad-c0mr   Ready    <none>   99m   v1.15.4-gke.22   10.128.0.7    35.193.95.253   Container-Optimized OS from Google   4.19.76+         docker://19.3.1
gke-your-first-cluster-1-pool-1-11fb21ad-t1lh   Ready    <none>   99m   v1.15.4-gke.22   10.128.0.6    34.67.142.137   Container-Optimized OS from Google   4.19.76+         docker://19.3.1
```
#### Найдите порт публикации сервиса ui

```
kubectl describe service ui -n dev | grep NodePort
Type:                     NodePort
NodePort:                 <unset>  32092/TCP
```

Идем по адресу http://<node-ip>:<NodePort>

Видим, тыкаем, работает.

#### В GKE также можно запустить Dashboard для кластера.

Kubernetes Dashboard
The Kubernetes Dashboard add-on is disabled by default on GKE.

***Starting with GKE v1.15, you will no longer be able to enable the Kubernetes Dashboard by using the add-on API. You will still be able to install Kubernetes Dashboard manually by following the instructions in the project's [repository](https://github.com/kubernetes/dashboard). For clusters in which you have already deployed the add-on, it will continue to function but you will need to manually apply any updates and security patches that are released.***

У меня как раз такой создан GKE v1.15

#### Kubernetes Dashboard is a general purpose, web-based UI for Kubernetes clusters. It allows users to manage applications running in the cluster and troubleshoot them, as well as manage the cluster itself.

IMPORTANT: Read the [Access Control](https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/README.md) guide before performing any further steps. The default Dashboard deployment contains a minimal set of RBAC privileges needed to run.

##### To deploy Dashboard, execute following command:

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-rc1/aio/deploy/recommended.yaml
```
To access Dashboard from your local workstation you must create a secure channel to your Kubernetes cluster. Run the following command:

```
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

##### Create An Authentication Token (RBAC)

To find out how to create sample user and log in follow [Creating sample](https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md) user guide.

##### NOTE:

Kubeconfig Authentication method does not support external identity providers or certificate-based authentication.
Dashboard can only be accessed over HTTPS
[Heapster](https://github.com/kubernetes/heapster/) has to be running in the cluster for the metrics and graphs to be available. Read more about it in [Integrations](https://github.com/kubernetes/dashboard/blob/master/docs/user/integrations.md) guide.

##### Documentation

Dashboard documentation can be found on [docs](https://github.com/kubernetes/dashboard/blob/master/docs/README.md):
- Common: Entry-level overview
- User Guide: Installation, Accessing Dashboard and more for users
- Developer Guide: Getting Started, Dependency Management and more for anyone interested in contributing



## Задание * 
- Разверните Kubenetes-кластер в GKE с помощью Terraform модуля
- Создайте YAML-манифесты для описания созданных
сущностей для включения dashboard.
- Приложите конфигурацию к PR

пока отложено чтоб успеть сдать все до кусовой работы, но в любом случае вопрос требует изучения


# HW 27 Ingress-контроллеры и сервисы в Kubernetes. Kubernetes. Networks ,Storages

В этой домашке вновь надо создавать кластер.
Тут стало понятно, что звезда предыдущей домашки необходима как воздух.
В /kubernetes/k8s-gcp-terraform/ лежит код инфры кубера в гугле, созданный посреди этой домашки.

Основа: https://github.com/terraform-google-modules/terraform-google-kubernetes-engine

Все работет, приложения задеплоил

## План

- Ingress Controller
- Ingress
- Secret
- TLS
- LoadBalancer Service
- Network Policies
- PersistentVolumes
- PersistentVolumeClaims

### Сетевое взаимодействие

В предыдущей работе нам уже довелось настраивать
сетевое взаимодействие с приложением в Kubernetes с
помощью Service - абстракции, определяющей конечные
узлы доступа (Endpoint’ы) и способ коммуникации с ними
(nodePort, LoadBalancer, ClusterIP). Разберем чуть
подробнее что в реальности нам это дает.

### Service

**Service** - определяет конечные узлы доступа (Endpoint’ы):
- селекторные сервисы (k8s сам находит POD-ы по label’ам)
 безселекторные сервисы (мы вручную описываем
конкретные endpoint’ы)
и способ коммуникации с ними (тип (type) сервиса):
- ClusterIP - дойти до сервиса можно только изнутри
кластера
- nodePort - клиент снаружи кластера приходит на
опубликованный порт
- LoadBalancer - клиент приходит на облачный (aws elb,
Google gclb) ресурс балансировки
- ExternalName - внешний ресурс по отношению к кластеру

Вспомним, как выглядели Service’ы:

```
---
apiVersion: v1
kind: Service
metadata:
  name: post
  labels:
    app: reddit
    component: post
spec:
  ports:
  - port: 5000
    protocol: TCP
    targetPort: 5000
  selector:
    app: reddit
    component: post 
```
Это селекторный сервис
типа **ClusetrIP** (тип не указан, т.к. этот тип по-умолчанию).

**ClusterIP** - это виртуальный (в реальности нет интерфейса,
pod’а или машины с таким адресом) IP-адрес из диапазона
адресов для работы внутри, скрывающий за собой IP-адреса
реальных POD-ов. Сервису любого типа (кроме
ExternalName) назначается этот IP-адрес.

```
kubectl get services

NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
comment      ClusterIP   10.102.10.77    <none>        9292/TCP         8m44s
comment-db   ClusterIP   10.102.0.198    <none>        27017/TCP        8m45s
kubernetes   ClusterIP   10.102.0.1      <none>        443/TCP          32m
mongodb      ClusterIP   10.102.12.227   <none>        27017/TCP        8m42s
post         ClusterIP   10.102.1.1      <none>        5000/TCP         8m40s
post-db      ClusterIP   10.102.11.251   <none>        27017/TCP        8m41s
ui           NodePort    10.102.9.136    <none>        9292:32092/TCP   8m38s

```

#### Схема взаимодействия
```
                                Схема взаимодействия
       +-------------------------------------------------------------------------+
       |                                                                         |
       |                                                    +----------------+   |
       |                                     +------------->+  POST_POD      |   |
       |                                     |              |                |   |
       |  +---------------+         +----------------+      |  10.102.A.B    |   |
       |  |               |         |                |      +----------------+   |
       |  |               |         |  Sevrice/POST  |      +----------------+   |
       |  |   UI_POD      +---------+                +----->+  POST_POD      |   |
       |  |               |         |  10.102.1.1    |      |                |   |
       |  |               |         |                |      |  10.102.C.D    |   |
       |  +---------------+         +----------------+      +----------------+   |
       |                                     |              +----------------+   |
       |                                     |              |  POST_POD      |   |
       |                                     +------------->+                |   |
       |         K8S                                        |  10.102.F.E    |   |
       |                                                    +----------------+   |
       +-------------------------------------------------------------------------+
```
### Kube-dns

Отметим, что Service - это лишь абстракция и описание того, как
получить доступ к сервису. Но опирается она на реальные
механизмы и объекты: DNS-сервер, балансировщики, iptables.
Для того, чтобы дойти до сервиса, нам нужно узнать его адрес
по имени. Kubernetes не имеет своего собственного DNSсервера для разрешения имен. Поэтому используется плагин
kube-dns (это тоже Pod).

Его задачи:
- ходить в API Kubernetes’a и отслеживать Service-объекты
- заносить DNS-записи о Service’ах в собственную базу
- предоставлять DNS-сервис для разрешения имен в IP-адреса
(как внутренних, так и внешних)

#### Схема приобретает следующий вид

```
+-------------------------------------------------------------------------+
|                                                    +----------------+   |
|                                     +------------->+  POST_POD      |   |
|                                     |              |                |   |
|                                     |              |                |   |
|  +---------------+         +--------+-------+      +----------------+   |
|  |               |         |  Sevrice/POST  |      +----------------+   |
|  |   UI_POD      +---------+                +----->+  POST_POD      |   |
|  |               |         |                |                       |   |
|  |               |         +--------+-------+      |                |   |
|  +--------------++----+             |              +----------------+   |
|                 ^     |             |              +----------------+   |
|                 |     |             |              |  POST_POD      |   |
|  +-----+----->+-+-----v-----+       +------------->+                |   |
|  | K8S |      |  KUBE-DNS   |                      |                |   |
|  +-----+<-----+-------------+                      +----------------+   |
|                                                                         |
+-------------------------------------------------------------------------+
```

Можете убедиться, что при отключенном kube-dns сервисе
связность между компонентами reddit-app пропадет и он
перестанет работать

1) Проскейлим в 0 сервис, который следит, чтобы dns-kube
подов всегда хватало

```
kubectl scale deployment --replicas 0 -n kube-system kube-dns-autoscaler

deployment.extensions/kube-dns-autoscaler scaled
```
2) Проскейлим в 0 сам kube-dns

```
kubectl scale deployment --replicas 0 -n kube-system kube-dns 

deployment.extensions/kube-dns scaled
```
3) Попробуйте достучатсья по имени до любого сервиса

```
kubectl get pods    

NAME                       READY   STATUS    RESTARTS   AGE
comment-854c7bc5b4-bzj6t   1/1     Running   0          21m
comment-854c7bc5b4-d588f   1/1     Running   0          21m
comment-854c7bc5b4-mt8dg   1/1     Running   0          21m
mongo-5d7969f8cd-js9nr     1/1     Running   0          21m
post-86974979b-hnphn       1/1     Running   0          21m
post-86974979b-kn6ws       1/1     Running   0          21m
post-86974979b-pddfx       1/1     Running   0          21m
ui-74846d8c5d-6rs9s        1/1     Running   0          21m
ui-74846d8c5d-6rwht        1/1     Running   0          21m
ui-74846d8c5d-mqf6v        1/1     Running   0          21m

kubectl exec -ti post-86974979b-hnphn ping ui
ping: bad address 'ui'
command terminated with exit code 1

kubectl exec -ti post-86974979b-hnphn ping comment
ping: bad address 'comment'
command terminated with exit code 1
```

Верну автоскейлер и куб-днс:

```
kubectl scale deployment --replicas 1 -n kube-system kube-dns
deployment.extensions/kube-dns scaled

kubectl scale deployment --replicas 1 -n kube-system kube-dns-autoscaler
deployment.extensions/kube-dns-autoscaler scaled
```

5) Проверьте, что приложение заработало

```
kubectl exec -ti post-86974979b-hnphn ping comment
PING comment (10.102.10.77): 56 data bytes
^C
--- comment ping statistics ---
13 packets transmitted, 0 packets received, 100% packet loss
command terminated with exit code 1

kubectl exec -ti post-86974979b-hnphn ping ui     
PING ui (10.102.9.136): 56 data bytes
^C
--- ui ping statistics ---
2 packets transmitted, 0 packets received, 100% packet loss
command terminated with exit code 1

```
Как уже говорилось, ClusterIP - виртуальный и не
принадлежит ни одной реальной физической сущности.
Его чтением и дальнейшими действиями с пакетами,
принадлежащими ему, занимается в нашем случае iptables,
который настраивается утилитой kube-proxy (забирающей
инфу с API-сервера). 

Сам kube-proxy, можно настроить на прием трафика, но это
устаревшее поведение и не рекомендуется его применять.

На любой из нод кластера можете посмотреть эти правила
IPTABLES.

Kubernetes не имеет в комплекте механизма организации overlayсетей (как у Docker Swarm). Он лишь предоставляет интерфейс
для этого. Для создания Overlay-сетей используются отдельные
аддоны: Weave, Calico, Flannel, … . В Google Kontainer Engine (GKE)
используется собственный плагин kubenet (он - часть kubelet).
Он работает только вместе с платформой GCP и, по-сути
занимается тем, что настраивает google-сети для передачи
трафика Kubernetes. Поэтому в конфигурации Docker сейчас вы
не увидите никаких Overlay-сетей. 

Посмотреть правила, согласно которым трафик
отправляется на ноды можно здесь:
https://console.cloud.google.com/networking/routes/

### nodePort

Service с типом NodePort - похож на сервис типа
ClusterIP, только к нему прибавляется прослушивание
портов нод (всех нод) для доступа к сервисам снаружи.
При этом ClusterIP также назначается этому сервису для
доступа к нему изнутри кластера.
kube-proxy прослушивается либо заданный порт
(nodePort: 32092), либо порт из диапазона 30000-32670.
Дальше IPTables решает, на какой Pod попадет трафик

Добавил в терраформ открытие порта 32092 в фаерволе.

Проверил, постучался на ноду первую на http://35.193.218.154:32092/ и увидел UI.

### LoadBalancer

Тип NodePort хоть и предоставляет доступ к сервису
снаружи, но открывать все порты наружу или искать IPадреса наших нод (которые вообще динамические) не
очень удобно. 

Тип LoadBalancer позволяет нам использовать внешний
облачный балансировщик нагрузки как единую точку
входа в наши сервисы, а не полагаться на IPTables и не
открывать наружу весь кластер.

Настроим соответствующим образом Service UI 

```
---
apiVersion: v1
kind: Service
metadata:
  name: ui
  labels:
    app: reddit
    component: ui
spec:
#  type: NodePort
  type: LoadBalancer
  ports:
#    - nodePort: 32092
#      port: 9292
    - port: 80
      protocol: TCP
      targetPort: 9292
  selector:
    app: reddit
    component: ui

```

передеплою сервис:

```
kubectl apply -f ui-service.yml

kubectl get services           
NAME         TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
comment      ClusterIP      10.102.0.146   <none>        9292/TCP       14m
comment-db   ClusterIP      10.102.2.145   <none>        27017/TCP      14m
kubernetes   ClusterIP      10.102.0.1     <none>        443/TCP        32m
mongodb      ClusterIP      10.102.2.19    <none>        27017/TCP      14m
post         ClusterIP      10.102.7.129   <none>        5000/TCP       14m
post-db      ClusterIP      10.102.6.8     <none>        27017/TCP      14m
ui           LoadBalancer   10.102.0.191   <pending>     80:30736/TCP   14m

kubectl get services --selector component=ui
NAME   TYPE           CLUSTER-IP     EXTERNAL-IP       PORT(S)        AGE
ui     LoadBalancer   10.102.0.191   104.154.210.206   80:30736/TCP   15m
```
Проверяю http://104.154.210.206/ - работает!


В консоли ГКЕ вижу как появился новый внешний адрес:
```
104.154.210.206	us-central1		IPv4	Правило переадресации a7b9d7bdfa46946d690c51a546445675
```

Там же вижу в сетевых сервисах новый LB:
```
a7b9d7bdfa46946d690c51a546445675	TCP	us-central1	 1 целевой пул (3 экземпляра)
```

#### Балансировка с помощью Service типа LoadBalancing имеет ряд недостатков:

- нельзя управлять с помощью http URI (L7-балансировка)
- используются только облачные балансировщики (AWS,GCP)
- нет гибких правил работы с трафиком

### Ingress

Для более удобного управления входящим
снаружи трафиком и решения недостатков
LoadBalancer можно использовать другой объект
Kubernetes - Ingress.

Ingress – это набор правил внутри кластера Kubernetes,
предназначенных для того, чтобы входящие подключения
могли достичь сервисов (Services) 

Сами по себе Ingress’ы это просто правила. Для их
применения нужен Ingress Controller

### Ingress Conroller

Для работы Ingress-ов необходим Ingress Controller.
В отличие остальных контроллеров k8s - он не стартует
вместе с кластером. 

Ingress Controller - это скорее плагин (а значит и отдельный
POD), который состоит из 2-х функциональных частей: 

- Приложение, которое отслеживает через k8s API новые объекты Ingress и обновляет конфигурацию балансировщика
- Балансировщик (Nginx, haproxy, traefik,…), который и занимается управлением сетевым трафиком

Основные задачи, решаемые с помощью Ingress’ов: 

 - Организация единой точки входа в приложения снаружи
 - Обеспечение балансировки трафика
 - Терминация SSL
 - Виртуальный хостинг на основе имен и т.д

#### Ingress

Посколько у нас web-приложение, нам вполне было бы
логично использовать L7-балансировщик вместо Service
LoadBalancer. 

Google в GKE уже предоставляет возможность использовать
их собственные решения балансирощик в качестве Ingress
controller-ов. 

Перейдите в настройки кластера в веб-консоли gcloud
Убедитесь, что встроенный Ingress включен.
Если нет - включите
.... ну это же не наш метод) надо в терраформе бахнуть "http_load_balancing    = true" и проверить как поменяется в консоли:)
сделяль

#### Создадим Ingress для сервиса UI:

```
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
    name: ui
spec:
    backend:
        serviceName: ui
        servicePort: 80

```
не понятно что-как писать в апи? тут по логике:
```
kubectl api-versions
```
но лучше точно вот тут почитать тоже:
https://cloud.google.com/kubernetes-engine/docs/concepts/ingress

Это Singe Service Ingress -
значит, что весь ingress
контроллер будет просто
балансировать нагрузку на
Node-ы для одного сервиса
(очень похоже на Service
LoadBalancer)

Применим конфиг и зайдем в консоль GCP и увидим уже несколько правил
```
kubectl apply -f ui-ingress.yml
ingress.extensions/ui created
```
>k8s-um-default-ui--ef720f6ad172ce36	HTTP	Глобальный	 1 серверная служба (3 группы экземпляров, 0 групп конечных точек сети)**
>Серверная часть
>Серверные службы
>1. k8s-be-30736--ef720f6ad172ce36
>Протокол конечной точки: HTTP Именованный порт: ***port30736*** Время ожидания: 30 сек. Cloud CDN: отключен Политика трафика: отключена Проверка состояния: 

***port30736*** это NodePort
опубликованного сервиса
Т.е. для работы с Ingress в
GCP нам нужен минимум
Service с типом NodePort
(он уже есть)

#### Посмотрим в сам кластер:

```
kubectl get ingress
NAME   HOSTS   ADDRESS          PORTS   AGE
ui     *       34.107.254.133   80      21m
```
Адрес сервиса http://34.107.254.133/

Работает.

#### В текущей схеме есть несколько недостатков:

- у нас 2 балансировщика для 1 сервиса
- Мы не умеем управлять трафиком на уровне HTTP

#### Один балансировщик можно спокойно убрать. Обновим сервис для UI:
ui-service.yml

```
---
apiVersion: v1
kind: Service
metadata:
  name: ui
  labels:
    app: reddit
    component: ui
spec:
  type: NodePort
#  type: LoadBalancer
  ports:
#    - nodePort: 32092
    - port: 9292
#    - port: 80
      protocol: TCP
      targetPort: 9292
  selector:
    app: reddit
    component: ui

```
Применяю:

```
kubectl apply -f ui-service.yml 
service/ui configured

```

Заставим работать Ingress Controller как классический веб
ui-ingress.yml

```
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ui
spec:
  rules:
  - http:
      paths:
      - path: /*
        backend:
          serviceName: ui
          servicePort: 9292

```
Обновлю ингрес:

```
kubectl apply -f ui-ingress.yml 
ingress.extensions/ui configured

kubectl get ingress
NAME   HOSTS   ADDRESS          PORTS   AGE
ui     *       34.107.254.133   80      44m
```
ЖДЕМ, потом проверяем, не все сразу перестраивается.

Проверяем, работает хорошо.

### Secret

Теперь давайте защитим наш сервис с помощью TLS.
Для начала вспомним Ingress IP 

```
kubectl get ingress
NAME   HOSTS   ADDRESS          PORTS   AGE
ui     *       34.107.254.133   80      52m
```
Далее подготовим сертификат используя IP как CN:
```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=34.107.254.133"
Generating a RSA private key
.....................................................................+++++
.........+++++
writing new private key to 'tls.key'
-----
```
Загружу сертификат в кластер:
```
kubectl create secret tls ui-ingress --key tls.key --cert tls.crt
secret/ui-ingress created
```
НО ЕСЛИ У НАС НЕ ДЕФОЛТНЫЙ НЕЙМСПЕЙС, ТО ВОТ ТАК:
```
kubectl create secret tls ui-ingress --key tls.key --cert tls.crt -n dev
secret/ui-ingress created
```
Проверить можно командой:

```
kubectl describe secret ui-ingress
Name:         ui-ingress
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  kubernetes.io/tls

Data
====
tls.crt:  1127 bytes
tls.key:  1704 bytes
```
Или, в случае с другим НС:
```
kubectl describe secret ui-ingress -n dev
Name:         ui-ingress
Namespace:    dev
Labels:       <none>
Annotations:  <none>

Type:  kubernetes.io/tls

Data
====
tls.crt:  1127 bytes
tls.key:  1704 bytes

```
### TLS Termination. Теперь настроим Ingress на прием только HTTPS траффика.

Теперь настроим Ingress на прием только HTTPS траффика

ui-ingress.yml

```
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
    name: ui
    annotations:
        kubernetes.io/ingress.allow-http: "false"
spec:
    tls:
        - secretName: ui-ingress
    backend:
        serviceName: ui
        servicePort: 9292

```
```
kubectl apply -f ui-ingress.yml 
ingress.extensions/ui configured

kubectl get ingress            
NAME   HOSTS   ADDRESS         PORTS     AGE
ui     *       34.107.147.50   80, 443   74m
```
Зайдем на страницу web console и увидим в описании нашего
балансировщика только один протокол HTTPS 

Иногда протокол HTTP может не удалиться у существующего
Ingress правила, тогда нужно его вручную удалить и
пересоздать

```
ubectl delete ingress ui
ingress.extensions "ui" deleted

kubectl apply -f ui-ingress.yml 
ingress.extensions/ui created
```
ЖДЕЕЕЕЕЕЕЕЕЕЕЕЕЕЕЕМ. Все долго.

Правила Ingress могут долго применяться, если не
получилось зайти с первой попытки - подождите и
попробуйте еще раз

Заходим на страницу нашего приложения по https, а не 443 тупо,
подтверждаем исключение безопасности (у нас сертификат
самоподписанный) и видим что все работает

### Задание со* 
Опишите создаваемый объект Secret в виде Kubernetes-манифеста.

```
mk certificates_for_tls && cd certificates_for_tls
```

https://kubernetes.io/docs/concepts/configuration/secret/
https://cloud.google.com/kubernetes-engine/docs/concepts/secret
https://kubernetes.io/docs/concepts/services-networking/ingress/#types-of-ingress
https://cloud.croc.ru/blog/byt-v-teme/kubernetes-ustanovka-tls-ssl-sertifikatov/
https://serveradmin.ru/kubernetes-ingress/#SSLTLS__Ingress
https://stackoverflow.com/questions/49614439/kubernetes-secret-types
Подсказали добрые люди:
https://github.com/kubernetes/kubernetes/blob/release-1.15/pkg/apis/core/types.go#L4530

```
// SecretTypeTLS contains information about a TLS client or server secret. It
// is primarily used with TLS termination of the Ingress resource, but may be
// used in other types.
//
// Required fields:
// - Secret.Data["tls.key"] - TLS private key.
//   Secret.Data["tls.crt"] - TLS certificate.
// TODO: Consider supporting different formats, specifying CA/destinationCA.

SecretTypeTLS SecretType = "kubernetes.io/tls"
// TLSCertKey is the key for tls certificates in a TLS secret.
TLSCertKey = "tls.crt"
// TLSPrivateKeyKey is the key for the private key field in a TLS secret.
TLSPrivateKeyKey = "tls.key"
```

файл ui-secret.yml типа такого нифига не работает:
```yml
---
apiVersion: v1
kind: Secret
metadata:
  name: ui-ingress
type: kubernetes.io/tls
data:
  tls.crt: base64-encoded-content-of_tls.crt
  tls.key: base64-encoded-content-of_tls.key
```
файл ui-secret.yml типа такого тоже нифига не работает:
```yml
---
apiVersion: v1
kind: Secret
metadata:
  name: ui-ingress
type: kubernetes.io/tls
data:
  tls.crt: содержимо этого файла
  tls.key: содержимо этого файла
```

так что отложу на потом
-------------------------------------------------------

## Network Policy

В прошлых проектах мы договорились о том, что хотелось бы разнести
сервисы базы данных и сервис фронтенда по разным сетям, сделав их
недоступными друг для друга. И приняли следующую схему сервисов. 

В Kubernetes у нас так сделать не получится с помощью отдельных
сетей, так как все POD-ы могут достучаться друг до друга по-умолчанию.

Мы будем использовать NetworkPolicy - инструмент
для декларативного описания потоков трафика.
Отметим, что не все сетевые плагины поддерживают
политики сети.
В частности, у GKE эта функция пока в Beta-тесте и для
её работы отдельно будет включен сетевой плагин
Calico (вместо Kubenet)

Давайте ее протеструем

Наша задача - ограничить трафик, поступающий на
mongodb отовсюду, кроме сервисов post и comment. 

### Найдите имя кластера

```bash
gcloud beta container clusters list
NAME                                  LOCATION        MASTER_VERSION  MASTER_IP      MACHINE_TYPE   NODE_VERSION  NUM_NODES  STATUS
simple-autoscale-clusterkubernetes-3  europe-west1-b  1.15.9-gke.9    35.233.111.53  n1-standard-1  1.15.9-gke.9  3          RUNNING

```
Включим network-policy для GKE

```bash
gcloud beta container clusters update simple-autoscale-clusterkubernetes-3 --zone=europe-west1-b --update-addons=NetworkPolicy=ENABLED

Updating simple-autoscale-clusterkubernetes-3...done.                                                                                                                                        
Updated [https://container.googleapis.com/v1beta1/projects/diploma-266217/zones/europe-west1-b/clusters/simple-autoscale-clusterkubernetes-3].
To inspect the contents of your cluster, go to: https://console.cloud.google.com/kubernetes/workload_/gcloud/europe-west1-b/simple-autoscale-clusterkubernetes-3?project=diploma-266217

gcloud beta container clusters update simple-autoscale-clusterkubernetes-3 --zone=europe-west1-b --enable-network-policy

Enabling/Disabling Network Policy causes a rolling update of all 
cluster nodes, similar to performing a cluster upgrade.  This 
operation is long-running and will block other operations on the 
cluster (including delete) until it has run to completion.

Do you want to continue (Y/n)?  y

Updating simple-autoscale-clusterkubernetes-3...done.                                                                                                                                        
Updated [https://container.googleapis.com/v1beta1/projects/diploma-266217/zones/europe-west1-b/clusters/simple-autoscale-clusterkubernetes-3].
To inspect the contents of your cluster, go to: https://console.cloud.google.com/kubernetes/workload_/gcloud/europe-west1-b/simple-autoscale-clusterkubernetes-3?project=diploma-266217

```
Дождитесь, пока кластер обновится
Вам может быть предложено добавить beta-функционал в gcloud -
нажмите yes. 

### mongo-network-policy.yml 

```yml
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-db-traffic
  labels:
    app: reddit
spec:
# Выбираем объекты:
# - Выбираем объекты политики (pod’ы с mongodb)
  podSelector:
    matchLabels:
      app: reddit
      component: mongo
# Блок запрещающих направлений:
# - Запрещаем все входящие подключения
# - Исходящие разрешены
  policyTypes:
  - Ingress
# Блок разрешающих правил:
# - Разрешаем все входящие подключения от
# - POD-ов с label-ами comment.
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: reddit
          component: comment
```
### Применяем политику
```
kubectl apply -f mongo-network-policy.yml
```
Заходим в приложение
Post-сервис не может достучаться до базы.

```yml
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-db-traffic
  labels:
    app: reddit
spec:
# Выбираем объекты:
# - Выбираем объекты политики (pod’ы с mongodb)
  podSelector:
    matchLabels:
      app: reddit
      component: mongo
# Блок запрещающих направлений:
# - Запрещаем все входящие подключения
# - Исходящие разрешены
  policyTypes:
  - Ingress
# Блок разрешающих правил:
# - Разрешаем все входящие подключения от
# - POD-ов с label-ами comment.
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: reddit
          component: comment
# - Разрешаем все входящие подключения от
# - POD-ов с label-ами post.
  - from:
    - podSelector:
        matchLabels:
          app: reddit
          component: post

```
## Хранилище для базы

Рассмотрим вопросы хранения данных. Основной
Stateful сервис в нашем приложении - это база данных
MongoDB.
В текущий момент она запускается в виде Deployment и
хранит данные в стаднартный Docker Volume-ах. Это
имеет несколько проблем:
- при удалении POD-а удаляется и Volume
- потеря Nod’ы с mongo грозит потерей данных
- запуск базы на другой ноде запускает новый
экземпляр данных

mongo-deployment.yml
```yml
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: mongo
  labels:
    app: reddit
    component: mongo
    post-db: "true"
    comment-db: "true"
spec:
  replicas: 1
  selector:
    matchLabels:
      app: reddit
      component: mongo
  template:
    metadata:
      name: mongo
      labels:
        app: reddit
        component: mongo
        post-db: "true"
        comment-db: "true"
    spec:
      containers:
      - image: mongo:3.2
        name: mongo
# Подключаем Volume
        volumeMounts:
        - name: mongo-persistent-storage
          mountPath: /data/db
# Объявляем Volume
      volumes:
      - name: mongo-persistent-storage
        emptyDir: {}
```

Сейчас используется тип Volume emptyDir. При создании пода с
таким типом просто создается пустой docker volume.
При остановке POD’a содержимое emtpyDir удалится навсегда. Хотя
в общем случае падение POD’a не вызывает удаления Volume’a.
Задание:
1) создайте пост в приложении
2) удалите deployment для mongo
3) Создайте его заново 

сделал
посты все удалились

Вместо того, чтобы хранить данные локально на ноде, имеет смысл
подключить удаленное хранилище. В нашем случае можем
использовать Volume gcePersistentDisk, который будет складывать
данные в хранилище GCE.

### Создадим диск в Google Cloud:
```bash
gcloud compute disks create --size=25GB --zone=europe-west1-b reddit-mongo-disk

WARNING: You have selected a disk size of under [200GB]. This may result in poor I/O performance. For more information, see: https://developers.google.com/compute/docs/disks#performance.
Created [https://www.googleapis.com/compute/v1/projects/diploma-266217/zones/europe-west1-b/disks/reddit-mongo-disk].

NAME               ZONE            SIZE_GB  TYPE         STATUS
reddit-mongo-disk  europe-west1-b  25       pd-standard  READY

New disks are unformatted. You must format and mount a disk before it
can be used. You can find instructions on how to do this at:

https://cloud.google.com/compute/docs/disks/add-persistent-disk#formatting

```
### Добавим новый Volume POD-у базы. 

Монтируем выделенный диск к POD’у mongo

```yml
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: mongo
  labels:
    app: reddit
    component: mongo
    post-db: "true"
    comment-db: "true"
spec:
  replicas: 1
  selector:
    matchLabels:
      app: reddit
      component: mongo
  template:
    metadata:
      name: mongo
      labels:
        app: reddit
        component: mongo
        post-db: "true"
        comment-db: "true"
    spec:
      containers:
      - image: mongo:3.2
        name: mongo
        volumeMounts:
        - name: mongo-gce-pd-storage
          mountPath: /data/db
      volumes:
      - name: mongo-persistent-storage
        emptyDir: {}
        volumes:
      - name: mongo-gce-pd-storage
        gcePersistentDisk:
          pdName: reddit-mongo-disk
          fsType: ext4

```
Зайдем в приложение и добавим пост
Удалим deployment 
Снова создадим деплой mongo. 

Наш пост все еще на месте

[можно посмотреть на созданный диск и увидеть какой
машиной он используется](https://console.cloud.google.com/compute/disks)

## PersistentVolume

Используемый механизм Volume-ов можно сделать удобнее.
Мы можем использовать не целый выделенный диск для
каждого пода, а целый ресурс хранилища, общий для всего
кластера.
Тогда при запуске Stateful-задач в кластере, мы сможем
запросить хранилище в виде такого же ресурса, как CPU или
оперативная память. 

Для этого будем использовать механизм PersistentVolume.

Создадим описание PersistentVolume 

```yml
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: reddit-mongo-disk
spec:
  capacity:
    storage: 25Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  gcePersistentDisk:
    fsType: "ext4" 
    pdName: "reddit-mongo-disk"
```

```bash
kubectl apply -f mongo-volume.yml
persistentvolume/reddit-mongo-disk created
```
Мы создали PersistentVolume в виде диска в GCP

### PersistentVolumeClaim

Мы создали ресурс дискового хранилища, распространенный
на весь кластер, в виде PersistentVolume. 

Чтобы выделить приложению часть такого ресурса - нужно
создать запрос на выдачу - PersistentVolumeClaim.
Claim - это именно запрос, а не само хранилище.

С помощью запроса можно выделить место как из
конкретного PersistentVolume (тогда параметры accessModes
и StorageClass должны соответствовать, а места должно
хватать), так и просто создать отдельный PersistentVolume под
конкретный запрос.

### Создадим описание PersistentVolumeClaim (PVC) 

```yml
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
# Имя PersistentVolumeClame'а
  name: mongo-pvc
spec:
# accessMode у PVC и у PV должен совпадать
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 15Gi

```
Добавим PersistentVolumeClaim в кластер
```
$ kubectl apply -f mongo-claim.yml
```

Мы выделили место в PV по запросу для нашей базы.
Одновременно использовать один PV можно только по
одному Claim’у

***Если Claim не найдет по заданным параметрам PV внутри кластера, либо тот будет занят другим Claim’ом то он сам создаст нужный ему PV воспользовавшись стандартным StorageClass.***

```bash
kubectl describe storageclass standard
Name:                  standard
IsDefaultClass:        Yes
Annotations:           storageclass.kubernetes.io/is-default-class=true
Provisioner:           kubernetes.io/gce-pd
Parameters:            type=pd-standard
AllowVolumeExpansion:  True
MountOptions:          <none>
ReclaimPolicy:         Delete
VolumeBindingMode:     Immediate
Events:                <none>
```
В нашем случае это обычный медленный Google Cloud
Persistent Drive

### Подключение PVC

mongo-deployment.yml
```yml
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: mongo
  labels:
    app: reddit
    component: mongo
    post-db: "true"
    comment-db: "true"
spec:
  replicas: 1
  selector:
    matchLabels:
      app: reddit
      component: mongo
  template:
    metadata:
      name: mongo
      labels:
        app: reddit
        component: mongo
        post-db: "true"
        comment-db: "true"
    spec:
      containers:
      - image: mongo:3.2
        name: mongo
        volumeMounts:
        - name: mongo-gce-pd-storage
          mountPath: /data/db
      volumes:
      - name: mongo-gce-pd-storage
        persistentVolumeClaim:
          claimName: mongo-pvc
```
Обновим описание нашего Deployment’а
$ kubectl apply -f mongo-deployment.yml

Монтируем выделенное по PVC хранилище к POD’у
mongo

## Динамическое выделение Volume'ов

Создав PersistentVolume мы отделили объект "хранилища" от
наших Service'ов и Pod'ов. Теперь мы можем его при
необходимости переиспользовать. 

Но нам гораздо интереснее создавать хранилища при
необходимости и в автоматическом режиме. В этом нам
помогут StorageClass’ы. Они описывают где (какой
провайдер) и какие хранилища создаются. 

В нашем случае создадим StorageClass Fast так, чтобы
монтировались SSD-диски для работы нашего хранилища.

### StorageClass

Создадим описание StorageClass’а

storage-fast.yml
```yml
---
kind: StorageClass
apiVersion: storage.k8s.io/v1beta1
metadata:
# Имя StorageClass'а
  name: fast
# Провайдер хранилища
provisioner: kubernetes.io/gce-pd
parameters:
# Тип предоставляемого хранилища
  type: pd-ssd
```
Добавим StorageClass в кластер
$ kubectl apply -f storage-fast.yml

### PVC + StorageClass

Создадим описание PersistentVolumeClaim
mongo-claim-dynamic.yml
```yml
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: mongo-pvc-dynamic
spec:
  accessModes:
    - ReadWriteOnce
# Вместо ссылки на
# созданный диск, теперь мы
# ссылаемся на StorageClass
  storageClassName: fast
  resources:
    requests:
      storage: 10Gi

```
```bash
kubectl apply -f mongo-claim-dynamic.yml
```
### Подключение динамического PVC

Подключим PVC к нашим Pod'ам

mongo-deployment.yml
```yml
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: mongo
  labels:
    app: reddit
    component: mongo
    post-db: "true"
    comment-db: "true"
spec:
  replicas: 1
  selector:
    matchLabels:
      app: reddit
      component: mongo
  template:
    metadata:
      name: mongo
      labels:
        app: reddit
        component: mongo
        post-db: "true"
        comment-db: "true"
    spec:
      containers:
      - image: mongo:3.2
        name: mongo
        volumeMounts:
        - name: mongo-gce-pd-storage
          mountPath: /data/db
      volumes:
      - name: mongo-gce-pd-storage
        persistentVolumeClaim:
# Обновим PersistentVolumeClaim
          claimName: mongo-pvc-dynamic

```
Обновим описание нашего Deployment

```
kubectl apply -f mongo-deployment.yml
```
### Давайте посмотрит какие в итоге у нас получились PersistentVolume'ы

```
kubectl get persistentvolume 
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                       STORAGECLASS   REASON   AGE
pvc-744f479a-c9b6-446f-926d-933d6bb17988   15Gi       RWO            Delete           Bound       default/mongo-pvc           standard                16m
pvc-798d23de-9a16-4287-a8da-3f4fe46feaed   10Gi       RWO            Delete           Bound       default/mongo-pvc-dynamic   fast                    3m15s
reddit-mongo-disk                          25Gi       RWO            Retain           Available                                                       22m
```
STATUS - Статус PV по отношению к
Pod'ам и Claim'ам

CLAIM -  какому Claim'у привязан
данный PV

StorageClass данного PV

[На созданные Kubernetes'ом диски можно посмотреть в web console](https://console.cloud.google.com/compute/disks)

# HW 28 Интеграция Kubernetes в GitlabCI. CI/CD в Kubernetes.

### План
Работа с Helm3
Развертывание Gitlab в Kubernetes
Запуск CI/CD конвейера в Kubernetes

## Helm

Helm - пакетный менеджер для Kubernetes.
С его помощью мы будем:
1. Стандартизировать поставку приложения в Kubernetes
2. Декларировать инфраструктуру
3. Деплоить новые версии приложения

### Helm - установка

Helm - клиент-серверное приложение. Установим его
клиентскую часть - консольный клиент Helm

https://github.com/helm/helm/releases

распакуйте и разместите исполняемый файл helm в директории
исполнения (/usr/local/bin/ , /usr/bin, …)

я, чтоб иметь 2 хельм и 3 одновременно, имею на машине бинарники helm и helm3 соответственно,
 по этому далее это будет в выдержках из выполяемых команд.

Helm читает конфигурацию kubectl (~/.kube/config) и сам
определяет текущий контекст (кластер, пользователь, неймспейс)
Если хотите сменить кластер, то либо меняйте контекст с
помощью

```bash
$ kubectl config set-context
```

либо подгружайте helm’у собственный config-файл флагом --
kube-context.

Тиллер я ставить не буду, т.к. использую хельм 3,1,1

### Charts

Chart - это пакет в Helm.
Charts в папке kubernetes со следующей
структурой директорий:

├── Charts
├── comment
├── post
├── reddit
└── ui

***ВАЖНО!!! Helm предпочитает .yaml !!!***

### Начнем разработку Chart’а для компонента ui приложения
Создайте файл-описание chart’а.

```bash
touch ui/Chart.yaml
```

```yml
name: ui
version: 1.0.0
description: OTUS reddit application UI
maintainers:
- name: Someone
email: my@mail.com
appVersion: 1.0

```
Реально значимыми являются поля name и version. От них
зависит работа Helm’а с Chart’ом. Остальное - описания

### Templates

Основным содержимым Chart’ов являются шаблоны
манифестов Kubernetes.

1. Создаю директорию ui/templates
2. Переношу в неё все манифесты, разработанные ранее для
сервиса ui (ui-service, ui-deployment, ui-ingress)
3. Переименую их (уберите префикс “ui-“) и поменяйте расширение
на .yaml) - стилистические правки

└── ui
├── Chart.yaml
├── templates
│ ├── deployment.yaml
│ ├── ingress.yaml
│ └── service.yaml

По-сути, это уже готовый пакет для установки в Kubernetes
1. Убедитесь, что у вас не развернуты компоненты приложения в
kubernetes. Если развернуты - удалите их
2. Установим Chart

```bash
helm3 install test-ui-1 ui/
NAME: test-ui-1
LAST DEPLOYED: Wed Feb 26 22:58:56 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None

```
```bash
helm3 ls
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
test-ui-1       default         1               2020-02-26 22:58:56.057373673 +0300 MSK deployed        ui-1.0.0        1          

kubectl get pods
NAME                  READY   STATUS              RESTARTS   AGE
ui-74846d8c5d-d9trz   0/1     ContainerCreating   0          68s
ui-74846d8c5d-npdf6   1/1     Running             0          68s
ui-74846d8c5d-r45g4   1/1     Running             0          68s

```
### Шаблонизируем

Теперь сделаем так, чтобы можно было использовать 1 Chart для
запуска нескольких экземпляров (релизов). Шаблонизируем его.
ui/templates/service.yaml

```yml
---
apiVersion: v1
kind: Service
metadata:
# уникальное имя запущенного сервиса
  name: {{ .Release.Name }}-{{ .Chart.Name }}
  labels:
    app: reddit
    component: ui
# сервис из конкретного релиза
    release: {{ .Release.Name }}
spec:
  type: NodePort
  ports:
  - port: {{ .Values.service.externalPort }}
    protocol: TCP
    targetPort: 9292
  selector:
# селектр подов из конкретного релиза
    app: reddit
    component: ui
    release: {{ .Release.Name }}
```
Объяснение:

name: {{ .Release.Name }}-{{ .Chart.Name }}
Здесь мы используем встроенные переменные

Release - группа переменных с информацией о релизе
(конкретном запуске Chart’а в k8s)

.Chart - группа переменных с информацией о Chart’е (содержимое
файла Chart.yaml)

Также еще есть группы переменных:

.Template - информация о текущем шаблоне ( .Name и .BasePath)
.Capabilities - информация о Kubernetes (версия, версии API)
.Files.Get - получить содержимое файла

Шаблонизируем подобным образом остальные сущности
ui/templates/deployment.yaml

```yml
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}
  labels:
    app: reddit
    component: ui
    release: {{ .Release.Name }}
spec:
  replicas: 3
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: reddit
      component: ui
      release: {{ .Release.Name }}
  template:
    metadata:
      name: ui
      labels:
        app: reddit
        component: ui
        release: {{ .Release.Name }}
    spec:
      containers:
      - image: chromko/ui
        name: ui
        ports:
        - containerPort: 9292
          name: ui
          protocol: TCP
        env:
        - name: ENV
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
```
Шаблонизируем подобным образом остальные сущности
ui/templates/ingress.yaml

```yml
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}
  annotations:
    kubernetes.io/ingress.class: "gce"
spec:
  rules:
  - http:
      paths:
      - path: /*
        backend:
          serviceName: {{ .Release.Name }}-{{ .Chart.Name }}
          servicePort: {{ .Values.service.externalPort }}
```
### Установим несколько релизов ui

```bash
helm3 install test-ui-2 ./ui/
Error: template: ui/templates/service.yaml:15:20: executing "ui/templates/service.yaml" at <.Values.service.externalPort>: nil pointer evaluating interface {}.externalPort
```
а почему? а по тому что у нас уже есть {{ .Values.service.externalPort }}, который требует или наличия файла Values, либо значения по умолчанию.

Ну и по тому вопреки методичке красиво вот тут не будет:

```bash
kubectl get ingress                 
NAME   HOSTS   ADDRESS   PORTS     AGE
ui     *                 80, 443   58m
```
не дождался айпишник первого резиза ингресса

По IP-адресам можно попасть на разные релизы ui-приложений.
P.S. подождите пару минут, пока ingress’ы станут доступными... ну да

### Дополнительная параметризация всех компонентов чарта ui и Values
Мы уже сделали возможность запуска нескольких версий
приложений из одного пакета манифестов, используя лишь
встроенные переменные. Кастомизируем установку своими
переменными (образ и порт).

ui/templates/deployment.yaml

```yml
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}
  labels:
    app: reddit
    component: ui
    release: {{ .Release.Name }}
spec:
  replicas: 3
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: reddit
      component: ui
      release: {{ .Release.Name }}
  template:
    metadata:
      name: ui
      labels:
        app: reddit
        component: ui
        release: {{ .Release.Name }}
    spec:
      containers:
      - image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        name: ui
        ports:
        - containerPort: {{ .Values.service.internalPort }}
          name: ui
          protocol: TCP
        env:
        - name: ENV
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
...

```
ui/templates/service.yaml

```yml
---
apiVersion: v1
kind: Service
metadata:
# уникальное имя запущенного сервиса
  name: {{ .Release.Name }}-{{ .Chart.Name }}
  labels:
    app: reddit
    component: ui
# сервис из конкретного релиза
    release: {{ .Release.Name }}
spec:
  type: NodePort
  ports:
  - port: {{ .Values.service.externalPort }}
    protocol: TCP
    targetPort: {{ .Values.service.internalPort }}
  selector:
# селектр подов из конкретного релиза
    app: reddit
    component: ui
    release: {{ .Release.Name }}
...

```

ui/templates/ingress.yaml

```yml
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}
  annotations:
    kubernetes.io/ingress.class: "gce"
spec:
  rules:
  - http:
      paths:
      - path: /
        backend:
          serviceName: {{ .Release.Name }}-{{ .Chart.Name }}
          servicePort: {{ .Values.service.externalPort }}
...
```

Определим значения собственных переменных ui/values.yaml

```yml
---
service:
  internalPort: 9292
  externalPort: 9292

image:
  repository: decapapreta/ui
  tag: "1.0"
```
**Важно** - тэг докер образа лучше брать в кавычки вопреки методичке, иначе тег 1.0 обрабатывается как число! т.е. верная запись выглядит как "1.0".

### Существующий релиз ui обновлю, новые запилю

```bash
helm3 upgrade --install test-ui-1 ui/
Release "test-ui-1" has been upgraded. Happy Helming!
NAME: test-ui-1
LAST DEPLOYED: Thu Feb 27 00:26:06 2020
NAMESPACE: default
STATUS: deployed
REVISION: 2
TEST SUITE: None

helm3 upgrade --install test-ui-2 ui/
Release "test-ui-2" does not exist. Installing it now.
NAME: test-ui-2
LAST DEPLOYED: Thu Feb 27 00:26:44 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None

helm3 upgrade --install test-ui-3 ui/
Release "test-ui-3" does not exist. Installing it now.
NAME: test-ui-3
LAST DEPLOYED: Thu Feb 27 00:26:51 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None

kubectl get ingress
NAME           HOSTS   ADDRESS          PORTS   AGE
test-ui-1-ui   *       35.201.117.95    80      2m24s
test-ui-2-ui   *       34.102.171.149   80      106s
test-ui-3-ui   *       34.98.125.245    80      100s

helm3 ls
NAME     	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART   	APP VERSION
test-ui-1	default  	2       	2020-02-27 00:26:06.516977485 +0300 MSK	deployed	ui-1.0.0	1          
test-ui-2	default  	1       	2020-02-27 00:26:44.854655894 +0300 MSK	deployed	ui-1.0.0	1          
test-ui-3	default  	1       	2020-02-27 00:26:51.312272822 +0300 MSK	deployed	ui-1.0.0	1    

```
ну вот тут конечно все пошло как следует)

Мы собрали Chart для развертывания ui-компоненты
приложения. Он должен иметь следующую структуру

```
tree
.
├── comment
├── post
├── reddit
└── ui
    ├── Chart.yaml
    ├── templates
    │   ├── deployment.yaml
    │   ├── ingress.yaml
    │   └── service.yaml
    └── values.yaml
```
Осталось собрать пакеты для остальных компонент

### Запилим чарт для post

post/templates/service.yaml

```yml
---
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}
  labels:
    app: reddit
    component: post
    release: {{ .Release.Name }}
spec:
  type: ClusterIP
  ports:
  - port: {{ .Values.service.externalPort }}
    protocol: TCP
    targetPort: {{ .Values.service.internalPort }}
  selector:
    app: reddit
    component: post
    release: {{ .Release.Name }}
... 

```
post/templates/deployment.yaml

```yml
---
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}
  labels:
    app: reddit
    component: post
    release: {{ .Release.Name }}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: reddit
      component: post
      release: {{ .Release.Name }}
  template:
    metadata:
      name: post
      labels:
        app: reddit
        component: post
        release: {{ .Release.Name }}
    spec:
      containers:
      - image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        name: post
        ports:
        - containerPort: {{ .Values.service.internalPort }}
          name: post
          protocol: TCP
        env:
        - name: POST_DATABASE_HOST
          value: {{ .Values.databaseHost | default (printf "%s-mongodb" .Release.Name) }}
...

```
Будем задавать бд через переменную databaseHost. Иногда
лучше использовать подобный формат переменных вместо
структур database.host, так как тогда прийдется определять
структуру database, иначе helm выдаст ошибку.
Используем функцию default. Если databaseHost не будет
определена или ее значение будет пустым, то используется вывод
функции printf (которая просто формирует строку <имя-релиза>-
mongodb)

```yml
value: {{ .Values.databaseHost | default (printf "%s-mongodb" .Release.Name) }}
```
Теперь, если databaseHost не задано, то будет использован
адрес базы, поднятой внутри релиза

[Более подробная дока по шаблонизации и функциям](https://docs.helm.sh/chart_template_guide/#the-chart-template-developer-s-guide)

post/values.yaml

```yml
---
service:
  internalPort: 5000
  externalPort: 5000

image:
  repository: decapapreta/post
  tag: "1.0"

databaseHost: 

```
от себя добавлю конечно post/Chart.yaml
```yml
---
name: post
version: 1.0.0
description: OTUS reddit application POST
maintainers:
- name: Gremyachikh Svetozar
email: sgremyachikh@gmail.com
appVersion: 1.0
...
```
### Шаблонизируем сервис comment:

comment/templates/deployment.yaml
```yml
---
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}
  labels:
    app: reddit
    component: comment
    release: {{ .Release.Name }}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: reddit
      component: comment
      release: {{ .Release.Name }}
  template:
    metadata:
      name: comment
      labels:
        app: reddit
        component: comment
        release: {{ .Release.Name }}
    spec:
      containers:
      - image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        name: comment
        ports:
        - containerPort: {{ .Values.service.internalPort }}
          name: comment
          protocol: TCP
        env:
        - name: COMMENT_DATABASE_HOST
          value: {{ .Values.databaseHost | default (printf "%s-mongodb" .Release.Name) }}
...

```
comment/templates/service.yaml
```yml
---
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}
  labels:
    app: reddit
    component: comment
    release: {{ .Release.Name }}
spec:
  type: ClusterIP
  ports:
  - port: {{ .Values.service.externalPort }}
    protocol: TCP
    targetPort: {{ .Values.service.internalPort }}
  selector:
    app: reddit
    component: comment
    release: {{ .Release.Name }}
...

```
comment/values.yaml
```yml
---
service:
  internalPort: 9292
  externalPort: 9292

image:
  repository: decapapreta/comment
  tag: "1.0"

databaseHost: 

```
post/Chart.yaml
```yml
---
name: comment
version: 1.0.0
description: OTUS reddit application COMMENT
maintainers:
- name: Gremyachikh Svetozar
email: sgremyachikh@gmail.com
appVersion: 1.0

```
### Итоговая структура должна выглядеть так:

Charts   kubernetes-4 ●  tree
.
├── comment
│   ├── Chart.yaml
│   ├── templates
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   └── values.yaml
├── post
│   ├── Chart.yaml
│   ├── templates
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   └── values.yaml
├── reddit
└── ui
    ├── Chart.yaml
    ├── templates
    │   ├── deployment.yaml
    │   ├── ingress.yaml
    │   └── service.yaml
    └── values.yaml

### Helper

Также стоит отметить функционал helm по использованию
helper’ов и функции templates. Helper - это написанная нами
функция. В функция описывается, как правило, сложная логика.
Шаблоны этих функция распологаются в файле `_helpers.tpl`

Пример функции `comment.fullname`:
Charts/comment/templates/_helpers.tpl
```go
{{- define "comment.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name }}
{{- end -}}
```
которая в результате выдаст то же, что и:
```go
{{ .Release.Name }}-{{ .Chart.Name }}
```
И заменим в соответствующие строчки в файле, чтобы
использовать helper charts/comment/templates/service.yaml

```yml
---
apiVersion: v1
kind: Service
metadata:
  name: {{ template "comment.fullname" . }}
  labels:
    app: reddit
    component: comment
    release: {{ .Release.Name }}
spec:
  type: ClusterIP
  ports:
  - port: {{ .Values.service.externalPort }}
    protocol: TCP
    targetPort: {{ .Values.service.internalPort }}
  selector:
    app: reddit
    component: comment
    release: {{ .Release.Name }}
...
```
### Структура ипортирующей функции template:

{{ template "comment.fullname" . }}

template функция
название функции для импорта - comment.fullname
. - область видимости (точка), т.е. вся област видимости всех переменных

### Задание

Создать файлы _helpers.tpl в папках templates сервисов ui, post
и comment
2. вставить функцию “.fullname” в каждый _helpers.tpl файл.
заменить на имя чарта соотв. сервиса
3. В каждом из шаблонов манифестов вставить следующую
функцию там, где это требуется (большинство полей это name: )

### tree

```bash
tree       
.
├── comment
│   ├── Chart.yaml
│   ├── templates
│   │   ├── deployment.yaml
│   │   ├── _helpers.tpl
│   │   └── service.yaml
│   └── values.yaml
├── post
│   ├── Chart.yaml
│   ├── templates
│   │   ├── deployment.yaml
│   │   ├── _helpers.tpl
│   │   └── service.yaml
│   └── values.yaml
├── reddit
└── ui
    ├── Chart.yaml
    ├── templates
    │   ├── deployment.yaml
    │   ├── _helpers.tpl
    │   ├── ingress.yaml
    │   └── service.yaml
    └── values.yaml

```

### Управление зависимостями

Мы создали Chart’ы для каждой компоненты нашего
приложения. Каждый из них можно запустить по-отдельности
командой

```bash
helm3 upgrade --install <RELEASE_NAME> <PATH_TO_CHART>/

```
Но они будут запускаться в разных релизах, и не будут видеть
друг друга. - так написано в метотодичке

С помощью механизма управления зависимостями создадим
единый Chart reddit, который объединит наши компоненты

###  reddit с зависимостями

Создайте reddit/Chart.yaml

```yml
---
dependencies:
  - name: ui
    version: "1.0.0"
    repository: "file://../ui"

  - name: post
    version: "1.0.0"
    repository: "file://../post"

  - name: comment
    version: "1.0.0"
    repository: "file://../comment"
...
```
Имена и версии должны совпадать с содержанием исходных Chart.yml

Пути указывается относительно расположения самого
requirements.yaml

Нужно загрузить зависимости (когда Chart’ не упакован в tgz
архив)

```bash
helm3 dep update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "jetstack" chart repository
...Successfully got an update from the "elastic" chart repository
...Successfully got an update from the "stable" chart repository
...Successfully got an update from the "gitlab" chart repository
Update Complete. ⎈Happy Helming!⎈
Saving 3 charts
Deleting outdated charts
```
Появится файл requirements.lock с фиксацией зависимостей
Будет создана директория charts с зависимостями в виде архивов
Структура станет следующей:

```bash
/Charts/reddit   kubernetes-4 ●✚  tree
.
├── charts
│   ├── comment-1.0.0.tgz
│   ├── post-1.0.0.tgz
│   └── ui-1.0.0.tgz
├── Chart.yaml
├── requirements.lock
├── requirements.yaml
└── values.yaml

1 directory, 7 files
```

Chart для базы данных не будем создавать вручную. Возьмем
готовый.

Найдем Chart в общедоступном репозитории

```bash
/Charts/reddit   kubernetes-4 ●✚  helm3 repo add stable https://kubernetes-charts.storage.googleapis.com
"stable" has been added to your repositories
### добавляю этот репо в helm3

/Charts/reddit   kubernetes-4 ●✚  helm3 search repo mongo
NAME                                    CHART VERSION   APP VERSION     DESCRIPTION                                       
stable/mongodb                          7.8.6           4.2.3           NoSQL document-oriented database that stores JS...
stable/mongodb-replicaset               3.11.6          3.6             NoSQL document-oriented database that stores JS...
stable/prometheus-mongodb-exporter      2.4.0           v0.10.0         A Prometheus exporter for MongoDB metrics         
stable/unifi                            0.6.1           5.11.50         Ubiquiti Network's Unifi Controller
```
добавим в reddit/requirements.yml:

```yml
---
dependencies:
  - name: ui
    version: "1.0.0"
    repository: "file://../ui"

  - name: post
    version: "1.0.0"
    repository: "file://../post"

  - name: comment
    version: "1.0.0"
    repository: "file://../comment"

  - name: mongodb
    version: "7.8.6"
    repository: "https://kubernetes-charts.storage.googleapis.com"
...

```
обновим зависимости

```bash
/Charts/reddit   kubernetes-4 ●✚  helm3 dep update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "jetstack" chart repository
...Successfully got an update from the "elastic" chart repository
...Successfully got an update from the "stable" chart repository
...Successfully got an update from the "gitlab" chart repository
Update Complete. ⎈Happy Helming!⎈
Saving 4 charts
Downloading mongodb from repo https://kubernetes-charts.storage.googleapis.com
Deleting outdated charts

/Charts/reddit   kubernetes-4 ●✚  tree
.
├── charts
│   ├── comment-1.0.0.tgz
│   ├── mongodb-7.8.6.tgz
│   ├── post-1.0.0.tgz
│   └── ui-1.0.0.tgz
├── Chart.yaml
├── requirements.lock
├── requirements.yaml
└── values.yaml

1 directory, 8 files
```
### Установим тестовый релиз:


```bash
/Charts   kubernetes-4 ●✚  helm3 delete test-ui-3                             
release "test-ui-3" uninstalled

/Charts   kubernetes-4 ●✚  helm3 upgrade --install reddit-test ./reddit
Release "reddit-test" does not exist. Installing it now.
NAME: reddit-test
LAST DEPLOYED: Sun Mar  1 15:19:07 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None

/Charts   kubernetes-4 ●✚  kubectl get ingress
NAME             HOSTS   ADDRESS          PORTS   AGE
reddit-test-ui   *       35.244.216.175   80      2m19s

kubectl get pods   
NAME                                   READY   STATUS    RESTARTS   AGE
reddit-test-comment-7dc6fd4b56-j24g6   1/1     Running   0          2m25s
reddit-test-mongodb-75cb86d878-jd8f7   1/1     Running   0          2m25s
reddit-test-post-7bf595979c-jkgvq      1/1     Running   0          2m25s
reddit-test-ui-944b8d49-7w7cd          1/1     Running   0          2m25s
reddit-test-ui-944b8d49-b7bd8          1/1     Running   0          2m25s
reddit-test-ui-944b8d49-gkl2c          1/1     Running   0          2m25s

```
Иду в гуи, вижу "Can't show blog posts, some problems with the post service"

> kubectl logs reddit-test-post-7bf595979c-jkgvq - ни шума. ни пыли
> kubectl describe pod reddit-test-post-7bf595979c-jkgvq - тоже все красиво, не понятно что-то... а надо было прочесть дальше просто)

Есть проблема с тем, что UI-сервис не знает как правильно
ходить в post и comment сервисы. Ведь их имена теперь
динамические и зависят от имен чартов

В Dockerfile UI-сервиса уже заданы переменные окружения.
Надо, чтобы они указывали на нужные бекенды

```Dockerfile
ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292
```
Добавим в ui/deployments.yaml:

```yml
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
# уникальное имя запущенного сервиса возвращает тоже самое что и {{ .Release.Name }}-{{ .Chart.Name }}, 
# но в этом случае из _helpers.tpl
  name: {{ template "ui.fullname" . }}
  labels:
    app: reddit
    component: ui
    release: {{ .Release.Name }}
spec:
  replicas: 3
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: reddit
      component: ui
      release: {{ .Release.Name }}
  template:
    metadata:
      name: ui
      labels:
        app: reddit
        component: ui
        release: {{ .Release.Name }}
    spec:
      containers:
      - image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        name: ui
        ports:
        - containerPort: {{ .Values.service.internalPort }}
          name: ui
          protocol: TCP
        env:
        - name: POST_SERVICE_HOST
          value: {{  .Values.postHost | default (printf "%s-post" .Release.Name) }}
        - name: POST_SERVICE_PORT
          value: {{  .Values.postPort | default "5000" | quote }}
        - name: COMMENT_SERVICE_HOST
          value: {{  .Values.commentHost | default (printf "%s-comment" .Release.Name) }}
        - name: COMMENT_SERVICE_PORT
          value: {{  .Values.commentPort | default "9292" | quote }}
        - name: ENV
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
...
```
***{{ .Values.commentPort | default "9292" | quote }} ❗ обратите внимание на функцию добавления кавычек. Для чисел и булевых значений это важно***

Добавим в ui/values.yaml

```yaml
---
service:
    internalPort: 9292
    externalPort: 9292

image:
    repository: decapapreta/ui
    tag: "1.0"

ingress:
  class: nginx

# Можете даже закоментировать эти параметры или оставить
# пустыми. Главное, чтобы они были в конфигурации Chart’а в
# качестве документации
postHost:
postPort:
commentHost:
commentPort:
```
### values reddit

Вы можете задавать теперь переменные для зависимостей
прямо в values.yaml самого Chart’а reddit. Они перезаписывают
значения переменных из зависимых чартов

reddit/values.yaml
Ссылаемся на переменные чартов из зависимостей

```yaml
---
comment:
  image:
    repository: decapapreta/comment
    tag: "1.0"
  service:
    externalPort: 9292

post:
  image:
    repository: decapapreta/post
    tag: "1.0"
  service:
    externalPort: 5000

ui:
  image:
    repository: decapapreta/ui
    tag: "1.0"
  service:
    externalPort: 9292

# иначе post и comment у нас в базе авторизироваться не могут
mongodb:
  usePassword: false


```

После обновления UI - нужно обновить зависимости чарта
reddit.

```bash
/Charts   kubernetes-4 ●✚  helm3 dep update ./reddit 

Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "jetstack" chart repository
...Successfully got an update from the "elastic" chart repository
...Successfully got an update from the "stable" chart repository
...Successfully got an update from the "gitlab" chart repository
Update Complete. ⎈Happy Helming!⎈
Saving 4 charts
Downloading mongodb from repo https://kubernetes-charts.storage.googleapis.com
Deleting outdated charts
```
Обновите релиз, установленный в k8s

```bash
/Charts   kubernetes-4 ●✚  helm3 upgrade --install reddit-test ./reddit

Release "reddit-test" has been upgraded. Happy Helming!
NAME: reddit-test
LAST DEPLOYED: Sun Mar  1 16:28:05 2020
NAMESPACE: default
STATUS: deployed
REVISION: 2
TEST SUITE: None

kubectl get ingress                           
NAME             HOSTS   ADDRESS          PORTS   AGE
reddit-test-ui   *       35.244.216.175   80      69m


```
### Как обезопасить себя? (helm2 tiller plugin) - пропустил т.к. все делаю в 3 хельме уже

## GitLab + Kubernetes

### Установим GitLab

Подготовим GKE-кластер. Нам нужны машинки помощнее.
но только не руками. Terraform.

в модуле создания пула нод сделаю изменения:

```terraform
  node_pools = [
    {
      name               = "cluster-node-pool"
      machine_type       = "n1-standard-2"
      disk_size_gb       = 20
      autoscaling        = true
      auto_repair        = true
      auto_upgrade       = true
      min_count          = 2
      max_count          = 3
      initial_node_count = 2
    },
```
и приименю

### Отключите RBAC для упрощения работы - Нет, это будет не правильно.

Gitlab будем ставить также с помощью Helm Chart’а из пакета
Omnibus.
1. Добавим репозиторий Gitlab

```bash
helm3 repo add gitlab https://charts.gitlab.io
"gitlab" has been added to your repositories
```
2. Мы будем менять конфигурацию Gitlab, поэтому скачаем Chart

```bash
helm3 fetch gitlab/gitlab-omnibus --untar
```
в /sgremyachikh_microservices/kubernetes/Charts/gitlab-omnibus/charts/gitlab-runner/values.yaml

```yaml
rbac:
  create: true
...
  clusterWideAccess: true
...
runners:
  privileged: true
...

```
### Установим GitLab

Раскомментируем по гайду Отуса
```
baseDomain: example.com
legoEmail: you@example.com
```
Добавьте в gitlab-omnibus/templates/gitlab/gitlabsvc.yaml по гайду отуса:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ template "fullname" . }}
  labels:
    app: {{ template "fullname" . }}
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    release: "{{ .Release.Name }}"
    heritage: "{{ .Release.Service }}"
spec:
  selector:
    name: {{ template "fullname" . }}
  ports:
    - name: ssh
      port: 22
      targetPort: ssh
    - name: mattermost
      port: 8065
      targetPort: mattermost
    - name: registry
      port: 8105
      targetPort: registry
    - name: workhorse
      port: 8005
      targetPort: workhorse
    - name: prometheus
      port: 9090
      targetPort: prometheus
    - name: web
      port: 80
      targetPort: workhorse
    {{- if and .Values.pagesExternalScheme .Values.pagesExternalDomain}}
    - name: pages
      port: 8090
      targetPort: pages
    {{- end }}

```
Поправить в gitlab-omnibus/templates/gitlab-config.yaml

```yaml
data:
  external_scheme: http
  external_hostname: gitlab.{{ .Values.baseDomain }}
```
Поправить в gitlab-omnibus/templates/ingress/gitlab-ingress.yaml

```yaml
  rules:
  - host: {{ template "fullname" . }}
    http:
      paths:
      - path: /
```
Установим сам гитлаб:

```bash
helm3 upgrade --install gitlab ./gitlab-omnibus -f ./gitlab-omnibus/values.yaml

Release "gitlab" does not exist. Installing it now.
WARNING: This chart is deprecated
Error: unable to build kubernetes objects from release manifest: error validating "": error validating data: [unknown object type "nil" in ConfigMap.data.pages_external_domain, unknown object type "nil" in ConfigMap.data.pages_external_scheme]

```
в `gitlab-omnibus/values.yaml`
```yaml
...
pagesExternalScheme: http
pagesExternalDomain: your-pages-domain.com
...
```
деплою еще раз

```bash
/Charts   kubernetes-4 ●✚  helm3 upgrade --install gitlab ./gitlab-omnibus -f ./gitlab-omnibus/values.yaml
Release "gitlab" does not exist. Installing it now.
WARNING: This chart is deprecated
NAME: gitlab
LAST DEPLOYED: Sun Mar  1 18:54:45 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
It may take several minutes for GitLab to reconfigure.
    You can watch the status by running `kubectl get deployment -w gitlab-gitlab --namespace default
  You did not specify a baseIP so one will be assigned for you.
  It may take a few minutes for the LoadBalancer IP to be available.
  Watch the status with: 'kubectl get svc -w --namespace nginx-ingress nginx', then:

  export SERVICE_IP=$(kubectl get svc --namespace nginx-ingress nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

  Then make sure to configure DNS with something like:
    *.your-domain.com	300 IN A $SERVICE_IP
```
```bash
/Charts   kubernetes-4 ●✚  kubectl get pods                                   
NAME                                        READY   STATUS             RESTARTS   AGE
gitlab-gitlab-766445f7d7-4l72x              0/1     Running            0          4m12s
gitlab-gitlab-postgresql-66d5b899b8-rzjn9   0/1     Pending            0          4m12s
gitlab-gitlab-redis-6c675dd568-hj8tp        1/1     Running            0          4m12s
gitlab-gitlab-runner-7fddf67f78-ds4xt       0/1     CrashLoopBackOff   4          4m12s
```
```log
/Charts   kubernetes-4 ●✚  kubectl describe pod gitlab-gitlab-postgresql-66d5b899b8-rzjn9
Name:           gitlab-gitlab-postgresql-66d5b899b8-rzjn9
Namespace:      default
Priority:       0
Node:           <none>
Labels:         app=gitlab-gitlab
                name=gitlab-gitlab-postgresql
                pod-template-hash=66d5b899b8
Annotations:    kubernetes.io/limit-ranger: LimitRanger plugin set: cpu request for container postgresql
Status:         Pending
IP:             
IPs:            <none>
Controlled By:  ReplicaSet/gitlab-gitlab-postgresql-66d5b899b8
Containers:
  postgresql:
    Image:      postgres:9.6.5
    Port:       5432/TCP
    Host Port:  0/TCP
    Requests:
      cpu:      100m
    Liveness:   exec [pg_isready -h localhost -U postgres] delay=30s timeout=5s period=10s #success=1 #failure=3
    Readiness:  exec [pg_isready -h localhost -U postgres] delay=5s timeout=1s period=10s #success=1 #failure=3
    Environment:
      POSTGRES_USER:      <set to the key 'postgres_user' of config map 'gitlab-gitlab-config'>   Optional: false
      POSTGRES_PASSWORD:  <set to the key 'postgres_password' in secret 'gitlab-gitlab-secrets'>  Optional: false
      POSTGRES_DB:        <set to the key 'postgres_db' of config map 'gitlab-gitlab-config'>     Optional: false
      DB_EXTENSION:       pg_trgm
      PGDATA:             /var/lib/postgresql/data/pgdata
    Mounts:
      /docker-entrypoint-initdb.d from initdb (ro)
      /var/lib/postgresql/data from data (rw,path="postgres")
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-lnwvg (ro)
Conditions:
  Type           Status
  PodScheduled   False 
Volumes:
  data:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  gitlab-gitlab-postgresql-storage
    ReadOnly:   false
  initdb:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      gitlab-gitlab-postgresql-initdb
    Optional:  false
  default-token-lnwvg:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-lnwvg
    Optional:    false
QoS Class:       Burstable
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type     Reason             Age                   From                Message
  ----     ------             ----                  ----                -------
  Warning  FailedScheduling   57s (x8 over 5m40s)   default-scheduler   pod has unbound immediate PersistentVolumeClaims (repeated 2 times)
  Normal   NotTriggerScaleUp  26s (x31 over 5m36s)  cluster-autoscaler  pod didn't trigger scale-up (it wouldn't fit if a new node is added):
```

```log
/Charts   kubernetes-4 ●✚  kubectl get persistentvolumeclaims
NAME                               STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS         AGE
gitlab-gitlab-config-storage       Bound     pvc-7e27ea91-c238-44b7-8357-376d16d95471   1Gi        RWO            gitlab-gitlab-fast   9m13s
gitlab-gitlab-postgresql-storage   Pending                                                                        gitlab-gitlab-fast   9m13s
gitlab-gitlab-redis-storage        Bound     pvc-1c532899-8503-4117-80b0-9fce6583fbfa   5Gi        RWO            gitlab-gitlab-fast   9m13s
gitlab-gitlab-registry-storage     Bound     pvc-bc605ac0-6984-4632-bd26-5761dba77296   30Gi       RWO            gitlab-gitlab-fast   9m13s
gitlab-gitlab-storage              Bound     pvc-6c3b8ff1-1938-4796-bd8f-aeb4399a2171   30Gi       RWO            gitlab-gitlab-fast   9m13s

/Charts   kubernetes-4 ●✚  kubectl describe persistentvolumeclaims gitlab-gitlab-postgresql-storage

Name:          gitlab-gitlab-postgresql-storage
Namespace:     default
StorageClass:  gitlab-gitlab-fast
Status:        Pending
Volume:        
Labels:        app=gitlab-gitlab
               chart=gitlab-omnibus-0.1.37
               heritage=Helm
               release=gitlab
Annotations:   volume.beta.kubernetes.io/storage-class: gitlab-gitlab-fast
               volume.beta.kubernetes.io/storage-provisioner: kubernetes.io/gce-pd
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:      
Access Modes:  
VolumeMode:    Filesystem
Mounted By:    gitlab-gitlab-postgresql-66d5b899b8-rzjn9
Events:
  Type     Reason              Age                 From                         Message
  ----     ------              ----                ----                         -------
  Warning  ProvisioningFailed  18s (x12 over 10m)  persistentvolume-controller  Failed to provision volume with StorageClass "gitlab-gitlab-fast": googleapi: Error 403: QUOTA_EXCEEDED - Quota 'SSD_TOTAL_GB' exceeded.  Limit: 100.0 in region europe-west1.
```
Эта домашка прекрасная своими приключениями.

```log
Failed to provision volume with StorageClass "gitlab-gitlab-fast": googleapi: Error 403: QUOTA_EXCEEDED - Quota 'SSD_TOTAL_GB' exceeded.  Limit: 100.0 in region europe-west1.
```
доступные классы
```log
/Charts   kubernetes-4 ●✚  kubectl get storageclasses
NAME                 PROVISIONER            AGE
gitlab-gitlab-fast   kubernetes.io/gce-pd   14m
standard (default)   kubernetes.io/gce-pd   6h21m

```
### уменьшить запрашиваемое место чтобы уместиться в 100Гб!

gitlab-omnibus/values.yaml
```yaml
...
redisDedicatedStorage: true
redisStorageSize: 5Gi
redisAccessMode: ReadWriteOnce
postgresImage: postgres:9.6.5
# If you disable postgresDedicatedStorage, you should consider bumping up gitlabRailsStorageSize
postgresDedicatedStorage: true
postgresAccessMode: ReadWriteOnce
postgresStorageSize: 10Gi
gitlabDataAccessMode: ReadWriteOnce
gitlabDataStorageSize: 10Gi
gitlabRegistryAccessMode: ReadWriteOnce
gitlabRegistryStorageSize: 10Gi
gitlabConfigAccessMode: ReadWriteOnce
gitlabConfigStorageSize: 1Gi
...
```
деплоиться по верх не получится наверняка, - выделенные квоты уже заявлены, надо удалять релиз и вкатывать заново
```bash
Charts   kubernetes-4 ●✚  helm3 delete gitlab                                                     
release "gitlab" uninstalled

/Charts   kubernetes-4 ●✚  kubectl get storageclasses
NAME                 PROVISIONER            AGE
standard (default)   kubernetes.io/gce-pd   6h27m

kubectl get persistentvolumeclaims                                      
No resources found in default namespace.

/Charts   kubernetes-4 ●✚  helm3 upgrade --install gitlab ./gitlab-omnibus -f ./gitlab-omnibus/values.yaml
Release "gitlab" does not exist. Installing it now.
WARNING: This chart is deprecated
NAME: gitlab
LAST DEPLOYED: Sun Mar  1 19:16:07 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
It may take several minutes for GitLab to reconfigure.
    You can watch the status by running `kubectl get deployment -w gitlab-gitlab --namespace default
  You did not specify a baseIP so one will be assigned for you.
  It may take a few minutes for the LoadBalancer IP to be available.
  Watch the status with: 'kubectl get svc -w --namespace nginx-ingress nginx', then:

  export SERVICE_IP=$(kubectl get svc --namespace nginx-ingress nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

  Then make sure to configure DNS with something like:
    *.your-domain.com	300 IN A $SERVICE_IP

/Charts   kubernetes-4 ●✚  kubectl get pods    
NAME                                        READY   STATUS    RESTARTS   AGE
gitlab-gitlab-766445f7d7-r29tr              1/1     Running   0          33m
gitlab-gitlab-postgresql-66d5b899b8-5cmcc   1/1     Running   0          33m
gitlab-gitlab-redis-6c675dd568-8r6r9        1/1     Running   0          33m
gitlab-gitlab-runner-7fddf67f78-5mgrs       1/1     Running   4          33m

```

Поместите запись в локальный файл `/etc/hosts` (поставьте свой IP-адрес)
```shell
echo "104.199.36.252 gitlab-gitlab staging production" | sudo tee /etc/hosts
```

http://104.199.36.252/ не работает


```log
ubectl get pods -n nginx-ingress
NAME                                    READY   STATUS             RESTARTS   AGE
default-http-backend-65b964d8cc-72phj   1/1     Running            0          57m
nginx-cxgl7                             0/1     CrashLoopBackOff   16         57m
nginx-jrtd8                             0/1     Error              16         57m

kubectl logs nginx-cxgl7 -n nginx-ingress
[dumb-init] Unable to detach from controlling tty (errno=25 Inappropriate ioctl for device).
[dumb-init] Child spawned with PID 6.
[dumb-init] Unable to attach to controlling tty (errno=25 Inappropriate ioctl for device).
[dumb-init] setsid complete.
I0301 17:12:58.919757       6 launch.go:105] &{NGINX 0.9.0-beta.11 git-a3131c5 https://github.com/kubernetes/ingress}
I0301 17:12:58.919919       6 launch.go:108] Watching for ingress class: nginx
I0301 17:12:58.920263       6 launch.go:262] Creating API server client for https://10.0.0.1:443
I0301 17:12:58.922216       6 nginx.go:182] starting NGINX process...
F0301 17:12:58.952163       6 launch.go:122] no service with name nginx-ingress/default-http-backend found: services "default-http-backend" is forbidden: User "system:serviceaccount:nginx-ingress:default" cannot get resource "services" in API group "" in the namespace "nginx-ingress"
[dumb-init] Received signal 17.
[dumb-init] A child with PID 6 exited with exit status 255.
[dumb-init] Forwarded signal 15 to children.
[dumb-init] Child exited with status 255. Goodbye.
```
Тут надо сказать, что это точка неразврата/невозврата - или надо будет брать, переделывать этот депрекейтед велосипед, допилитьвать роли, биндинги, деплоймент... или сдаться и просто сдать домашку. В курсаче мы сделали с rbac разок все, по сути этот опыт тут ни к чему может быть.

### ок...а мы пойдем другим путем

https://docs.gitlab.com/charts/
https://docs.gitlab.com/charts/installation/deployment.html
```bash
helm3 fetch gitlab/gitlab --untar

/sgremyachikh_microservices/kubernetes/Charts   kubernetes-4 ●  helm3 upgrade --install gitlab --set global.edition=ce --set certmanager-issuer.email=sgremyachikh@gmail.com --set global.hosts.domain=systemctl.tech --set gitlab-runner.runners.privileged=true ./gitlab
Release "gitlab" does not exist. Installing it now.
NAME: gitlab
LAST DEPLOYED: Sun Mar  1 23:45:18 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
WARNING: If you are upgrading from a previous version of the GitLab Helm Chart, there is a major upgrade to the included PostgreSQL chart, which requires manual steps be performed. Please see our upgrade documentation for more information: https://docs.gitlab.com/charts/installation/upgrade.html

kubectl get ingress
NAME              HOSTS                     ADDRESS          PORTS     AGE
gitlab-minio      minio.systemctl.tech      104.199.36.252   80, 443   2m19s
gitlab-registry   registry.systemctl.tech   104.199.36.252   80, 443   2m19s
gitlab-unicorn    gitlab.systemctl.tech     104.199.36.252   80, 443   2m19s

/sgremyachikh_microservices/kubernetes/Charts   kubernetes-4 ●  kubectl get pods
NAME                                                    READY   STATUS      RESTARTS   AGE
gitlab-cainjector-8586db65b6-hnnj4                      1/1     Running     0          3m2s
gitlab-cert-manager-544cb76db9-5nr6m                    1/1     Running     0          3m4s
gitlab-gitaly-0                                         1/1     Running     0          2m57s
gitlab-gitlab-exporter-6c56b66f96-b4jwn                 1/1     Running     0          3m3s
gitlab-gitlab-runner-7766d74f8-s4psq                    1/1     Running     0          3m
gitlab-gitlab-shell-7fdd4589b9-b8885                    1/1     Running     0          3m2s
gitlab-gitlab-shell-7fdd4589b9-gthdc                    1/1     Running     0          2m48s
gitlab-issuer.1-qvxcd                                   0/1     Completed   0          3m
gitlab-migrations.1-zb7vd                               0/1     Completed   0          3m
gitlab-minio-8f879c754-4lls6                            1/1     Running     0          3m4s
gitlab-minio-create-buckets.1-g5wvj                     0/1     Completed   0          3m
gitlab-nginx-ingress-controller-68f544df7d-5nrhr        1/1     Running     0          3m4s
gitlab-nginx-ingress-controller-68f544df7d-bcxqd        1/1     Running     0          3m4s
gitlab-nginx-ingress-controller-68f544df7d-smpzv        1/1     Running     0          3m4s
gitlab-nginx-ingress-default-backend-6cd54c5f86-g2pjl   1/1     Running     0          3m1s
gitlab-nginx-ingress-default-backend-6cd54c5f86-lh5qv   1/1     Running     0          3m
gitlab-postgresql-0                                     2/2     Running     0          2m59s
gitlab-prometheus-server-86bbc4c747-sdtbq               2/2     Running     0          3m2s
gitlab-redis-master-0                                   2/2     Running     0          3m1s
gitlab-registry-56c4f6cc8f-m6cjz                        1/1     Running     0          3m4s
gitlab-registry-56c4f6cc8f-mzlg6                        1/1     Running     0          3m4s
gitlab-sidekiq-all-in-1-v1-5564bf89bd-78h7x             1/1     Running     0          3m4s
gitlab-task-runner-798fd6646f-vlbws                     1/1     Running     0          3m3s
gitlab-unicorn-55ddbdc775-67hp9                         2/2     Running     0          2m48s
gitlab-unicorn-55ddbdc775-bmtq6                         2/2     Running     0          3m2s
runner-sqxv272l-project-3-concurrent-0bv948             3/3     Running     0          34s

```
тем временет на reg ru кручу A записи

systemctl.tech
DNS-серверы и управление зоной

A
gitlab
→
104.199.36.252

A
minio
→
104.199.36.252

A
registry
→
104.199.36.252


```bash
#Initial login
#You can access the GitLab instance by visiting the domain specified during installation. If you manually created the secret for #initial root password, you can use that to sign in as root user. If not, GitLab would’ve automatically created a random password for #root user. This can be extracted by the following command (replace <name> by name of the release - which is gitlab if you used the #command above).
kubectl get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo
# эхо вернет сгенерированный пароль
```
В результате имею:

https://gitlab.systemctl.tech/

соглашаюсь на исключения безопасности на самоподписанные серты

логинюсь рутом с паролем
добавляю свои ключи ssh

### Запустим проект

Создать группу с именем докерайди decapapreta

https://gitlab.systemctl.tech//decapapreta

В настройках группы выберите пункт CI/CD

Добавьте 2 переменные:
CI_REGISTRY_USER- логин в dockerhub 
CI_REGISTRY_PASSWORD - пароль от Docker Hub

Эти учетные данные будут использованы при сборке и
релизе docker-образов с помощью Gitlab CI

В группе создадим новый проект

https://gitlab.systemctl.tech/decapapreta/reddit-deploy

Создайте еще 3 проекта: post, ui, comment (сделайте также их
публичными)

Локально у себя создайте директорию Gitlab_ci со следующей
структурой директорий.

```
/sgremyachikh_microservices/kubernetes/Gitlab_ci/ui   kubernetes-4 ●  tree
.
├── build_info.txt
├── config.ru
├── docker_build.sh
├── Dockerfile
├── Gemfile
├── Gemfile.lock
├── helpers.rb
├── middleware.rb
├── ui_app.rb
├── VERSION
└── views
    ├── create.haml
    ├── index.haml
    ├── layout.haml
    └── show.haml
```
### В директории Gitlab_ci/ui:
1. Инициализируем локальный git-репозиторий
2. Добавим удаленный репозиторий
3. Закоммитим и отправим в gitlab
```
git init
git remote add origin git@gitlab.systemctl.tech:decapapreta/ui.git
git add .
git commit -am "initial commit"
git push origin master
```
Для post и comment продейлайте аналогичные действия. Не
забудьте указывать соответствующие названия репозиториев и
групп.

Перенести содержимое директории Charts (папки ui, post,
comment, reddit) в Gitlab_ci/reddit-deploy

Запушить reddit-deploy в gitlab-проект reddit-deploy

Структура:
```
/sgremyachikh_microservices/kubernetes/Gitlab_ci/reddit-deploy   master  tree
.
├── comment
│   ├── Chart.yaml
│   ├── templates
│   │   ├── deployment.yaml
│   │   ├── _helpers.tpl
│   │   └── service.yaml
│   └── values.yaml
├── post
│   ├── Chart.yaml
│   ├── templates
│   │   ├── deployment.yaml
│   │   ├── _helpers.tpl
│   │   └── service.yaml
│   └── values.yaml
├── reddit
│   ├── charts
│   │   ├── comment-1.0.0.tgz
│   │   ├── mongodb-7.8.6.tgz
│   │   ├── post-1.0.0.tgz
│   │   └── ui-1.0.0.tgz
│   ├── Chart.yaml
│   ├── requirements.lock
│   ├── requirements.yaml
│   └── values.yaml
└── ui
    ├── Chart.yaml
    ├── templates
    │   ├── deployment.yaml
    │   ├── _helpers.tpl
    │   ├── ingress.yaml
    │   └── service.yaml
    └── values.yaml

```

 Создайте файл gitlab_ci/ui/.gitlab-ci.yml с содержимым:
```yaml
---
image: alpine:latest
# В текущей конфигурации CI выполняет
# 1. Build: Сборку докер-образа с тегом master
# 2. Test: Фиктивное тестирование
# 3. Release: Смену тега с master на тег из файла VERSION и пуш
# docker-образа с новым тегом
# Job для выполнения каждой задачи запускается в отдельном
# Kubernetes POD-е.

stages:
  - build
  - test
  - release
  - cleanup

build:
  stage: build
  image: docker:git
  services:
    - docker:18.09.7-dind
  script:
# Требуемые операции вызываются в блоках script
    - setup_docker
    - build
  variables:
    DOCKER_DRIVER: overlay2
  only:
    - branches

test:
  stage: test
  script:
# Требуемые операции вызываются в блоках script
    - exit 0
  only:
    - branches

release:
  stage: release
  image: docker
  services:
    - docker:dind
  script:
# Требуемые операции вызываются в блоках script
    - setup_docker
    - release
  variables:
    DOCKER_TLS_CERTDIR: ""
  only:
    - master

# Описание самих операций производится в виде bash-функций в
# блоке .auto_devops
.auto_devops: &auto_devops |
  [[ "$TRACE" ]] && set -x
  export CI_REGISTRY="index.docker.io"
  export CI_APPLICATION_REPOSITORY=$CI_REGISTRY/$CI_PROJECT_PATH
  export CI_APPLICATION_TAG=$CI_COMMIT_REF_SLUG
  export CI_CONTAINER_NAME=ci_job_build_${CI_JOB_ID}
  export TILLER_NAMESPACE="kube-system"

  function setup_docker() {
    if ! docker info &>/dev/null; then
      if [ -z "$DOCKER_HOST" -a "$KUBERNETES_PORT" ]; then
        export DOCKER_HOST='tcp://localhost:2375'
      fi
    fi
  }

  function release() {

    echo "Updating docker images ..."

    if [[ -n "$CI_REGISTRY_USER" ]]; then
      echo "Logging to GitLab Container Registry with CI credentials..."
      docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD"
      echo ""
    fi

    docker pull "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG"
    docker tag "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG" "$CI_APPLICATION_REPOSITORY:$(cat VERSION)"
    docker push "$CI_APPLICATION_REPOSITORY:$(cat VERSION)"
    echo ""
  }

  function build() {

    echo "Building Dockerfile-based application..."
    echo `git show --format="%h" HEAD | head -1` > build_info.txt
    echo `git rev-parse --abbrev-ref HEAD` >> build_info.txt
    docker build -t "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG" .

    if [[ -n "$CI_REGISTRY_USER" ]]; then
      echo "Logging to GitLab Container Registry with CI credentials..."
      docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD"
      echo ""
    fi

    echo "Pushing to GitLab Container Registry..."
    docker push "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG"
    echo ""
  }

before_script:
  - *auto_devops

```
2. Закомитьте и запуште в gitlab
3. Проверьте, что Pipeline работает

В текущей конфигурации CI выполняет
1. Build: Сборку докер-образа с тегом master
2. Test: Фиктивное тестирование
3. Release: Смену тега с master на тег из файла VERSION и пуш
docker-образа с новым тегом
Job для выполнения каждой задачи запускается в отдельном
Kubernetes POD-е.

Для Post и Comment также добавьте в репозиторий .gitlabci.yml и проследите, что сборки образов прошли успешно.

Все успешно.

### Настроим CI

Дадим возможность разработчику запускать отдельное
окружение в Kubernetes по коммиту в feature-бранч.
Немного обновим конфиг ингресса для сервиса UI:

```yml
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
# уникальное имя запущенного сервиса возвращает тоже самое что и {{ .Release.Name }}-{{ .Chart.Name }}, 
# но в этом случае из _helpers.tpl
  name: {{ template "ui.fullname" . }}
  annotations:
    kubernetes.io/ingress.class: {{ .Values.ingress.class }}
spec:
  rules:
  - host: {{ .Values.ingress.host | default .Release.Name }}
    http:
      paths:
      - path: /
        backend:
          serviceName: {{ template "ui.fullname" . }}
          servicePort: {{ .Values.service.externalPort }}
...
```
Обновим конфиг ингресса для сервиса UI:
```yml
---
service:
    internalPort: 9292
    externalPort: 9292

image:
    repository: decapapreta/ui
    tag: "1.0"

ingress:
  class: nginx

# Можете даже закоментировать эти параметры или оставить
# пустыми. Главное, чтобы они были в конфигурации Chart’а в
# качестве документации
postHost:
postPort:
commentHost:
commentPort:

```
#### Дадим возможность разработчику запускать отдельное окружение в Kubernetes по коммиту в feature-бранч.

1. Создайте новый бранч в репозитории ui
```
git checkout -b feature/3
```
2. Обновите [ui/.gitlab-ci.yml](https://github.com/Otus-DevOps-2019-08/sgremyachikh_microservices/blob/kubernetes-4/kubernetes/Gitlab_ci/ui/.gitlab-ci.yml)
3. Закоммитьте и запушьте изменения

Отметим, что мы добавили стадию review, запускающую
приложение в k8s по коммиту в feature-бранчи (не master).

```yml
review:
  stage: review
  script:
    - install_dependencies
    - ensure_namespace
    - install_tiller
    - deploy
  variables:
    KUBE_NAMESPACE: review
    host: $CI_PROJECT_PATH_SLUG-$CI_COMMIT_REF_SLUG
  environment:
    name: review/$CI_PROJECT_PATH/$CI_COMMIT_REF_NAME
    url: http://$CI_PROJECT_PATH_SLUG-$CI_COMMIT_REF_SLUG
    on_stop: stop_review
  only:
    refs:
      - branches
#    kubernetes: active
  except:
    - master
```
ВАЖНО! - #    kubernetes: active
чтоб стейджи работали как в методичке. В курсаче делал так же.

Мы добавили функцию deploy, которая загружает Chart из
репозитория reddit-deploy и делает релиз в неймспейсе review с
образом приложения, собранным на стадии build.

```bash
  function deploy() {
    track="${1-stable}"
    name="$CI_ENVIRONMENT_SLUG"

    if [[ "$track" != "stable" ]]; then
      name="$name-$track"
    fi

    echo "Clone deploy repository..."
    git clone http://gitlab-gitlab/$CI_PROJECT_NAMESPACE/reddit-deploy.git

    echo "Download helm dependencies..."
    helm dep update reddit-deploy/reddit

    echo "Deploy helm release $name to $KUBE_NAMESPACE"
    helm upgrade --install \
      --wait \
      --set ui.ingress.host="$host" \
      --set $CI_PROJECT_NAME.image.tag=$CI_APPLICATION_TAG \
      --namespace="$KUBE_NAMESPACE" \
      --version="$CI_PIPELINE_ID-$CI_JOB_ID" \
      "$name" \
      reddit-deploy/reddit/
  }
```
Созданные для таких целей окружения временны, их требуется
“убивать” , когда они больше не нужны
добавим стейдж чистки:

```yml
stop_review:
  stage: cleanup
  variables:
    GIT_STRATEGY: none
  script:
    - install_dependencies
    - delete
  environment:
    name: review/$CI_PROJECT_PATH/$CI_COMMIT_REF_NAME
    action: stop
  when: manual
  allow_failure: true
  only:
    refs:
      - branches
#    kubernetes: active
  except:
    - master
```
разумеется, добавляем его и в стейджи в начале файла

```yaml
---
image: alpine:latest

stages:
  - build
  - test
  - review
  - release
  - cleanup

build:
  stage: build
  image: docker:git
  services:
    - docker:18.09.7-dind
  script:
    - setup_docker
    - build
  variables:
    DOCKER_DRIVER: overlay2
  only:
    - branches

test:
  stage: test
  script:
    - exit 0
  only:
    - branches

release:
  stage: release
  image: docker
  services:
    - docker:18.09.7-dind
  script:
    - setup_docker
    - release
  only:
    - master

review:
  stage: review
  script:
    - install_dependencies
    - ensure_namespace
    - install_tiller
    - deploy
  variables:
    KUBE_NAMESPACE: review
    host: $CI_PROJECT_PATH_SLUG-$CI_COMMIT_REF_SLUG
  environment:
    name: review/$CI_PROJECT_PATH/$CI_COMMIT_REF_NAME
    url: http://$CI_PROJECT_PATH_SLUG-$CI_COMMIT_REF_SLUG
    on_stop: stop_review
  only:
    refs:
      - branches
#    kubernetes: active
  except:
    - master
# test

stop_review:
  stage: cleanup
  variables:
    GIT_STRATEGY: none
  script:
    - install_dependencies
    - delete
  environment:
    name: review/$CI_PROJECT_PATH/$CI_COMMIT_REF_NAME
    action: stop
  when: manual
  allow_failure: true
  only:
    refs:
      - branches
#    kubernetes: active
  except:
    - master

.auto_devops: &auto_devops |
  [[ "$TRACE" ]] && set -x
  export CI_REGISTRY="index.docker.io"
  export CI_APPLICATION_REPOSITORY=$CI_REGISTRY/$CI_PROJECT_PATH
  export CI_APPLICATION_TAG=$CI_COMMIT_REF_SLUG
  export CI_CONTAINER_NAME=ci_job_build_${CI_JOB_ID}
  export TILLER_NAMESPACE="kube-system"

  function deploy() {
    track="${1-stable}"
    name="$CI_ENVIRONMENT_SLUG"

    if [[ "$track" != "stable" ]]; then
      name="$name-$track"
    fi

    echo "Clone deploy repository..."
    git clone http://gitlab.systemctl.tech/$CI_PROJECT_NAMESPACE/reddit-deploy.git

    echo "Download helm dependencies..."
    helm dep update reddit-deploy/reddit

# Это костыль из-за 3 хельма, CI рассчитан на 2
    kubectl describe namespace $KUBE_NAMESPACE || kubectl create namespace $KUBE_NAMESPACE

    echo "Deploy helm release $name to $KUBE_NAMESPACE"
    helm upgrade --install \
      --wait \
      --set ui.ingress.host="$host" \
      --set $CI_PROJECT_NAME.image.tag=$CI_APPLICATION_TAG \
      --namespace="$KUBE_NAMESPACE" \
      --version="$CI_PIPELINE_ID-$CI_JOB_ID" \
      "$name" \
      reddit-deploy/reddit/
  }

  function install_dependencies() {

    apk add -U openssl curl tar gzip bash ca-certificates git
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-2.23-r3.apk
    apk add glibc-2.23-r3.apk
    rm glibc-2.23-r3.apk

    curl https://storage.googleapis.com/pub/gsutil.tar.gz | tar -xz -C $HOME
    export PATH=${PATH}:$HOME/gsutil

    curl https://kubernetes-helm.storage.googleapis.com/helm-v2.13.1-linux-amd64.tar.gz | tar zx

    mv linux-amd64/helm /usr/bin/
    helm version --client

    curl  -o /usr/bin/sync-repo.sh https://raw.githubusercontent.com/kubernetes/helm/master/scripts/sync-repo.sh
    chmod a+x /usr/bin/sync-repo.sh

    curl -L -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
    chmod +x /usr/bin/kubectl
    kubectl version --client
  }

  function setup_docker() {
    if ! docker info &>/dev/null; then
      if [ -z "$DOCKER_HOST" -a "$KUBERNETES_PORT" ]; then
        export DOCKER_HOST='tcp://localhost:2375'
      fi
    fi
  }

  function ensure_namespace() {
    kubectl describe namespace "$KUBE_NAMESPACE" || kubectl create namespace "$KUBE_NAMESPACE"
  }

  function release() {

    echo "Updating docker images ..."

    if [[ -n "$CI_REGISTRY_USER" ]]; then
      echo "Logging to GitLab Container Registry with CI credentials..."
      docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD"
      echo ""
    fi

    docker pull "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG"
    docker tag "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG" "$CI_APPLICATION_REPOSITORY:$(cat VERSION)"
    docker push "$CI_APPLICATION_REPOSITORY:$(cat VERSION)"
    echo ""
  }

  function build() {

    echo "Building Dockerfile-based application..."
    echo `git show --format="%h" HEAD | head -1` > build_info.txt
    echo `git rev-parse --abbrev-ref HEAD` >> build_info.txt
    docker build -t "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG" .

    if [[ -n "$CI_REGISTRY_USER" ]]; then
      echo "Logging to GitLab Container Registry with CI credentials..."
      docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD"
      echo ""
    fi

    echo "Pushing to GitLab Container Registry..."
    docker push "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG"
    echo ""
  }

  function delete() {
    track="${1-stable}"
    name="$CI_ENVIRONMENT_SLUG"
    helm delete "$name" --purge || true
  }

  function install_tiller() {
    echo "Checking Tiller..."
    helm init --upgrade
    kubectl rollout status -n "$TILLER_NAMESPACE" -w "deployment/tiller-deploy"
    if ! helm version --debug; then
      echo "Failed to init Tiller."
      return 1
    fi
    echo ""
  }

before_script:
  - *auto_devops
```
но фокус не удается из-за rbac:
```log
 $ ensure_namespace
 Error from server (Forbidden): namespaces "review" is forbidden: User "system:serviceaccount:default:default" cannot get resource "namespaces" in API group "" in the namespace "review"
 Error from server (Forbidden): namespaces is forbidden: User "system:serviceaccount:default:default" cannot create resource "namespaces" in API group "" at the cluster scope
```

попробую как в курсаче: красиво. раннер в кластере с ***кластерной ролью***. 
```bash
cd /sgremyachikh_microservices/kubernetes/gitlab-runner/
make apply
```
раннер тегировал "cabac", соответственно тегирую стейджи, наверное далее подключу кластер, чтоб так не делать
```yml
---
image: alpine:latest

stages:
  - build
  - test
  - review
  - release
  - cleanup

build:
  stage: build
  image: docker:git
  services:
    - docker:18.09.7-dind
  script:
    - setup_docker
    - build
  variables:
    DOCKER_DRIVER: overlay2
  only:
    - branches
  tags:
    - cabac

test:
  stage: test
  script:
    - exit 0
  only:
    - branches
  tags:
    - cabac

release:
  stage: release
  image: docker
  services:
    - docker:18.09.7-dind
  script:
    - setup_docker
    - release
  only:
    - master
  tags:
    - cabac

review:
  stage: review
  script:
    - install_dependencies
    - ensure_namespace
    - install_tiller
    - deploy
  variables:
    KUBE_NAMESPACE: review
    host: $CI_PROJECT_PATH_SLUG-$CI_COMMIT_REF_SLUG
  environment:
    name: review/$CI_PROJECT_PATH/$CI_COMMIT_REF_NAME
    url: http://$CI_PROJECT_PATH_SLUG-$CI_COMMIT_REF_SLUG
    on_stop: stop_review
  only:
    refs:
      - branches
#    kubernetes: active
  except:
    - master
  tags:
    - cabac

stop_review:
  stage: cleanup
  variables:
    GIT_STRATEGY: none
  script:
    - install_dependencies
    - delete
  environment:
    name: review/$CI_PROJECT_PATH/$CI_COMMIT_REF_NAME
    action: stop
  when: manual
  allow_failure: true
  only:
    refs:
      - branches
#    kubernetes: active
  except:
    - master
  tags:
    - cabac

.auto_devops: &auto_devops |
  [[ "$TRACE" ]] && set -x
  export CI_REGISTRY="index.docker.io"
  export CI_APPLICATION_REPOSITORY=$CI_REGISTRY/$CI_PROJECT_PATH
  export CI_APPLICATION_TAG=$CI_COMMIT_REF_SLUG
  export CI_CONTAINER_NAME=ci_job_build_${CI_JOB_ID}
  export TILLER_NAMESPACE="kube-system"

  function deploy() {
    track="${1-stable}"
    name="$CI_ENVIRONMENT_SLUG"

    if [[ "$track" != "stable" ]]; then
      name="$name-$track"
    fi

    echo "Clone deploy repository..."
    git clone ${CI_SERVER_PROTOCOL}://gitlab-ci-token:${CI_JOB_TOKEN}@gitlab.systemctl.tech:${CI_SERVER_PORT}/decapapreta/reddit-deploy.git

    echo "Download helm dependencies..."
    helm dep update reddit-deploy/reddit

    echo "Deploy helm release $name to $KUBE_NAMESPACE"
    helm upgrade --install \
      --wait \
      --set ui.ingress.host="$host" \
      --set $CI_PROJECT_NAME.image.tag=$CI_APPLICATION_TAG \
      --namespace="$KUBE_NAMESPACE" \
      --version="$CI_PIPELINE_ID-$CI_JOB_ID" \
      "$name" \
      reddit-deploy/reddit/
  }

  function install_dependencies() {

    apk add -U openssl curl tar gzip bash ca-certificates git
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-2.23-r3.apk
    apk add glibc-2.23-r3.apk
    rm glibc-2.23-r3.apk

    curl https://storage.googleapis.com/pub/gsutil.tar.gz | tar -xz -C $HOME
    export PATH=${PATH}:$HOME/gsutil

    curl https://kubernetes-helm.storage.googleapis.com/helm-v2.13.1-linux-amd64.tar.gz | tar zx

    mv linux-amd64/helm /usr/bin/
    helm version --client

    curl  -o /usr/bin/sync-repo.sh https://raw.githubusercontent.com/kubernetes/helm/master/scripts/sync-repo.sh
    chmod a+x /usr/bin/sync-repo.sh

    curl -L -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
    chmod +x /usr/bin/kubectl
    kubectl version --client
  }

  function setup_docker() {
    if ! docker info &>/dev/null; then
      if [ -z "$DOCKER_HOST" -a "$KUBERNETES_PORT" ]; then
        export DOCKER_HOST='tcp://localhost:2375'
      fi
    fi
  }

  function ensure_namespace() {
    kubectl describe namespace "$KUBE_NAMESPACE" || kubectl create namespace "$KUBE_NAMESPACE"
  }

  function release() {

    echo "Updating docker images ..."

    if [[ -n "$CI_REGISTRY_USER" ]]; then
      echo "Logging to GitLab Container Registry with CI credentials..."
      docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD"
      echo ""
    fi

    docker pull "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG"
    docker tag "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG" "$CI_APPLICATION_REPOSITORY:$(cat VERSION)"
    docker push "$CI_APPLICATION_REPOSITORY:$(cat VERSION)"
    echo ""
  }

  function build() {

    echo "Building Dockerfile-based application..."
    echo `git show --format="%h" HEAD | head -1` > build_info.txt
    echo `git rev-parse --abbrev-ref HEAD` >> build_info.txt
    docker build -t "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG" .

    if [[ -n "$CI_REGISTRY_USER" ]]; then
      echo "Logging to GitLab Container Registry with CI credentials..."
      docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD"
      echo ""
    fi

    echo "Pushing to GitLab Container Registry..."
    docker push "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG"
    echo ""
  }

  function delete() {
    track="${1-stable}"
    name="$CI_ENVIRONMENT_SLUG"
    helm delete "$name" --purge || true
  }

  function install_tiller() {
    echo "Checking Tiller..."
    helm init --upgrade
    kubectl rollout status -n "$TILLER_NAMESPACE" -w "deployment/tiller-deploy"
    if ! helm version --debug; then
      echo "Failed to init Tiller."
      return 1
    fi
    echo ""
  }

before_script:
  - *auto_devops

```

В Environments https://gitlab.systemctl.tech/decapapreta/ui/-/environments/1

запуск и удаление работают

Скопировать полученный файл .gitlab-ci.yml для ui в
репозитории для post и comment.
Проверить, что динамическое создание и удаление окружений
работает с ними как ожидалось

работают

### Деплоим

Теперь создадим staging и production среды для работы
приложения
Создайте файл reddit-deploy/.gitlab-ci.yml
```yml
image: alpine:latest

stages:
  - test
  - staging
  - production

test:
  stage: test
  script:
    - exit 0
  only:
    - triggers
    - branches
  tags:
    - cabac

staging:
  stage: staging
  script:
  - install_dependencies
  - ensure_namespace
  - install_tiller
  - deploy
  variables:
    KUBE_NAMESPACE: staging
  environment:
    name: staging
    url: http://staging
  only:
    refs:
      - master
#    kubernetes: active
  tags:
    - cabac

production:
  stage: production
  script:
    - install_dependencies
    - ensure_namespace
    - install_tiller
    - deploy
  variables:
    KUBE_NAMESPACE: production
  environment:
    name: production
    url: http://production
  when: manual
  only:
    refs:
      - master
  tags:
    - cabac
#    kubernetes: active

.auto_devops: &auto_devops |
  # Auto DevOps variables and functions
  [[ "$TRACE" ]] && set -x
  export CI_REGISTRY="index.docker.io"
  export CI_APPLICATION_REPOSITORY=$CI_REGISTRY/$CI_PROJECT_PATH
  export CI_APPLICATION_TAG=$CI_COMMIT_REF_SLUG
  export CI_CONTAINER_NAME=ci_job_build_${CI_JOB_ID}
  export TILLER_NAMESPACE="kube-system"

  function deploy() {
    echo $KUBE_NAMESPACE
    track="${1-stable}"
    name="$CI_ENVIRONMENT_SLUG"
    helm dep build reddit

    # for microservice in $(helm dep ls | grep "file://" | awk '{print $1}') ; do
    #   SET_VERSION="$SET_VERSION \ --set $microservice.image.tag='$(curl http://gitlab-gitlab/$CI_PROJECT_NAMESPACE/ui/raw/master/VERSION)' "

    helm upgrade --install \
      --wait \
      --set ui.ingress.host="$host" \
      --set ui.image.tag="$(curl http://gitlab-gitlab/$CI_PROJECT_NAMESPACE/ui/raw/master/VERSION)" \
      --set post.image.tag="$(curl http://gitlab-gitlab/$CI_PROJECT_NAMESPACE/post/raw/master/VERSION)" \
      --set comment.image.tag="$(curl http://gitlab-gitlab/$CI_PROJECT_NAMESPACE/comment/raw/master/VERSION)" \
      --namespace="$KUBE_NAMESPACE" \
      --version="$CI_PIPELINE_ID-$CI_JOB_ID" \
      "$name" \
      reddit
  }

  function install_dependencies() {

    apk add -U openssl curl tar gzip bash ca-certificates git
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-2.23-r3.apk
    apk add glibc-2.23-r3.apk
    rm glibc-2.23-r3.apk

    curl https://kubernetes-helm.storage.googleapis.com/helm-v2.13.1-linux-amd64.tar.gz | tar zx

    mv linux-amd64/helm /usr/bin/
    helm version --client

    curl -L -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
    chmod +x /usr/bin/kubectl
    kubectl version --client
  }

  function ensure_namespace() {
    kubectl describe namespace "$KUBE_NAMESPACE" || kubectl create namespace "$KUBE_NAMESPACE"
  }

  function install_tiller() {
    echo "Checking Tiller..."
    helm init --upgrade
    kubectl rollout status -n "$TILLER_NAMESPACE" -w "deployment/tiller-deploy"
    if ! helm version --debug; then
      echo "Failed to init Tiller."
      return 1
    fi
    echo ""
  }

  function delete() {
    track="${1-stable}"
    name="$CI_ENVIRONMENT_SLUG"
    helm delete "$name" || true
  }

before_script:
  - *auto_devops
```
Запуште в репозиторий reddit-deploy ветку master
Этот файл отличается от предыдущих тем, что:
1. Не собирает docker-образы
2. Деплоит на статичные окружения (staging и production)
3. Не удаляет окружения

Удостоверьтесь, что staging успешно завершен
Ошибка в job `staging`
```log
$ deploy
staging
Error: requirements.lock is out of sync with requirements.yaml
```
обновил зависимости чарта 2-м хельмом, запушил в мастер

Деплой на staging успешно. Сайт доступен из https://gitlab.systemctl.tech/decapapreta/reddit-deploy/environments
Production: здесь мы запускаем ручной пайплайн деплоя на прод. И ждем, пока пайплайн завершится
В https://gitlab.systemctl.tech/decapapreta/reddit-deploy/environments видно  оба окружения

### Пайплайн здорового человека

Сейчас почти вся логика пайплайна заключена в auto_devops и
трудночитаема. Давайте переделаем имеющийся для ui пайплайн
так, чтобы он соответствовал синтаксису Gitlab

```yaml
---
image: alpine:latest

stages:
  - build
  - test
  - review
  - release
  - cleanup

build:
  stage: build
  only:
    - branches
  image: docker:git
  services:
    - docker:18.09.7-dind
  variables:
    DOCKER_DRIVER: overlay2
    CI_REGISTRY: 'index.docker.io'
    CI_APPLICATION_REPOSITORY: $CI_REGISTRY/$CI_PROJECT_PATH
    CI_APPLICATION_TAG: $CI_COMMIT_REF_SLUG
    CI_CONTAINER_NAME: ci_job_build_${CI_JOB_ID}
  before_script:
    - >
      if ! docker info &>/dev/null; then
        if [ -z "$DOCKER_HOST" -a "$KUBERNETES_PORT" ]; then
          export DOCKER_HOST='tcp://localhost:2375'
        fi
      fi
  script:
    # Building
    - echo "Building Dockerfile-based application..."
    - echo `git show --format="%h" HEAD | head -1` > build_info.txt
    - echo `git rev-parse --abbrev-ref HEAD` >> build_info.txt
    - docker build -t "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG" .
    - >
      if [[ -n "$CI_REGISTRY_USER" ]]; then
        echo "Logging to GitLab Container Registry with CI credentials...for build"
        docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD"
      fi
    - echo "Pushing to GitLab Container Registry..."
    - docker push "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG"

test:
  stage: test
  script:
    - exit 0
  only:
    - branches

release:
  stage: release
  image: docker
  services:
    - docker:18.09.7-dind
  variables:
    CI_REGISTRY: 'index.docker.io'
    CI_APPLICATION_REPOSITORY: $CI_REGISTRY/$CI_PROJECT_PATH
    CI_APPLICATION_TAG: $CI_COMMIT_REF_SLUG
    CI_CONTAINER_NAME: ci_job_build_${CI_JOB_ID}
  before_script:
    - >
      if ! docker info &>/dev/null; then
        if [ -z "$DOCKER_HOST" -a "$KUBERNETES_PORT" ]; then
          export DOCKER_HOST='tcp://localhost:2375'
        fi
      fi
  script:
    # Releasing
    - echo "Updating docker images ..."
    - >
      if [[ -n "$CI_REGISTRY_USER" ]]; then
        echo "Logging to GitLab Container Registry with CI credentials for release..."
        docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD"
      fi
    - docker pull "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG"
    - docker tag "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG" "$CI_APPLICATION_REPOSITORY:$(cat VERSION)"
    - docker push "$CI_APPLICATION_REPOSITORY:$(cat VERSION)"
    # latest is neede for feature flags
    - docker tag "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG" "$CI_APPLICATION_REPOSITORY:latest"
    - docker push "$CI_APPLICATION_REPOSITORY:latest"
  only:
    - master

review:
  stage: review
  variables:
    KUBE_NAMESPACE: review
    host: $CI_PROJECT_PATH_SLUG-$CI_COMMIT_REF_SLUG
    TILLER_NAMESPACE: kube-system
    CI_APPLICATION_TAG: $CI_COMMIT_REF_SLUG
    name: $CI_ENVIRONMENT_SLUG
  environment:
    name: review/$CI_PROJECT_PATH/$CI_COMMIT_REF_NAME
    url: http://$CI_PROJECT_PATH_SLUG-$CI_COMMIT_REF_SLUG
    on_stop: stop_review
  only:
    refs:
      - branches
    kubernetes: active
  except:
    - master
  before_script:
    # installing dependencies
    - apk add -U openssl curl tar gzip bash ca-certificates git
    - wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
    - wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-2.23-r3.apk
    - apk add glibc-2.23-r3.apk
    - curl https://storage.googleapis.com/pub/gsutil.tar.gz | tar -xz -C $HOME
    - export PATH=${PATH}:$HOME/gsutil
    - curl https://kubernetes-helm.storage.googleapis.com/helm-v2.13.1-linux-amd64.tar.gz | tar zx
    - mv linux-amd64/helm /usr/bin/
    - helm version --client
    - curl  -o /usr/bin/sync-repo.sh https://raw.githubusercontent.com/kubernetes/helm/master/scripts/sync-repo.sh
    - chmod a+x /usr/bin/sync-repo.sh
    - curl -L -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
    - chmod +x /usr/bin/kubectl
    - kubectl version --client
    # ensuring namespace
    - kubectl describe namespace "$KUBE_NAMESPACE" || kubectl create namespace "$KUBE_NAMESPACE"
    # installing Tiller
    - echo "Checking Tiller..."
    - helm init --upgrade
    - kubectl rollout status -n "$TILLER_NAMESPACE" -w "deployment/tiller-deploy"
    - >
      if ! helm version --debug; then
        echo "Failed to init Tiller."
        exit 1
      fi
  script:
    - export track="${1-stable}"
    - >
      if [[ "$track" != "stable" ]]; then
        name="$name-$track"
      fi
    - echo "Clone deploy repository..."
    - git clone http://gitlab-gitlab/$CI_PROJECT_NAMESPACE/reddit-deploy.git
    - echo "Download helm dependencies..."
    - helm dep update reddit-deploy/reddit
    - echo "Deploy helm release $name to $KUBE_NAMESPACE"
    - echo "Upgrading existing release..."
    - echo "helm upgrade --install --wait --set ui.ingress.host="$host" --set $CI_PROJECT_NAME.image.tag="$CI_APPLICATION_TAG" --namespace="$KUBE_NAMESPACE" --version="$CI_PIPELINE_ID-$CI_JOB_ID" "$name" reddit-deploy/reddit/"
    - >
      helm upgrade \
        --install \
        --wait \
        --set ui.ingress.host="$host" \
        --set $CI_PROJECT_NAME.image.tag="$CI_APPLICATION_TAG" \
        --namespace="$KUBE_NAMESPACE" \
        --version="$CI_PIPELINE_ID-$CI_JOB_ID" \
        "$name" \
        reddit-deploy/reddit/

stop_review:
  stage: cleanup
  variables:
    GIT_STRATEGY: none
    name: $CI_ENVIRONMENT_SLUG
  environment:
    name: review/$CI_PROJECT_PATH/$CI_COMMIT_REF_NAME
    action: stop
  when: manual
  allow_failure: true
  only:
    refs:
      - branches
    kubernetes: active
  except:
    - master
  before_script:
    # installing dependencies
    - apk add -U openssl curl tar gzip bash ca-certificates git
    - wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
    - wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-2.23-r3.apk
    - apk add glibc-2.23-r3.apk
    - curl https://storage.googleapis.com/pub/gsutil.tar.gz | tar -xz -C $HOME
    - export PATH=${PATH}:$HOME/gsutil
    - curl https://kubernetes-helm.storage.googleapis.com/helm-v2.13.1-linux-amd64.tar.gz | tar zx
    - mv linux-amd64/helm /usr/bin/
    - helm version --client
    - curl  -o /usr/bin/sync-repo.sh https://raw.githubusercontent.com/kubernetes/helm/master/scripts/sync-repo.sh
    - chmod a+x /usr/bin/sync-repo.sh
    - curl -L -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
    - chmod +x /usr/bin/kubectl
    - kubectl version --client
  script:
    - helm delete "$name" --purge
...
```
Тонкости синтаксиса:

- Объявление переменных можно перенести в variables
- conditional statements можно записать так:
  ```shell
  if [[ "$track" != "stable" ]]; then
  name="$name-$track"
  fi
  ```
- А рзносить строку на несолько так:
  ```shell
  helm upgrade --install \
  --wait \
  --set ui.ingress.host="$host"
  ```

Как видите, читаемость кода значительно возросла.

1. Изменить пайплайн сервиса _COMMENT_, использующих для деплоя `helm2` таким образом, чтобы деплой осуществлялся с использованием `tiller plugin`. Таким образом, деплой каждого пайплайна из трех сервисов должен производиться по-разному.
2. Изменить пайплайн сервиса _POST_, чтобы он использовал `helm3` для деплоя.

Полученные файлы пайплайнов для сервисов (4 штуки: `ui`, `post`, `comment`, `reddit`) положить в директорию `Charts/gitlabci` под именами `gitlab-ci-.yml` и закоммитить.

### UI

```yml
---
image: alpine:latest

stages:
  - build
  - test
  - review
  - release
  - cleanup

build:
  stage: build
  only:
    - branches
  image: docker:git
  services:
    - docker:18.09.7-dind
  variables:
    DOCKER_DRIVER: overlay2
    CI_REGISTRY: 'index.docker.io'
    CI_APPLICATION_REPOSITORY: $CI_REGISTRY/$CI_PROJECT_PATH
    CI_APPLICATION_TAG: $CI_COMMIT_REF_SLUG
    CI_CONTAINER_NAME: ci_job_build_${CI_JOB_ID}
  before_script:
    - >
      if ! docker info &>/dev/null; then
        if [ -z "$DOCKER_HOST" -a "$KUBERNETES_PORT" ]; then
          export DOCKER_HOST='tcp://localhost:2375'
        fi
      fi
  script:
    # Building
    - echo "Building Dockerfile-based application..."
    - echo `git show --format="%h" HEAD | head -1` > build_info.txt
    - echo `git rev-parse --abbrev-ref HEAD` >> build_info.txt
    - docker build -t "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG" .
    - >
      if [[ -n "$CI_REGISTRY_USER" ]]; then
        echo "Logging to GitLab Container Registry with CI credentials...for build"
        docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD"
      fi
    - echo "Pushing to GitLab Container Registry..."
    - docker push "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG"

test:
  stage: test
  script:
    - exit 0
  only:
    - branches

release:
  stage: release
  image: docker
  services:
    - docker:18.09.7-dind
  variables:
    CI_REGISTRY: 'index.docker.io'
    CI_APPLICATION_REPOSITORY: $CI_REGISTRY/$CI_PROJECT_PATH
    CI_APPLICATION_TAG: $CI_COMMIT_REF_SLUG
    CI_CONTAINER_NAME: ci_job_build_${CI_JOB_ID}
  before_script:
    - >
      if ! docker info &>/dev/null; then
        if [ -z "$DOCKER_HOST" -a "$KUBERNETES_PORT" ]; then
          export DOCKER_HOST='tcp://localhost:2375'
        fi
      fi
  script:
    # Releasing
    - echo "Updating docker images ..."
    - >
      if [[ -n "$CI_REGISTRY_USER" ]]; then
        echo "Logging to GitLab Container Registry with CI credentials for release..."
        docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD"
      fi
    - docker pull "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG"
    - docker tag "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG" "$CI_APPLICATION_REPOSITORY:$(cat VERSION)"
    - docker push "$CI_APPLICATION_REPOSITORY:$(cat VERSION)"
    # latest is neede for feature flags
    - docker tag "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG" "$CI_APPLICATION_REPOSITORY:latest"
    - docker push "$CI_APPLICATION_REPOSITORY:latest"
  only:
    - master

review:
  stage: review
  variables:
    KUBE_NAMESPACE: review
    host: $CI_PROJECT_PATH_SLUG-$CI_COMMIT_REF_SLUG
    TILLER_NAMESPACE: kube-system
    CI_APPLICATION_TAG: $CI_COMMIT_REF_SLUG
    name: $CI_ENVIRONMENT_SLUG
  environment:
    name: review/$CI_PROJECT_PATH/$CI_COMMIT_REF_NAME
    url: http://$CI_PROJECT_PATH_SLUG-$CI_COMMIT_REF_SLUG
    on_stop: stop_review
  only:
    refs:
      - branches
    kubernetes: active
  except:
    - master
  before_script:
    # installing dependencies
    - apk add -U openssl curl tar gzip bash ca-certificates git
    - wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
    - wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-2.23-r3.apk
    - apk add glibc-2.23-r3.apk
    - curl https://storage.googleapis.com/pub/gsutil.tar.gz | tar -xz -C $HOME
    - export PATH=${PATH}:$HOME/gsutil
    - curl https://kubernetes-helm.storage.googleapis.com/helm-v2.13.1-linux-amd64.tar.gz | tar zx
    - mv linux-amd64/helm /usr/bin/
    - helm version --client
    - curl  -o /usr/bin/sync-repo.sh https://raw.githubusercontent.com/kubernetes/helm/master/scripts/sync-repo.sh
    - chmod a+x /usr/bin/sync-repo.sh
    - curl -L -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
    - chmod +x /usr/bin/kubectl
    - kubectl version --client
    # ensuring namespace
    - kubectl describe namespace "$KUBE_NAMESPACE" || kubectl create namespace "$KUBE_NAMESPACE"
    # installing Tiller
    - echo "Checking Tiller..."
    - helm init --upgrade
    - kubectl rollout status -n "$TILLER_NAMESPACE" -w "deployment/tiller-deploy"
    - >
      if ! helm version --debug; then
        echo "Failed to init Tiller."
        exit 1
      fi
  script:
    - export track="${1-stable}"
    - >
      if [[ "$track" != "stable" ]]; then
        name="$name-$track"
      fi
    - echo "Clone deploy repository..."
    - git clone http://gitlab-gitlab/$CI_PROJECT_NAMESPACE/reddit-deploy.git
    - echo "Download helm dependencies..."
    - helm dep update reddit-deploy/reddit
    - echo "Deploy helm release $name to $KUBE_NAMESPACE"
    - echo "Upgrading existing release..."
    - echo "helm upgrade --install --wait --set ui.ingress.host="$host" --set $CI_PROJECT_NAME.image.tag="$CI_APPLICATION_TAG" --namespace="$KUBE_NAMESPACE" --version="$CI_PIPELINE_ID-$CI_JOB_ID" "$name" reddit-deploy/reddit/"
    - >
      helm upgrade \
        --install \
        --wait \
        --set ui.ingress.host="$host" \
        --set $CI_PROJECT_NAME.image.tag="$CI_APPLICATION_TAG" \
        --namespace="$KUBE_NAMESPACE" \
        --version="$CI_PIPELINE_ID-$CI_JOB_ID" \
        "$name" \
        reddit-deploy/reddit/

stop_review:
  stage: cleanup
  variables:
    GIT_STRATEGY: none
    name: $CI_ENVIRONMENT_SLUG
  environment:
    name: review/$CI_PROJECT_PATH/$CI_COMMIT_REF_NAME
    action: stop
  when: manual
  allow_failure: true
  only:
    refs:
      - branches
    kubernetes: active
  except:
    - master
  before_script:
    # installing dependencies
    - apk add -U openssl curl tar gzip bash ca-certificates git
    - wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
    - wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-2.23-r3.apk
    - apk add glibc-2.23-r3.apk
    - curl https://storage.googleapis.com/pub/gsutil.tar.gz | tar -xz -C $HOME
    - export PATH=${PATH}:$HOME/gsutil
    - curl https://kubernetes-helm.storage.googleapis.com/helm-v2.13.1-linux-amd64.tar.gz | tar zx
    - mv linux-amd64/helm /usr/bin/
    - helm version --client
    - curl  -o /usr/bin/sync-repo.sh https://raw.githubusercontent.com/kubernetes/helm/master/scripts/sync-repo.sh
    - chmod a+x /usr/bin/sync-repo.sh
    - curl -L -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
    - chmod +x /usr/bin/kubectl
    - kubectl version --client
  script:
    - helm delete "$name" --purge
...
```
### Comment

```yml
---
image: alpine:latest

stages:
  - build
  - test
  - review
  - release
  - cleanup

build:
  stage: build
  image: docker:git
  services:
    - docker:18.09.7-dind
  script:
    - setup_docker
    - build
  variables:
    DOCKER_DRIVER: overlay2
  only:
    - branches

test:
  stage: test
  script:
    - exit 0
  only:
    - branches

release:
  stage: release
  image: docker
  services:
    - docker:18.09.7-dind
  script:
    - setup_docker
    - release
  only:
    - master

review:
  stage: review
  script:
    - install_dependencies
    - ensure_namespace
    - install_tiller
    - deploy
  variables:
    KUBE_NAMESPACE: review
    host: $CI_PROJECT_PATH_SLUG-$CI_COMMIT_REF_SLUG
  environment:
    name: review/$CI_PROJECT_PATH/$CI_COMMIT_REF_NAME
    url: http://$CI_PROJECT_PATH_SLUG-$CI_COMMIT_REF_SLUG
    on_stop: stop_review
  only:
    refs:
      - branches
    kubernetes: active
  except:
    - master

stop_review:
  stage: cleanup
  variables:
    GIT_STRATEGY: none
  script:
    - install_dependencies
    - delete
  environment:
    name: review/$CI_PROJECT_PATH/$CI_COMMIT_REF_NAME
    action: stop
  when: manual
  allow_failure: true
  only:
    refs:
      - branches
    kubernetes: active
  except:
    - master
                                                                                                                      
.auto_devops: &auto_devops |
  [[ "$TRACE" ]] && set -x
  export CI_REGISTRY="index.docker.io"
  export CI_APPLICATION_REPOSITORY=$CI_REGISTRY/$CI_PROJECT_PATH
  export CI_APPLICATION_TAG=$CI_COMMIT_REF_SLUG
  export CI_CONTAINER_NAME=ci_job_build_${CI_JOB_ID}
  export TILLER_NAMESPACE="kube-system"

  function deploy() {
    track="${1-stable}"
    name="$CI_ENVIRONMENT_SLUG"

    if [[ "$track" != "stable" ]]; then
      name="$name-$track"
    fi

    echo "Clone deploy repository..."
    git clone http://gitlab-gitlab/$CI_PROJECT_NAMESPACE/reddit-deploy.git

    echo "Download helm dependencies..."
    helm dep update reddit-deploy/reddit

    echo "Deploy helm release $name to $KUBE_NAMESPACE"
    helm tiller run \
    helm upgrade --install \
      --wait \
      --set ui.ingress.host="$host" \
      --set $CI_PROJECT_NAME.image.tag=$CI_APPLICATION_TAG \
      --namespace="$KUBE_NAMESPACE" \
      --version="$CI_PIPELINE_ID-$CI_JOB_ID" \
      "$name" \
      reddit-deploy/reddit/
  }

  function install_dependencies() {

    apk add -U openssl curl tar gzip bash ca-certificates git
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-2.23-r3.apk
    apk add glibc-2.23-r3.apk
    rm glibc-2.23-r3.apk

    curl https://storage.googleapis.com/pub/gsutil.tar.gz | tar -xz -C $HOME
    export PATH=${PATH}:$HOME/gsutil

    curl https://kubernetes-helm.storage.googleapis.com/helm-v2.13.1-linux-amd64.tar.gz | tar zx

    mv linux-amd64/helm /usr/bin/
    helm version --client

    echo "Helm init & plugin tiller install"
    helm init --client-only
    helm plugin install https://github.com/rimusz/helm-tiller

    curl  -o /usr/bin/sync-repo.sh https://raw.githubusercontent.com/kubernetes/helm/master/scripts/sync-repo.sh
    chmod a+x /usr/bin/sync-repo.sh

    curl -L -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
    chmod +x /usr/bin/kubectl
    kubectl version --client
  }

  function setup_docker() {
    if ! docker info &>/dev/null; then
      if [ -z "$DOCKER_HOST" -a "$KUBERNETES_PORT" ]; then
        export DOCKER_HOST='tcp://localhost:2375'
      fi
    fi
  }

  function ensure_namespace() {
    kubectl describe namespace "$KUBE_NAMESPACE" || kubectl create namespace "$KUBE_NAMESPACE"
  }

  function release() {

    echo "Updating docker images ..."

    if [[ -n "$CI_REGISTRY_USER" ]]; then
      echo "Logging to GitLab Container Registry with CI credentials..."
      docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD"
      echo ""
    fi

    docker pull "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG"
    docker tag "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG" "$CI_APPLICATION_REPOSITORY:$(cat VERSION)"
    docker push "$CI_APPLICATION_REPOSITORY:$(cat VERSION)"
    echo ""
  }

  function build() {

    echo "Building Dockerfile-based application..."
    echo `git show --format="%h" HEAD | head -1` > build_info.txt
    echo `git rev-parse --abbrev-ref HEAD` >> build_info.txt
    docker build -t "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG" .

    if [[ -n "$CI_REGISTRY_USER" ]]; then
      echo "Logging to GitLab Container Registry with CI credentials..."
      docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD"
      echo ""
    fi

    echo "Pushing to GitLab Container Registry..."
    docker push "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG"
    echo ""
  }

  function install_tiller() {
    echo "Checking Tiller..."
    #helm init --upgrade
    helm init --client-only
    kubectl rollout status -n "$TILLER_NAMESPACE" -w "deployment/tiller-deploy"
    if ! helm version --debug; then
      echo "Failed to init Tiller."
      return 1
    fi
    echo ""
  }

  function delete() {
    track="${1-stable}"
    name="$CI_ENVIRONMENT_SLUG"
    helm delete "$name" --purge || true
  }

before_script:
  - *auto_devops
...
 
```
### POST

```yml
---
image: alpine:latest

stages:
  - build
  - test
  - review
  - release
  - cleanup

build:
  stage: build
  image: docker:git
  services:
    - docker:18.09.7-dind
  script:
    - setup_docker
    - build
  variables:
    DOCKER_DRIVER: overlay2
  only:
    - branches

test:
  stage: test
  script:
    - exit 0
  only:
    - branches

release:
  stage: release
  image: docker
  services:
    - docker:18.09.7-dind
  script:
    - setup_docker
    - release
  only:
    - master

review:
  stage: review
  script:
    - install_dependencies
    - ensure_namespace
    - install_tiller
    - deploy
  variables:
    KUBE_NAMESPACE: review
    host: $CI_PROJECT_PATH_SLUG-$CI_COMMIT_REF_SLUG
  environment:
    name: review/$CI_PROJECT_PATH/$CI_COMMIT_REF_NAME
    url: http://$CI_PROJECT_PATH_SLUG-$CI_COMMIT_REF_SLUG
    on_stop: stop_review
  only:
    refs:
      - branches
    kubernetes: active
  except:
    - master

stop_review:
  stage: cleanup
  variables:
    GIT_STRATEGY: none
  script:
    - install_dependencies
    - delete
  environment:
    name: review/$CI_PROJECT_PATH/$CI_COMMIT_REF_NAME
    action: stop
  when: manual
  allow_failure: true
  only:
    refs:
      - branches
    kubernetes: active
  except:
    - master
                                                                                                                      
.auto_devops: &auto_devops |
  [[ "$TRACE" ]] && set -x
  export CI_REGISTRY="index.docker.io"
  export CI_APPLICATION_REPOSITORY=$CI_REGISTRY/$CI_PROJECT_PATH
  export CI_APPLICATION_TAG=$CI_COMMIT_REF_SLUG
  export CI_CONTAINER_NAME=ci_job_build_${CI_JOB_ID}
  export TILLER_NAMESPACE="kube-system"

  function deploy() {
    track="${1-stable}"
    name="$CI_ENVIRONMENT_SLUG"

    if [[ "$track" != "stable" ]]; then
      name="$name-$track"
    fi

    echo "Clone deploy repository..."
    git clone http://gitlab-gitlab/$CI_PROJECT_NAMESPACE/reddit-deploy.git

    echo "Download helm dependencies..."
    helm dep update reddit-deploy/reddit

    echo "Deploy helm release $name to $KUBE_NAMESPACE"
    helm upgrade --install \
      --wait \
      --set ui.ingress.host="$host" \
      --set $CI_PROJECT_NAME.image.tag=$CI_APPLICATION_TAG \
      --namespace="$KUBE_NAMESPACE" \
      --version="$CI_PIPELINE_ID-$CI_JOB_ID" \
      "$name" \
      reddit-deploy/reddit/
  }

  function install_dependencies() {

    apk add -U openssl curl tar gzip bash ca-certificates git
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-2.23-r3.apk
    apk add glibc-2.23-r3.apk
    rm glibc-2.23-r3.apk

    curl https://storage.googleapis.com/pub/gsutil.tar.gz | tar -xz -C $HOME
    export PATH=${PATH}:$HOME/gsutil

    #curl https://kubernetes-helm.storage.googleapis.com/helm-v2.13.1-linux-amd64.tar.gz | tar zx
    curl https://get.helm.sh/helm-v3.0.2-linux-amd64.tar.gz | tar zx

    mv linux-amd64/helm /usr/bin/
    helm version --client

    curl  -o /usr/bin/sync-repo.sh https://raw.githubusercontent.com/kubernetes/helm/master/scripts/sync-repo.sh
    chmod a+x /usr/bin/sync-repo.sh

    curl -L -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
    chmod +x /usr/bin/kubectl
    kubectl version --client
  }

  function setup_docker() {
    if ! docker info &>/dev/null; then
      if [ -z "$DOCKER_HOST" -a "$KUBERNETES_PORT" ]; then
        export DOCKER_HOST='tcp://localhost:2375'
      fi
    fi
  }

  function ensure_namespace() {
    kubectl describe namespace "$KUBE_NAMESPACE" || kubectl create namespace "$KUBE_NAMESPACE"
  }

  function release() {

    echo "Updating docker images ..."

    if [[ -n "$CI_REGISTRY_USER" ]]; then
      echo "Logging to GitLab Container Registry with CI credentials..."
      docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD"
      echo ""
    fi

    docker pull "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG"
    docker tag "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG" "$CI_APPLICATION_REPOSITORY:$(cat VERSION)"
    docker push "$CI_APPLICATION_REPOSITORY:$(cat VERSION)"
    echo ""
  }

  function build() {

    echo "Building Dockerfile-based application..."
    echo `git show --format="%h" HEAD | head -1` > build_info.txt
    echo `git rev-parse --abbrev-ref HEAD` >> build_info.txt
    docker build -t "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG" .

    if [[ -n "$CI_REGISTRY_USER" ]]; then
      echo "Logging to GitLab Container Registry with CI credentials..."
      docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD"
      echo ""
    fi

    echo "Pushing to GitLab Container Registry..."
    docker push "$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG"
    echo ""
  }

  function install_tiller() {
    echo "Checking Tiller..."
    #helm init --upgrade
    #kubectl rollout status -n "$TILLER_NAMESPACE" -w "deployment/tiller-deploy"
    #if ! helm version --debug; then
    #  echo "Failed to init Tiller."
    #  return 1
    #fi
    echo ""
  }

  function delete() {
    track="${1-stable}"
    name="$CI_ENVIRONMENT_SLUG"
    helm delete "$name" --purge || true
  }

before_script:
  - *auto_devops
...

```
