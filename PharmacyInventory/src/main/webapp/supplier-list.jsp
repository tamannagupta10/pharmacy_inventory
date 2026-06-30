<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.pharmacy.model.User" %>
<%@ page import="com.pharmacy.model.Supplier" %>
<%@ page import="java.util.List" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("loggedUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login.html");
        return;
    }
    User loggedUser = (User) userSession.getAttribute("loggedUser");
    String role = loggedUser.getRole();

    List<Supplier> suppliers = (List<Supplier>) request.getAttribute("suppliers");
    String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Suppliers — Pharmacy Inventory</title>
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
        .btn-purchase {
            background: #6b46c1; color: #fff; padding: 9px 18px; border-radius: 8px;
            text-decoration: none; font-size: 13px; font-weight: 600; margin-left: 8px;
        }

        .alert {
            padding: 10px 16px; border-radius: 8px; font-size: 13px; margin-bottom: 1rem;
        }
        .alert.success { background: #f0fff4; color: #276749; border: 1px solid #c6f6d5; }

        table {
            width: 100%; border-collapse: collapse; background: #fff;
            border-radius: 12px; overflow: hidden; border: 1px solid #dde3ed;
        }
        thead { background: #f7fafc; }
        th { text-align: left; padding: 12px 14px; font-size: 12px; color: #718096; text-transform: uppercase; }
        td { padding: 12px 14px; font-size: 13px; color: #2d3748; border-top: 1px solid #edf2f7; }

        .actions a {
            font-size: 12px; text-decoration: none; padding: 4px 10px; border-radius: 6px; margin-right: 6px;
        }
        .edit-link   { background: #ebf8ff; color: #2b6cb0; }
        .delete-link { background: #fff5f5; color: #c53030; }

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
        <h2>🚚 All Suppliers (<%= suppliers != null ? suppliers.size() : 0 %>)</h2>
        <div>
            <a href="supplier?action=add" class="btn-add">+ Add Supplier</a>
            <a href="<%= request.getContextPath() %>/purchase" class="btn-purchase">📦 Purchase Orders</a>
        </div>
    </div>

    <% if ("added".equals(msg)) { %>
        <div class="alert success">✅ Supplier added successfully!</div>
    <% } else if ("updated".equals(msg)) { %>
        <div class="alert success">✅ Supplier updated successfully!</div>
    <% } else if ("deleted".equals(msg)) { %>
        <div class="alert success">🗑️ Supplier deleted successfully!</div>
    <% } %>

    <% if (suppliers == null || suppliers.isEmpty()) { %>
        <div class="empty-state">No suppliers found. Click "Add Supplier" to get started.</div>
    <% } else { %>
    <table>
        <thead>
            <tr>
                <th>Supplier Name</th>
                <th>Contact Person</th>
                <th>Phone</th>
                <th>Email</th>
                <th>Address</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <% for (Supplier s : suppliers) { %>
            <tr>
                <td><%= s.getSupplierName() %></td>
                <td><%= s.getContactName() %></td>
                <td><%= s.getPhone() %></td>
                <td><%= s.getEmail() %></td>
                <td><%= s.getAddress() %></td>
                <td class="actions">
                    <a href="supplier?action=edit&id=<%= s.getSupplierId() %>" class="edit-link">Edit</a>
                    <% if ("ADMIN".equals(role)) { %>
                    <a href="supplier?action=delete&id=<%= s.getSupplierId() %>" class="delete-link"
                       onclick="return confirm('Are you sure you want to delete this supplier?')">Delete</a>
                    <% } %>
                </td>
            </tr>
            <% } %>
        </tbody>
    </table>
    <% } %>

</div>
</body>
</html>
