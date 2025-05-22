package com.example.serviceprovideraws;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@SpringBootApplication
@EnableDiscoveryClient
public class ServiceProviderAwsApplication {

    public static void main(String[] args) {
        SpringApplication.run(ServiceProviderAwsApplication.class, args);
    }
} 