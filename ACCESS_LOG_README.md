# Access日志功能说明

## 功能概述

为所有服务模块（除了eureka-server）添加了请求访问的access日志功能，用于记录每个HTTP请求的详细信息。

## 涉及的服务模块

- service-consumer
- service-provider
- service-provider-aws
- service-provider-common

## 日志内容

每个HTTP请求都会记录以下信息：

- 请求方法（GET、POST等）
- 请求URI（包含查询参数）
- HTTP状态码
- 客户端IP地址（支持X-Forwarded-For和X-Real-IP）
- 请求处理耗时（毫秒）
- 异常信息（如果有）

## 日志格式

```
[ACCESS] {METHOD} {URI} - Status: {STATUS_CODE} - IP: {CLIENT_IP} - Duration: {DURATION}ms
```

示例：
```
[ACCESS] GET /hello?name=test - Status: 200 - IP: 127.0.0.1 - Duration: 15ms
```

## 日志级别

- 正常请求（2xx、3xx）：INFO级别
- 客户端错误（4xx）和服务端错误（5xx）：WARN级别
- 异常请求：ERROR级别

## 日志输出

每个服务的access日志会：

1. 输出到控制台
2. 输出到独立的日志文件：
   - service-consumer: `logs/service-consumer-access.log`
   - service-provider: `logs/service-provider-access.log`
   - service-provider-aws: `logs/service-provider-aws-access.log`
   - service-provider-common: `logs/service-provider-common-access.log`

## 日志滚动策略

- 按天滚动
- 保留最近30天的日志
- 历史日志文件格式：`{service}-access.{yyyy-MM-dd}.log`

## 实现方式

使用Spring MVC的`HandlerInterceptor`拦截器实现：

1. **拦截器**：每个服务都有一个`AccessLogInterceptor`类
2. **配置类**：每个服务都有一个`AccessLogConfig`类用于注册拦截器
3. **Logback配置**：每个服务都有一个`logback-spring.xml`配置文件

## 配置文件

### application.yml

在每个服务的application.yml中添加了ACCESS_LOG的日志级别配置：

```yaml
logging:
  level:
    ACCESS_LOG: INFO
```

### logback-spring.xml

每个服务都有独立的logback配置文件，配置了ACCESS_LOG的输出方式。

## 如何调整日志级别

如果需要禁用access日志，可以在对应服务的application.yml中将日志级别设置为OFF：

```yaml
logging:
  level:
    ACCESS_LOG: OFF
```

如果需要更详细的日志，可以设置为DEBUG级别（虽然当前实现中DEBUG和INFO输出相同）。

## IP地址获取优先级

拦截器会按以下优先级获取客户端真实IP：

1. X-Forwarded-For 请求头
2. X-Real-IP 请求头
3. request.getRemoteAddr()

这样可以在有反向代理（如Nginx）的情况下获取到真实的客户端IP。
