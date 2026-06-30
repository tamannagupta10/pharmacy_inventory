<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.pharmacy.model.User" %>
<%@ page import="com.pharmacy.model.Sale" %>
<%@ page import="com.pharmacy.model.SaleItem" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("loggedUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login.html");
        return;
    }

    Sale sale = (Sale) request.getAttribute("sale");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Receipt #<%= sale.getSaleId() %> — Pharmacy Inventory</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Verdana, sans-serif; background: #eef2f7; }

        .navbar {
            background: #2b6cb0; color: #fff; padding: 0 2rem; height: 56px;
            display: flex; align-items: center; justify-content: space-between;
        }
        .brand { font-size: 16px; font-weight: 700; }
        .nav-right { display: flex; gap: 10px; }
        .btn-back, .btn-print {
            background: rgba(255,255,255,0.15); border: 1px solid rgba(255,255,255,0.35);
            color: #fff; padding: 5px 14px; border-radius: 6px; text-decoration: none; font-size: 13px; cursor: pointer;
        }

        .container { max-width: 550px; margin: 2rem auto; padding: 0 1.5rem; }

        .receipt-card {
            background: #fff; border-radius: 14px; border: 1px solid #dde3ed; padding: 2rem;
        }

        .success-banner {
            background: #f0fff4; border: 1px solid #c6f6d5; color: #276749;
            padding: 10px 14px; border-radius: 8px; font-size: 13px; text-align: center; margin-bottom: 1.5rem;
        }

        .receipt-header { text-align: center; margin-bottom: 1.5rem; border-bottom: 2px dashed #e2e8f0; padding-bottom: 1.2rem; }
        .receipt-header h2 { font-size: 18px; color: #1a202c; }
        .receipt-header p { font-size: 12px; color: #718096; margin-top: 4px; }

        .receipt-meta { display: flex; justify-content: space-between; font-size: 12px; color: #4a5568; margin-bottom: 1.2rem; }

        table { width: 100%; border-collapse: collapse; margin-bottom: 1.2rem; }
        th { text-align: left; font-size: 11px; color: #718096; text-transform: uppercase; padding: 6px 4px; border-bottom: 1px solid #e2e8f0; }
        td { padding: 8px 4px; font-size: 13px; color: #2d3748; border-bottom: 1px solid #f7fafc; }
        .text-right { text-align: right; }

        .total-section {
            border-top: 2px dashed #e2e8f0; padding-top: 1rem; display: flex; justify-content: space-between; align-items: center;
        }
        .total-section .label { font-size: 14px; color: #4a5568; }
        .total-section .amount { font-size: 24px; font-weight: 700; color: #2b6cb0; }

        .footer-note { text-align: center; font-size: 11px; color: #a0aec0; margin-top: 1.5rem; }

        @media print {
            .navbar { display: none; }
            body { background: #fff; }
            .receipt-card { border: none; }
        }
    </style>
</head>
<body>

<nav class="navbar">
    <div class="brand">💊 Pharmacy Inventory System</div>
    <div class="nav-right">
        <button class="btn-print" onclick="window.print()">🖨 Print</button>
        <a href="<%= request.getContextPath() %>/sales" class="btn-back">← Sales History</a>
    </div>
</nav>

<div class="container">
    <div class="receipt-card">

        <div class="success-banner">✅ Bill saved successfully! Stock updated automatically.</div>

        <div class="receipt-header">
            <h2>💊 Pharmacy Inventory System</h2>
            <p>Sales Receipt</p>
        </div>

        <div class="receipt-meta">
            <span>Bill #<%= sale.getSaleId() %></span>
            <span><%= sale.getSaleDate() %></span>
        </div>

        <div class="receipt-meta">
            <span>Customer: <strong><%= sale.getCustomerName() %></strong></span>
            <span>Sold by: <strong><%= sale.getSoldByName() %></strong></span>
        </div>

        <table>
            <thead>
                <tr>
                    <th>Medicine</th>
                    <th class="text-right">Qty</th>
                    <th class="text-right">Price</th>
                    <th class="text-right">Subtotal</th>
                </tr>
            </thead>
            <tbody>
                <% for (SaleItem item : sale.getItems()) { %>
                <tr>
                    <td><%= item.getMedicineName() %></td>
                    <td class="text-right"><%= item.getQuantity() %></td>
                    <td class="text-right">₹<%= item.getUnitPrice() %></td>
                    <td class="text-right">₹<%= item.getSubtotal() %></td>
                </tr>
                <% } %>
            </tbody>
        </table>

        <div class="total-section">
            <span class="label">Grand Total</span>
            <span class="amount">₹<%= sale.getTotalAmount() %></span>
        </div>

        <div class="footer-note">Thank you for your purchase! Get well soon. 💙</div>

    </div>
</div>

</body>
</html>
