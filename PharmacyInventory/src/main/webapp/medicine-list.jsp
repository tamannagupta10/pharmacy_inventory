<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.pharmacy.model.User" %>
<%@ page import="com.pharmacy.model.Medicine" %>
<%@ page import="java.util.List" %>
<%
    // Session check
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("loggedUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login.html");
        return;
    }
    User loggedUser = (User) userSession.getAttribute("loggedUser");
    String role = loggedUser.getRole();

    List<Medicine> medicines = (List<Medicine>) request.getAttribute("medicines");
    String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Medicines — Pharmacy Inventory</title>
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

        .container { max-width: 1200px; margin: 2rem auto; padding: 0 1.5rem; }

        .top-bar {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 1.2rem; flex-wrap: wrap; gap: 10px;
        }
        .top-bar h2 { font-size: 20px; color: #1a202c; }

        .btn-add {
            background: #2f855a; color: #fff; padding: 9px 18px; border-radius: 8px;
            text-decoration: none; font-size: 13px; font-weight: 600;
        }

        .search-box {
            display: flex; gap: 8px; margin-bottom: 1rem;
        }
        .search-box input {
            flex: 1; padding: 9px 14px; border: 1.5px solid #e2e8f0; border-radius: 8px; font-size: 13px;
        }
        .search-box button {
            padding: 9px 18px; background: #4299e1; color: #fff; border: none; border-radius: 8px;
            font-size: 13px; cursor: pointer;
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

        .badge-low { background: #fff5f5; color: #c53030; padding: 2px 8px; border-radius: 12px; font-size: 11px; font-weight: 600; }
        .badge-ok  { background: #f0fff4; color: #276749; padding: 2px 8px; border-radius: 12px; font-size: 11px; font-weight: 600; }

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
        <h2>🗂 All Medicines (<%= medicines != null ? medicines.size() : 0 %>)</h2>
        <a href="medicine?action=add" class="btn-add">+ Add New Medicine</a>
    </div>

    <% if ("added".equals(msg)) { %>
        <div class="alert success">✅ Medicine added successfully!</div>
    <% } else if ("updated".equals(msg)) { %>
        <div class="alert success">✅ Medicine updated successfully!</div>
    <% } else if ("deleted".equals(msg)) { %>
        <div class="alert success">🗑️ Medicine deleted successfully!</div>
    <% } %>

    <form class="search-box" action="medicine" method="get">
        <input type="hidden" name="action" value="search" />
        <input type="text" name="keyword" placeholder="Search by medicine name or brand..." />
        <button type="submit">🔍 Search</button>
    </form>

    <% if (medicines == null || medicines.isEmpty()) { %>
        <div class="empty-state">No medicines found. Click "Add New Medicine" to get started.</div>
    <% } else { %>
    <table>
        <thead>
            <tr>
                <th>Name</th>
                <th>Brand</th>
                <th>Category</th>
                <th>Qty</th>
                <th>Price</th>
                <th>Expiry</th>
                <th>Stock Status</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <% for (Medicine m : medicines) { %>
            <tr>
                <td><%= m.getMedicineName() %></td>
                <td><%= m.getBrandName() %></td>
                <td><%= m.getCategoryName() != null ? m.getCategoryName() : "-" %></td>
                <td><%= m.getQuantity() %></td>
                <td>₹<%= m.getUnitPrice() %></td>
                <td><%= m.getExpiryDate() %></td>
                <td>
                    <% if (m.isLowStock()) { %>
                        <span class="badge-low">Low Stock</span>
                    <% } else { %>
                        <span class="badge-ok">In Stock</span>
                    <% } %>
                </td>
                <td class="actions">
                    <a href="medicine?action=edit&id=<%= m.getMedicineId() %>" class="edit-link">Edit</a>
                    <% if ("ADMIN".equals(role)) { %>
                    <a href="medicine?action=delete&id=<%= m.getMedicineId() %>" class="delete-link"
                       onclick="return confirm('Are you sure you want to delete this medicine?')">Delete</a>
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
