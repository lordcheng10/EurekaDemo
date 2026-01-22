# OneAgent 快速启动指南

## 🚀 一键启动

### 启用 OneAgent（完整功能）

```bash
./start-all-with-oneagent.sh
```

**说明：**
- ✅ 自动检查和启动 etcd
- ✅ 后台启动 Provider 和 Consumer
- ✅ 启用所有 OneAgent 功能
- ✅ 日志输出到 `logs/` 目录
- ✅ PID 保存到 `.pids/` 目录

**验证：**
```bash
# 测试服务
curl http://localhost:8081/call-provider

# 查看日志
tail -f logs/provider-oneagent.log
tail -f logs/consumer-oneagent.log

# 查看 etcd 注册信息
curl http://localhost:2379/v3/kv/range -X POST -d '{"key":"L3NlcnZpY2Vz","range_end":"L3NlcnZpY2Vz0A=="}'
```

---

### 禁用 OneAgent（纯 Eureka）

```bash
./start-all-without-oneagent.sh
```

**说明：**
- ❌ 不使用 OneAgent 功能
- ✅ 纯 Eureka 注册发现
- ✅ 性能基线测试
- ✅ SkyWalking 监控正常

---

### 停止所有服务

```bash
./stop-all.sh
```

**说明：**
- 🛑 优雅停止所有服务
- 🧹 清理 PID 文件
- ✅ 检查端口释放

---

## 📋 单服务启动

### Provider（服务提供者）

```bash
# 启用 OneAgent
./start-provider-with-agent.sh

# 禁用 OneAgent
./start-provider-without-oneagent.sh
```

### Consumer（服务消费者）

```bash
# 启用 OneAgent
./start-consumer-with-agent.sh

# 禁用 OneAgent
./start-consumer-without-oneagent.sh
```

---

## 🎯 典型场景

### 场景 1：开发调试（推荐）

```bash
# 1. 启动所有服务（启用 OneAgent）
./start-all-with-oneagent.sh

# 2. 实时查看日志
tail -f logs/*.log

# 3. 测试请求
curl http://localhost:8081/call-provider

# 4. 停止服务
./stop-all.sh
```

---

### 场景 2：性能对比测试

#### 步骤 1：测试基线性能（禁用 OneAgent）

```bash
# 启动服务（禁用 OneAgent）
./start-all-without-oneagent.sh

# 等待服务启动
sleep 15

# 压测
ab -n 10000 -c 100 http://localhost:8081/call-provider

# 停止服务
./stop-all.sh
```

#### 步骤 2：测试 OneAgent 性能

```bash
# 启动服务（启用 OneAgent）
./start-all-with-oneagent.sh

# 等待服务启动
sleep 15

# 压测
ab -n 10000 -c 100 http://localhost:8081/call-provider

# 停止服务
./stop-all.sh
```

---

### 场景 3：灰度发布模拟

```bash
# 启动 Provider 1（启用 OneAgent）
./start-provider-with-agent.sh

# 启动 Provider 2（禁用 OneAgent，不同端口）
SERVER_PORT=8082 JDWP_PORT=5007 ./start-provider-without-oneagent.sh

# 启动 Consumer（启用 OneAgent）
./start-consumer-with-agent.sh

# 观察负载均衡
for i in {1..10}; do
  curl http://localhost:8081/call-provider
  echo ""
  sleep 1
done
```

---

### 场景 4：流量预热测试

```bash
# 1. 启动 Consumer
./start-consumer-with-agent.sh

# 2. 等待 Consumer 完全启动
sleep 10

# 3. 启动 Provider（会触发预热）
./start-provider-with-agent.sh

# 4. 观察预热过程（权重从低到高）
watch -n 1 'curl -s http://localhost:2379/v3/kv/range -X POST -d "{\"key\":\"L3NlcnZpY2Vz\"}" | jq'

# 5. 持续发送请求，观察流量分布
for i in {1..30}; do
  curl http://localhost:8081/call-provider
  sleep 1
done
```

---

### 场景 5：优雅下线测试

```bash
# 1. 启动所有服务
./start-all-with-oneagent.sh

# 2. 发送持续流量（另一个终端）
while true; do curl http://localhost:8081/call-provider; sleep 0.5; done

# 3. 停止 Provider（观察优雅下线）
kill $(cat .pids/provider-oneagent.pid)

# 4. 观察日志
tail -f logs/provider-oneagent.log

# 预期：
# - Provider 等待正在处理的请求完成
# - 最多等待 10 秒（DRAIN_WAIT_TIME_MS）
# - 优雅关闭连接
```

---

## 🔧 配置修改

### 修改预热时间

编辑 `start-provider-with-agent.sh` 或 `start-consumer-with-agent.sh`:

```bash
# 修改此行
export ONEAGENT_WARMUP_TIME_MS=5000  # 从 3000 改为 5000（5秒）
```

### 修改排空等待时间

```bash
# 修改此行
export ONEAGENT_DRAIN_WAIT_TIME_MS=20000  # 从 10000 改为 20000（20秒）
```

### 修改 Etcd 地址

```bash
# 修改此行
export ONEAGENT_ETCD_ENDPOINTS=http://192.168.1.100:2379  # 远程 etcd
```

---

## 📊 监控和调试

### 查看实时日志

```bash
# 所有服务
tail -f logs/*.log

# 仅 Provider
tail -f logs/provider-*.log

# 仅 Consumer
tail -f logs/consumer-*.log
```

### 查看 Agent 日志

```bash
# SkyWalking Agent 日志
tail -f ~/skywalking-agent/logs/skywalking-api.log
```

### 查看 Etcd 数据

```bash
# 列出所有服务
etcdctl --endpoints=http://localhost:2379 get --prefix /services/

# 或使用 curl
curl http://localhost:2379/v3/kv/range -X POST -d '{"key":"L3NlcnZpY2Vz","range_end":"L3NlcnZpY2Vz0A=="}' | jq
```

### 查看进程状态

```bash
# 查看 Java 进程
jps -l | grep service-

# 查看端口占用
lsof -i :8080  # Provider
lsof -i :8081  # Consumer
```

---

## 🐛 故障排查

### 问题 1：Etcd 连接失败

```bash
# 检查 etcd 状态
docker ps | grep etcd
curl http://localhost:2379/version

# 启动 etcd
docker start etcd

# 或重新创建
docker rm -f etcd
./start-all-with-oneagent.sh
```

### 问题 2：端口被占用

```bash
# 查看端口占用
lsof -i :8080
lsof -i :8081

# 停止所有服务
./stop-all.sh

# 强制清理
pkill -f "service-provider"
pkill -f "service-consumer"
```

### 问题 3：服务启动失败

```bash
# 查看日志
cat logs/provider-*.log
cat logs/consumer-*.log

# 检查 Agent 路径
ls -la /Users/bitmart/work/codes/company/skywalking-java-agent/skywalking-agent/

# 检查插件
ls -la /Users/bitmart/work/codes/company/skywalking-java-agent/skywalking-agent/plugins/ | grep eureka
```

---

## 📚 完整文档

详细配置和功能说明请参考：

- [README_ONEAGENT.md](./README_ONEAGENT.md) - OneAgent 完整文档
- [OneAgent 配置说明](../skywalking-java-agent/apm-sniffer/optional-plugins/optional-oneagent-plugins/eureka-2.x-plugin/CONFIG.md)
- [功能开关说明](../skywalking-java-agent/apm-sniffer/optional-plugins/optional-oneagent-plugins/eureka-2.x-plugin/FEATURE_TOGGLE.md)

---

## 🎉 常用命令速查

```bash
# 启动（启用 OneAgent）
./start-all-with-oneagent.sh

# 启动（禁用 OneAgent）
./start-all-without-oneagent.sh

# 停止所有服务
./stop-all.sh

# 查看日志
tail -f logs/*.log

# 测试服务
curl http://localhost:8081/call-provider

# 查看 etcd
curl http://localhost:2379/version

# 停止 etcd
docker stop etcd

# 启动 etcd
docker start etcd
```
