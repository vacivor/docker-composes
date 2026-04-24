# Redis Cluster

这是一套基于 Docker Compose 的 Redis Cluster 开发版部署，拓扑为：

- 6 个 Redis 节点
- 3 个 master
- 3 个 replica
- 1 个初始化容器，用于自动执行 `redis-cli --cluster create`

## 目录结构

- `docker-compose.yaml`
- `init-cluster.sh`

## 设计说明

这套配置使用 `host network`，主要是为了避免 Redis Cluster 在端口映射 / NAT 环境下的地址广播问题。

因此有两个直接结果：

- `docker ps` 的 `PORTS` 列通常会是空的
- Redis 直接监听宿主机端口，而不是通过 `-p` 做端口映射

## 端口说明

客户端端口：

- `7001`
- `7002`
- `7003`
- `7004`
- `7005`
- `7006`

Cluster bus 端口：

- `17001`
- `17002`
- `17003`
- `17004`
- `17005`
- `17006`

## 启动方式

如果只在本机访问，可以直接启动：

```bash
docker compose up -d
```

如果需要让其他机器访问，请在启动前指定宿主机真实 IP：

```bash
REDIS_CLUSTER_ANNOUNCE_IP=10.10.1.152 docker compose up -d
```

否则集群节点会默认广播为 `127.0.0.1`，只适合本机测试。

## 初始化逻辑

`init-cluster.sh` 会等待 6 个节点健康后，自动执行：

```bash
redis-cli --cluster create ... --cluster-replicas 1
```

如果集群已经初始化完成，脚本会直接退出，不会重复创建。

## 常用检查命令

查看集群状态：

```bash
docker exec -it redis-node-1 redis-cli -p 7001 cluster info
```

查看节点列表：

```bash
docker exec -it redis-node-1 redis-cli -p 7001 cluster nodes
```

执行集群检查：

```bash
docker exec -it redis-node-1 redis-cli --cluster check 127.0.0.1:7001
```

如果你设置了 `REDIS_CLUSTER_ANNOUNCE_IP`，也可以把这里的 `127.0.0.1` 换成对应宿主机 IP。

## 数据持久化

每个节点各自使用独立的 named volume：

- `redis-cluster-node-1`
- `redis-cluster-node-2`
- `redis-cluster-node-3`
- `redis-cluster-node-4`
- `redis-cluster-node-5`
- `redis-cluster-node-6`

当前配置开启了 AOF：

```text
--appendonly yes
```

## 适用场景

这套更适合：

- 单机开发环境
- 本机或内网测试 Redis Cluster
- 快速验证分片与副本行为

如果你要做正式生产环境，通常还需要进一步考虑：

- 宿主机网络与防火墙策略
- 数据盘规划
- 备份与恢复流程
- 密码 / ACL
- 监控与告警
