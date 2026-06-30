<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.pharmacy.model.User" %>
<%@ page import="com.pharmacy.model.Supplier" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("loggedUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login.html");
        return;
    }

    Supplier supplier = (Supplier) request.getAttribute("supplier"); // null = add, not null = edit
    boolean isEdit = (supplier != null);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEdit ? "Edit" : "Add" %> Supplier — Pharmacy Inventory</title>
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
        .form-card h2 { font-size: 19px; color: #1a202c; margin-bottom: 1.5rem; }

        .form-group { margin-bottom: 14px; }
        label { display: block; font-size: 13px; font-weight: 600; color: #4a5568; margin-bottom: 6px; }

        input[type="text"], input[type="email"], textarea {
            width: 100%; padding: 9px 12px; border: 1.5px solid #e2e8f0; border-radius: 8px;
            font-size: 13px; color: #2d3748; background: #f7fafc; outline: none;
        }
        input:focus, textarea:focus { border-color: #4299e1; background: #fff; }
        textarea { resize: vertical; min-height: 70px; }

        .btn-row { display: flex; gap: 10px; margin-top: 1.5rem; }
        .btn-save {
            background: #2b6cb0; color: #fff; border: none; padding: 11px 24px;
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
    <a href="<%= request.getContextPath() %>/supplier" class="btn-back">← Back to List</a>
</nav>

<div class="container">
    <div class="form-card">
        <h2><%= isEdit ? "✏️ Edit Supplier" : "➕ Add New Supplier" %></h2>

        <form action="supplier" method="post">

            <% if (isEdit) { %>
                <input type="hidden" name="supplierId" value="<%= supplier.getSupplierId() %>" />
            <% } %>

            <div class="form-group">
                <label>Supplier Name</label>
                <input type="text" name="supplierName" required
                       value="<%= isEdit ? supplier.getSupplierName() : "" %>" />
            </div>

            <div class="form-group">
                <label>Contact Person</label>
                <input type="text" name="contactName" required
                       value="<%= isEdit ? supplier.getContactName() : "" %>" />
            </div>

            <div class="form-group">
                <label>Phone</label>
                <input type="text" name="phone" required
                       value="<%= isEdit ? supplier.getPhone() : "" %>" />
            </div>

            <div class="form-group">
                <label>Email</label>
                <input type="email" name="email"
                       value="<%= isEdit ? supplier.getEmail() : "" %>" />
            </div>

            <div class="form-group">
                <label>Address</label>
                <textarea name="address"><%= isEdit ? supplier.getAddress() : "" %></textarea>
            </div>

            <div class="btn-row">
                <button type="submit" class="btn-save"><%= isEdit ? "Update Supplier" : "Save Supplier" %></button>
                <a href="supplier" class="btn-cancel">Cancel</a>
            </div>

        </form>
    </div>
</div>

</body>
</html>
