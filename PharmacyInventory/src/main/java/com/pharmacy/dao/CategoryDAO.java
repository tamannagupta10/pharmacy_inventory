package com.pharmacy.dao;

import com.pharmacy.db.DBConnection;
import com.pharmacy.model.Category;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/** CategoryDAO.java - Dropdown list ke liye categories laata hai */
public class CategoryDAO {

    public List<Category> getAllCategories() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT * FROM categories ORDER BY category_name";

        try {
            Connection conn = DBConnection.getConnection();
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);

            while (rs.next()) {
                list.add(new Category(rs.getInt("category_id"), rs.getString("category_name")));
            }

            rs.close();
            stmt.close();
        } catch (SQLException e) {
            System.err.println("[CategoryDAO] error: " + e.getMessage());
        }

        return list;
    }
}