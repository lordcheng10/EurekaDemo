# Eureka Demo

This is a simple demo of Spring Cloud Netflix Eureka with a service provider and consumer.

## Project Structure

- **eureka-server**: Eureka Server running on port 8761
- **service-provider**: Service Provider with a simple REST endpoint that returns "hello", running on port 8001
- **service-consumer**: Service Consumer that calls the provider's endpoint using Feign, running on port 8002

## How to Run

1. Start the Eureka Server:
   ```
   cd eureka-server
   mvn spring-boot:run
   ```

2. Start the Service Provider:
   ```
   cd service-provider
   mvn spring-boot:run
   ```

3. Start the Service Consumer:
   ```
   cd service-consumer
   mvn spring-boot:run
   ```

## Testing

1. Access the Eureka Dashboard: http://localhost:8761
2. Test the Service Provider directly: http://localhost:8001/hello
3. Test the Service Consumer: http://localhost:8002/consume

The consumer will call the provider and return: "Consumer received: hello" 