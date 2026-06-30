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

    List<Medicine> medicines = (List<Medicine>) request.getAttribute("medicines");
    String errorMessage = (String) request.getAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>New Bill — Pharmacy Inventory</title>
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

        .container { max-width: 800px; margin: 2rem auto; padding: 0 1.5rem; }

        .form-card { background: #fff; border-radius: 14px; border: 1px solid #dde3ed; padding: 2rem; }
        .form-card h2 { font-size: 19px; color: #1a202c; margin-bottom: 1.5rem; }

        .error-box {
            background: #fff5f5; border: 1px solid #fed7d7; color: #c53030;
            border-radius: 8px; padding: 10px 14px; font-size: 13px; margin-bottom: 1rem;
        }

        .form-group { margin-bottom: 16px; }
        label { display: block; font-size: 13px; font-weight: 600; color: #4a5568; margin-bottom: 6px; }
        input[type="text"] {
            width: 100%; padding: 9px 12px; border: 1.5px solid #e2e8f0; border-radius: 8px;
            font-size: 13px; color: #2d3748; background: #f7fafc;
        }

        .items-section { margin-top: 1.5rem; }
        .items-header {
            display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;
        }
        .items-header h3 { font-size: 14px; color: #4a5568; }

        .btn-add-row {
            background: #ebf8ff; color: #2b6cb0; border: 1px solid #bee3f8;
            padding: 6px 14px; border-radius: 6px; font-size: 12px; cursor: pointer; font-weight: 600;
        }

        table#itemsTable {
            width: 100%; border-collapse: collapse; margin-top: 10px;
        }
        table#itemsTable th {
            text-align: left; font-size: 11px; color: #718096; text-transform: uppercase;
            padding: 8px; border-bottom: 2px solid #edf2f7;
        }
        table#itemsTable td {
            padding: 8px; border-bottom: 1px solid #edf2f7;
        }

        select, input[type="number"] {
            width: 100%; padding: 7px 10px; border: 1.5px solid #e2e8f0; border-radius: 6px; font-size: 13px;
        }

        .subtotal-cell { font-weight: 600; color: #2d3748; white-space: nowrap; }
        .remove-btn {
            background: #fff5f5; color: #c53030; border: none; width: 26px; height: 26px;
            border-radius: 6px; cursor: pointer; font-size: 14px;
        }

        .total-row {
            display: flex; justify-content: flex-end; align-items: center; gap: 10px;
            margin-top: 16px; padding-top: 16px; border-top: 2px solid #edf2f7;
        }
        .total-row .label { font-size: 14px; color: #718096; }
        .total-row .amount { font-size: 22px; font-weight: 700; color: #2b6cb0; }

        .btn-row { display: flex; gap: 10px; margin-top: 1.5rem; }
        .btn-save {
            background: #2f855a; color: #fff; border: none; padding: 12px 28px;
            border-radius: 8px; font-size: 15px; font-weight: 600; cursor: pointer;
        }
        .btn-cancel {
            background: #f7fafc; color: #4a5568; border: 1.5px solid #e2e8f0; padding: 12px 24px;
            border-radius: 8px; font-size: 14px; text-decoration: none; font-weight: 600;
        }
    </style>
</head>
<body>

<nav class="navbar">
    <div class="brand">💊 Pharmacy Inventory System</div>
    <a href="<%= request.getContextPath() %>/sales" class="btn-back">← Back to Sales</a>
</nav>

<div class="container">
    <div class="form-card">
        <h2>🧾 Create New Bill</h2>

        <% if (errorMessage != null) { %>
            <div class="error-box">❌ <%= errorMessage %></div>
        <% } %>

        <form action="sales" method="post" id="billForm" onsubmit="return validateBill()">

            <div class="form-group">
                <label>Customer Name</label>
                <input type="text" name="customerName" placeholder="Walk-in Customer" />
            </div>

            <div class="items-section">
                <div class="items-header">
                    <h3>Medicines</h3>
                    <button type="button" class="btn-add-row" onclick="addRow()">+ Add Item</button>
                </div>

                <table id="itemsTable">
                    <thead>
                        <tr>
                            <th style="width:40%">Medicine</th>
                            <th style="width:15%">Qty</th>
                            <th style="width:18%">Unit Price</th>
                            <th style="width:18%">Subtotal</th>
                            <th style="width:9%"></th>
                        </tr>
                    </thead>
                    <tbody id="itemsBody">
                        <!-- JS yahan rows add karega -->
                    </tbody>
                </table>
            </div>

            <div class="total-row">
                <span class="label">Grand Total:</span>
                <span class="amount" id="grandTotal">₹0.00</span>
            </div>

            <div class="btn-row">
                <button type="submit" class="btn-save">💾 Save Bill & Print Receipt</button>
                <a href="sales" class="btn-cancel">Cancel</a>
            </div>

        </form>
    </div>
</div>

<script>
    // Medicines list — JSP se JS array mein convert kiya
    const medicines = [
        <% if (medicines != null) { for (Medicine m : medicines) { %>
            { id: <%= m.getMedicineId() %>, name: "<%= m.getMedicineName().replace("\"", "\\\"") %>", price: <%= m.getUnitPrice() %>, stock: <%= m.getQuantity() %> },
        <% } } %>
    ];

    let rowCount = 0;

    function addRow() {

        rowCount++;

        const tbody = document.getElementById("itemsBody");

        const row = document.createElement("tr");

        row.id = "row-" + rowCount;

        let options = '<option value="">-- Select --</option>';

        medicines.forEach(function(m) {

            options += '<option value="' + m.id + '" data-price="' + m.price + '" data-stock="' + m.stock + '">' 
                    + m.name + ' (Stock: ' + m.stock + ')</option>';

        });

        row.innerHTML =
            '<td>' +
                '<select name="medicineId[]" required onchange="updateRow(' + rowCount + ')" id="med-' + rowCount + '">' +
                    options +
                '</select>' +
            '</td>' +

            '<td>' +
                '<input type="number" name="quantity[]" min="1" value="1" required onchange="calculateRow(' + rowCount + ')" id="qty-' + rowCount + '" />' +
            '</td>' +

            '<td>' +
                '<input type="number" name="unitPrice[]" step="0.01" min="0" required readonly id="price-' + rowCount + '" />' +
            '</td>' +

            '<td class="subtotal-cell" id="subtotal-' + rowCount + '">₹0.00</td>' +

            '<td>' +
                '<button type="button" class="remove-btn" onclick="removeRow(' + rowCount + ')">✕</button>' +
            '</td>';

        tbody.appendChild(row);
    }
    function updateRow(id) {
        const select = document.getElementById('med-' + id);
        const selectedOption = select.options[select.selectedIndex];
        const price = selectedOption.getAttribute('data-price') || 0;

        document.getElementById('price-' + id).value = price;
        calculateRow(id);
    }

    function calculateRow(id) {
        const qty = parseFloat(document.getElementById('qty-' + id).value) || 0;
        const price = parseFloat(document.getElementById('price-' + id).value) || 0;
        const subtotal = qty * price;

        document.getElementById('subtotal-' + id).textContent = '₹' + subtotal.toFixed(2);
        calculateGrandTotal();
    }

    function removeRow(id) {
        document.getElementById('row-' + id).remove();
        calculateGrandTotal();
    }

    function calculateGrandTotal() {
        let total = 0;
        document.querySelectorAll('[id^="subtotal-"]').forEach(cell => {
            const value = parseFloat(cell.textContent.replace('₹', '')) || 0;
            total += value;
        });
        document.getElementById('grandTotal').textContent = '₹' + total.toFixed(2);
    }

    function validateBill() {
        const tbody = document.getElementById('itemsBody');
        if (tbody.children.length === 0) {
            alert('Kam se kam ek medicine add karo bill mein!');
            return false;
        }
        return true;
    }

    // Page load hote hi ek row by default add karo
    addRow();
</script>

</body>
</html>
