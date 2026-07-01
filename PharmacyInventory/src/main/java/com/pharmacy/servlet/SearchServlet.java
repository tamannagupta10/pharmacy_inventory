package com.pharmacy.servlet;

import com.pharmacy.dao.MedicineDAO;
import com.pharmacy.dao.SupplierDAO;
import com.pharmacy.model.Medicine;
import com.pharmacy.model.Supplier;
import com.pharmacy.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * SearchServlet.java
 * Global search — medicines + suppliers dono mein search karta hai
 * /search?q=paracetamol
 */
@WebServlet("/search")
public class SearchServlet extends HttpServlet {

    private MedicineDAO medicineDAO = new MedicineDAO();
    private SupplierDAO supplierDAO = new SupplierDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login.html");
            return;
        }

        String keyword = request.getParameter("q");

        if (keyword != null && !keyword.trim().isEmpty()) {
            keyword = keyword.trim();
            List<Medicine> medicines = medicineDAO.searchMedicines(keyword);
            List<Supplier> suppliers = supplierDAO.searchSuppliers(keyword);

            request.setAttribute("keyword",   keyword);
            request.setAttribute("medicines", medicines);
            request.setAttribute("suppliers", suppliers);
            request.setAttribute("totalResults", medicines.size() + suppliers.size());
        }

        request.getRequestDispatcher("/search-results.jsp").forward(request, response);
    }
}