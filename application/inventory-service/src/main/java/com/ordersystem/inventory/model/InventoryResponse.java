package com.ordersystem.inventory.model;

public record InventoryResponse(
    String productCode,
    boolean available,
    int stockQuantity
) {}
