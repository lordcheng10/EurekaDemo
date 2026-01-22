#!/bin/bash

echo "========================================="
echo "快速启动所有服务（禁用 OneAgent）"
echo "========================================="

# 在后台启动 provider
echo "启动 Provider（禁用 OneAgent）..."
./start-provider-without-oneagent.sh > logs/provider-no-oneagent.log 2>&1 &
PROVIDER_PID=$!
echo "  PID: ${PROVIDER_PID}"
echo "  日志: logs/provider-no-oneagent.log"

# 等待 provider 启动
echo "等待 Provider 启动..."
sleep 10

# 在后台启动 consumer
echo "启动 Consumer（禁用 OneAgent）..."
./start-consumer-without-oneagent.sh > logs/consumer-no-oneagent.log 2>&1 &
CONSUMER_PID=$!
echo "  PID: ${CONSUMER_PID}"
echo "  日志: logs/consumer-no-oneagent.log"

# 等待 consumer 启动
echo "等待 Consumer 启动..."
sleep 10

echo ""
echo "========================================="
echo "服务启动完成！"
echo "========================================="
echo "Provider PID: ${PROVIDER_PID}"
echo "Consumer PID: ${CONSUMER_PID}"
echo ""
echo "查看日志："
echo "  tail -f logs/provider-no-oneagent.log"
echo "  tail -f logs/consumer-no-oneagent.log"
echo ""
echo "测试服务："
echo "  curl http://localhost:8081/call-provider"
echo ""
echo "停止服务："
echo "  kill ${PROVIDER_PID} ${CONSUMER_PID}"
echo "  或运行: ./stop-all.sh"
echo "========================================="

# 保存 PID
mkdir -p .pids
echo ${PROVIDER_PID} > .pids/provider-no-oneagent.pid
echo ${CONSUMER_PID} > .pids/consumer-no-oneagent.pid
