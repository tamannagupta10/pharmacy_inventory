<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.pharmacy.model.User" %>
<%@ page import="com.pharmacy.model.Medicine" %>
<%@ page import="com.pharmacy.model.Category" %>
<%@ page import="com.pharmacy.model.Supplier" %>
<%@ page import="java.util.List" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("loggedUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login.html");
        return;
    }
    User loggedUser = (User) userSession.getAttribute("loggedUser");

    Medicine medicine = (Medicine) request.getAttribute("medicine"); // null = add mode, not null = edit mode
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    List<Supplier> suppliers  = (List<Supplier>)  request.getAttribute("suppliers");

    boolean isEdit = (medicine != null);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEdit ? "Edit" : "Add" %> Medicine — Pharmacy Inventory</title>
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

        .container { max-width: 700px; margin: 2rem auto; padding: 0 1.5rem; }

        .form-card {
            background: #fff; border-radius: 14px; border: 1px solid #dde3ed; padding: 2rem;
        }
        .form-card h2 { font-size: 19px; color: #1a202c; margin-bottom: 1.5rem; }

        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 14px; }
        .form-group { margin-bottom: 14px; }
        .form-group.full { grid-column: 1 / -1; }

        label { display: block; font-size: 13px; font-weight: 600; color: #4a5568; margin-bottom: 6px; }

        input[type="text"], input[type="number"], input[type="date"],
        select, textarea {
            width: 100%; padding: 9px 12px; border: 1.5px solid #e2e8f0; border-radius: 8px;
            font-size: 13px; color: #2d3748; background: #f7fafc; outline: none;
        }
        input:focus, select:focus, textarea:focus {
            border-color: #4299e1; background: #fff;
        }
        textarea { resize: vertical; min-height: 60px; }

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
    <a href="<%= request.getContextPath() %>/medicine" class="btn-back">← Back to List</a>
</nav>

<div class="container">
    <div class="form-card">
        <h2><%= isEdit ? "✏️ Edit Medicine" : "➕ Add New Medicine" %></h2>

        <form action="medicine" method="post" onsubmit="return validateForm()">

            <% if (isEdit) { %>
                <input type="hidden" name="medicineId" value="<%= medicine.getMedicineId() %>" />
            <% } %>

            <div class="form-row">
                <div class="form-group">
                    <label>Medicine Name</label>
                    <input type="text" name="medicineName" required
                           value="<%= isEdit ? medicine.getMedicineName() : "" %>" />
                </div>
                <div class="form-group">
                    <label>Brand Name</label>
                    <input type="text" name="brandName" required
                           value="<%= isEdit ? medicine.getBrandName() : "" %>" />
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label>Category</label>
                    <select name="categoryId" required>
                        <option value="">-- Select Category --</option>
                        <% for (Category c : categories) { %>
                            <option value="<%= c.getCategoryId() %>"
                                <%= (isEdit && medicine.getCategoryId() == c.getCategoryId()) ? "selected" : "" %>>
                                <%= c.getCategoryName() %>
                            </option>
                        <% } %>
                    </select>
                </div>
                <div class="form-group">
                    <label>Supplier</label>
                    <select name="supplierId" required>
                        <option value="">-- Select Supplier --</option>
                        <% for (Supplier s : suppliers) { %>
                            <option value="<%= s.getSupplierId() %>"
                                <%= (isEdit && medicine.getSupplierId() == s.getSupplierId()) ? "selected" : "" %>>
                                <%= s.getSupplierName() %>
                            </option>
                        <% } %>
                    </select>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label>Quantity in Stock</label>
                    <input type="number" name="quantity" min="0" required
                           value="<%= isEdit ? medicine.getQuantity() : "" %>" />
                </div>
                <div class="form-group">
                    <label>Minimum Stock Alert Level</label>
                    <input type="number" name="minStock" min="0" required
                           value="<%= isEdit ? medicine.getMinStock() : "10" %>" />
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label>Unit Price (₹)</label>
                    <input type="number" name="unitPrice" step="0.01" min="0" required
                           value="<%= isEdit ? medicine.getUnitPrice() : "" %>" />
                </div>
                <div class="form-group">
                    <label>Expiry Date</label>
                    <input type="date" name="expiryDate" required
                           value="<%= isEdit ? medicine.getExpiryDate() : "" %>" />
                </div>
            </div>

            <div class="form-group">
                <label>Manufacture Date</label>
                <input type="date" name="manufactureDate" required
                       value="<%= isEdit ? medicine.getManufactureDate() : "" %>" />
            </div>

            <div class="form-group full">
                <label>Description</label>
                <textarea name="description"><%= isEdit ? medicine.getDescription() : "" %></textarea>
            </div>

            <div class="btn-row">
                <button type="submit" class="btn-save"><%= isEdit ? "Update Medicine" : "Save Medicine" %></button>
                <a href="medicine" class="btn-cancel">Cancel</a>
            </div>

        </form>
    </div>
</div>

<script>
    function validateForm() {
        const qty = document.querySelector('[name="quantity"]').value;
        const price = document.querySelector('[name="unitPrice"]').value;
        if (qty < 0 || price < 0) {
            alert('Quantity aur Price negative nahi ho sakte!');
            return false;
        }
        return true;
    }
</script>

</body>
</html>
