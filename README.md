# HA PostgreSQL cluster on docker

This is a docker compose file and some helper scripts to demonstrate how to deploy a highly available postgres cluster with automatic failover using docker swarm.

PostgreSQL + pgbouncer + patroni + wal-g + etcd + haproxy

The complete stack is:

  - docker swarm mode (orchestration)
  - haproxy (endpoint for db write/reads)
  - etcd (configuration, leader election)
  - patroni (governs db repliation and high availability) https://github.com/zalando/patroni
  - postgres (https://www.postgresql.org/)
  - pgbouncer (https://github.com/pgbouncer/pgbouncer)
  - wal-g (https://github.com/wal-g/wal-g)

## PG configuration

https://pgtune.leopard.in.ua/#/

## Setup servers (nodes)

Manager node:

```
docker swarm init
docker swarm join-token worker -q
docker node inspect NODEID --format "{{ .ManagerStatus.Addr }}"
```

## Create network

```
docker network create -d overlay --attachable pg-cluster-net
```

```
docker swarm init --advertise-addr 10.8.0.1
docker network create -d overlay --attachable pg-cluster-net
```

## Add labels

All actions at swarm manager node:

```
docker node ls
docker node update --label-add name=node1 <node_id1>
docker node update --label-add name=node2 <node_id2>
docker node update --label-add name=node3 <node_id3>
```

## Start cluster

```
docker stack deploy -c docker-compose.yml batman
```

## Backup database

```
docker exec container_id /opt/postgres/bin/archive.sh
```

## Cluster status

Connect to container and run commands inside patroni container.
More commands:
https://github.com/zalando/patroni/blob/8adddb3467f3c43ddf4ff723a2381e0cf6e2a31b/docs/patronictl.rst

```
patronictl -c ./config/postgres.yml list batman
patronictl -c ./config/postgres.yml dns batman -r primary
patronictl -c ./config/postgres.yml history batman

patronictl -c ./config/postgres.yml switchover batman --leader patroni3 --candidate patroni1 --force
```

## HaProxy tuning

```
sysctl -w net.ipv4.tcp_max_syn_backlog=100000
sysctl -w net.core.netdev_max_backlog=100000
sysctl -w net.core.somaxconn=65534
sysctl -w net.ipv4.tcp_syncookies=0
```

## Delete stack

```
docker stack rm batman
docker system prune -a
```

## Links

  - https://github.com/zalando/patroni
  - https://github.com/zalando/patroni/blob/master/docs/SETTINGS.rst
  - https://github.com/wal-g/wal-g/blob/master/docs/PostgreSQL.md
  - https://github.com/wal-g/wal-g/blob/master/docs/STORAGES.md

  - https://github.com/bitnami/containers/tree/main/bitnami/etcd
  - https://etcd.io/docs/v3.5/op-guide/configuration/
  - https://hub.docker.com/r/bitnami/etcd

  - https://www.pgbouncer.org/config.html
  - https://hub.docker.com/r/bitnami/pgbouncer

  - https://www.haproxy.com/documentation/haproxy-configuration-tutorials/core-concepts/frontends/
  - https://github.com/ufoscout/docker-compose-wait
  - https://github.com/Yelp/dumb-init

  - https://pgtune.leopard.in.ua/

Copyright (c) 2025
