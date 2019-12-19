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

In order for GitLab to display correct repository clone links to your users it needs to know the URL under which it is reached by your users, e.g. http://gitlab.example.com. Add or edit the following line in :

> external_url "http://gitlab.example.com"

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
