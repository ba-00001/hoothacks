package com.homepilot.app.dto;

public class AuthResponse {
    public String token;
    public String message;
    public Long userId;

    public AuthResponse(String token, String message, Long userId) {
        this.token = token;
        this.message = message;
        this.userId = userId;
    }
}
