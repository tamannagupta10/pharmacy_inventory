package com.pharmacy.model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;

/**
 * Sale.java - Model Class
 * Ek object = ek bill (jisme multiple medicines ho sakti hain)
 */
public class Sale {

    private int             saleId;
    private String          customerName;
    private BigDecimal      totalAmount;
    private int              soldBy;       // user_id
    private String           soldByName;   // join se aayega
    private Timestamp        saleDate;
    private List<SaleItem>   items;        // bill ke andar ke saare medicines

    public Sale() {}

    // Getters
    public int           getSaleId()       { return saleId; }
    public String        getCustomerName() { return customerName; }
    public BigDecimal    getTotalAmount()  { return totalAmount; }
    public int           getSoldBy()       { return soldBy; }
    public String        getSoldByName()   { return soldByName; }
    public Timestamp      getSaleDate()     { return saleDate; }
    public List<SaleItem> getItems()        { return items; }

    // Setters
    public void setSaleId(int saleId)               { this.saleId = saleId; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }
    public void setTotalAmount(BigDecimal amount)    { this.totalAmount = amount; }
    public void setSoldBy(int soldBy)                { this.soldBy = soldBy; }
    public void setSoldByName(String name)           { this.soldByName = name; }
    public void setSaleDate(Timestamp saleDate)      { this.saleDate = saleDate; }
    public void setItems(List<SaleItem> items)       { this.items = items; }
}