package com.pharmacy.dao;

import com.pharmacy.db.DBConnection;
import com.pharmacy.model.User;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;


public class UserDAO {

    
    public User validateLogin(String username, String password) {
        User user = null;

        String sql = "SELECT * FROM users WHERE username = ? AND password = ? AND is_active = 1";

        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, password);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                
                user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setFullName(rs.getString("full_name"));
                user.setUsername(rs.getString("username"));
                user.setPassword(rs.getString("password"));
                user.setRole(rs.getString("role"));
                user.setEmail(rs.getString("email"));
                user.setPhone(rs.getString("phone"));
                user.setActive(rs.getBoolean("is_active"));
            }

            rs.close();
            ps.close();

        } catch (SQLException e) {
            System.err.println("[UserDAO] Login error: " + e.getMessage());
        }

        return user; 
    }
}
