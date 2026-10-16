package com.ordersystem.order.controller;

import com.ordersystem.order.model.CreateOrderRequest;
import com.ordersystem.order.model.Order;
import com.ordersystem.order.service.OrderService;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;

import java.util.List;

@RestController
@RequestMapping("/api/orders")
public class OrderController {

    private final OrderService orderService;

    public OrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)

    public Order createOrder(@RequestBody CreateOrderRequest request){
        return orderService.create(request);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Order> getOrder(@PathVariable Long id){
        return orderService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping
    public List<Order> getAllOrders(){
        return orderService.findAll();
    }
}