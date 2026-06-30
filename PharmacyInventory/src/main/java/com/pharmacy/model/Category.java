package com.pharmacy.model;

/** Category.java - Model Class (dropdown ke liye chahiye) */
public class Category {
    private int categoryId;
    private String categoryName;

    public Category() {}
    public Category(int categoryId, String categoryName) {
        this.categoryId = categoryId;
        this.categoryName = categoryName;
    }

    public int getCategoryId()             { return categoryId; }
    public void setCategoryId(int id)      { this.categoryId = id; }
    public String getCategoryName()        { return categoryName; }
    public void setCategoryName(String n)  { this.categoryName = n; }
}