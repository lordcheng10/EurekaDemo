# OneAgent 启动脚本说明

## 📋 脚本列表

### 启用 OneAgent（完整功能）

#### 1. Provider（服务提供者）
```bash
./start-provider-with-agent.sh
```

**功能：**
- ✅ 启用 OneAgent 功能
- ✅ 注册到 etcd
- ✅ 流量预热（3秒）
- ✅ 优雅下线（排空等待10秒）
- ✅ 基于权重的负载均衡

**配置：**
- Etcd: `http://localhost:2379`
- 预热时间: 3秒
- 排空等待: 10秒
- JDWP 端口: 5005

#### 2. Consumer（服务消费者）
```bash
./start-consumer-with-agent.sh
```

**功能：**
- ✅ 启用 OneAgent 功能
- ✅ 注册到 etcd
- ✅ Watch etcd 监听 provider 变化
- ✅ 基于权重的负载均衡
- ✅ 流量预热感知

**配置：**
- Etcd: `http://localhost:2379`
- JDWP 端口: 5006

---

### 禁用 OneAgent（纯 Eureka）

#### 3. Provider（不使用 OneAgent）
```bash
./start-provider-without-oneagent.sh
```

**功能：**
- ❌ OneAgent 功能禁用
- ✅ 纯 Eureka 注册发现
- ✅ SkyWalking 监控正常
- ⚡ 性能影响为 0

#### 4. Consumer（不使用 OneAgent）
```bash
./start-consumer-without-oneagent.sh
```

**功能：**
- ❌ OneAgent 功能禁用
- ✅ 纯 Eureka 服务发现
- ✅ Eureka 默认负载均衡
- ✅ SkyWalking 监控正常

---

## 🎯 使用场景

### 场景 1：完整测试 OneAgent 功能

```bash
# 1. 启动 Etcd（必须）
docker run -d --name etcd \
  -p 2379:2379 \
  -p 2380:2380 \
  quay.io/coreos/etcd:latest \
  etcd --listen-client-urls http://0.0.0.0:2379 \
       --advertise-client-urls http://localhost:2379

# 2. 启动 Provider（启用 OneAgent）
./start-provider-with-agent.sh

# 3. 启动 Consumer（启用 OneAgent）
./start-consumer-with-agent.sh

# 4. 测试流量
curl http://localhost:8081/call-provider
```

**验证：**
- Provider 和 Consumer 注册到 etcd
- 流量预热生效（初期权重低，逐步增加）
- 优雅下线生效（Ctrl+C 时等待流量排空）

---

### 场景 2：对比测试（OneAgent vs 纯 Eureka）

**启动 2 个 Provider：**

```bash
# Provider 1: 启用 OneAgent
./start-provider-with-agent.sh

# Provider 2: 禁用 OneAgent（使用不同端口）
SERVER_PORT=8082 JDWP_PORT=5007 ./start-provider-without-oneagent.sh
```

**启动 Consumer（启用 OneAgent）：**

```bash
./start-consumer-with-agent.sh
```

**观察：**
- Provider 1: 注册到 etcd，支持流量预热和排空
- Provider 2: 仅注册到 Eureka，使用默认机制
- Consumer: 只能感知 Provider 1 的状态（从 etcd watch）

---

### 场景 3：灰度发布测试

```bash
# 阶段 1：部分实例启用 OneAgent
# Provider 1: OneAgent 启用
./start-provider-with-agent.sh

# Provider 2-3: OneAgent 禁用
SERVER_PORT=8082 JDWP_PORT=5007 ./start-provider-without-oneagent.sh
SERVER_PORT=8083 JDWP_PORT=5008 ./start-provider-without-oneagent.sh

# Consumer: OneAgent 启用（监听所有 Provider）
./start-consumer-with-agent.sh
```

**验证：**
- Consumer 能发现所有 3 个 Provider（Eureka + etcd）
- Provider 1 支持流量管理
- Provider 2-3 使用 Eureka 默认策略

---

### 场景 4：性能基线测试

```bash
# 1. 禁用 OneAgent，测试基线性能
./start-provider-without-oneagent.sh
./start-consumer-without-oneagent.sh

# 2. 压测
ab -n 10000 -c 100 http://localhost:8081/call-provider

# 3. 启用 OneAgent，对比性能
# 停止服务，重新启动
./start-provider-with-agent.sh
./start-consumer-with-agent.sh

# 4. 再次压测
ab -n 10000 -c 100 http://localhost:8081/call-provider
```

---

## 🔧 配置说明

### OneAgent 核心配置

所有启用 OneAgent 的脚本都包含以下配置：

```bash
# 必须配置
export ONEAGENT_ENABLE=true                    # 总开关
export ONEAGENT_ETCD_ENDPOINTS=http://localhost:2379  # Etcd 地址

# 可选配置（默认值）
export ONEAGENT_ETCD_SERVICE_PREFIX=/services          # 服务前缀
export ONEAGENT_WARMUP_TIME_MS=3000                    # 预热时间
export ONEAGENT_INITIAL_WEIGHT=1000                    # 初始权重
export ONEAGENT_DRAIN_WAIT_TIME_MS=10000               # 排空等待
export ONEAGENT_DRAIN_CHECK_INTERVAL_MS=500            # 检测间隔
export ONEAGENT_ETCD_LEASE_TTL=30                      # Lease TTL
```

### 修改配置

#### 修改预热时间

```bash
# 编辑脚本，修改此行
export ONEAGENT_WARMUP_TIME_MS=5000  # 改为 5 秒
```

#### 修改 Etcd 地址

```bash
# 如果 etcd 在远程服务器
export ONEAGENT_ETCD_ENDPOINTS=http://192.168.1.100:2379
```

#### 修改服务端口

```bash
# 启动时指定环境变量
SERVER_PORT=8082 ./start-provider-with-agent.sh
```

---

## 📊 日志和监控

### 查看 OneAgent 日志

```bash
# Agent 日志位置
tail -f ~/skywalking-agent/logs/skywalking-api.log
```

### 关键日志信息

**启用 OneAgent 时：**
```log
[INFO] OneAgent feature is ENABLED (from environment variable)
[INFO] Loaded plugin: oneagent-eureka-2.x (5 instrumentations)
[INFO] EtcdClientService prepared successfully
[INFO] EtcdClient started successfully with endpoint: http://localhost:2379
[INFO] Registered provider to etcd: /services/service-provider/providers/...
```

**禁用 OneAgent 时：**
```log
[INFO] OneAgent feature is DISABLED (from environment variable)
[INFO] remove plugin:oneagent-eureka-2.x=...RegisterInstrumentation
[INFO] remove plugin:oneagent-eureka-2.x=...DiscoveryInstrumentation
[INFO] remove plugin:oneagent-eureka-2.x=...LoadBalancerInstrumentation
```

---

## 🐛 故障排查

### 问题 1：OneAgent 未启用

**现象：**
```log
[INFO] OneAgent feature is DISABLED
```

**排查：**
```bash
# 检查环境变量
echo $ONEAGENT_ENABLE  # 应该输出 true

# 检查脚本配置
grep "ONEAGENT_ENABLE" start-provider-with-agent.sh
```

### 问题 2：无法连接 Etcd

**现象：**
```log
[ERROR] Failed to start EtcdClient
```

**排查：**
```bash
# 1. 检查 etcd 是否运行
docker ps | grep etcd

# 2. 测试连接
curl http://localhost:2379/version

# 3. 检查配置
echo $ONEAGENT_ETCD_ENDPOINTS
```

### 问题 3：插件加载失败

**现象：**
```log
[ERROR] load plugin [org.apache.skywalking.apm.plugin.oneagent.eureka.v2x...] failure
```

**排查：**
```bash
# 1. 检查插件是否存在
ls -la skywalking-agent/plugins/ | grep eureka

# 2. 检查 SkyWalking Agent 路径
echo $SKYWALKING_AGENT_PATH

# 3. 重新编译插件
cd skywalking-java-agent
./build.sh
```

---

## 🔄 快速切换

### 从启用切换到禁用

```bash
# 停止当前服务（Ctrl+C）

# 启动禁用 OneAgent 的版本
./start-provider-without-oneagent.sh
```

### 从禁用切换到启用

```bash
# 停止当前服务（Ctrl+C）

# 确保 etcd 运行
docker start etcd

# 启动启用 OneAgent 的版本
./start-provider-with-agent.sh
```

---

## 💡 最佳实践

1. **开发调试**：使用启用 OneAgent 的脚本，方便测试完整功能
2. **性能测试**：先用禁用版本建立基线，再对比启用版本
3. **灰度部署**：混合使用启用和禁用版本，观察兼容性
4. **生产环境**：根据实际需求决定是否启用（需要 etcd 基础设施）

---

## 📚 相关文档

- [OneAgent 配置说明](../skywalking-java-agent/apm-sniffer/optional-plugins/optional-oneagent-plugins/eureka-2.x-plugin/CONFIG.md)
- [功能开关说明](../skywalking-java-agent/apm-sniffer/optional-plugins/optional-oneagent-plugins/eureka-2.x-plugin/FEATURE_TOGGLE.md)

---

## 🎉 快速开始

```bash
# 1. 确保依赖启动
docker start etcd

# 2. 编译 SkyWalking Agent（首次）
cd skywalking-java-agent
./build.sh

# 3. 给脚本添加执行权限
chmod +x *.sh

# 4. 启动服务
./start-provider-with-agent.sh   # 终端 1
./start-consumer-with-agent.sh   # 终端 2

# 5. 测试
curl http://localhost:8081/call-provider
```
