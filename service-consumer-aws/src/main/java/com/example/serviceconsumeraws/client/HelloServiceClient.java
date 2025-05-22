package com.example.serviceconsumeraws.client;

import com.example.serviceconsumeraws.config.FeignConfig;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;

@FeignClient(name = "service-provider", configuration = FeignConfig.class)
public interface HelloServiceClient {

    @GetMapping("/hello")
    String getHello();
} 