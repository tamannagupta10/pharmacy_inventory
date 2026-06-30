package com.pharmacy.dao;

import com.pharmacy.db.DBConnection;
import com.pharmacy.model.Medicine;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * MedicineDAO.java - Database operations for Medicine
 * CRUD methods: Create, Read, Update, Delete
 */
public class MedicineDAO {

    /**
     * Sab medicines laata hai (category + supplier naam ke saath JOIN se)
     */
    public List<Medicine> getAllMedicines() {
        List<Medicine> list = new ArrayList<>();

        String sql = "SELECT m.*, c.category_name, s.supplier_name " +
                     "FROM medicines m " +
                     "LEFT JOIN categories c ON m.category_id = c.category_id " +
                     "LEFT JOIN suppliers s ON m.supplier_id = s.supplier_id " +
                     "ORDER BY m.medicine_id DESC";

        try {
            Connection conn = DBConnection.getConnection();
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);

            while (rs.next()) {
                list.add(mapRowToMedicine(rs));
            }

            rs.close();
            stmt.close();

        } catch (SQLException e) {
            System.err.println("[MedicineDAO] getAllMedicines error: " + e.getMessage());
        }

        return list;
    }

    /**
     * ID se ek medicine laata hai (edit form ke liye)
     */
    public Medicine getMedicineById(int id) {
        Medicine medicine = null;

        String sql = "SELECT m.*, c.category_name, s.supplier_name " +
                     "FROM medicines m " +
                     "LEFT JOIN categories c ON m.category_id = c.category_id " +
                     "LEFT JOIN suppliers s ON m.supplier_id = s.supplier_id " +
                     "WHERE m.medicine_id = ?";

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                medicine = mapRowToMedicine(rs);
            }

            rs.close();
            ps.close();

        } catch (SQLException e) {
            System.err.println("[MedicineDAO] getMedicineById error: " + e.getMessage());
        }

        return medicine;
    }

    /**
     * Naya medicine add karta hai
     */
    public boolean addMedicine(Medicine m) {
        String sql = "INSERT INTO medicines " +
                     "(medicine_name, brand_name, category_id, supplier_id, quantity, min_stock, unit_price, expiry_date, manufacture_date, description) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setString(1, m.getMedicineName());
            ps.setString(2, m.getBrandName());
            ps.setInt(3, m.getCategoryId());
            ps.setInt(4, m.getSupplierId());
            ps.setInt(5, m.getQuantity());
            ps.setInt(6, m.getMinStock());
            ps.setBigDecimal(7, m.getUnitPrice());
            ps.setDate(8, m.getExpiryDate());
            ps.setDate(9, m.getManufactureDate());
            ps.setString(10, m.getDescription());

            int rows = ps.executeUpdate();
            ps.close();

            return rows > 0;

        } catch (SQLException e) {
            System.err.println("[MedicineDAO] addMedicine error: " + e.getMessage());
            return false;
        }
    }

    /**
     * Existing medicine update karta hai
     */
    public boolean updateMedicine(Medicine m) {
        String sql = "UPDATE medicines SET medicine_name=?, brand_name=?, category_id=?, supplier_id=?, " +
                     "quantity=?, min_stock=?, unit_price=?, expiry_date=?, manufacture_date=?, description=? " +
                     "WHERE medicine_id=?";

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setString(1, m.getMedicineName());
            ps.setString(2, m.getBrandName());
            ps.setInt(3, m.getCategoryId());
            ps.setInt(4, m.getSupplierId());
            ps.setInt(5, m.getQuantity());
            ps.setInt(6, m.getMinStock());
            ps.setBigDecimal(7, m.getUnitPrice());
            ps.setDate(8, m.getExpiryDate());
            ps.setDate(9, m.getManufactureDate());
            ps.setString(10, m.getDescription());
            ps.setInt(11, m.getMedicineId());

            int rows = ps.executeUpdate();
            ps.close();

            return rows > 0;

        } catch (SQLException e) {
            System.err.println("[MedicineDAO] updateMedicine error: " + e.getMessage());
            return false;
        }
    }

    /**
     * Medicine delete karta hai
     */
    public boolean deleteMedicine(int id) {
        String sql = "DELETE FROM medicines WHERE medicine_id = ?";

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);

            int rows = ps.executeUpdate();
            ps.close();

            return rows > 0;

        } catch (SQLException e) {
            System.err.println("[MedicineDAO] deleteMedicine error: " + e.getMessage());
            return false;
        }
    }

    /**
     * Naam se medicines search karta hai
     */
    public List<Medicine> searchMedicines(String keyword) {
        List<Medicine> list = new ArrayList<>();

        String sql = "SELECT m.*, c.category_name, s.supplier_name " +
                     "FROM medicines m " +
                     "LEFT JOIN categories c ON m.category_id = c.category_id " +
                     "LEFT JOIN suppliers s ON m.supplier_id = s.supplier_id " +
                     "WHERE m.medicine_name LIKE ? OR m.brand_name LIKE ? " +
                     "ORDER BY m.medicine_name";

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, "%" + keyword + "%");
            ps.setString(2, "%" + keyword + "%");

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRowToMedicine(rs));
            }

            rs.close();
            ps.close();

        } catch (SQLException e) {
            System.err.println("[MedicineDAO] searchMedicines error: " + e.getMessage());
        }

        return list;
    }

    /**
     * Helper method - ResultSet row ko Medicine object mein convert karta hai
     * (Repeat code avoid karne ke liye)
     */
    private Medicine mapRowToMedicine(ResultSet rs) throws SQLException {
        Medicine m = new Medicine();
        m.setMedicineId(rs.getInt("medicine_id"));
        m.setMedicineName(rs.getString("medicine_name"));
        m.setBrandName(rs.getString("brand_name"));
        m.setCategoryId(rs.getInt("category_id"));
        m.setCategoryName(rs.getString("category_name"));
        m.setSupplierId(rs.getInt("supplier_id"));
        m.setSupplierName(rs.getString("supplier_name"));
        m.setQuantity(rs.getInt("quantity"));
        m.setMinStock(rs.getInt("min_stock"));
        m.setUnitPrice(rs.getBigDecimal("unit_price"));
        m.setExpiryDate(rs.getDate("expiry_date"));
        m.setManufactureDate(rs.getDate("manufacture_date"));
        m.setDescription(rs.getString("description"));
        return m;
    }
}