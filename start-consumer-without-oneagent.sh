#!/bin/bash

# ===================================
# OneAgent 配置（禁用 OneAgent）
# ===================================

# OneAgent 功能总开关（设置为 false 禁用）
export ONEAGENT_ENABLE=false

# ===================================
# SkyWalking 配置
# ===================================
export SW_AGENT_NAME=service-consumer
export SW_AGENT_COLLECTOR_BACKEND_SERVICES=127.0.0.1:11800
export SW_OPEN_GRAY=false

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
echo "启动 Service Consumer 服务（禁用 OneAgent）"
echo "========================================="
echo "OneAgent 配置："
echo "  - 功能开关: ${ONEAGENT_ENABLE} ❌"
echo "  - 说明: 使用 Eureka 默认注册和发现机制"
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
     -jar target/service-consumer-0.0.1-SNAPSHOT.jar
