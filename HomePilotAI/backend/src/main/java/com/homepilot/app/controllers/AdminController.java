package com.homepilot.app.controllers;

import com.homepilot.app.services.DatabaseAdminService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequestMapping("/admin")
public class AdminController {

    @Autowired private DatabaseAdminService dbAdmin;

    @PostMapping("/reset")
    public ResponseEntity<?> resetDatabase() {
        String msg = dbAdmin.resetAllTables();
        return ResponseEntity.ok(Map.of("message", msg));
    }

    @PostMapping("/seed")
    public ResponseEntity<?> seedDatabase() {
        String msg = dbAdmin.seedDatabase();
        return ResponseEntity.ok(Map.of("message", msg));
    }

    @PostMapping("/reset-and-seed")
    public ResponseEntity<?> resetAndSeed() {
        String r = dbAdmin.resetAllTables();
        String s = dbAdmin.seedDatabase();
        return ResponseEntity.ok(Map.of("reset", r, "seed", s));
    }
}
