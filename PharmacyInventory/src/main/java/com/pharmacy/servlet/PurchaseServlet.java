package com.pharmacy.servlet;

import com.pharmacy.dao.PurchaseDAO;
import com.pharmacy.dao.SupplierDAO;
import com.pharmacy.dao.MedicineDAO;
import com.pharmacy.model.PurchaseOrder;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

/**
 * PurchaseServlet.java
 *   /purchase                → purchase history dikhao
 *   /purchase?action=add     → purchase form (GET) / save + stock update (POST)
 */
@WebServlet("/purchase")
public class PurchaseServlet extends HttpServlet {

    private PurchaseDAO purchaseDAO = new PurchaseDAO();
    private SupplierDAO supplierDAO = new SupplierDAO();
    private MedicineDAO medicineDAO = new MedicineDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action == null) {
            // Purchase history dikhao
            List<PurchaseOrder> orders = purchaseDAO.getAllPurchaseOrders();
            request.setAttribute("orders", orders);
            request.getRequestDispatcher("/purchase-history.jsp").forward(request, response);

        } else if (action.equals("add")) {
            // Purchase form dikhao - dropdowns ke saath
            request.setAttribute("suppliers", supplierDAO.getAllSuppliers());
            request.setAttribute("medicines", medicineDAO.getAllMedicines());
            request.getRequestDispatcher("/purchase-form.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        PurchaseOrder po = new PurchaseOrder();
        po.setSupplierId(Integer.parseInt(request.getParameter("supplierId")));
        po.setMedicineId(Integer.parseInt(request.getParameter("medicineId")));
        po.setQuantity(Integer.parseInt(request.getParameter("quantity")));
        po.setUnitCost(new BigDecimal(request.getParameter("unitCost")));

        // Yeh method ek transaction mein purchase record save karta hai
        // AUR medicine ka stock automatically badha deta hai
        boolean success = purchaseDAO.createPurchaseOrder(po);

        response.sendRedirect(request.getContextPath() +
            "/purchase?msg=" + (success ? "added" : "error"));
    }
}