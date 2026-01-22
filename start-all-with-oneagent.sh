#!/bin/bash

echo "========================================="
echo "快速启动所有服务（启用 OneAgent）"
echo "========================================="

# 检查 etcd 是否运行
echo "检查 etcd 状态..."
if ! curl -s http://localhost:2379/version > /dev/null 2>&1; then
    echo "❌ Etcd 未运行，正在启动..."
    docker start etcd 2>/dev/null || \
    docker run -d --name etcd \
      -p 2379:2379 \
      -p 2380:2380 \
      quay.io/coreos/etcd:latest \
      etcd --listen-client-urls http://0.0.0.0:2379 \
           --advertise-client-urls http://localhost:2379
    
    echo "等待 etcd 启动..."
    sleep 3
fi

if curl -s http://localhost:2379/version > /dev/null 2>&1; then
    echo "✅ Etcd 运行正常"
else
    echo "❌ Etcd 启动失败，请手动启动"
    exit 1
fi

echo ""
echo "========================================="
echo "启动服务..."
echo "========================================="

# 在后台启动 provider
echo "启动 Provider（启用 OneAgent）..."
./start-provider-with-agent.sh > logs/provider-oneagent.log 2>&1 &
PROVIDER_PID=$!
echo "  PID: ${PROVIDER_PID}"
echo "  日志: logs/provider-oneagent.log"

# 等待 provider 启动
echo "等待 Provider 启动..."
sleep 10

# 在后台启动 consumer
echo "启动 Consumer（启用 OneAgent）..."
./start-consumer-with-agent.sh > logs/consumer-oneagent.log 2>&1 &
CONSUMER_PID=$!
echo "  PID: ${CONSUMER_PID}"
echo "  日志: logs/consumer-oneagent.log"

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
echo "  tail -f logs/provider-oneagent.log"
echo "  tail -f logs/consumer-oneagent.log"
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
echo ${PROVIDER_PID} > .pids/provider-oneagent.pid
echo ${CONSUMER_PID} > .pids/consumer-oneagent.pid
