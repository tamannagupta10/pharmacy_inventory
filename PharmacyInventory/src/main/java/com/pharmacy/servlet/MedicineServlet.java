package com.pharmacy.servlet;

import com.pharmacy.dao.MedicineDAO;
import com.pharmacy.dao.CategoryDAO;
import com.pharmacy.dao.SupplierDAO;
import com.pharmacy.model.Medicine;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;

/**
 * MedicineServlet.java
 * Ek hi servlet sab kaam handle karta hai using "action" parameter:
 *   /medicine            → list dikhao
 *   /medicine?action=add        → add form dikhao (GET) / save karo (POST)
 *   /medicine?action=edit&id=5  → edit form dikhao (GET) / update karo (POST)
 *   /medicine?action=delete&id=5 → delete karo
 */
@WebServlet("/medicine")
public class MedicineServlet extends HttpServlet {

    private MedicineDAO medicineDAO = new MedicineDAO();
    private CategoryDAO categoryDAO = new CategoryDAO();
    private SupplierDAO supplierDAO = new SupplierDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action == null) {
            // Default: sab medicines ki list dikhao
            showList(request, response);

        } else if (action.equals("add")) {
            // Add form dikhao (dropdowns ke saath)
            loadDropdowns(request);
            request.getRequestDispatcher("/add-medicine.jsp").forward(request, response);

        } else if (action.equals("edit")) {
            // Edit form dikhao — existing data ke saath
            int id = Integer.parseInt(request.getParameter("id"));
            Medicine medicine = medicineDAO.getMedicineById(id);
            request.setAttribute("medicine", medicine);
            loadDropdowns(request);
            request.getRequestDispatcher("/add-medicine.jsp").forward(request, response);

        } else if (action.equals("delete")) {
            // Delete karo aur list pe wapas bhejo
            int id = Integer.parseInt(request.getParameter("id"));
            medicineDAO.deleteMedicine(id);
            response.sendRedirect(request.getContextPath() + "/medicine?msg=deleted");

        } else if (action.equals("search")) {
            // Search karo
            String keyword = request.getParameter("keyword");
            List<Medicine> results = medicineDAO.searchMedicines(keyword);
            request.setAttribute("medicines", results);
            request.setAttribute("searchKeyword", keyword);
            request.getRequestDispatcher("/medicine-list.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Form se data padho
        String idParam = request.getParameter("medicineId");

        Medicine m = new Medicine();
        m.setMedicineName(request.getParameter("medicineName"));
        m.setBrandName(request.getParameter("brandName"));
        m.setCategoryId(Integer.parseInt(request.getParameter("categoryId")));
        m.setSupplierId(Integer.parseInt(request.getParameter("supplierId")));
        m.setQuantity(Integer.parseInt(request.getParameter("quantity")));
        m.setMinStock(Integer.parseInt(request.getParameter("minStock")));
        m.setUnitPrice(new BigDecimal(request.getParameter("unitPrice")));
        m.setExpiryDate(Date.valueOf(request.getParameter("expiryDate")));
        m.setManufactureDate(Date.valueOf(request.getParameter("manufactureDate")));
        m.setDescription(request.getParameter("description"));

        boolean success;

        if (idParam == null || idParam.isEmpty()) {
            // Naya medicine add karo
            success = medicineDAO.addMedicine(m);
            response.sendRedirect(request.getContextPath() +
                "/medicine?msg=" + (success ? "added" : "error"));
        } else {
            // Existing medicine update karo
            m.setMedicineId(Integer.parseInt(idParam));
            success = medicineDAO.updateMedicine(m);
            response.sendRedirect(request.getContextPath() +
                "/medicine?msg=" + (success ? "updated" : "error"));
        }
    }

    /** List page ko data deta hai */
    private void showList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Medicine> medicines = medicineDAO.getAllMedicines();
        request.setAttribute("medicines", medicines);
        request.getRequestDispatcher("/medicine-list.jsp").forward(request, response);
    }

    /** Add/Edit form ke dropdowns (category + supplier list) load karta hai */
    private void loadDropdowns(HttpServletRequest request) {
        request.setAttribute("categories", categoryDAO.getAllCategories());
        request.setAttribute("suppliers", supplierDAO.getAllSuppliers());
    }
}