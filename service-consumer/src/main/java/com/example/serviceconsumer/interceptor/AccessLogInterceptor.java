package com.example.serviceconsumer.interceptor;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class AccessLogInterceptor implements HandlerInterceptor {

    private static final Logger accessLog = LoggerFactory.getLogger("ACCESS_LOG");
    private static final String START_TIME_ATTRIBUTE = "startTime";

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        request.setAttribute(START_TIME_ATTRIBUTE, System.currentTimeMillis());
        return true;
    }

    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) {
        // 可以在这里添加额外的后处理逻辑
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
        Long startTime = (Long) request.getAttribute(START_TIME_ATTRIBUTE);
        long duration = System.currentTimeMillis() - (startTime != null ? startTime : System.currentTimeMillis());
        
        String method = request.getMethod();
        String uri = request.getRequestURI();
        String queryString = request.getQueryString();
        String remoteAddr = getRemoteAddr(request);
        int status = response.getStatus();
        
        String fullUrl = uri;
        if (queryString != null && !queryString.isEmpty()) {
            fullUrl = uri + "?" + queryString;
        }
        
        String logMessage = String.format("[ACCESS] %s %s - Status: %d - IP: %s - Duration: %dms",
                method, fullUrl, status, remoteAddr, duration);
        
        if (ex != null) {
            accessLog.error(logMessage + " - Exception: " + ex.getMessage(), ex);
        } else if (status >= 400) {
            accessLog.warn(logMessage);
        } else {
            accessLog.info(logMessage);
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
