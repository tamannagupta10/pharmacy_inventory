package com.pharmacy.dao;

import com.pharmacy.db.DBConnection;
import com.pharmacy.model.Supplier;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * SupplierDAO.java - Updated for Day 7
 * searchSuppliers() method add kiya
 */
public class SupplierDAO {

    public List<Supplier> getAllSuppliers() {
        List<Supplier> list = new ArrayList<>();
        String sql = "SELECT * FROM suppliers ORDER BY supplier_name";
        try {
            Connection conn = DBConnection.getConnection();
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);
            while (rs.next()) list.add(mapRowToSupplier(rs));
            rs.close(); stmt.close();
        } catch (SQLException e) {
            System.err.println("[SupplierDAO] getAllSuppliers error: " + e.getMessage());
        }
        return list;
    }

    public Supplier getSupplierById(int id) {
        Supplier supplier = null;
        String sql = "SELECT * FROM suppliers WHERE supplier_id = ?";
        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) supplier = mapRowToSupplier(rs);
            rs.close(); ps.close();
        } catch (SQLException e) {
            System.err.println("[SupplierDAO] getSupplierById error: " + e.getMessage());
        }
        return supplier;
    }

    public boolean addSupplier(Supplier s) {
        String sql = "INSERT INTO suppliers (supplier_name, contact_name, phone, email, address) VALUES (?, ?, ?, ?, ?)";
        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, s.getSupplierName());
            ps.setString(2, s.getContactName());
            ps.setString(3, s.getPhone());
            ps.setString(4, s.getEmail());
            ps.setString(5, s.getAddress());
            int rows = ps.executeUpdate();
            ps.close();
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("[SupplierDAO] addSupplier error: " + e.getMessage());
            return false;
        }
    }

    public boolean updateSupplier(Supplier s) {
        String sql = "UPDATE suppliers SET supplier_name=?, contact_name=?, phone=?, email=?, address=? WHERE supplier_id=?";
        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, s.getSupplierName());
            ps.setString(2, s.getContactName());
            ps.setString(3, s.getPhone());
            ps.setString(4, s.getEmail());
            ps.setString(5, s.getAddress());
            ps.setInt(6, s.getSupplierId());
            int rows = ps.executeUpdate();
            ps.close();
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("[SupplierDAO] updateSupplier error: " + e.getMessage());
            return false;
        }
    }

    public boolean deleteSupplier(int id) {
        String sql = "DELETE FROM suppliers WHERE supplier_id = ?";
        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            int rows = ps.executeUpdate();
            ps.close();
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("[SupplierDAO] deleteSupplier error: " + e.getMessage());
            return false;
        }
    }

    /** NEW - Day 7: naam ya contact se search karta hai */
    public List<Supplier> searchSuppliers(String keyword) {
        List<Supplier> list = new ArrayList<>();
        String sql = "SELECT * FROM suppliers WHERE supplier_name LIKE ? OR contact_name LIKE ? OR phone LIKE ?";
        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            String kw = "%" + keyword + "%";
            ps.setString(1, kw);
            ps.setString(2, kw);
            ps.setString(3, kw);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRowToSupplier(rs));
            rs.close(); ps.close();
        } catch (SQLException e) {
            System.err.println("[SupplierDAO] searchSuppliers error: " + e.getMessage());
        }
        return list;
    }

    private Supplier mapRowToSupplier(ResultSet rs) throws SQLException {
        Supplier s = new Supplier();
        s.setSupplierId(rs.getInt("supplier_id"));
        s.setSupplierName(rs.getString("supplier_name"));
        s.setContactName(rs.getString("contact_name"));
        s.setPhone(rs.getString("phone"));
        s.setEmail(rs.getString("email"));
        s.setAddress(rs.getString("address"));
        return s;
    }
}