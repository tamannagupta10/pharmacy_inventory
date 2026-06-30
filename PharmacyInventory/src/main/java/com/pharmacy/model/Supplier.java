package com.pharmacy.model;

/**
 * Supplier.java - Model Class (Day 4 ke liye full version)
 * Ek object = suppliers table ki ek row
 */
public class Supplier {

    private int    supplierId;
    private String supplierName;
    private String contactName;
    private String phone;
    private String email;
    private String address;

    public Supplier() {}

    // Day 3 wala chhota constructor (dropdown ke liye) - backward compatible
    public Supplier(int supplierId, String supplierName) {
        this.supplierId = supplierId;
        this.supplierName = supplierName;
    }

    // Getters
    public int    getSupplierId()   { return supplierId; }
    public String getSupplierName() { return supplierName; }
    public String getContactName()  { return contactName; }
    public String getPhone()        { return phone; }
    public String getEmail()        { return email; }
    public String getAddress()      { return address; }

    // Setters
    public void setSupplierId(int id)            { this.supplierId = id; }
    public void setSupplierName(String name)     { this.supplierName = name; }
    public void setContactName(String name)      { this.contactName = name; }
    public void setPhone(String phone)           { this.phone = phone; }
    public void setEmail(String email)           { this.email = email; }
    public void setAddress(String address)       { this.address = address; }
}