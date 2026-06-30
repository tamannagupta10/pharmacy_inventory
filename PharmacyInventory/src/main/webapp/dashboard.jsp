<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.pharmacy.model.User" %>
<%
    // Session check — agar login nahi kiya toh wapas login pe bhejo
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("loggedUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login.html");
        return;
    }

    User loggedUser = (User) userSession.getAttribute("loggedUser");
    String fullName = loggedUser.getFullName();
    String role     = loggedUser.getRole();
    String username = loggedUser.getUsername();
    String initial  = fullName.substring(0, 1).toUpperCase();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard — Pharmacy Inventory</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #eef2f7;
            min-height: 100vh;
        }

        /* ── Navbar ── */
        .navbar {
            background: #2b6cb0;
            color: #fff;
            padding: 0 2rem;
            height: 58px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: 0 2px 8px rgba(0,0,0,0.15);
        }

        .brand {
            font-size: 17px;
            font-weight: 700;
            letter-spacing: 0.3px;
        }

        .nav-right {
            display: flex;
            align-items: center;
            gap: 14px;
            font-size: 13px;
        }

        .role-badge {
            background: rgba(255,255,255,0.2);
            border: 1px solid rgba(255,255,255,0.3);
            padding: 3px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }

        .btn-logout {
            background: rgba(255,255,255,0.15);
            border: 1px solid rgba(255,255,255,0.35);
            color: #fff;
            padding: 6px 16px;
            border-radius: 7px;
            text-decoration: none;
            font-size: 13px;
            font-weight: 500;
            transition: background 0.2s;
        }

        .btn-logout:hover { background: rgba(255,255,255,0.28); }

        /* ── Container ── */
        .container {
            max-width: 1000px;
            margin: 2rem auto;
            padding: 0 1.5rem;
        }

        /* ── Welcome card ── */
        .welcome-card {
            background: #fff;
            border-radius: 14px;
            border: 1px solid #dde3ed;
            padding: 1.5rem 2rem;
            margin-bottom: 1.8rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: 0 1px 4px rgba(0,0,0,0.05);
        }

        .welcome-card h2 {
            font-size: 20px;
            color: #1a202c;
            margin-bottom: 5px;
        }

        .welcome-card p {
            font-size: 13px;
            color: #718096;
        }

        .avatar {
            width: 52px;
            height: 52px;
            border-radius: 50%;
            background: #bee3f8;
            color: #2b6cb0;
            font-size: 22px;
            font-weight: 700;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        /* ── Section label ── */
        .section-label {
            font-size: 12px;
            font-weight: 600;
            color: #a0aec0;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            margin-bottom: 12px;
        }

        /* ── Module cards ── */
        .modules-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 14px;
        }

        .module-card {
            background: #fff;
            border-radius: 14px;
            border: 1.5px solid #e2e8f0;
            padding: 1.6rem 1.2rem;
            text-align: center;
            text-decoration: none;
            color: inherit;
            transition: border-color 0.2s, box-shadow 0.2s, transform 0.15s;
            display: block;
            cursor: pointer;
        }

        .module-card:hover {
            border-color: #4299e1;
            box-shadow: 0 4px 16px rgba(66,153,225,0.15);
            transform: translateY(-3px);
        }

        .module-card .icon { font-size: 38px; margin-bottom: 12px; display: block; }
        .module-card h3 { font-size: 15px; font-weight: 600; color: #2d3748; margin-bottom: 5px; }
        .module-card p  { font-size: 12px; color: #718096; line-height: 1.5; }

        .admin-tag {
            display: inline-block;
            font-size: 10px;
            background: #fff5f5;
            color: #c53030;
            border: 1px solid #fed7d7;
            padding: 1px 6px;
            border-radius: 4px;
            margin-left: 4px;
            vertical-align: middle;
        }

        /* ── Coming soon tag ── */
        .coming { opacity: 0.55; cursor: default; }
        .coming:hover { transform: none; box-shadow: none; border-color: #e2e8f0; }
        .soon-tag {
            display: inline-block;
            font-size: 10px;
            background: #fefcbf;
            color: #744210;
            border: 1px solid #f6e05e;
            padding: 1px 6px;
            border-radius: 4px;
            margin-top: 6px;
        }
    </style>
</head>
<body>

<!-- Navbar -->
<nav class="navbar">
    <div class="brand">&#128138; Pharmacy Inventory System</div>
    <div class="nav-right">
        <span>Hello, <strong><%= fullName %></strong></span>
        <span class="role-badge"><%= role %></span>
        <a href="<%= request.getContextPath() %>/logout" class="btn-logout">&#128682; Logout</a>
    </div>
</nav>

<!-- Main -->
<div class="container">

    <!-- Welcome -->
    <div class="welcome-card">
        <div>
            <h2>&#128075; Welcome, <%= fullName %>!</h2>
            <p>Username: <strong><%= username %></strong> &nbsp;|&nbsp; Role: <strong><%= role %></strong></p>
        </div>
        <div class="avatar"><%= initial %></div>
    </div>

    <!-- Modules -->
    <div class="section-label">Modules</div>
    <div class="modules-grid">

        <a href="<%= request.getContextPath() %>/medicine" class="module-card">
    <span class="icon">&#128138;</span>
    <h3>Medicines</h3>
    <p>Check Stock, add or edit</p>
</a>

        <a href="<%= request.getContextPath() %>/supplier" class="module-card">
    <span class="icon">&#128666;</span>
    <h3>Suppliers</h3>
    <p>Manage Suppliers and Purchase Orders</p>
</a>

        <a href="#" class="module-card coming">
            <span class="icon">&#128179;</span>
            <h3>Sales & Billing</h3>
            <p>Make bill and Check Sales History</p>
            <div class="soon-tag"></div>
        </a>

        <a href="#" class="module-card coming">
            <span class="icon">&#9888;</span>
            <h3>Alerts</h3>
            <p>Low stock and Expiry Warnings</p>
            <div class="soon-tag"></div>
        </a>

        <% if ("ADMIN".equals(role)) { %>
        <a href="#" class="module-card coming">
            <span class="icon">&#128101;</span>
            <h3>Users <span class="admin-tag">Admin Only</span></h3>
            <p>Manage Pharmacist Account</p>
            <div class="soon-tag"></div>
        </a>
        <% } %>

    </div>

</div>
</body>
</html>
