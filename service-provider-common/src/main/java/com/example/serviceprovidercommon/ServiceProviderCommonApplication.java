package com.example.serviceprovidercommon;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@SpringBootApplication
@EnableDiscoveryClient
public class ServiceProviderCommonApplication {

    public static void main(String[] args) {
        SpringApplication.run(ServiceProviderCommonApplication.class, args);
    }
} 