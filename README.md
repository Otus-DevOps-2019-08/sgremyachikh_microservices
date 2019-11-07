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
