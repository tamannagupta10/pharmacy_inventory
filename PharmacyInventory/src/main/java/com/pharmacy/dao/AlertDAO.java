package com.pharmacy.dao;

import com.pharmacy.db.DBConnection;
import com.pharmacy.model.Medicine;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * AlertDAO.java - Expiry + Low Stock queries
 * Day 6 ka main DAO — 4 types ke alerts handle karta hai
 */
public class AlertDAO {

    /**
     * Medicines jo already expire ho chuki hain (expiry_date < TODAY)
     */
    public List<Medicine> getExpiredMedicines() {
        List<Medicine> list = new ArrayList<>();
        String sql = "SELECT m.*, c.category_name, s.supplier_name " +
                     "FROM medicines m " +
                     "LEFT JOIN categories c ON m.category_id = c.category_id " +
                     "LEFT JOIN suppliers s ON m.supplier_id = s.supplier_id " +
                     "WHERE m.expiry_date < CURDATE() " +
                     "ORDER BY m.expiry_date ASC";
        try {
            Connection conn = DBConnection.getConnection();
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);
            while (rs.next()) list.add(mapRow(rs));
            rs.close(); stmt.close();
        } catch (SQLException e) {
            System.err.println("[AlertDAO] getExpiredMedicines: " + e.getMessage());
        }
        return list;
    }

    /**
     * Medicines jo agle 30 din mein expire hongi (expiry_date BETWEEN TODAY AND TODAY+30)
     */
    public List<Medicine> getExpiringMedicines() {
        List<Medicine> list = new ArrayList<>();
        String sql = "SELECT m.*, c.category_name, s.supplier_name, " +
                     "DATEDIFF(m.expiry_date, CURDATE()) AS days_left " +
                     "FROM medicines m " +
                     "LEFT JOIN categories c ON m.category_id = c.category_id " +
                     "LEFT JOIN suppliers s ON m.supplier_id = s.supplier_id " +
                     "WHERE m.expiry_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY) " +
                     "ORDER BY m.expiry_date ASC";
        try {
            Connection conn = DBConnection.getConnection();
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);
            while (rs.next()) {
                Medicine m = mapRow(rs);
                m.setDaysLeft(rs.getInt("days_left"));
                list.add(m);
            }
            rs.close(); stmt.close();
        } catch (SQLException e) {
            System.err.println("[AlertDAO] getExpiringMedicines: " + e.getMessage());
        }
        return list;
    }

    /**
     * Medicines jinki quantity 0 hai (out of stock)
     */
    public List<Medicine> getOutOfStockMedicines() {
        List<Medicine> list = new ArrayList<>();
        String sql = "SELECT m.*, c.category_name, s.supplier_name " +
                     "FROM medicines m " +
                     "LEFT JOIN categories c ON m.category_id = c.category_id " +
                     "LEFT JOIN suppliers s ON m.supplier_id = s.supplier_id " +
                     "WHERE m.quantity = 0 " +
                     "ORDER BY m.medicine_name ASC";
        try {
            Connection conn = DBConnection.getConnection();
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);
            while (rs.next()) list.add(mapRow(rs));
            rs.close(); stmt.close();
        } catch (SQLException e) {
            System.err.println("[AlertDAO] getOutOfStockMedicines: " + e.getMessage());
        }
        return list;
    }

    /**
     * Medicines jinki quantity min_stock se kam hai (low stock)
     */
    public List<Medicine> getLowStockMedicines() {
        List<Medicine> list = new ArrayList<>();
        String sql = "SELECT m.*, c.category_name, s.supplier_name " +
                     "FROM medicines m " +
                     "LEFT JOIN categories c ON m.category_id = c.category_id " +
                     "LEFT JOIN suppliers s ON m.supplier_id = s.supplier_id " +
                     "WHERE m.quantity > 0 AND m.quantity < m.min_stock " +
                     "ORDER BY m.quantity ASC";
        try {
            Connection conn = DBConnection.getConnection();
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);
            while (rs.next()) list.add(mapRow(rs));
            rs.close(); stmt.close();
        } catch (SQLException e) {
            System.err.println("[AlertDAO] getLowStockMedicines: " + e.getMessage());
        }
        return list;
    }

    /**
     * Dashboard ke liye alert counts (sirf numbers, poori list nahi)
     */
    public int countExpired()    { return countQuery("SELECT COUNT(*) FROM medicines WHERE expiry_date < CURDATE()"); }
    public int countExpiring()   { return countQuery("SELECT COUNT(*) FROM medicines WHERE expiry_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY)"); }
    public int countOutOfStock() { return countQuery("SELECT COUNT(*) FROM medicines WHERE quantity = 0"); }
    public int countLowStock()   { return countQuery("SELECT COUNT(*) FROM medicines WHERE quantity > 0 AND quantity < min_stock"); }

    private int countQuery(String sql) {
        try {
            Connection conn = DBConnection.getConnection();
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);
            if (rs.next()) return rs.getInt(1);
            rs.close(); stmt.close();
        } catch (SQLException e) {
            System.err.println("[AlertDAO] countQuery error: " + e.getMessage());
        }
        return 0;
    }

    /** Helper - ResultSet row ko Medicine object mein convert karta hai */
    private Medicine mapRow(ResultSet rs) throws SQLException {
        Medicine m = new Medicine();
        m.setMedicineId(rs.getInt("medicine_id"));
        m.setMedicineName(rs.getString("medicine_name"));
        m.setBrandName(rs.getString("brand_name"));
        m.setCategoryName(rs.getString("category_name"));
        m.setSupplierName(rs.getString("supplier_name"));
        m.setQuantity(rs.getInt("quantity"));
        m.setMinStock(rs.getInt("min_stock"));
        m.setUnitPrice(rs.getBigDecimal("unit_price"));
        m.setExpiryDate(rs.getDate("expiry_date"));
        return m;
    }
}