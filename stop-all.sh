#!/bin/bash

echo "========================================="
echo "停止所有服务"
echo "========================================="

# 从 PID 文件读取并停止
if [ -d ".pids" ]; then
    for pid_file in .pids/*.pid; do
        if [ -f "$pid_file" ]; then
            PID=$(cat "$pid_file")
            SERVICE_NAME=$(basename "$pid_file" .pid)
            
            if ps -p $PID > /dev/null 2>&1; then
                echo "停止 ${SERVICE_NAME} (PID: ${PID})..."
                kill $PID
                
                # 等待进程停止
                for i in {1..10}; do
                    if ! ps -p $PID > /dev/null 2>&1; then
                        echo "  ✅ ${SERVICE_NAME} 已停止"
                        break
                    fi
                    sleep 1
                done
                
                # 如果还没停止，强制停止
                if ps -p $PID > /dev/null 2>&1; then
                    echo "  ⚠️  强制停止 ${SERVICE_NAME}..."
                    kill -9 $PID
                fi
            else
                echo "⚠️  ${SERVICE_NAME} (PID: ${PID}) 已经停止"
            fi
            
            rm "$pid_file"
        fi
    done
    rmdir .pids 2>/dev/null
else
    echo "⚠️  未找到 PID 文件，尝试通过进程名停止..."
    
    # 通过进程名查找并停止
    pkill -f "service-provider.*jar"
    pkill -f "service-consumer.*jar"
    
    sleep 2
fi

echo ""
echo "========================================="
echo "检查服务状态"
echo "========================================="

# 检查端口占用
if lsof -i :8080 > /dev/null 2>&1; then
    echo "⚠️  端口 8080 仍被占用"
    lsof -i :8080
else
    echo "✅ 端口 8080 已释放"
fi

if lsof -i :8081 > /dev/null 2>&1; then
    echo "⚠️  端口 8081 仍被占用"
    lsof -i :8081
else
    echo "✅ 端口 8081 已释放"
fi

echo "========================================="
echo "所有服务已停止"
echo "========================================="
