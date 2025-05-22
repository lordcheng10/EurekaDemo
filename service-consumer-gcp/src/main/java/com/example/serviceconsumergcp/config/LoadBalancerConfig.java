package com.example.serviceconsumergcp.config;

import org.springframework.cloud.loadbalancer.annotation.LoadBalancerClients;
import org.springframework.context.annotation.Configuration;

@Configuration
@LoadBalancerClients(defaultConfiguration = CustomLoadBalancerConfiguration.class)
public class LoadBalancerConfig {
} 