package com.pharmacy.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * PurchaseOrder.java - Model Class
 * Ek object = ek purchase order (supplier se medicine khareedna)
 */
public class PurchaseOrder {

    private int        orderId;
    private int        supplierId;
    private String     supplierName;   // join se aayega
    private int        medicineId;
    private String     medicineName;   // join se aayega
    private int        quantity;
    private BigDecimal unitCost;
    private BigDecimal totalCost;      // database mein auto-calculate hota hai
    private Timestamp  orderDate;

    public PurchaseOrder() {}

    // Getters
    public int        getOrderId()      { return orderId; }
    public int        getSupplierId()   { return supplierId; }
    public String     getSupplierName() { return supplierName; }
    public int        getMedicineId()   { return medicineId; }
    public String     getMedicineName() { return medicineName; }
    public int        getQuantity()     { return quantity; }
    public BigDecimal getUnitCost()     { return unitCost; }
    public BigDecimal getTotalCost()    { return totalCost; }
    public Timestamp  getOrderDate()    { return orderDate; }

    // Setters
    public void setOrderId(int orderId)            { this.orderId = orderId; }
    public void setSupplierId(int supplierId)      { this.supplierId = supplierId; }
    public void setSupplierName(String name)       { this.supplierName = name; }
    public void setMedicineId(int medicineId)      { this.medicineId = medicineId; }
    public void setMedicineName(String name)       { this.medicineName = name; }
    public void setQuantity(int quantity)          { this.quantity = quantity; }
    public void setUnitCost(BigDecimal unitCost)   { this.unitCost = unitCost; }
    public void setTotalCost(BigDecimal totalCost) { this.totalCost = totalCost; }
    public void setOrderDate(Timestamp orderDate)  { this.orderDate = orderDate; }
}