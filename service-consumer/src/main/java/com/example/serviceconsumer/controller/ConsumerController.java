package com.example.serviceconsumer.controller;

import com.example.serviceconsumer.client.HelloServiceClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ConsumerController {

    @Autowired
    private HelloServiceClient helloServiceClient;

    @GetMapping("/consume")
    public String consume() {
        return "Consumer received: " + helloServiceClient.getHello();
    }
} 