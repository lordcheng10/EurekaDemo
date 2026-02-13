package com.example.serviceprovideraws.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import javax.servlet.http.HttpServletRequest;

@RestController
public class HelloController {

    private static final Logger accessLog = LoggerFactory.getLogger("ACCESS_LOG");
    private static final Logger log = LoggerFactory.getLogger(HelloController.class);

    @GetMapping("/hello")
    public String hello() {
        long startTime = System.currentTimeMillis();
        
        try {
            // 获取请求信息
            ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attributes != null) {
                HttpServletRequest request = attributes.getRequest();
                String method = request.getMethod();
                String uri = request.getRequestURI();
                String queryString = request.getQueryString();
                String remoteAddr = getRemoteAddr(request);
                
                String fullUrl = uri;
                if (queryString != null && !queryString.isEmpty()) {
                    fullUrl = uri + "?" + queryString;
                }
                
                // 记录访问日志
                log.info("处理请求: {} {} from {}", method, fullUrl, remoteAddr);
                accessLog.info("[ACCESS] {} {} - IP: {} - 开始处理", method, fullUrl, remoteAddr);
            }
            
            return "hello AWS";
            
        } finally {
            long duration = System.currentTimeMillis() - startTime;
            accessLog.info("[ACCESS] /hello - 处理完成 - Duration: {}ms", duration);
        }
    }
    
    private String getRemoteAddr(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("X-Real-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        return ip;
    }
} 