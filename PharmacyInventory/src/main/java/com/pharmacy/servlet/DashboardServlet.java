package com.pharmacy.servlet;

import com.pharmacy.dao.DashboardDAO;
import com.pharmacy.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.Map;

/**
 * DashboardServlet.java
 * /dashboard → summary stats load karke dashboard.jsp pe forward karta hai
 */
@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    private DashboardDAO dashboardDAO = new DashboardDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Session check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login.html");
            return;
        }

        // Sab stats load karo
        request.setAttribute("totalMedicines",    dashboardDAO.getTotalMedicines());
        request.setAttribute("totalSuppliers",    dashboardDAO.getTotalSuppliers());
        request.setAttribute("todaySalesCount",   dashboardDAO.getTodaySalesCount());
        request.setAttribute("todayRevenue",      dashboardDAO.getTodayRevenue());
        request.setAttribute("totalRevenue",      dashboardDAO.getTotalRevenue());
        request.setAttribute("lowStockCount",     dashboardDAO.getLowStockCount());
        request.setAttribute("expiringCount",     dashboardDAO.getExpiringCount());
        request.setAttribute("expiredCount",      dashboardDAO.getExpiredCount());
        request.setAttribute("totalPurchases",    dashboardDAO.getTotalPurchaseOrders());
        request.setAttribute("totalSales",        dashboardDAO.getTotalSales());

        // Chart data
        Map<String, BigDecimal> salesChart = dashboardDAO.getLast7DaysSales();
        Map<String, Integer>    catChart   = dashboardDAO.getMedicinesByCategory();

        // JSON strings banao (JavaScript chart ke liye)
        request.setAttribute("salesChartLabels", toJsonStringArray(salesChart.keySet().toArray(new String[0])));
        request.setAttribute("salesChartData",   toJsonNumberArray(salesChart.values().toArray(new BigDecimal[0])));
        request.setAttribute("catChartLabels",   toJsonStringArray(catChart.keySet().toArray(new String[0])));
        request.setAttribute("catChartData",     toJsonNumberArray(catChart.values().toArray(new Integer[0])));

        request.getRequestDispatcher("/dashboard.jsp").forward(request, response);
    }

    private String toJsonStringArray(String[] arr) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < arr.length; i++) {
            sb.append("\"").append(arr[i]).append("\"");
            if (i < arr.length - 1) sb.append(",");
        }
        sb.append("]");
        return sb.toString();
    }

    private String toJsonNumberArray(Object[] arr) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < arr.length; i++) {
            sb.append(arr[i]);
            if (i < arr.length - 1) sb.append(",");
        }
        sb.append("]");
        return sb.toString();
    }
}