<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.pharmacy.model.User" %>
<%@ page import="com.pharmacy.model.Sale" %>
<%@ page import="java.util.List" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("loggedUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login.html");
        return;
    }
    User loggedUser = (User) userSession.getAttribute("loggedUser");

    List<Sale> sales = (List<Sale>) request.getAttribute("sales");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sales History — Pharmacy Inventory</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Verdana, sans-serif; background: #eef2f7; }

        .navbar {
            background: #2b6cb0; color: #fff; padding: 0 2rem; height: 56px;
            display: flex; align-items: center; justify-content: space-between;
        }
        .brand { font-size: 16px; font-weight: 700; }
        .nav-right { display: flex; align-items: center; gap: 14px; font-size: 13px; }
        .btn-logout, .btn-back {
            background: rgba(255,255,255,0.15); border: 1px solid rgba(255,255,255,0.35);
            color: #fff; padding: 5px 14px; border-radius: 6px; text-decoration: none; font-size: 13px;
        }

        .container { max-width: 1100px; margin: 2rem auto; padding: 0 1.5rem; }

        .top-bar {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 1.2rem; flex-wrap: wrap; gap: 10px;
        }
        .top-bar h2 { font-size: 20px; color: #1a202c; }

        .btn-add {
            background: #2f855a; color: #fff; padding: 9px 18px; border-radius: 8px;
            text-decoration: none; font-size: 13px; font-weight: 600;
        }

        .summary-cards { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 12px; margin-bottom: 1.5rem; }
        .summary-card { background: #fff; border-radius: 12px; border: 1px solid #dde3ed; padding: 1.2rem; }
        .summary-card .label { font-size: 12px; color: #718096; margin-bottom: 6px; }
        .summary-card .value { font-size: 22px; font-weight: 700; color: #1a202c; }

        table {
            width: 100%; border-collapse: collapse; background: #fff;
            border-radius: 12px; overflow: hidden; border: 1px solid #dde3ed;
        }
        thead { background: #f7fafc; }
        th { text-align: left; padding: 12px 14px; font-size: 12px; color: #718096; text-transform: uppercase; }
        td { padding: 12px 14px; font-size: 13px; color: #2d3748; border-top: 1px solid #edf2f7; }

        .view-link {
            font-size: 12px; text-decoration: none; padding: 4px 12px; border-radius: 6px;
            background: #ebf8ff; color: #2b6cb0;
        }

        .empty-state { text-align: center; padding: 3rem; color: #a0aec0; }
    </style>
</head>
<body>

<nav class="navbar">
    <div class="brand">💊 Pharmacy Inventory System</div>
    <div class="nav-right">
        <a href="<%= request.getContextPath() %>/dashboard.jsp" class="btn-back">← Dashboard</a>
        <span>Hello, <strong><%= loggedUser.getFullName() %></strong></span>
        <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Logout</a>
    </div>
</nav>

<div class="container">

    <div class="top-bar">
        <h2>💳 Sales History (<%= sales != null ? sales.size() : 0 %>)</h2>
        <a href="sales?action=add" class="btn-add">+ Create New Bill</a>
    </div>

    <%
        // Quick summary calculate karo
        java.math.BigDecimal totalRevenue = java.math.BigDecimal.ZERO;
        if (sales != null) {
            for (Sale s : sales) {
                totalRevenue = totalRevenue.add(s.getTotalAmount());
            }
        }
    %>

    <div class="summary-cards">
        <div class="summary-card">
            <div class="label">Total Bills</div>
            <div class="value"><%= sales != null ? sales.size() : 0 %></div>
        </div>
        <div class="summary-card">
            <div class="label">Total Revenue</div>
            <div class="value">₹<%= totalRevenue %></div>
        </div>
    </div>

    <% if (sales == null || sales.isEmpty()) { %>
        <div class="empty-state">No sales yet. Click "Create New Bill" to make your first sale.</div>
    <% } else { %>
    <table>
        <thead>
            <tr>
                <th>Bill #</th>
                <th>Customer</th>
                <th>Total Amount</th>
                <th>Sold By</th>
                <th>Date</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            <% for (Sale s : sales) { %>
            <tr>
                <td>#<%= s.getSaleId() %></td>
                <td><%= s.getCustomerName() %></td>
                <td><strong>₹<%= s.getTotalAmount() %></strong></td>
                <td><%= s.getSoldByName() %></td>
                <td><%= s.getSaleDate() %></td>
                <td><a href="sales?action=view&id=<%= s.getSaleId() %>" class="view-link">View Receipt</a></td>
            </tr>
            <% } %>
        </tbody>
    </table>
    <% } %>

</div>
</body>
</html>
