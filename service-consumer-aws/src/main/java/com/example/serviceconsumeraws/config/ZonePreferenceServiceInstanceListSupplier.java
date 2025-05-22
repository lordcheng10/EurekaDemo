package com.example.serviceconsumeraws.config;

import org.springframework.cloud.client.ServiceInstance;
import org.springframework.cloud.loadbalancer.core.ServiceInstanceListSupplier;
import reactor.core.publisher.Flux;

import java.util.ArrayList;
import java.util.List;

public class ZonePreferenceServiceInstanceListSupplier implements ServiceInstanceListSupplier {

    private final ServiceInstanceListSupplier delegate;
    private final String preferredZone;

    public ZonePreferenceServiceInstanceListSupplier(ServiceInstanceListSupplier delegate, String preferredZone) {
        this.delegate = delegate;
        this.preferredZone = preferredZone;
    }

    @Override
    public String getServiceId() {
        return delegate.getServiceId();
    }

    @Override
    public Flux<List<ServiceInstance>> get() {
        return delegate.get().map(this::filteredByZone);
    }

    private List<ServiceInstance> filteredByZone(List<ServiceInstance> serviceInstances) {
        if (serviceInstances.isEmpty()) {
            return serviceInstances;
        }

        List<ServiceInstance> filteredInstances = new ArrayList<>();
        for (ServiceInstance instance : serviceInstances) {
            String zone = instance.getMetadata().get("zone");
            if (preferredZone.equals(zone)) {
                filteredInstances.add(instance);
            }
        }

        // 如果没有指定区域的实例，则返回所有实例
        return filteredInstances.isEmpty() ? serviceInstances : filteredInstances;
    }
} 