<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.pharmacy.model.User" %>
<%@ page import="com.pharmacy.model.Medicine" %>
<%@ page import="com.pharmacy.model.Supplier" %>
<%@ page import="java.util.List" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("loggedUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login.html");
        return;
    }
    User loggedUser = (User) userSession.getAttribute("loggedUser");

    String keyword      = (String) request.getAttribute("keyword");
    List<Medicine> medicines = (List<Medicine>) request.getAttribute("medicines");
    List<Supplier> suppliers = (List<Supplier>) request.getAttribute("suppliers");
    Integer totalResults = (Integer) request.getAttribute("totalResults");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Search Results — Pharmacy Inventory</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Verdana, sans-serif; background: #eef2f7; }
        .navbar {
            background: #2b6cb0; color: #fff; padding: 0 2rem; height: 56px;
            display: flex; align-items: center; justify-content: space-between;
        }
        .brand { font-size: 16px; font-weight: 700; }
        .nav-right { display: flex; align-items: center; gap: 12px; }
        .btn-back {
            background: rgba(255,255,255,0.15); border: 1px solid rgba(255,255,255,0.35);
            color: #fff; padding: 5px 14px; border-radius: 6px; text-decoration: none; font-size: 13px;
        }
        .search-form {
            display: flex; background: rgba(255,255,255,0.18); border: 1px solid rgba(255,255,255,0.3);
            border-radius: 8px; overflow: hidden;
        }
        .search-form input {
            background: transparent; border: none; outline: none; color: #fff;
            padding: 6px 12px; font-size: 13px; width: 220px;
        }
        .search-form input::placeholder { color: rgba(255,255,255,0.7); }
        .search-form button {
            background: rgba(255,255,255,0.2); border: none; color: #fff; padding: 6px 12px; cursor: pointer;
        }

        .container { max-width: 1000px; margin: 2rem auto; padding: 0 1.5rem; }
        .result-title { font-size: 18px; color: #1a202c; margin-bottom: 1.5rem; }
        .result-title span { color: #4299e1; }

        .section { margin-bottom: 1.8rem; }
        .section h3 { font-size: 14px; font-weight: 600; color: #718096; margin-bottom: 10px; text-transform: uppercase; letter-spacing: 0.05em; }

        table { width: 100%; border-collapse: collapse; background: #fff; border-radius: 12px; overflow: hidden; border: 1px solid #dde3ed; }
        th { text-align: left; padding: 10px 14px; font-size: 11px; color: #718096; text-transform: uppercase; background: #f7fafc; }
        td { padding: 10px 14px; font-size: 13px; color: #2d3748; border-top: 1px solid #edf2f7; }

        .link { font-size: 12px; color: #4299e1; text-decoration: none; }
        .badge-low { background: #fff5f5; color: #c53030; padding: 2px 8px; border-radius: 10px; font-size: 11px; }
        .badge-ok  { background: #f0fff4; color: #276749; padding: 2px 8px; border-radius: 10px; font-size: 11px; }

        .empty-state { text-align: center; padding: 3rem; color: #a0aec0; font-size: 14px; }
        .no-results {
            background: #fff; border-radius: 12px; border: 1px solid #dde3ed;
            padding: 3rem; text-align: center; color: #a0aec0;
        }
        .no-results h3 { font-size: 16px; margin-bottom: 8px; color: #4a5568; }
    </style>
</head>
<body>

<nav class="navbar">
    <div class="brand">💊 Pharmacy Inventory</div>
    <form class="search-form" action="<%= request.getContextPath() %>/search" method="get">
        <input type="text" name="q" value="<%= keyword != null ? keyword : "" %>" placeholder="Search again..." />
        <button type="submit">🔍</button>
    </form>
    <div class="nav-right">
        <a href="<%= request.getContextPath() %>/dashboard" class="btn-back">← Dashboard</a>
    </div>
</nav>

<div class="container">

    <% if (keyword == null || keyword.isEmpty()) { %>
        <div class="no-results">
            <h3>Enter something to search</h3>
            <p>Try medicine name, brand, or supplier name</p>
        </div>

    <% } else if (totalResults == 0) { %>
        <div class="no-results">
            <h3>No results found for "<%= keyword %>"</h3>
            <p>Try a different keyword or check the spelling</p>
        </div>

    <% } else { %>
        <p class="result-title">
            <%= totalResults %> result(s) for <span>"<%= keyword %>"</span>
        </p>

        <!-- Medicine Results -->
        <% if (medicines != null && !medicines.isEmpty()) { %>
        <div class="section">
            <h3>💊 Medicines (<%= medicines.size() %>)</h3>
            <table>
                <thead>
                    <tr><th>Name</th><th>Brand</th><th>Category</th><th>Qty</th><th>Price</th><th>Expiry</th><th>Status</th><th></th></tr>
                </thead>
                <tbody>
                <% for (Medicine m : medicines) { %>
                    <tr>
                        <td><%= m.getMedicineName() %></td>
                        <td><%= m.getBrandName() %></td>
                        <td><%= m.getCategoryName() %></td>
                        <td><%= m.getQuantity() %></td>
                        <td>₹<%= m.getUnitPrice() %></td>
                        <td><%= m.getExpiryDate() %></td>
                        <td>
                            <% if (m.isLowStock()) { %>
                                <span class="badge-low">Low Stock</span>
                            <% } else { %>
                                <span class="badge-ok">OK</span>
                            <% } %>
                        </td>
                        <td><a href="medicine?action=edit&id=<%= m.getMedicineId() %>" class="link">Edit</a></td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>
        <% } %>

        <!-- Supplier Results -->
        <% if (suppliers != null && !suppliers.isEmpty()) { %>
        <div class="section">
            <h3>🚚 Suppliers (<%= suppliers.size() %>)</h3>
            <table>
                <thead>
                    <tr><th>Supplier Name</th><th>Contact Person</th><th>Phone</th><th>Email</th><th></th></tr>
                </thead>
                <tbody>
                <% for (Supplier s : suppliers) { %>
                    <tr>
                        <td><%= s.getSupplierName() %></td>
                        <td><%= s.getContactName() %></td>
                        <td><%= s.getPhone() %></td>
                        <td><%= s.getEmail() %></td>
                        <td><a href="supplier?action=edit&id=<%= s.getSupplierId() %>" class="link">Edit</a></td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>
        <% } %>
    <% } %>

</div>
</body>
</html>
