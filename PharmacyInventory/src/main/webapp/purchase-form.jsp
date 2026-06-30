<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.pharmacy.model.User" %>
<%@ page import="com.pharmacy.model.Supplier" %>
<%@ page import="com.pharmacy.model.Medicine" %>
<%@ page import="java.util.List" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("loggedUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login.html");
        return;
    }

    List<Supplier> suppliers = (List<Supplier>) request.getAttribute("suppliers");
    List<Medicine> medicines = (List<Medicine>) request.getAttribute("medicines");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>New Purchase Order — Pharmacy Inventory</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Verdana, sans-serif; background: #eef2f7; }

        .navbar {
            background: #2b6cb0; color: #fff; padding: 0 2rem; height: 56px;
            display: flex; align-items: center; justify-content: space-between;
        }
        .brand { font-size: 16px; font-weight: 700; }
        .btn-back {
            background: rgba(255,255,255,0.15); border: 1px solid rgba(255,255,255,0.35);
            color: #fff; padding: 5px 14px; border-radius: 6px; text-decoration: none; font-size: 13px;
        }

        .container { max-width: 600px; margin: 2rem auto; padding: 0 1.5rem; }

        .form-card { background: #fff; border-radius: 14px; border: 1px solid #dde3ed; padding: 2rem; }
        .form-card h2 { font-size: 19px; color: #1a202c; margin-bottom: 6px; }
        .form-card .subtitle { font-size: 13px; color: #718096; margin-bottom: 1.5rem; }

        .form-group { margin-bottom: 14px; }
        label { display: block; font-size: 13px; font-weight: 600; color: #4a5568; margin-bottom: 6px; }

        select, input[type="number"] {
            width: 100%; padding: 9px 12px; border: 1.5px solid #e2e8f0; border-radius: 8px;
            font-size: 13px; color: #2d3748; background: #f7fafc; outline: none;
        }
        select:focus, input:focus { border-color: #4299e1; background: #fff; }

        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }

        .info-box {
            background: #ebf8ff; border: 1px solid #bee3f8; border-radius: 8px;
            padding: 10px 14px; font-size: 12px; color: #2c5282; margin-top: 1rem; line-height: 1.6;
        }

        .btn-row { display: flex; gap: 10px; margin-top: 1.5rem; }
        .btn-save {
            background: #6b46c1; color: #fff; border: none; padding: 11px 24px;
            border-radius: 8px; font-size: 14px; font-weight: 600; cursor: pointer;
        }
        .btn-cancel {
            background: #f7fafc; color: #4a5568; border: 1.5px solid #e2e8f0; padding: 11px 24px;
            border-radius: 8px; font-size: 14px; text-decoration: none; font-weight: 600;
        }
    </style>
</head>
<body>

<nav class="navbar">
    <div class="brand">💊 Pharmacy Inventory System</div>
    <a href="<%= request.getContextPath() %>/purchase" class="btn-back">← Back to History</a>
</nav>

<div class="container">
    <div class="form-card">
        <h2>📦 New Purchase Order</h2>
        <p class="subtitle">Purchase stock from the supplier — the quantity will be automatically added to the medicine stock.</p>

        <form action="purchase" method="post">

            <div class="form-group">
                <label>Supplier</label>
                <select name="supplierId" required>
                    <option value="">-- Select Supplier --</option>
                    <% for (Supplier s : suppliers) { %>
                        <option value="<%= s.getSupplierId() %>"><%= s.getSupplierName() %></option>
                    <% } %>
                </select>
            </div>

            <div class="form-group">
                <label>Medicine</label>
                <select name="medicineId" required>
                    <option value="">-- Select Medicine --</option>
                    <% for (Medicine m : medicines) { %>
                        <option value="<%= m.getMedicineId() %>">
                            <%= m.getMedicineName() %> (Current stock: <%= m.getQuantity() %>)
                        </option>
                    <% } %>
                </select>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label>Quantity to Purchase</label>
                    <input type="number" name="quantity" min="1" required />
                </div>
                <div class="form-group">
                    <label>Unit Cost (₹)</label>
                    <input type="number" name="unitCost" step="0.01" min="0" required />
                </div>
            </div>

            <div class="info-box">
                💡 As soon as you submit, the quantity will be added to the medicine’s current stock, and the record will also be saved in the purchase history.
            </div>

            <div class="btn-row">
                <button type="submit" class="btn-save">Save Purchase Order</button>
                <a href="purchase" class="btn-cancel">Cancel</a>
            </div>

        </form>
    </div>
</div>

</body>
</html>
