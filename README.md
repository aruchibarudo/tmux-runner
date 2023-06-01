# Dumper
Скрипт запуска сбора трафика (tcpdump) на хостах в tmux

## Требования
* Удаленный хост linux с установленным `tcpdump, ip, sed`.
* Пользователь, из под которого запускается скрипт, должен подключаться по ключу через `ssh`.
* Пользователь, под которым происходит подключения к удаленному хосту, должен иметь право запуска `tcpdump`.
## Как работает
* Создается сессия `tmux` (по умолчанию `tcpdump`)
* Список хостов для подключения берется из файла (один хост на строку), указанного первым параметром (по умолчанию `list.txt`).
* Создаются окна максимумом с 4-мя панелями (общее кол-во панелей равно кол-ву хостов).
* В каждой панеле подключается к хосту через `ssh` и запускает `tcpdump`. Собирается трафик к хосту и от него, исключая хост, с которого идет подключение.
* Трафик складывается в файл `hostname.pcap` в директорию указанную вторым параметром (по умолчанию `./dump`) в поддиректорию указанную третьм параметром (по умолчанию текущие дата и время).
* В консолях выводятся заголовки пакетов.
## Как работать в tmux
* В рамках одного окна весь ввод идет на все панели сразу, т.е. если нажать `ctrl+c`, то это прервет сбор трафика на всех панелях/хостах в текущем окне.
* Переключение между окнами `ctrl+b n`
* Переключение к конкретному окну `ctrl+b <номер_окна>`, окна нумеруются с 0
* Отключится от сессии `ctrl+b d`
* Вернуться в сессию `tmux a -t tcpdump`
* Оставновить сбор трафика `ctrl+c`
* Выход из всех панелей/хостов в текущем окне `ctrl+d`

## Запуск
```
$ cat list.txt
spb99tpagent01
spb99tpagent02
spb99tpagent03
spb99tpagent04
$ ./run.sh
Proccess spb99tpagent01 spb99tpagent02 spb99tpagent03 spb99tpagent04 in window 0
arranging in: tiled
run ssh spb99tpagent01 bash /tmp/run.sh | tee ./dump/2023-06-01T16-52-55/spb99tpagent01.pcap | tcpdump -r - in pane 0.0
run ssh spb99tpagent02 bash /tmp/run.sh | tee ./dump/2023-06-01T16-52-55/spb99tpagent02.pcap | tcpdump -r - in pane 0.1
run ssh spb99tpagent03 bash /tmp/run.sh | tee ./dump/2023-06-01T16-52-55/spb99tpagent03.pcap | tcpdump -r - in pane 0.2
run ssh spb99tpagent04 bash /tmp/run.sh | tee ./dump/2023-06-01T16-52-55/spb99tpagent04.pcap | tcpdump -r - in pane 0.3
set option: synchronize-panes -> on
[exited]
$ tree dump/
dump/
`-- 2023-06-01T16-52-55
    |-- spb99tpagent01.pcap
    |-- spb99tpagent02.pcap
    |-- spb99tpagent03.pcap
    `-- spb99tpagent04.pcap

1 directory, 4 files
```
## Запуск с параметрами
```
$ ./run.sh list.txt TP-10943 noservice
Proccess spb99tpagent01 spb99tpagent02 spb99tpagent03 spb99tpagent04 in window 0
arranging in: tiled
run ssh spb99tpagent01 bash /tmp/run.sh | tee ./TP-10943/noservice/spb99tpagent01.pcap | tcpdump -r - in pane 0.0
run ssh spb99tpagent02 bash /tmp/run.sh | tee ./TP-10943/noservice/spb99tpagent02.pcap | tcpdump -r - in pane 0.1
run ssh spb99tpagent03 bash /tmp/run.sh | tee ./TP-10943/noservice/spb99tpagent03.pcap | tcpdump -r - in pane 0.2
run ssh spb99tpagent04 bash /tmp/run.sh | tee ./TP-10943/noservice/spb99tpagent04.pcap | tcpdump -r - in pane 0.3
set option: synchronize-panes -> on
[exited]
[techpark@spb99tpman01 dumper]$ tree TP-10943/
TP-10943/
`-- noservice
    |-- spb99tpagent01.pcap
    |-- spb99tpagent02.pcap
    |-- spb99tpagent03.pcap
    `-- spb99tpagent04.pcap

1 directory, 4 files
```
![screenhost tmux with four panes](docs/tmux4.png "Экран после успешного запуска")