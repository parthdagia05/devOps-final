package com.ordersystem.order.model;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "orders")
public class Order{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String productCode;

    private int quantity;

    @Column(nullable = false)
    private String status;

    private Instant createdAt;

    protected Order() {}

    public Order(String productCode, int quantity, String status, Instant createdAt){
        this.productCode = productCode;
        this.quantity = quantity;
        this.status = status;
        this.createdAt = createdAt;
    }

    public Long getId() {
        return id;
    }

    public String getStatus() {
        return status;
    }

    public String getProductCode() {
        return productCode;
    }

    public int getQuantity() {
        return quantity;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }
}