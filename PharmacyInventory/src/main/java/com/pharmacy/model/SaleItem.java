package com.pharmacy.model;

import java.math.BigDecimal;

/**
 * SaleItem.java - Model Class
 * Ek object = bill ke andar ek medicine ki line item
 */
public class SaleItem {

    private int        itemId;
    private int        saleId;
    private int        medicineId;
    private String     medicineName;   // join se aayega, display ke liye
    private int        quantity;
    private BigDecimal unitPrice;
    private BigDecimal subtotal;       // database mein auto-calculate hota hai

    public SaleItem() {}

    // Getters
    public int        getItemId()      { return itemId; }
    public int        getSaleId()      { return saleId; }
    public int        getMedicineId()  { return medicineId; }
    public String     getMedicineName(){ return medicineName; }
    public int        getQuantity()    { return quantity; }
    public BigDecimal getUnitPrice()   { return unitPrice; }
    public BigDecimal getSubtotal()    { return subtotal; }

    // Setters
    public void setItemId(int itemId)             { this.itemId = itemId; }
    public void setSaleId(int saleId)              { this.saleId = saleId; }
    public void setMedicineId(int medicineId)      { this.medicineId = medicineId; }
    public void setMedicineName(String name)       { this.medicineName = name; }
    public void setQuantity(int quantity)          { this.quantity = quantity; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }
    public void setSubtotal(BigDecimal subtotal)   { this.subtotal = subtotal; }
}