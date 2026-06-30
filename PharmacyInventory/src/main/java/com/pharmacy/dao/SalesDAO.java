package com.pharmacy.dao;

import com.pharmacy.db.DBConnection;
import com.pharmacy.model.Sale;
import com.pharmacy.model.SaleItem;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * SalesDAO.java - Database operations for Sales/Billing
 * IMPORTANT: createSale() ek TRANSACTION use karta hai:
 *   1. Stock check karta hai (kya itni quantity available hai?)
 *   2. sales table mein bill insert karta hai
 *   3. sale_items table mein har medicine ki line insert karta hai
 *   4. medicines table se stock deduct karta hai
 * Agar koi bhi step fail ho (jaise stock kam hai), sab rollback ho jaata hai
 */
public class SalesDAO {

    /**
     * Naya bill banata hai (Sale object mein customerName aur items list honi chahiye)
     * Returns: error message ho toh String, success ho toh null
     */
    public String createSale(Sale sale) {
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Transaction shuru

            // STEP 1 - Har item ke liye stock check karo
            for (SaleItem item : sale.getItems()) {
                String checkSql = "SELECT quantity, medicine_name FROM medicines WHERE medicine_id = ?";
                PreparedStatement psCheck = conn.prepareStatement(checkSql);
                psCheck.setInt(1, item.getMedicineId());
                ResultSet rs = psCheck.executeQuery();

                if (rs.next()) {
                    int available = rs.getInt("quantity");
                    String medName = rs.getString("medicine_name");
                    if (available < item.getQuantity()) {
                        conn.rollback();
                        return "Insufficient stock for " + medName + ". Available: " + available;
                    }
                }
                rs.close();
                psCheck.close();
            }

            // STEP 2 - sales table mein bill ka header insert karo
            String insertSaleSql =
                "INSERT INTO sales (customer_name, total_amount, sold_by) VALUES (?, ?, ?)";
            PreparedStatement psSale = conn.prepareStatement(insertSaleSql, Statement.RETURN_GENERATED_KEYS);
            psSale.setString(1, sale.getCustomerName());
            psSale.setBigDecimal(2, sale.getTotalAmount());
            psSale.setInt(3, sale.getSoldBy());
            psSale.executeUpdate();

            // Naya generated sale_id nikalo (taaki sale_items mein use kar sakein)
            ResultSet keys = psSale.getGeneratedKeys();
            int newSaleId = 0;
            if (keys.next()) {
                newSaleId = keys.getInt(1);
            }
            keys.close();
            psSale.close();

            // STEP 3 - Har medicine ki line item insert karo AUR stock deduct karo
            String insertItemSql =
                "INSERT INTO sale_items (sale_id, medicine_id, quantity, unit_price) VALUES (?, ?, ?, ?)";
            String deductStockSql =
                "UPDATE medicines SET quantity = quantity - ? WHERE medicine_id = ?";

            for (SaleItem item : sale.getItems()) {
                // Item insert karo
                PreparedStatement psItem = conn.prepareStatement(insertItemSql);
                psItem.setInt(1, newSaleId);
                psItem.setInt(2, item.getMedicineId());
                psItem.setInt(3, item.getQuantity());
                psItem.setBigDecimal(4, item.getUnitPrice());
                psItem.executeUpdate();
                psItem.close();

                // Stock kam karo
                PreparedStatement psDeduct = conn.prepareStatement(deductStockSql);
                psDeduct.setInt(1, item.getQuantity());
                psDeduct.setInt(2, item.getMedicineId());
                psDeduct.executeUpdate();
                psDeduct.close();
            }

            // STEP 4 - Sab kuch successful → commit karo
            conn.commit();
            sale.setSaleId(newSaleId);
            return null; // null = no error = success

        } catch (SQLException e) {
            System.err.println("[SalesDAO] createSale error: " + e.getMessage());
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                System.err.println("[SalesDAO] Rollback error: " + ex.getMessage());
            }
            return "Database error: " + e.getMessage();

        } finally {
            try {
                if (conn != null) conn.setAutoCommit(true);
            } catch (SQLException e) {
                System.err.println("[SalesDAO] setAutoCommit reset error: " + e.getMessage());
            }
        }
    }

    /** Sab bills ki history laata hai (user naam ke saath) */
    public List<Sale> getAllSales() {
        List<Sale> list = new ArrayList<>();

        String sql = "SELECT s.*, u.full_name AS sold_by_name " +
                     "FROM sales s " +
                     "LEFT JOIN users u ON s.sold_by = u.user_id " +
                     "ORDER BY s.sale_date DESC";

        try {
            Connection conn = DBConnection.getConnection();
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);

            while (rs.next()) {
                Sale sale = new Sale();
                sale.setSaleId(rs.getInt("sale_id"));
                sale.setCustomerName(rs.getString("customer_name"));
                sale.setTotalAmount(rs.getBigDecimal("total_amount"));
                sale.setSoldBy(rs.getInt("sold_by"));
                sale.setSoldByName(rs.getString("sold_by_name"));
                sale.setSaleDate(rs.getTimestamp("sale_date"));
                list.add(sale);
            }

            rs.close();
            stmt.close();
        } catch (SQLException e) {
            System.err.println("[SalesDAO] getAllSales error: " + e.getMessage());
        }

        return list;
    }

    /** Ek bill ki poori detail laata hai (receipt dikhane ke liye, items ke saath) */
    public Sale getSaleById(int saleId) {
        Sale sale = null;

        String saleSql = "SELECT s.*, u.full_name AS sold_by_name " +
                          "FROM sales s LEFT JOIN users u ON s.sold_by = u.user_id " +
                          "WHERE s.sale_id = ?";

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(saleSql);
            ps.setInt(1, saleId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                sale = new Sale();
                sale.setSaleId(rs.getInt("sale_id"));
                sale.setCustomerName(rs.getString("customer_name"));
                sale.setTotalAmount(rs.getBigDecimal("total_amount"));
                sale.setSoldBy(rs.getInt("sold_by"));
                sale.setSoldByName(rs.getString("sold_by_name"));
                sale.setSaleDate(rs.getTimestamp("sale_date"));

                // Ab is sale ke items laao
                sale.setItems(getItemsBySaleId(saleId));
            }

            rs.close();
            ps.close();
        } catch (SQLException e) {
            System.err.println("[SalesDAO] getSaleById error: " + e.getMessage());
        }

        return sale;
    }

    /** Helper - ek sale ke saare items laata hai */
    private List<SaleItem> getItemsBySaleId(int saleId) {
        List<SaleItem> items = new ArrayList<>();

        String sql = "SELECT si.*, m.medicine_name " +
                     "FROM sale_items si " +
                     "JOIN medicines m ON si.medicine_id = m.medicine_id " +
                     "WHERE si.sale_id = ?";

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, saleId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                SaleItem item = new SaleItem();
                item.setItemId(rs.getInt("item_id"));
                item.setSaleId(rs.getInt("sale_id"));
                item.setMedicineId(rs.getInt("medicine_id"));
                item.setMedicineName(rs.getString("medicine_name"));
                item.setQuantity(rs.getInt("quantity"));
                item.setUnitPrice(rs.getBigDecimal("unit_price"));
                item.setSubtotal(rs.getBigDecimal("subtotal"));
                items.add(item);
            }

            rs.close();
            ps.close();
        } catch (SQLException e) {
            System.err.println("[SalesDAO] getItemsBySaleId error: " + e.getMessage());
        }

        return items;
    }
}