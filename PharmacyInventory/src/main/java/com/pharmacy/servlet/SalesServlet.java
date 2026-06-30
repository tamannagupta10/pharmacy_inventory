package com.pharmacy.servlet;

import com.pharmacy.dao.SalesDAO;
import com.pharmacy.dao.MedicineDAO;
import com.pharmacy.model.Sale;
import com.pharmacy.model.SaleItem;
import com.pharmacy.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/**
 * SalesServlet.java
 *   /sales                     → sales history dikhao
 *   /sales?action=add          → naya bill banane ka form
 *   /sales?action=view&id=5    → ek bill ka receipt dikhao
 *
 * POST /sales — bill save karta hai.
 * Form se medicineId[], quantity[], unitPrice[] arrays aate hain
 * (kyunki ek bill mein multiple medicines ho sakti hain)
 */
@WebServlet("/sales")
public class SalesServlet extends HttpServlet {

    private SalesDAO    salesDAO    = new SalesDAO();
    private MedicineDAO medicineDAO = new MedicineDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action == null) {
            // Sales history dikhao
            List<Sale> sales = salesDAO.getAllSales();
            request.setAttribute("sales", sales);
            request.getRequestDispatcher("/sales-history.jsp").forward(request, response);

        } else if (action.equals("add")) {
            // Naya bill banane ka form — medicines list dropdown ke liye
            request.setAttribute("medicines", medicineDAO.getAllMedicines());
            request.getRequestDispatcher("/create-bill.jsp").forward(request, response);

        } else if (action.equals("view")) {
            // Ek bill ka receipt dikhao
            int id = Integer.parseInt(request.getParameter("id"));
            Sale sale = salesDAO.getSaleById(id);
            request.setAttribute("sale", sale);
            request.getRequestDispatcher("/bill-receipt.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Logged-in user ka ID lena hai (kisne bill banaya)
        HttpSession session = request.getSession(false);
        User loggedUser = (User) session.getAttribute("loggedUser");

        String customerName = request.getParameter("customerName");
        if (customerName == null || customerName.trim().isEmpty()) {
            customerName = "Walk-in Customer";
        }

        // Arrays se data padho - JS form mein medicineId[], quantity[], unitPrice[] bheja jaata hai
        String[] medicineIds = request.getParameterValues("medicineId[]");
        String[] quantities  = request.getParameterValues("quantity[]");
        String[] unitPrices  = request.getParameterValues("unitPrice[]");

        if (medicineIds == null || medicineIds.length == 0) {
            response.sendRedirect(request.getContextPath() + "/sales?action=add&msg=empty");
            return;
        }

        // Sale object banao
        Sale sale = new Sale();
        sale.setCustomerName(customerName);
        sale.setSoldBy(loggedUser.getUserId());

        List<SaleItem> items = new ArrayList<>();
        BigDecimal total = BigDecimal.ZERO;

        for (int i = 0; i < medicineIds.length; i++) {
            SaleItem item = new SaleItem();
            item.setMedicineId(Integer.parseInt(medicineIds[i]));
            item.setQuantity(Integer.parseInt(quantities[i]));
            item.setUnitPrice(new BigDecimal(unitPrices[i]));
            items.add(item);

            // Total amount calculate karo
            BigDecimal lineTotal = item.getUnitPrice().multiply(new BigDecimal(item.getQuantity()));
            total = total.add(lineTotal);
        }

        sale.setItems(items);
        sale.setTotalAmount(total);

        // Transaction ke saath bill save karo
        String error = salesDAO.createSale(sale);

        if (error == null) {
            // Success - receipt page pe bhejo
            response.sendRedirect(request.getContextPath() + "/sales?action=view&id=" + sale.getSaleId());
        } else {
            // Error - error message ke saath form pe wapas
            request.setAttribute("errorMessage", error);
            request.setAttribute("medicines", medicineDAO.getAllMedicines());
            request.getRequestDispatcher("/create-bill.jsp").forward(request, response);
        }
    }
}