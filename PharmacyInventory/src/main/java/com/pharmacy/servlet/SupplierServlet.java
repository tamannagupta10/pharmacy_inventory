package com.pharmacy.servlet;

import com.pharmacy.dao.SupplierDAO;
import com.pharmacy.model.Supplier;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * SupplierServlet.java
 *   /supplier                    → list dikhao
 *   /supplier?action=add         → add form (GET) / save (POST)
 *   /supplier?action=edit&id=5   → edit form (GET) / update (POST)
 *   /supplier?action=delete&id=5 → delete karo
 */
@WebServlet("/supplier")
public class SupplierServlet extends HttpServlet {

    private SupplierDAO supplierDAO = new SupplierDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action == null) {
            List<Supplier> suppliers = supplierDAO.getAllSuppliers();
            request.setAttribute("suppliers", suppliers);
            request.getRequestDispatcher("/supplier-list.jsp").forward(request, response);

        } else if (action.equals("add")) {
            request.getRequestDispatcher("/add-supplier.jsp").forward(request, response);

        } else if (action.equals("edit")) {
            int id = Integer.parseInt(request.getParameter("id"));
            Supplier supplier = supplierDAO.getSupplierById(id);
            request.setAttribute("supplier", supplier);
            request.getRequestDispatcher("/add-supplier.jsp").forward(request, response);

        } else if (action.equals("delete")) {
            int id = Integer.parseInt(request.getParameter("id"));
            supplierDAO.deleteSupplier(id);
            response.sendRedirect(request.getContextPath() + "/supplier?msg=deleted");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("supplierId");

        Supplier s = new Supplier();
        s.setSupplierName(request.getParameter("supplierName"));
        s.setContactName(request.getParameter("contactName"));
        s.setPhone(request.getParameter("phone"));
        s.setEmail(request.getParameter("email"));
        s.setAddress(request.getParameter("address"));

        boolean success;

        if (idParam == null || idParam.isEmpty()) {
            success = supplierDAO.addSupplier(s);
            response.sendRedirect(request.getContextPath() +
                "/supplier?msg=" + (success ? "added" : "error"));
        } else {
            s.setSupplierId(Integer.parseInt(idParam));
            success = supplierDAO.updateSupplier(s);
            response.sendRedirect(request.getContextPath() +
                "/supplier?msg=" + (success ? "updated" : "error"));
        }
    }
}