package com.pharmacy.servlet;

import com.pharmacy.dao.AlertDAO;
import com.pharmacy.model.Medicine;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * AlertServlet.java
 *   /alerts              → sab alerts ek saath dikhao
 *   /alerts?type=expired → sirf expired medicines
 *   /alerts?type=expiring → sirf 30 din mein expire hongi
 *   /alerts?type=lowstock → sirf low stock
 *   /alerts?type=outofstock → sirf out of stock
 */
@WebServlet("/alerts")
public class AlertServlet extends HttpServlet {

    private AlertDAO alertDAO = new AlertDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String type = request.getParameter("type");

        if (type == null) {
            // Default: sab 4 categories ek saath dikhao
            request.setAttribute("expiredList",    alertDAO.getExpiredMedicines());
            request.setAttribute("expiringList",   alertDAO.getExpiringMedicines());
            request.setAttribute("outOfStockList", alertDAO.getOutOfStockMedicines());
            request.setAttribute("lowStockList",   alertDAO.getLowStockMedicines());

            // Counts bhi bhejo (tab badges ke liye)
            request.setAttribute("expiredCount",    alertDAO.countExpired());
            request.setAttribute("expiringCount",   alertDAO.countExpiring());
            request.setAttribute("outOfStockCount", alertDAO.countOutOfStock());
            request.setAttribute("lowStockCount",   alertDAO.countLowStock());

            request.getRequestDispatcher("/alerts-dashboard.jsp").forward(request, response);

        } else {
            // Filter: sirf ek type dikhao
            List<Medicine> filteredList = null;
            String title = "";

            switch (type) {
                case "expired":
                    filteredList = alertDAO.getExpiredMedicines();
                    title = "Expired Medicines";
                    break;
                case "expiring":
                    filteredList = alertDAO.getExpiringMedicines();
                    title = "Expiring in 30 Days";
                    break;
                case "outofstock":
                    filteredList = alertDAO.getOutOfStockMedicines();
                    title = "Out of Stock";
                    break;
                case "lowstock":
                    filteredList = alertDAO.getLowStockMedicines();
                    title = "Low Stock";
                    break;
            }

            request.setAttribute("filteredList", filteredList);
            request.setAttribute("filterTitle", title);
            request.setAttribute("filterType", type);
            request.getRequestDispatcher("/alerts-dashboard.jsp").forward(request, response);
        }
    }
}