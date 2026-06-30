package com.pharmacy.model;

import java.math.BigDecimal;
import java.sql.Date;

/**
 * Medicine.java - Model Class
 * Ek object = medicines table ki ek row
 */
public class Medicine {

    private int        medicineId;
    private String     medicineName;
    private String     brandName;
    private int         categoryId;
    private String      categoryName;   // join se aayega, display ke liye
    private int         supplierId;
    private String      supplierName;   // join se aayega, display ke liye
    private int         quantity;
    private int         minStock;
    private BigDecimal  unitPrice;
    private Date        expiryDate;
    private Date        manufactureDate;
    private String      description;

    public Medicine() {}

    // Getters
    public int        getMedicineId()      { return medicineId; }
    public String     getMedicineName()    { return medicineName; }
    public String     getBrandName()       { return brandName; }
    public int        getCategoryId()      { return categoryId; }
    public String     getCategoryName()    { return categoryName; }
    public int        getSupplierId()      { return supplierId; }
    public String     getSupplierName()    { return supplierName; }
    public int        getQuantity()        { return quantity; }
    public int        getMinStock()        { return minStock; }
    public BigDecimal getUnitPrice()       { return unitPrice; }
    public Date        getExpiryDate()      { return expiryDate; }
    public Date        getManufactureDate() { return manufactureDate; }
    public String      getDescription()     { return description; }

    // Setters
    public void setMedicineId(int medicineId)            { this.medicineId = medicineId; }
    public void setMedicineName(String medicineName)     { this.medicineName = medicineName; }
    public void setBrandName(String brandName)           { this.brandName = brandName; }
    public void setCategoryId(int categoryId)            { this.categoryId = categoryId; }
    public void setCategoryName(String categoryName)     { this.categoryName = categoryName; }
    public void setSupplierId(int supplierId)            { this.supplierId = supplierId; }
    public void setSupplierName(String supplierName)     { this.supplierName = supplierName; }
    public void setQuantity(int quantity)                { this.quantity = quantity; }
    public void setMinStock(int minStock)                { this.minStock = minStock; }
    public void setUnitPrice(BigDecimal unitPrice)       { this.unitPrice = unitPrice; }
    public void setExpiryDate(Date expiryDate)           { this.expiryDate = expiryDate; }
    public void setManufactureDate(Date manufactureDate) { this.manufactureDate = manufactureDate; }
    public void setDescription(String description)       { this.description = description; }

    /** Helper - low stock hai ya nahi check karne ke liye (Day 6 mein use hoga) */
    public boolean isLowStock() {
        return quantity < minStock;
    }
}