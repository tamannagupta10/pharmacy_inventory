package com.pharmacy.dao;

import com.pharmacy.db.DBConnection;
import java.math.BigDecimal;
import java.sql.*;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * DashboardDAO.java - Admin Dashboard ke liye summary stats
 * Sab key metrics ek jagah se laata hai
 */
public class DashboardDAO {

    /** Kul medicines count */
    public int getTotalMedicines() {
        return countQuery("SELECT COUNT(*) FROM medicines");
    }

    /** Kul suppliers count */
    public int getTotalSuppliers() {
        return countQuery("SELECT COUNT(*) FROM suppliers");
    }

    /** Aaj ki total sales */
    public int getTodaySalesCount() {
        return countQuery("SELECT COUNT(*) FROM sales WHERE DATE(sale_date) = CURDATE()");
    }

    /** Aaj ka total revenue */
    public BigDecimal getTodayRevenue() {
        String sql = "SELECT COALESCE(SUM(total_amount), 0) FROM sales WHERE DATE(sale_date) = CURDATE()";
        try {
            Connection conn = DBConnection.getConnection();
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);
            if (rs.next()) return rs.getBigDecimal(1);
            rs.close(); stmt.close();
        } catch (SQLException e) {
            System.err.println("[DashboardDAO] getTodayRevenue: " + e.getMessage());
        }
        return BigDecimal.ZERO;
    }

    /** Total revenue (sab time) */
    public BigDecimal getTotalRevenue() {
        String sql = "SELECT COALESCE(SUM(total_amount), 0) FROM sales";
        try {
            Connection conn = DBConnection.getConnection();
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);
            if (rs.next()) return rs.getBigDecimal(1);
            rs.close(); stmt.close();
        } catch (SQLException e) {
            System.err.println("[DashboardDAO] getTotalRevenue: " + e.getMessage());
        }
        return BigDecimal.ZERO;
    }

    /** Low stock count (quantity < min_stock) */
    public int getLowStockCount() {
        return countQuery("SELECT COUNT(*) FROM medicines WHERE quantity < min_stock");
    }

    /** Expiring in 30 days count */
    public int getExpiringCount() {
        return countQuery(
            "SELECT COUNT(*) FROM medicines WHERE expiry_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY)"
        );
    }

    /** Expired medicines count */
    public int getExpiredCount() {
        return countQuery("SELECT COUNT(*) FROM medicines WHERE expiry_date < CURDATE()");
    }

    /** Total purchase orders count */
    public int getTotalPurchaseOrders() {
        return countQuery("SELECT COUNT(*) FROM purchase_orders");
    }

    /** Total bills count */
    public int getTotalSales() {
        return countQuery("SELECT COUNT(*) FROM sales");
    }

    /**
     * Last 7 days ki daily sales — chart ke liye
     * Returns: Map<date_string, revenue>
     */
    public Map<String, BigDecimal> getLast7DaysSales() {
        Map<String, BigDecimal> data = new LinkedHashMap<>();
        String sql = "SELECT DATE(sale_date) AS sale_day, COALESCE(SUM(total_amount), 0) AS revenue " +
                     "FROM sales " +
                     "WHERE sale_date >= DATE_SUB(CURDATE(), INTERVAL 6 DAY) " +
                     "GROUP BY DATE(sale_date) " +
                     "ORDER BY sale_day ASC";
        try {
            Connection conn = DBConnection.getConnection();
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);
            while (rs.next()) {
                data.put(rs.getString("sale_day"), rs.getBigDecimal("revenue"));
            }
            rs.close(); stmt.close();
        } catch (SQLException e) {
            System.err.println("[DashboardDAO] getLast7DaysSales: " + e.getMessage());
        }
        return data;
    }

    /**
     * Category-wise medicine count — pie chart ke liye
     */
    public Map<String, Integer> getMedicinesByCategory() {
        Map<String, Integer> data = new LinkedHashMap<>();
        String sql = "SELECT c.category_name, COUNT(m.medicine_id) AS cnt " +
                     "FROM categories c " +
                     "LEFT JOIN medicines m ON c.category_id = m.category_id " +
                     "GROUP BY c.category_name ORDER BY cnt DESC";
        try {
            Connection conn = DBConnection.getConnection();
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);
            while (rs.next()) {
                data.put(rs.getString("category_name"), rs.getInt("cnt"));
            }
            rs.close(); stmt.close();
        } catch (SQLException e) {
            System.err.println("[DashboardDAO] getMedicinesByCategory: " + e.getMessage());
        }
        return data;
    }

    /** Helper - simple COUNT query */
    private int countQuery(String sql) {
        try {
            Connection conn = DBConnection.getConnection();
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);
            if (rs.next()) return rs.getInt(1);
            rs.close(); stmt.close();
        } catch (SQLException e) {
            System.err.println("[DashboardDAO] countQuery error: " + e.getMessage());
        }
        return 0;
    }
}