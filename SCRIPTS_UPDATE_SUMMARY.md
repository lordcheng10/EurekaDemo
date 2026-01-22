# 脚本更新总结

## 📝 更新日期

2026-01-22

---

## 🎯 更新目标

根据最新的 OneAgent 配置要求（默认禁用，需要显式启用）更新所有启动脚本。

---

## 📄 新增脚本列表

### 1. 主要启动脚本（已更新）

| 脚本文件 | 大小 | 功能 |
|---------|------|------|
| `start-provider-with-agent.sh` | 3.0K | 启动 Provider（启用 OneAgent） |
| `start-consumer-with-agent.sh` | 3.0K | 启动 Consumer（启用 OneAgent） |
| `start-provider-without-oneagent.sh` | 2.0K | 启动 Provider（禁用 OneAgent） |
| `start-consumer-without-oneagent.sh` | 2.0K | 启动 Consumer（禁用 OneAgent） |

### 2. 批量操作脚本（新增）

| 脚本文件 | 大小 | 功能 |
|---------|------|------|
| `start-all-with-oneagent.sh` | 2.2K | 一键启动所有服务（启用 OneAgent） |
| `start-all-without-oneagent.sh` | 1.5K | 一键启动所有服务（禁用 OneAgent） |
| `stop-all.sh` | 2.0K | 停止所有服务 |

### 3. 文档（新增）

| 文档文件 | 说明 |
|---------|------|
| `README_ONEAGENT.md` | OneAgent 完整使用文档 |
| `QUICK_START.md` | 快速启动指南 |
| `SCRIPTS_UPDATE_SUMMARY.md` | 本文档（更新总结） |
| `.gitignore` | Git 忽略配置 |

---

## 🔄 主要变更

### 1. 配置命名规范

#### 旧配置（已废弃）
```bash
export EUREKA_GRACEFUL_STARTUP_ENABLED=true
export EUREKA_GRACEFUL_STARTUP_DELAY_MS=2000
export EUREKA_WARMUP_ENABLED=true
export EUREKA_WARMUP_TIME_MS=3000
export EUREKA_GRACEFUL_SHUTDOWN_ENABLED=true
export EUREKA_GRACEFUL_SHUTDOWN_NO_TRAFFIC_TIMEOUT_MS=10000
```

#### 新配置（当前使用）
```bash
# 必须配置
export ONEAGENT_ENABLE=true                           # 总开关（默认 false）
export ONEAGENT_ETCD_ENDPOINTS=http://localhost:2379  # Etcd 地址

# 可选配置
export ONEAGENT_WARMUP_TIME_MS=3000                   # 预热时间
export ONEAGENT_DRAIN_WAIT_TIME_MS=10000              # 排空等待
export ONEAGENT_INITIAL_WEIGHT=1000                   # 初始权重
export ONEAGENT_ETCD_SERVICE_PREFIX=/services         # 服务前缀
```

---

### 2. 默认行为变更

#### 之前
- OneAgent 功能隐式启用（如果插件存在）
- 不需要配置 `ONEAGENT_ENABLE`

#### 现在
- ✅ **OneAgent 功能默认禁用**
- ✅ **必须显式配置 `ONEAGENT_ENABLE=true` 才能启用**
- ✅ **必须配置 `ONEAGENT_ETCD_ENDPOINTS`**

---

### 3. 脚本结构优化

#### 统一的配置区块
```bash
# ===================================
# OneAgent 配置（新版配置方式）
# ===================================
export ONEAGENT_ENABLE=true
export ONEAGENT_ETCD_ENDPOINTS=http://localhost:2379
...

# ===================================
# SkyWalking 配置
# ===================================
export SW_AGENT_NAME=service-provider
...

# ===================================
# 路径配置
# ===================================
SKYWALKING_AGENT_PATH="..."
PROJECT_DIR="..."

# ===================================
# 启动服务
# ===================================
...
```

#### 信息输出优化
```bash
echo "========================================="
echo "启动 Service Provider 服务"
echo "========================================="
echo "OneAgent 配置："
echo "  - 功能开关: ${ONEAGENT_ENABLE}"
echo "  - Etcd 地址: ${ONEAGENT_ETCD_ENDPOINTS}"
echo "  - 流量预热: ${ONEAGENT_WARMUP_TIME_MS}ms"
echo "  - 排空等待: ${ONEAGENT_DRAIN_WAIT_TIME_MS}ms"
echo "========================================="
```

---

## 🎯 使用指南

### 快速开始

```bash
# 1. 给脚本添加执行权限（已完成）
chmod +x *.sh

# 2. 启动所有服务（启用 OneAgent）
./start-all-with-oneagent.sh

# 3. 测试
curl http://localhost:8081/call-provider

# 4. 停止服务
./stop-all.sh
```

### 对比测试

```bash
# 测试 1：启用 OneAgent
./start-all-with-oneagent.sh
ab -n 1000 -c 10 http://localhost:8081/call-provider
./stop-all.sh

# 测试 2：禁用 OneAgent
./start-all-without-oneagent.sh
ab -n 1000 -c 10 http://localhost:8081/call-provider
./stop-all.sh
```

---

## 📊 配置对照表

| 功能 | 旧环境变量 | 新环境变量 | 新系统属性 | 默认值 |
|-----|-----------|-----------|-----------|--------|
| 总开关 | - | `ONEAGENT_ENABLE` | `oneagent.enable` | `false` ⚠️ |
| Etcd地址 | - | `ONEAGENT_ETCD_ENDPOINTS` | `oneagent.etcd.endpoints` | `""` |
| 服务前缀 | - | `ONEAGENT_ETCD_SERVICE_PREFIX` | `oneagent.etcd.service.prefix` | `/services` |
| 预热时间 | `EUREKA_WARMUP_TIME_MS` | `ONEAGENT_WARMUP_TIME_MS` | `oneagent.warmup.time.ms` | `30000` |
| 初始权重 | - | `ONEAGENT_INITIAL_WEIGHT` | `oneagent.initial.weight` | `1000` |
| 排空等待 | `EUREKA_GRACEFUL_SHUTDOWN_NO_TRAFFIC_TIMEOUT_MS` | `ONEAGENT_DRAIN_WAIT_TIME_MS` | `oneagent.drain.wait.time.ms` | `10000` |
| 检测间隔 | - | `ONEAGENT_DRAIN_CHECK_INTERVAL_MS` | `oneagent.drain.check.interval.ms` | `500` |

---

## ⚠️ 重要提示

### 1. 向后兼容性

- ❌ 旧的 `EUREKA_*` 环境变量**不再支持**
- ✅ 必须使用新的 `ONEAGENT_*` 环境变量
- ⚠️ OneAgent 功能现在**默认禁用**，需要显式启用

### 2. 依赖要求

启用 OneAgent 功能需要：
- ✅ Etcd 服务运行（`http://localhost:2379`）
- ✅ 配置 `ONEAGENT_ENABLE=true`
- ✅ 配置 `ONEAGENT_ETCD_ENDPOINTS`

### 3. 迁移步骤

如果你有旧的启动脚本：

```bash
# 步骤 1：备份旧脚本
cp start-provider.sh start-provider.sh.backup

# 步骤 2：使用新脚本
cp start-provider-with-agent.sh start-provider.sh

# 步骤 3：修改配置
vim start-provider.sh
# 更新 ONEAGENT_* 配置

# 步骤 4：测试
./start-provider.sh
```

---

## 🔍 验证清单

### 启用 OneAgent 时

检查以下日志，确认功能正常：

```log
✅ [INFO] OneAgent feature is ENABLED (from environment variable)
✅ [INFO] Loaded plugin: oneagent-eureka-2.x (5 instrumentations)
✅ [INFO] EtcdClientService prepared successfully
✅ [INFO] EtcdClient started successfully with endpoint: http://localhost:2379
✅ [INFO] Registered provider to etcd: /services/service-provider/providers/...
```

### 禁用 OneAgent 时

检查以下日志，确认功能已禁用：

```log
✅ [INFO] OneAgent feature is DISABLED (from environment variable)
✅ [INFO] remove plugin:oneagent-eureka-2.x=...RegisterInstrumentation
✅ [INFO] remove plugin:oneagent-eureka-2.x=...DiscoveryInstrumentation
✅ [INFO] remove plugin:oneagent-eureka-2.x=...LoadBalancerInstrumentation
```

---

## 📁 目录结构

更新后的目录结构：

```
EurekaDemo/
├── service-provider/           # Provider 项目
├── service-consumer/           # Consumer 项目
├── logs/                       # 日志目录（自动创建）
│   ├── provider-oneagent.log
│   ├── consumer-oneagent.log
│   ├── provider-no-oneagent.log
│   └── consumer-no-oneagent.log
├── .pids/                      # PID 文件目录（自动创建）
│   ├── provider-oneagent.pid
│   └── consumer-oneagent.pid
├── start-provider-with-agent.sh         # ✅ 更新
├── start-consumer-with-agent.sh         # ✅ 更新
├── start-provider-without-oneagent.sh   # ✅ 新增
├── start-consumer-without-oneagent.sh   # ✅ 新增
├── start-all-with-oneagent.sh           # ✅ 新增
├── start-all-without-oneagent.sh        # ✅ 新增
├── stop-all.sh                          # ✅ 新增
├── README_ONEAGENT.md                   # ✅ 新增
├── QUICK_START.md                       # ✅ 新增
├── SCRIPTS_UPDATE_SUMMARY.md            # ✅ 新增（本文档）
└── .gitignore                           # ✅ 新增
```

---

## 🎉 总结

### 核心改进

1. ✅ **配置标准化**：统一使用 `ONEAGENT_*` 命名
2. ✅ **安全优先**：默认禁用，需要显式启用
3. ✅ **灵活测试**：提供启用/禁用两套脚本
4. ✅ **批量操作**：一键启动/停止所有服务
5. ✅ **完善文档**：详细的使用说明和故障排查

### 下一步

```bash
# 1. 快速测试（推荐）
./start-all-with-oneagent.sh
curl http://localhost:8081/call-provider
./stop-all.sh

# 2. 阅读详细文档
cat QUICK_START.md
cat README_ONEAGENT.md

# 3. 根据需要调整配置
vim start-provider-with-agent.sh  # 修改配置参数
```

---

## 📞 技术支持

如有问题，请参考：

1. [QUICK_START.md](./QUICK_START.md) - 快速启动指南
2. [README_ONEAGENT.md](./README_ONEAGENT.md) - 完整使用文档
3. [OneAgent 配置说明](../skywalking-java-agent/apm-sniffer/optional-plugins/optional-oneagent-plugins/eureka-2.x-plugin/CONFIG.md)
4. [功能开关说明](../skywalking-java-agent/apm-sniffer/optional-plugins/optional-oneagent-plugins/eureka-2.x-plugin/FEATURE_TOGGLE.md)

---

**更新完成！** 🎊
