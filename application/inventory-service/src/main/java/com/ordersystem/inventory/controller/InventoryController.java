package com.ordersystem.inventory.controller;

import com.ordersystem.inventory.model.InventoryResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@RestController
@RequestMapping("/api/inventory")
public class InventoryController {

    private final Map<String, Integer> inventoryStore = new ConcurrentHashMap<>();

    public InventoryController() {
        // Pre-populate with standard inventory catalog
        inventoryStore.put("BOOK-123", 50);
        inventoryStore.put("LAPTOP-456", 15);
        inventoryStore.put("PHONE-789", 30);
    }

    @GetMapping("/{productCode}")
    public ResponseEntity<InventoryResponse> checkStock(@PathVariable String productCode) {
        int stock = inventoryStore.getOrDefault(productCode, 10);
        boolean available = stock > 0;
        return ResponseEntity.ok(new InventoryResponse(productCode, available, stock));
    }

    @PostMapping("/reserve")
    public ResponseEntity<InventoryResponse> reserveStock(
            @RequestParam String productCode,
            @RequestParam int quantity) {
        int currentStock = inventoryStore.getOrDefault(productCode, 10);
        if (currentStock >= quantity) {
            int remaining = currentStock - quantity;
            inventoryStore.put(productCode, remaining);
            return ResponseEntity.ok(new InventoryResponse(productCode, true, remaining));
        } else {
            return ResponseEntity.badRequest().body(new InventoryResponse(productCode, false, currentStock));
        }
    }
}
