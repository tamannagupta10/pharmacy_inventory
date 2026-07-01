<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.pharmacy.model.User" %>
<%@ page import="com.pharmacy.model.Medicine" %>
<%@ page import="java.util.List" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("loggedUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login.html");
        return;
    }
    User loggedUser = (User) userSession.getAttribute("loggedUser");

    // Default view (sab 4 lists)
    List<Medicine> expiredList    = (List<Medicine>) request.getAttribute("expiredList");
    List<Medicine> expiringList   = (List<Medicine>) request.getAttribute("expiringList");
    List<Medicine> outOfStockList = (List<Medicine>) request.getAttribute("outOfStockList");
    List<Medicine> lowStockList   = (List<Medicine>) request.getAttribute("lowStockList");

    // Counts
    Integer expiredCount    = (Integer) request.getAttribute("expiredCount");
    Integer expiringCount   = (Integer) request.getAttribute("expiringCount");
    Integer outOfStockCount = (Integer) request.getAttribute("outOfStockCount");
    Integer lowStockCount   = (Integer) request.getAttribute("lowStockCount");

    // Filter view (sirf ek type)
    List<Medicine> filteredList = (List<Medicine>) request.getAttribute("filteredList");
    String filterTitle = (String) request.getAttribute("filterTitle");
    String filterType  = (String) request.getAttribute("filterType");

    boolean isFiltered = (filteredList != null);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Alerts — Pharmacy Inventory</title>
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

        h2 { font-size: 20px; color: #1a202c; margin-bottom: 1.5rem; }

        /* Alert summary cards */
        .alert-cards { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 14px; margin-bottom: 2rem; }
        .alert-card {
            border-radius: 12px; padding: 1.2rem 1.4rem; border: 1.5px solid;
            text-decoration: none; display: block; transition: transform 0.15s;
        }
        .alert-card:hover { transform: translateY(-2px); }
        .alert-card .count { font-size: 32px; font-weight: 700; margin-bottom: 4px; }
        .alert-card .label { font-size: 13px; font-weight: 500; }
        .alert-card .sub   { font-size: 11px; margin-top: 4px; opacity: 0.8; }

        .card-red    { background: #fff5f5; border-color: #feb2b2; color: #c53030; }
        .card-orange { background: #fffaf0; border-color: #fbd38d; color: #c05621; }
        .card-purple { background: #faf5ff; border-color: #d6bcfa; color: #6b46c1; }
        .card-yellow { background: #fefce8; border-color: #fde68a; color: #92400e; }

        /* Section */
        .section { margin-bottom: 2rem; }
        .section-head {
            display: flex; align-items: center; justify-content: space-between;
            margin-bottom: 10px;
        }
        .section-head h3 { font-size: 15px; font-weight: 600; }
        .section-head .see-all { font-size: 12px; text-decoration: none; color: #4299e1; }

        /* Tables */
        table {
            width: 100%; border-collapse: collapse; background: #fff;
            border-radius: 12px; overflow: hidden; border: 1px solid #dde3ed;
        }
        thead { background: #f7fafc; }
        th { text-align: left; padding: 10px 14px; font-size: 11px; color: #718096; text-transform: uppercase; }
        td { padding: 10px 14px; font-size: 13px; color: #2d3748; border-top: 1px solid #edf2f7; }

        /* Row highlighting */
        .row-red    { background: #fff5f5; }
        .row-orange { background: #fffaf0; }
        .row-yellow { background: #fefce8; }
        .row-purple { background: #faf5ff; }

        /* Badges */
        .badge {
            display: inline-block; font-size: 11px; font-weight: 600;
            padding: 2px 10px; border-radius: 12px; white-space: nowrap;
        }
        .badge-red    { background: #fed7d7; color: #c53030; }
        .badge-orange { background: #feebc8; color: #c05621; }
        .badge-yellow { background: #fef3c7; color: #92400e; }
        .badge-purple { background: #e9d8fd; color: #6b46c1; }
        .badge-green  { background: #c6f6d5; color: #276749; }

        .empty-state {
            text-align: center; padding: 2rem; color: #a0aec0; font-size: 13px;
            background: #fff; border-radius: 12px; border: 1px solid #dde3ed;
        }

        .edit-link {
            font-size: 12px; text-decoration: none; padding: 4px 10px;
            border-radius: 6px; background: #ebf8ff; color: #2b6cb0;
        }
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

<% if (!isFiltered) { %>
    <%-- ===== DEFAULT VIEW: Sab 4 sections ===== --%>

    <h2>⚠️ Alerts Dashboard</h2>

    <%-- Summary Cards --%>
    <div class="alert-cards">
        <a href="alerts?type=expired" class="alert-card card-red">
            <div class="count"><%= expiredCount %></div>
            <div class="label">Expired Medicines</div>
            <div class="sub">Immediately remove these</div>
        </a>
        <a href="alerts?type=expiring" class="alert-card card-orange">
            <div class="count"><%= expiringCount %></div>
            <div class="label">Expiring in 30 Days</div>
            <div class="sub">Act before they expire</div>
        </a>
        <a href="alerts?type=outofstock" class="alert-card card-purple">
            <div class="count"><%= outOfStockCount %></div>
            <div class="label">Out of Stock</div>
            <div class="sub">Quantity is zero</div>
        </a>
        <a href="alerts?type=lowstock" class="alert-card card-yellow">
            <div class="count"><%= lowStockCount %></div>
            <div class="label">Low Stock</div>
            <div class="sub">Below minimum level</div>
        </a>
    </div>

    <%-- Section 1: Expired --%>
    <div class="section">
        <div class="section-head">
            <h3 style="color:#c53030">🔴 Expired Medicines (<%= expiredList.size() %>)</h3>
            <% if (expiredList.size() > 3) { %><a href="alerts?type=expired" class="see-all">See all →</a><% } %>
        </div>
        <% if (expiredList.isEmpty()) { %>
            <div class="empty-state">✅ No expired medicines!</div>
        <% } else { %>
        <table>
            <thead><tr><th>Medicine</th><th>Brand</th><th>Expiry Date</th><th>Qty</th><th>Supplier</th><th>Action</th></tr></thead>
            <tbody>
            <% int count = 0; for (Medicine m : expiredList) { if (count++ >= 3) break; %>
                <tr class="row-red">
                    <td><%= m.getMedicineName() %></td>
                    <td><%= m.getBrandName() %></td>
                    <td><span class="badge badge-red"><%= m.getExpiryDate() %></span></td>
                    <td><%= m.getQuantity() %></td>
                    <td><%= m.getSupplierName() %></td>
                    <td><a href="medicine?action=edit&id=<%= m.getMedicineId() %>" class="edit-link">Update</a></td>
                </tr>
            <% } %>
            </tbody>
        </table>
        <% } %>
    </div>

    <%-- Section 2: Expiring Soon --%>
    <div class="section">
        <div class="section-head">
            <h3 style="color:#c05621">🟠 Expiring in 30 Days (<%= expiringList.size() %>)</h3>
            <% if (expiringList.size() > 3) { %><a href="alerts?type=expiring" class="see-all">See all →</a><% } %>
        </div>
        <% if (expiringList.isEmpty()) { %>
            <div class="empty-state">✅ No medicines expiring in next 30 days!</div>
        <% } else { %>
        <table>
            <thead><tr><th>Medicine</th><th>Brand</th><th>Expiry Date</th><th>Days Left</th><th>Qty</th><th>Action</th></tr></thead>
            <tbody>
            <% int count = 0; for (Medicine m : expiringList) { if (count++ >= 3) break; %>
                <tr class="row-orange">
                    <td><%= m.getMedicineName() %></td>
                    <td><%= m.getBrandName() %></td>
                    <td><%= m.getExpiryDate() %></td>
                    <td>
                        <span class="badge <%= m.getDaysLeft() <= 7 ? "badge-red" : "badge-orange" %>">
                            <%= m.getDaysLeft() %> days
                        </span>
                    </td>
                    <td><%= m.getQuantity() %></td>
                    <td><a href="medicine?action=edit&id=<%= m.getMedicineId() %>" class="edit-link">Update</a></td>
                </tr>
            <% } %>
            </tbody>
        </table>
        <% } %>
    </div>

    <%-- Section 3: Out of Stock --%>
    <div class="section">
        <div class="section-head">
            <h3 style="color:#6b46c1">🟣 Out of Stock (<%= outOfStockList.size() %>)</h3>
            <% if (outOfStockList.size() > 3) { %><a href="alerts?type=outofstock" class="see-all">See all →</a><% } %>
        </div>
        <% if (outOfStockList.isEmpty()) { %>
            <div class="empty-state">✅ All medicines are in stock!</div>
        <% } else { %>
        <table>
            <thead><tr><th>Medicine</th><th>Brand</th><th>Category</th><th>Min Stock</th><th>Supplier</th><th>Action</th></tr></thead>
            <tbody>
            <% int count = 0; for (Medicine m : outOfStockList) { if (count++ >= 3) break; %>
                <tr class="row-purple">
                    <td><%= m.getMedicineName() %></td>
                    <td><%= m.getBrandName() %></td>
                    <td><%= m.getCategoryName() %></td>
                    <td><%= m.getMinStock() %></td>
                    <td><%= m.getSupplierName() %></td>
                    <td><a href="purchase?action=add" class="edit-link">Reorder</a></td>
                </tr>
            <% } %>
            </tbody>
        </table>
        <% } %>
    </div>

    <%-- Section 4: Low Stock --%>
    <div class="section">
        <div class="section-head">
            <h3 style="color:#92400e">🟡 Low Stock (<%= lowStockList.size() %>)</h3>
            <% if (lowStockList.size() > 3) { %><a href="alerts?type=lowstock" class="see-all">See all →</a><% } %>
        </div>
        <% if (lowStockList.isEmpty()) { %>
            <div class="empty-state">✅ All medicines are above minimum stock level!</div>
        <% } else { %>
        <table>
            <thead><tr><th>Medicine</th><th>Brand</th><th>Current Qty</th><th>Min Required</th><th>Shortage</th><th>Action</th></tr></thead>
            <tbody>
            <%int count = 0; for (Medicine m : lowStockList) { if (count++ >= 3) break; %>
                <tr class="row-yellow">
                    <td><%= m.getMedicineName() %></td>
                    <td><%= m.getBrandName() %></td>
                    <td><span class="badge badge-yellow"><%= m.getQuantity() %></span></td>
                    <td><%= m.getMinStock() %></td>
                    <td><%= m.getMinStock() - m.getQuantity() %> units short</td>
                    <td><a href="purchase?action=add" class="edit-link">Reorder</a></td>
                </tr>
            <% } %>
            </tbody>
        </table>
        <% } %>
    </div>

<% } else { %>
    <%-- ===== FILTERED VIEW: Sirf ek type ===== --%>
    <div style="display:flex; align-items:center; gap:14px; margin-bottom:1.5rem;">
        <a href="alerts" style="font-size:13px; color:#4299e1; text-decoration:none;">← All Alerts</a>
        <h2 style="margin:0"><%= filterTitle %> (<%= filteredList.size() %>)</h2>
    </div>

    <% if (filteredList.isEmpty()) { %>
        <div class="empty-state" style="padding:3rem;">✅ No alerts in this category!</div>
    <% } else { %>
    <table>
        <thead>
            <tr>
                <th>Medicine</th>
                <th>Brand</th>
                <th>Category</th>
                <th>Qty</th>
                <th>Min Stock</th>
                <th>Expiry Date</th>
                <% if ("expiring".equals(filterType)) { %><th>Days Left</th><% } %>
                <th>Supplier</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
        <% for (Medicine m : filteredList) {
               String rowClass = "";
               String badgeClass = "";
               if ("expired".equals(filterType))    { rowClass = "row-red";    badgeClass = "badge-red"; }
               if ("expiring".equals(filterType))   { rowClass = "row-orange"; badgeClass = "badge-orange"; }
               if ("outofstock".equals(filterType)) { rowClass = "row-purple"; badgeClass = "badge-purple"; }
               if ("lowstock".equals(filterType))   { rowClass = "row-yellow"; badgeClass = "badge-yellow"; }
        %>
            <tr class="<%= rowClass %>">
                <td><%= m.getMedicineName() %></td>
                <td><%= m.getBrandName() %></td>
                <td><%= m.getCategoryName() %></td>
                <td><span class="badge <%= badgeClass %>"><%= m.getQuantity() %></span></td>
                <td><%= m.getMinStock() %></td>
                <td><%= m.getExpiryDate() %></td>
                <% if ("expiring".equals(filterType)) { %>
                    <td><span class="badge <%= m.getDaysLeft() <= 7 ? "badge-red" : "badge-orange" %>"><%= m.getDaysLeft() %> days</span></td>
                <% } %>
                <td><%= m.getSupplierName() %></td>
                <td>
                    <% if ("outofstock".equals(filterType) || "lowstock".equals(filterType)) { %>
                        <a href="purchase?action=add" class="edit-link">Reorder</a>
                    <% } else { %>
                        <a href="medicine?action=edit&id=<%= m.getMedicineId() %>" class="edit-link">Update</a>
                    <% } %>
                </td>
            </tr>
        <% } %>
        </tbody>
    </table>
    <% } %>
<% } %>

</div>
</body>
</html>