package com.ordersystem.order.model;

public record CreateOrderRequest(
    String productCode,
    int quantity
){}