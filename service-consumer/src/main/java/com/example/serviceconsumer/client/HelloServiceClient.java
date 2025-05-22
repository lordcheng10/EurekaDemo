package com.example.serviceconsumer.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;

@FeignClient(name = "service-provider")
public interface HelloServiceClient {

    @GetMapping("/hello")
    String getHello();
} 