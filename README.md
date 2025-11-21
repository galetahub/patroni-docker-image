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

## Configudation

### Patroni Environment Variables

| Name | Description | Default |
|------|-------------|---------|
| `PATRONI_SCOPE` | Cluster name/scope for Patroni | `batman` |
| `PATRONI_NAME` | Name of the Patroni node | `$(hostname)` |
| `PATRONI_POSTGRESQL_DATA_DIR` | PostgreSQL data directory | `$PGDATA` |
| `PATRONI_POSTGRESQL_LISTEN` | PostgreSQL listen address | `0.0.0.0:5432` |
| `PATRONI_POSTGRESQL_CONNECT_ADDRESS` | PostgreSQL connect address | `$DOCKER_IP:5432` |
| `PATRONI_RESTAPI_LISTEN` | Patroni REST API listen address | `0.0.0.0:8008` |
| `PATRONI_RESTAPI_CONNECT_ADDRESS` | Patroni REST API connect address | `$DOCKER_IP:8008` |
| `PATRONI_REPLICATION_USERNAME` | Username for replication | `replicator` |
| `PATRONI_POSTGRESQL_PGPASS` | Path to .pgpass file | `/opt/postgres/.pgpass` |
| `PATRONI_CONFIG_PATH` | Path to Patroni configuration file | `/opt/postgres/config/postgres.yml` |

### PostgreSQL Environment Variables

| Name | Description | Default |
|------|-------------|---------|
| `PG_SHARED_BUFFERS` | Amount of memory for shared buffers | `2GB` |
| `PG_EFFECTIVE_CACHE_SIZE` | Planner's assumption about kernel cache size | `6GB` |
| `PG_MAINTENANCE_WORK_MEM` | Memory for maintenance operations | `512MB` |
| `PG_CHECKPOINT_COMPLETION_TARGET` | Target for checkpoint completion | `0.7` |
| `PG_WAL_BUFFERS` | Amount of memory for WAL buffers | `16MB` |
| `PG_DEFAULT_STATISTICS_TARGET` | Default statistics target for columns | `100` |
| `PG_RANDOM_PAGE_COST` | Cost of a non-sequentially-fetched disk page | `1.1` |
| `PG_EFFECTIVE_IO_CONCURRENCY` | Number of concurrent disk I/O operations | `200` |
| `PG_WORK_MEM` | Memory for query operations | `16MB` |
| `PG_MIN_WAL_SIZE` | Minimum size to shrink the WAL to | `1GB` |
| `PG_MAX_WAL_SIZE` | Maximum size to let the WAL grow to | `4GB` |
| `PG_MAX_WORKER_PROCESSES` | Maximum number of background processes | `2` |
| `PG_MAX_PARALLEL_WORKERS_PER_GATHER` | Maximum parallel workers per gather node | `1` |
| `PG_MAX_PARALLEL_WORKERS` | Maximum number of parallel workers | `2` |
| `PG_UNIX_SOCKET_DIRECTORIES` | Directory for Unix socket | `/tmp` |
| `PG_MAX_CONNECTIONS` | Maximum number of concurrent connections | `64` |

Calculate configuration for PostgreSQL based on the maximum performance for a given hardware configuration:

https://pgtune.leopard.in.ua/#/

### Notifications Environment Variables

| Name | Description | Default |
|------|-------------|---------|
| `TELEGRAM_API_TOKEN` | Telegram bot API token for sending notifications | - |
| `TELEGRAM_CHAT_ID` | Telegram chat ID where notifications will be sent | - |

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

## License

This repository is licensed under the [MIT License](LICENSE)
