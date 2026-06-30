package com.pharmacy.dao;

import com.pharmacy.db.DBConnection;
import com.pharmacy.model.PurchaseOrder;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * PurchaseDAO.java - Database operations for Purchase Orders
 * IMPORTANT: createPurchaseOrder() ek TRANSACTION use karta hai
 * taaki "purchase record save karna" aur "medicine stock badhana"
 * dono ek saath successful hon, ya dono fail hon (partial update kabhi nahi)
 */
public class PurchaseDAO {

    /**
     * Purchase order create karta hai AUR medicine ka stock automatically badhata hai.
     * Yeh ek hi database transaction mein hota hai (safe & atomic).
     */
    public boolean createPurchaseOrder(PurchaseOrder po) {
        Connection conn = null;

        String insertOrderSql =
            "INSERT INTO purchase_orders (supplier_id, medicine_id, quantity, unit_cost) " +
            "VALUES (?, ?, ?, ?)";

        String updateStockSql =
            "UPDATE medicines SET quantity = quantity + ? WHERE medicine_id = ?";

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Transaction shuru -- manual commit control

            // Step 1 - Purchase order insert karo
            PreparedStatement psOrder = conn.prepareStatement(insertOrderSql);
            psOrder.setInt(1, po.getSupplierId());
            psOrder.setInt(2, po.getMedicineId());
            psOrder.setInt(3, po.getQuantity());
            psOrder.setBigDecimal(4, po.getUnitCost());
            psOrder.executeUpdate();
            psOrder.close();

            // Step 2 - Medicine ka stock badhao
            PreparedStatement psStock = conn.prepareStatement(updateStockSql);
            psStock.setInt(1, po.getQuantity());
            psStock.setInt(2, po.getMedicineId());
            psStock.executeUpdate();
            psStock.close();

            // Step 3 - Dono operations successful → commit karo (permanent save)
            conn.commit();
            return true;

        } catch (SQLException e) {
            System.err.println("[PurchaseDAO] createPurchaseOrder error: " + e.getMessage());
            try {
                // Kuch fail hua → rollback karo (sab undo, half-done na rahe)
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                System.err.println("[PurchaseDAO] Rollback error: " + ex.getMessage());
            }
            return false;

        } finally {
            try {
                if (conn != null) conn.setAutoCommit(true); // wapas normal mode
            } catch (SQLException e) {
                System.err.println("[PurchaseDAO] setAutoCommit reset error: " + e.getMessage());
            }
        }
    }

    /**
     * Sab purchase orders ki history laata hai (supplier + medicine naam ke saath)
     */
    public List<PurchaseOrder> getAllPurchaseOrders() {
        List<PurchaseOrder> list = new ArrayList<>();

        String sql = "SELECT po.*, s.supplier_name, m.medicine_name " +
                     "FROM purchase_orders po " +
                     "JOIN suppliers s ON po.supplier_id = s.supplier_id " +
                     "JOIN medicines m ON po.medicine_id = m.medicine_id " +
                     "ORDER BY po.order_date DESC";

        try {
            Connection conn = DBConnection.getConnection();
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);

            while (rs.next()) {
                PurchaseOrder po = new PurchaseOrder();
                po.setOrderId(rs.getInt("order_id"));
                po.setSupplierId(rs.getInt("supplier_id"));
                po.setSupplierName(rs.getString("supplier_name"));
                po.setMedicineId(rs.getInt("medicine_id"));
                po.setMedicineName(rs.getString("medicine_name"));
                po.setQuantity(rs.getInt("quantity"));
                po.setUnitCost(rs.getBigDecimal("unit_cost"));
                po.setTotalCost(rs.getBigDecimal("total_cost"));
                po.setOrderDate(rs.getTimestamp("order_date"));
                list.add(po);
            }

            rs.close();
            stmt.close();
        } catch (SQLException e) {
            System.err.println("[PurchaseDAO] getAllPurchaseOrders error: " + e.getMessage());
        }

        return list;
    }
}