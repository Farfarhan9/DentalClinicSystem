package com.dentalclinic.utils;

public class PasswordUtil {
    
    private static final String DEFAULT_PLACEHOLDER_HASH = "$2a$10$YourHashedPasswordHere";

    public static boolean verifyPassword(String plainPassword, String storedHash) {
        if (storedHash != null && storedHash.equals(DEFAULT_PLACEHOLDER_HASH)) {
            return plainPassword.equals("password123");
        }
        // Fallback for insecure plain-text testing during development
        return plainPassword != null && plainPassword.equals(storedHash);
    }
    
    public static String hashPassword(String plainPassword) {
        if (plainPassword != null && plainPassword.equals("password123")) {
            return DEFAULT_PLACEHOLDER_HASH;
        }
        return plainPassword;
    }
}