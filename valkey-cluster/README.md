# Valkey Cluster

这是一套基于 Docker Compose 的 Valkey Cluster 开发版部署，拓扑为 6 个节点：3 个 master 和 3 个 replica。

## 启动

仅本机访问：

```bash
docker compose up -d
```

需要让其他机器访问时，使用宿主机真实 IP：

```bash
VALKEY_CLUSTER_ANNOUNCE_IP=10.10.1.152 docker compose up -d
```

## 网络与端口

这套配置使用 `host network`，因此 `docker ps` 的 `PORTS` 列通常为空，节点会直接监听宿主机端口。

客户端端口为 `7001` 到 `7006`，Cluster bus 端口为 `17001` 到 `17006`。

## 检查集群

```bash
docker exec -it valkey-node-1 valkey-cli -p 7001 cluster info
docker exec -it valkey-node-1 valkey-cli -p 7001 cluster nodes
docker exec -it valkey-node-1 valkey-cli --cluster check 127.0.0.1:7001
```

正常情况下应看到：

- `cluster_state:ok`
- `cluster_known_nodes:6`
- `cluster_size:3`

## 持久化

每个节点使用独立的 named volume，并开启 AOF：

- `valkey-cluster-node-1`
- `valkey-cluster-node-2`
- `valkey-cluster-node-3`
- `valkey-cluster-node-4`
- `valkey-cluster-node-5`
- `valkey-cluster-node-6`
