package com.pharmacy.model;


public class User {

    private int     userId;
    private String  fullName;
    private String  username;
    private String  password;
    private String  role;      // "ADMIN" ya "PHARMACIST"
    private String  email;
    private String  phone;
    private boolean isActive;

    // Default constructor
    public User() {}

    // Getters
    public int     getUserId()   { return userId; }
    public String  getFullName() { return fullName; }
    public String  getUsername() { return username; }
    public String  getPassword() { return password; }
    public String  getRole()     { return role; }
    public String  getEmail()    { return email; }
    public String  getPhone()    { return phone; }
    public boolean isActive()    { return isActive; }

    // Setters
    public void setUserId(int userId)        { this.userId   = userId; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public void setUsername(String username) { this.username = username; }
    public void setPassword(String password) { this.password = password; }
    public void setRole(String role)         { this.role     = role; }
    public void setEmail(String email)       { this.email    = email; }
    public void setPhone(String phone)       { this.phone    = phone; }
    public void setActive(boolean isActive)  { this.isActive = isActive; }
}
