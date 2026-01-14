
export SW_OPEN_GRAY=true
export EUREKA_GRACEFUL_SHUTDOWN_NO_TRAFFIC_TIMEOUT_MS=1000  # 无流量超时缩短到1秒
export EUREKA_GRACEFUL_SHUTDOWN_WAIT_NO_TRAFFIC_MAX_MS=2000 # 最大等待时间缩短到2秒

# SkyWalking Agent 路径
SKYWALKING_AGENT_PATH="/Users/bitmart/work/codes/company/skywalking-java-agent/skywalking-agent"

# 服务提供者 JAR 路径
cd /Users/bitmart/work/codes/company/EurekaDemo/service-provider

# 无损上下线配置（开发环境 - 快速迭代）
export EUREKA_GRACEFUL_STARTUP_ENABLED=true
export EUREKA_GRACEFUL_STARTUP_DELAY_MS=2000

export EUREKA_WARMUP_ENABLED=true
export EUREKA_WARMUP_TIME_MS=3000

export EUREKA_GRACEFUL_SHUTDOWN_ENABLED=true
export EUREKA_GRACEFUL_SHUTDOWN_NOTIFICATION_ENABLED=true
export EUREKA_GRACEFUL_SHUTDOWN_NO_TRAFFIC_TIMEOUT_MS=10000
export EUREKA_GRACEFUL_SHUTDOWN_WAIT_NO_TRAFFIC_MAX_MS=60000

# SkyWalking 配置
export SW_AGENT_NAME=service-provider
export SW_AGENT_COLLECTOR_BACKEND_SERVICES=127.0.0.1:11800

echo "========================================="
echo "启动 Service Provider 服务"
echo "========================================="
echo "无损上下线配置："
echo "  - 优雅上线延迟: ${EUREKA_GRACEFUL_STARTUP_DELAY_MS}ms"
echo "  - 流量预热时间: ${EUREKA_WARMUP_TIME_MS}ms"
echo "  - 优雅下线: 已启用"
echo "========================================="

# 构建项目（如果需要）
if [ ! -f "target/service-provider-0.0.1-SNAPSHOT.jar" ]; then
    echo "构建项目..."
    mvn clean package -DskipTests
fi

# 启动服务
java -javaagent:${SKYWALKING_AGENT_PATH}/skywalking-agent.jar \
     -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005 \
     -Dskywalking.agent.service_name=service-provider \
     -Dskywalking.collector.backend_service=127.0.0.1:11800 \
     -Deureka.graceful.startup.enabled=true \
     -Deureka.graceful.startup.delay.ms=2000 \
     -Deureka.warmup.enabled=true \
     -Deureka.warmup.time.ms=3000 \
     -Deureka.graceful.shutdown.enabled=true \
     -Dskywalking.agent.sw_open_gray=true \
     -Deureka.graceful.shutdown.notification.enabled=true \
     -Deureka.graceful.shutdown.no.traffic.timeout.ms=10000 \
     -Deureka.graceful.shutdown.wait.no.traffic.max.ms=60000 \
     -Dagent.logging.level=DEBUG \
     -jar target/service-provider-0.0.1-SNAPSHOT.jar

