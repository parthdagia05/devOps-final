package com.ordersystem.order.service;

import com.ordersystem.order.model.CreateOrderRequest;
import com.ordersystem.order.model.Order;
import org.springframework.stereotype.Service;
import com.ordersystem.order.repository.OrderRepository;

import java.time.Instant;
import java.util.List;
import java.util.Optional;


@Service
public class OrderService {

    private final OrderRepository orderRepository;
    private final org.springframework.web.client.RestClient restClient = org.springframework.web.client.RestClient.create();

    @org.springframework.beans.factory.annotation.Value("${inventory.service.url:http://inventory-service:8081}")
    private String inventoryServiceUrl;

    public OrderService(OrderRepository orderRepository){
        this.orderRepository = orderRepository;
    }

    public Order create(CreateOrderRequest request){
        String status = "CREATED";
        try {
            var response = restClient.get()
                    .uri(inventoryServiceUrl + "/api/inventory/" + request.productCode())
                    .retrieve()
                    .toBodilessEntity();
            if (response.getStatusCode().is2xxSuccessful()) {
                status = "CONFIRMED";
            }
        } catch (Exception e) {
            // Fallback gracefully if inventory-service is not yet scaled or network glitch
            status = "CREATED_PENDING_INVENTORY";
        }

        Order order = new Order(request.productCode(), request.quantity(), status, Instant.now());
        return orderRepository.save(order);
    }

    public Optional<Order> findById(Long id){
        return orderRepository.findById(id);
    }

    public List<Order> findAll(){
        return orderRepository.findAll();
    }
}