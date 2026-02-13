# Access日志功能实现总结

## 修改概述

为EurekaDemo项目中的所有服务模块（除eureka-server外）添加了HTTP请求访问日志功能。

## 涉及的服务模块

1. **service-consumer** (端口: 8002)
2. **service-provider** (端口: 8001)
3. **service-provider-aws** (端口: 8003)
4. **service-provider-common** (端口: 8010)

## 新增文件列表

### service-consumer
- `src/main/java/com/example/serviceconsumer/config/AccessLogConfig.java` - 拦截器配置类
- `src/main/java/com/example/serviceconsumer/interceptor/AccessLogInterceptor.java` - Access日志拦截器
- `src/main/resources/logback-spring.xml` - Logback日志配置

### service-provider
- `src/main/java/com/example/serviceprovider/config/AccessLogConfig.java` - 拦截器配置类
- `src/main/java/com/example/serviceprovider/interceptor/AccessLogInterceptor.java` - Access日志拦截器
- `src/main/resources/logback-spring.xml` - Logback日志配置

### service-provider-aws
- `src/main/java/com/example/serviceprovideraws/config/AccessLogConfig.java` - 拦截器配置类
- `src/main/java/com/example/serviceprovideraws/interceptor/AccessLogInterceptor.java` - Access日志拦截器
- `src/main/resources/logback-spring.xml` - Logback日志配置

### service-provider-common
- `src/main/java/com/example/serviceprovidercommon/config/AccessLogConfig.java` - 拦截器配置类
- `src/main/java/com/example/serviceprovidercommon/interceptor/AccessLogInterceptor.java` - Access日志拦截器
- `src/main/resources/logback-spring.xml` - Logback日志配置

### 文档和工具
- `ACCESS_LOG_README.md` - Access日志功能使用说明文档
- `test-access-log.sh` - Access日志功能测试脚本

## 修改的文件列表

### application.yml配置文件
1. `service-consumer/src/main/resources/application.yml` - 添加ACCESS_LOG日志级别配置
2. `service-provider/src/main/resources/application.yml` - 添加ACCESS_LOG日志级别配置
3. `service-provider-aws/src/main/resources/application.yml` - 添加ACCESS_LOG日志级别配置
4. `service-provider-common/src/main/resources/application.yml` - 添加ACCESS_LOG日志级别配置

## 功能特性

### 1. 日志内容
每个HTTP请求会记录：
- 请求方法（GET, POST等）
- 完整URI（包含查询参数）
- HTTP状态码
- 客户端IP地址（支持代理头解析）
- 请求处理时间（毫秒）
- 异常信息（如有）

### 2. 日志格式
```
[ACCESS] {METHOD} {URI} - Status: {STATUS_CODE} - IP: {CLIENT_IP} - Duration: {DURATION}ms
```

示例：
```
2026-02-13 15:30:45.123 [ACCESS] GET /hello?name=test - Status: 200 - IP: 127.0.0.1 - Duration: 15ms
```

### 3. 日志级别
- 2xx, 3xx 响应：INFO级别
- 4xx, 5xx 响应：WARN级别
- 有异常的请求：ERROR级别

### 4. 日志输出
- **控制台输出**：方便开发调试
- **文件输出**：便于生产环境审计
  - service-consumer: `logs/service-consumer-access.log`
  - service-provider: `logs/service-provider-access.log`
  - service-provider-aws: `logs/service-provider-aws-access.log`
  - service-provider-common: `logs/service-provider-common-access.log`

### 5. 日志滚动
- 按天滚动
- 保留30天历史
- 格式：`{service}-access.{yyyy-MM-dd}.log`

## 技术实现

### 实现方式
使用Spring MVC的HandlerInterceptor机制：
1. `preHandle`: 记录请求开始时间
2. `afterCompletion`: 计算耗时并输出日志

### IP地址解析优先级
1. `X-Forwarded-For` 请求头（反向代理场景）
2. `X-Real-IP` 请求头（Nginx等代理）
3. `request.getRemoteAddr()`（直连场景）

## 测试方法

### 方法1: 使用测试脚本
```bash
./test-access-log.sh
```

### 方法2: 手动测试
```bash
# 测试service-provider
curl http://localhost:8001/hello?name=test

# 测试service-provider-aws
curl http://localhost:8003/hello?name=test

# 测试service-consumer
curl http://localhost:8002/consume?name=test
```

### 方法3: 查看日志文件
```bash
# 实时查看日志
tail -f logs/service-consumer-access.log
tail -f logs/service-provider-access.log
tail -f logs/service-provider-aws-access.log
tail -f logs/service-provider-common-access.log
```

## 配置调整

### 关闭access日志
在对应服务的application.yml中设置：
```yaml
logging:
  level:
    ACCESS_LOG: OFF
```

### 仅文件输出（不在控制台输出）
修改对应服务的logback-spring.xml，移除CONSOLE appender：
```xml
<logger name="ACCESS_LOG" level="INFO" additivity="false">
    <appender-ref ref="ACCESS_FILE"/>
    <!-- 注释掉控制台输出 -->
    <!-- <appender-ref ref="CONSOLE"/> -->
</logger>
```

### 调整日志保留天数
修改logback-spring.xml中的maxHistory：
```xml
<rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
    <fileNamePattern>logs/service-xxx-access.%d{yyyy-MM-dd}.log</fileNamePattern>
    <maxHistory>90</maxHistory>  <!-- 修改为90天 -->
</rollingPolicy>
```

## 编译验证

所有修改已通过Maven编译验证：
```bash
mvn clean compile -DskipTests
```

编译结果：BUILD SUCCESS ✅

## 注意事项

1. **eureka-server未添加**：根据需求，eureka-server服务端不需要access日志
2. **日志目录**：logs目录已在.gitignore中，不会提交到版本控制
3. **性能影响**：拦截器的性能开销很小（只是记录时间和简单的字符串拼接）
4. **线程安全**：每个请求独立记录，无并发问题

## 后续优化建议

如需更高级的功能，可以考虑：
1. 添加请求体和响应体记录（注意性能和隐私）
2. 集成ELK或其他日志分析系统
3. 添加慢请求告警（基于Duration阈值）
4. 记录User-Agent、Referer等更多HTTP头信息
5. 添加链路追踪ID（Trace ID）以支持分布式追踪

## 参考文档

详细使用说明请参考：[ACCESS_LOG_README.md](ACCESS_LOG_README.md)
