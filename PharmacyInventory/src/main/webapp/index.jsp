<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pharmacy Inventory System</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f0f4f8;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }

        .card {
            background: #ffffff;
            border-radius: 12px;
            border: 1px solid #e2e8f0;
            padding: 3rem 2.5rem;
            text-align: center;
            max-width: 420px;
            width: 90%;
        }

        .icon {
            font-size: 56px;
            margin-bottom: 1rem;
        }

        h1 {
            font-size: 22px;
            font-weight: 600;
            color: #1a202c;
            margin-bottom: 0.5rem;
        }

        p {
            font-size: 14px;
            color: #718096;
            margin-bottom: 2rem;
            line-height: 1.6;
        }

        .btn {
            display: inline-block;
            padding: 10px 28px;
            background: #2b6cb0;
            color: #ffffff;
            text-decoration: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 500;
            transition: background 0.2s;
        }

        .btn:hover { background: #2c5282; }

        .status {
            margin-top: 1.5rem;
            padding: 10px 16px;
            border-radius: 8px;
            font-size: 13px;
        }

        .status.ok  { background: #f0fff4; color: #276749; border: 1px solid #c6f6d5; }
        .status.err { background: #fff5f5; color: #c53030; border: 1px solid #fed7d7; }
    </style>
</head>
<body>
<div class="card">
    <div class="icon">&#128138;</div>
    <h1>Pharmacy Inventory System</h1>
    <p>Manage medicines, suppliers, stock levels, billing, and expiry alerts — all in one place.</p>
    <a href="login.html" class="btn">Go to Login</a>

    <%-- Day 1 DB connection test --%>
    <%
        String dbStatus = "";
        String dbClass  = "";
        try {
            java.sql.Connection conn = com.pharmacy.db.DBConnection.getConnection();
            if (conn != null && !conn.isClosed()) {
                dbStatus = "Database connected successfully";
                dbClass  = "ok";
            }
        } catch (Exception e) {
            dbStatus = "DB connection failed: " + e.getMessage();
            dbClass  = "err";
        }
    %>
    <div class="status <%= dbClass %>"><%= dbStatus %></div>
</div>
</body>
</html>
