#!/bin/bash

# ===================================
# OneAgent 配置（新版配置方式）
# ===================================

# 1. OneAgent 功能总开关（必须显式启用）
export ONEAGENT_ENABLE=true

# 2. Etcd 服务地址（必须配置）
export ONEAGENT_ETCD_ENDPOINTS=http://localhost:2379

# 3. 可选配置（以下为推荐值，可根据实际情况调整）
export ONEAGENT_ETCD_SERVICE_PREFIX=/services
export ONEAGENT_WARMUP_TIME_MS=3000                    # 流量预热时间（开发环境：3秒）
export ONEAGENT_INITIAL_WEIGHT=1000                    # 初始权重
export ONEAGENT_DRAIN_WAIT_TIME_MS=10000               # 下线时等待时间（开发环境：10秒）
export ONEAGENT_DRAIN_CHECK_INTERVAL_MS=500            # 检测间隔
export ONEAGENT_ETCD_LEASE_TTL=30                      # Etcd lease TTL（秒）
export ONEAGENT_ETCD_WATCH_RETRY_INTERVAL_MS=3000     # Watch 重试间隔
export ONEAGENT_ETCD_WATCH_MAX_RETRY_INTERVAL_MS=30000 # Watch 最大重试间隔
export ONEAGENT_ETCD_KEEPALIVE_MAX_RETRIES=3          # Keepalive 最大重试次数

# ===================================
# SkyWalking 配置
# ===================================
export SW_AGENT_NAME=service-consumer
export SW_AGENT_COLLECTOR_BACKEND_SERVICES=127.0.0.1:11800
# 灰度功能配置（如需使用灰度功能，设置为 true）
export SW_OPEN_GRAY=false

# ===================================
# SkyWalking 优雅关闭配置
# ===================================
# 解决 Kafka Producer 过早关闭的问题
export SW_AGENT_SHUTDOWN_WAIT_TIME=30           # Agent 关闭等待时间（秒）
export SW_KAFKA_FLUSH_TIMEOUT=5000              # Kafka 刷新超时时间（毫秒）

# ===================================
# 路径配置
# ===================================
SKYWALKING_AGENT_PATH="/Users/bitmart/work/codes/company/skywalking-java-agent/skywalking-agent"
PROJECT_DIR="/Users/bitmart/work/codes/company/EurekaDemo/service-consumer"

# ===================================
# 启动服务
# ===================================
cd ${PROJECT_DIR}

echo "========================================="
echo "启动 Service Consumer 服务"
echo "========================================="
echo "OneAgent 配置："
echo "  - 功能开关: ${ONEAGENT_ENABLE}"
echo "  - Etcd 地址: ${ONEAGENT_ETCD_ENDPOINTS}"
echo "  - 流量预热: ${ONEAGENT_WARMUP_TIME_MS}ms"
echo "  - 排空等待: ${ONEAGENT_DRAIN_WAIT_TIME_MS}ms"
echo "  - 初始权重: ${ONEAGENT_INITIAL_WEIGHT}"
echo "========================================="

# 构建项目（如果需要）
if [ ! -f "target/service-consumer-0.0.1-SNAPSHOT.jar" ]; then
    echo "构建项目..."
    mvn clean package -DskipTests
fi

# 支持通过环境变量禁用 JDWP
JDWP_OPTS=""
if [ "${DISABLE_JDWP}" != "true" ]; then
    JDWP_PORT=${JDWP_PORT:-5006}
    JDWP_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:${JDWP_PORT}"
    echo "JDWP 调试端口: ${JDWP_PORT}"
fi

echo "========================================="
echo "正在启动服务..."
echo "========================================="

# 启动服务
java -javaagent:${SKYWALKING_AGENT_PATH}/skywalking-agent.jar \
     ${JDWP_OPTS} \
     -Dskywalking.agent.service_name=service-consumer \
     -Dskywalking.collector.backend_service=127.0.0.1:11800 \
     -Dskywalking.logging.level=INFO \
     -Dskywalking.agent.shutdown_wait_time=30 \
     -Dskywalking.plugin.kafka.flush_timeout=5000 \
     -jar target/service-consumer-0.0.1-SNAPSHOT.jar
