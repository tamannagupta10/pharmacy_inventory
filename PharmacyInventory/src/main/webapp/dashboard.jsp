<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.pharmacy.model.User" %>
<%
    // Session check
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

    // Stats from DashboardServlet (null safe defaults)
    int    totalMedicines  = (request.getAttribute("totalMedicines")  != null) ? (int) request.getAttribute("totalMedicines")  : 0;
    int    totalSuppliers  = (request.getAttribute("totalSuppliers")  != null) ? (int) request.getAttribute("totalSuppliers")  : 0;
    int    todaySalesCount = (request.getAttribute("todaySalesCount") != null) ? (int) request.getAttribute("todaySalesCount") : 0;
    int    lowStockCount   = (request.getAttribute("lowStockCount")   != null) ? (int) request.getAttribute("lowStockCount")   : 0;
    int    expiringCount   = (request.getAttribute("expiringCount")   != null) ? (int) request.getAttribute("expiringCount")   : 0;
    int    expiredCount    = (request.getAttribute("expiredCount")    != null) ? (int) request.getAttribute("expiredCount")    : 0;
    int    totalSales      = (request.getAttribute("totalSales")      != null) ? (int) request.getAttribute("totalSales")      : 0;
    int    totalPurchases  = (request.getAttribute("totalPurchases")  != null) ? (int) request.getAttribute("totalPurchases") : 0;

    Object todayRev = request.getAttribute("todayRevenue");
    Object totalRev = request.getAttribute("totalRevenue");
    String todayRevenue = (todayRev != null) ? todayRev.toString() : "0.00";
    String totalRevenue = (totalRev != null) ? totalRev.toString() : "0.00";

    String salesChartLabels = (request.getAttribute("salesChartLabels") != null) ? (String) request.getAttribute("salesChartLabels") : "[]";
    String salesChartData   = (request.getAttribute("salesChartData")   != null) ? (String) request.getAttribute("salesChartData")   : "[]";
    String catChartLabels   = (request.getAttribute("catChartLabels")   != null) ? (String) request.getAttribute("catChartLabels")   : "[]";
    String catChartData     = (request.getAttribute("catChartData")     != null) ? (String) request.getAttribute("catChartData")     : "[]";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard — Pharmacy Inventory</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Verdana, sans-serif; background: #eef2f7; }

        /* ── Navbar ── */
        .navbar {
            background: #2b6cb0; color: #fff; padding: 0 2rem; height: 58px;
            display: flex; align-items: center; justify-content: space-between;
            box-shadow: 0 2px 8px rgba(0,0,0,0.15); position: sticky; top: 0; z-index: 100;
        }
        .brand { font-size: 17px; font-weight: 700; }
        .nav-right { display: flex; align-items: center; gap: 12px; font-size: 13px; }
        .role-badge {
            background: rgba(255,255,255,0.2); border: 1px solid rgba(255,255,255,0.3);
            padding: 3px 10px; border-radius: 20px; font-size: 12px; font-weight: 600;
        }
        .btn-logout {
            background: rgba(255,255,255,0.15); border: 1px solid rgba(255,255,255,0.35);
            color: #fff; padding: 6px 14px; border-radius: 7px; text-decoration: none; font-size: 13px;
        }

        /* ── Search bar ── */
        .search-form {
            display: flex; align-items: center; background: rgba(255,255,255,0.18);
            border: 1px solid rgba(255,255,255,0.3); border-radius: 8px; overflow: hidden;
        }
        .search-form input {
            background: transparent; border: none; outline: none; color: #fff;
            padding: 6px 12px; font-size: 13px; width: 200px;
        }
        .search-form input::placeholder { color: rgba(255,255,255,0.7); }
        .search-form button {
            background: rgba(255,255,255,0.2); border: none; color: #fff;
            padding: 6px 12px; cursor: pointer; font-size: 13px;
        }

        /* ── Container ── */
        .container { max-width: 1100px; margin: 2rem auto; padding: 0 1.5rem; }

        /* ── Welcome ── */
        .welcome-card {
            background: linear-gradient(135deg, #2b6cb0, #4299e1);
            border-radius: 14px; padding: 1.5rem 2rem; margin-bottom: 1.5rem;
            display: flex; align-items: center; justify-content: space-between; color: #fff;
        }
        .welcome-card h2 { font-size: 20px; margin-bottom: 4px; }
        .welcome-card p  { font-size: 13px; opacity: 0.85; }
        .avatar {
            width: 52px; height: 52px; border-radius: 50%; background: rgba(255,255,255,0.25);
            font-size: 22px; font-weight: 700; display: flex; align-items: center; justify-content: center;
        }

        /* ── Section label ── */
        .section-label {
            font-size: 11px; font-weight: 600; color: #a0aec0; text-transform: uppercase;
            letter-spacing: 0.08em; margin-bottom: 10px;
        }

        /* ── Stat cards ── */
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); gap: 12px; margin-bottom: 1.5rem; }
        .stat-card {
            background: #fff; border-radius: 12px; border: 1.5px solid #e2e8f0;
            padding: 1.2rem 1.3rem;
        }
        .stat-card .icon  { font-size: 22px; margin-bottom: 8px; }
        .stat-card .value { font-size: 26px; font-weight: 700; color: #1a202c; margin-bottom: 2px; }
        .stat-card .label { font-size: 12px; color: #718096; }
        .stat-card.alert  { border-color: #fed7d7; background: #fff5f5; }
        .stat-card.warn   { border-color: #fbd38d; background: #fffaf0; }
        .stat-card.good   { border-color: #c6f6d5; background: #f0fff4; }

        /* ── Alert banner ── */
        .alert-banner {
            background: #fff5f5; border: 1.5px solid #fed7d7; border-radius: 10px;
            padding: 12px 16px; margin-bottom: 1.5rem; display: flex;
            align-items: center; justify-content: space-between; font-size: 13px;
        }
        .alert-banner span { color: #c53030; font-weight: 500; }
        .alert-banner a { color: #c53030; font-weight: 600; text-decoration: none; font-size: 12px; }

        /* ── Module cards ── */
        .modules-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(170px, 1fr)); gap: 12px; margin-bottom: 1.5rem; }
        .module-card {
            background: #fff; border-radius: 14px; border: 1.5px solid #e2e8f0;
            padding: 1.4rem 1.2rem; text-align: center; text-decoration: none; color: inherit;
            transition: border-color 0.2s, box-shadow 0.2s, transform 0.15s; display: block;
        }
        .module-card:hover { border-color: #4299e1; box-shadow: 0 4px 14px rgba(66,153,225,0.15); transform: translateY(-2px); }
        .module-card .icon { font-size: 36px; margin-bottom: 10px; display: block; }
        .module-card h3    { font-size: 14px; font-weight: 600; color: #2d3748; margin-bottom: 4px; }
        .module-card p     { font-size: 11px; color: #718096; line-height: 1.5; }
        .admin-tag {
            display: inline-block; font-size: 10px; background: #fff5f5; color: #c53030;
            border: 1px solid #fed7d7; padding: 1px 6px; border-radius: 4px; margin-left: 4px;
        }

        /* ── Charts ── */
        .charts-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 14px; margin-bottom: 1.5rem; }
        .chart-card { background: #fff; border-radius: 14px; border: 1px solid #dde3ed; padding: 1.4rem; }
        .chart-card h3 { font-size: 14px; font-weight: 600; color: #2d3748; margin-bottom: 1rem; }

        @media (max-width: 768px) {
            .charts-grid { grid-template-columns: 1fr; }
            .search-form input { width: 130px; }
        }
    </style>
</head>
<body>

<!-- Navbar with Global Search -->
<nav class="navbar">
    <div class="brand">💊 Pharmacy Inventory</div>
    <form class="search-form" action="<%= request.getContextPath() %>/search" method="get">
        <input type="text" name="q" placeholder="Search medicines, suppliers..." />
        <button type="submit">🔍</button>
    </form>
    <div class="nav-right">
        <span>Hello, <strong><%= fullName %></strong></span>
        <span class="role-badge"><%= role %></span>
        <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Logout</a>
    </div>
</nav>

<div class="container">

    <!-- Welcome -->
    <div class="welcome-card">
        <div>
            <h2>👋 Welcome back, <%= fullName %>!</h2>
            <p>Here's what's happening at your pharmacy today.</p>
        </div>
        <div class="avatar"><%= initial %></div>
    </div>

    <!-- Alert Banner (sirf tab dikhao jab alerts hon) -->
    <% if (expiredCount > 0 || lowStockCount > 0) { %>
    <div class="alert-banner">
        <span>
            ⚠️ Attention:
            <% if (expiredCount > 0) { %> <%= expiredCount %> expired medicine(s) <% } %>
            <% if (expiredCount > 0 && lowStockCount > 0) { %> and <% } %>
            <% if (lowStockCount > 0) { %> <%= lowStockCount %> low stock item(s) <% } %>
            require immediate action!
        </span>
        <a href="<%= request.getContextPath() %>/alerts">View Alerts →</a>
    </div>
    <% } %>

    <!-- Key Stats -->
    <div class="section-label">Today's Summary</div>
    <div class="stats-grid">
        <div class="stat-card good">
            <div class="icon">💊</div>
            <div class="value"><%= totalMedicines %></div>
            <div class="label">Total Medicines</div>
        </div>
        <div class="stat-card good">
            <div class="icon">🚚</div>
            <div class="value"><%= totalSuppliers %></div>
            <div class="label">Suppliers</div>
        </div>
        <div class="stat-card good">
            <div class="icon">🧾</div>
            <div class="value"><%= todaySalesCount %></div>
            <div class="label">Bills Today</div>
        </div>
        <div class="stat-card good">
            <div class="icon">💰</div>
            <div class="value">₹<%= todayRevenue %></div>
            <div class="label">Revenue Today</div>
        </div>
        <div class="stat-card warn">
            <div class="icon">📦</div>
            <div class="value"><%= lowStockCount %></div>
            <div class="label">Low Stock Items</div>
        </div>
        <div class="stat-card warn">
            <div class="icon">⏰</div>
            <div class="value"><%= expiringCount %></div>
            <div class="label">Expiring Soon</div>
        </div>
        <div class="stat-card alert">
            <div class="icon">❌</div>
            <div class="value"><%= expiredCount %></div>
            <div class="label">Expired</div>
        </div>
        <div class="stat-card good">
            <div class="icon">📈</div>
            <div class="value">₹<%= totalRevenue %></div>
            <div class="label">Total Revenue</div>
        </div>
    </div>

    <!-- Charts -->
    <div class="charts-grid">
        <div class="chart-card">
            <h3>📊 Last 7 Days Sales Revenue</h3>
            <canvas id="salesChart" height="120"></canvas>
        </div>
        <div class="chart-card">
            <h3>🍩 Medicines by Category</h3>
            <canvas id="catChart" height="180"></canvas>
        </div>
    </div>

    <!-- Modules -->
    <div class="section-label">Quick Navigation</div>
    <div class="modules-grid">
        <a href="<%= request.getContextPath() %>/medicine" class="module-card">
            <span class="icon">💊</span>
            <h3>Medicines</h3>
            <p>Stock, add, edit, delete</p>
        </a>
        <a href="<%= request.getContextPath() %>/supplier" class="module-card">
            <span class="icon">🚚</span>
            <h3>Suppliers</h3>
            <p>Manage suppliers</p>
        </a>
        <a href="<%= request.getContextPath() %>/purchase" class="module-card">
            <span class="icon">📦</span>
            <h3>Purchase Orders</h3>
            <p>Stock inflow history</p>
        </a>
        <a href="<%= request.getContextPath() %>/sales" class="module-card">
            <span class="icon">💳</span>
            <h3>Sales & Billing</h3>
            <p>Create bills, receipts</p>
        </a>
        <a href="<%= request.getContextPath() %>/alerts" class="module-card">
            <span class="icon">⚠️</span>
            <h3>Alerts</h3>
            <p>Expiry & stock warnings</p>
        </a>
        <% if ("ADMIN".equals(role)) { %>
        <a href="<%= request.getContextPath() %>/search" class="module-card">
            <span class="icon">🔍</span>
            <h3>Search <span class="admin-tag">New</span></h3>
            <p>Global search across all data</p>
        </a>
        <% } %>
    </div>

</div>

<script>
    // Sales Chart (Bar)
    const salesCtx = document.getElementById('salesChart').getContext('2d');
    new Chart(salesCtx, {
        type: 'bar',
        data: {
            labels: <%= salesChartLabels %>,
            datasets: [{
                label: 'Revenue (₹)',
                data: <%= salesChartData %>,
                backgroundColor: 'rgba(66, 153, 225, 0.7)',
                borderColor: '#2b6cb0',
                borderWidth: 1,
                borderRadius: 6
            }]
        },
        options: {
            responsive: true,
            plugins: { legend: { display: false } },
            scales: { y: { beginAtZero: true } }
        }
    });

    // Category Chart (Doughnut)
    const catCtx = document.getElementById('catChart').getContext('2d');
    new Chart(catCtx, {
        type: 'doughnut',
        data: {
            labels: <%= catChartLabels %>,
            datasets: [{
                data: <%= catChartData %>,
                backgroundColor: ['#4299e1','#48bb78','#ed8936','#9f7aea','#f56565','#38b2ac','#ecc94b','#667eea'],
                borderWidth: 2
            }]
        },
        options: {
            responsive: true,
            plugins: { legend: { position: 'bottom', labels: { font: { size: 11 } } } }
        }
    });
</script>

</body>
</html>
