#!/bin/bash

# Access日志功能测试脚本

echo "=== Access日志功能测试 ==="
echo ""
echo "请确保以下服务正在运行："
echo "1. eureka-server (8761)"
echo "2. service-provider (8001)"
echo "3. service-provider-aws (8003)"
echo "4. service-consumer (8002)"
echo ""

# 等待用户确认
read -p "按Enter键开始测试，或按Ctrl+C退出: "

echo ""
echo "开始测试..."
echo ""

# 测试service-provider
echo "1. 测试 service-provider (8001)..."
curl -s http://localhost:8001/hello?name=TestUser > /dev/null
echo "   请求已发送，请查看service-provider控制台或logs/service-provider-access.log"
sleep 1

# 测试service-provider-aws
echo "2. 测试 service-provider-aws (8003)..."
curl -s http://localhost:8003/hello?name=TestUser > /dev/null
echo "   请求已发送，请查看service-provider-aws控制台或logs/service-provider-aws-access.log"
sleep 1

# 测试service-consumer
echo "3. 测试 service-consumer (8002)..."
curl -s http://localhost:8002/consume?name=TestUser > /dev/null
echo "   请求已发送，请查看service-consumer控制台或logs/service-consumer-access.log"
sleep 1

echo ""
echo "=== 测试完成 ==="
echo ""
echo "日志位置："
echo "- service-provider: logs/service-provider-access.log"
echo "- service-provider-aws: logs/service-provider-aws-access.log"
echo "- service-consumer: logs/service-consumer-access.log"
echo ""
echo "日志格式示例："
echo "[ACCESS] GET /hello?name=TestUser - Status: 200 - IP: 127.0.0.1 - Duration: 15ms"
echo ""
