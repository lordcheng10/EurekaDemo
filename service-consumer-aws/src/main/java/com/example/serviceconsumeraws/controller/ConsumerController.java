package com.example.serviceconsumeraws.controller;

import com.example.serviceconsumeraws.client.HelloServiceClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ConsumerController {

    private static final Logger logger = LoggerFactory.getLogger(ConsumerController.class);

    @Autowired
    private HelloServiceClient helloServiceClient;

    @GetMapping("/consume")
    public String consume() {
        String result = helloServiceClient.getHello();
        logger.info("AWS消费者收到响应: {}", result);
        return "AWS Consumer received: " + result;
    }
} 
 