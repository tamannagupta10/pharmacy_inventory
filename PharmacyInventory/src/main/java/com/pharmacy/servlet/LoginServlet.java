package com.pharmacy.servlet;

import com.pharmacy.dao.UserDAO;
import com.pharmacy.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;


@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Step 1 - Form se username aur password lo
        String username = request.getParameter("username").trim();
        String password = request.getParameter("password").trim();

        // Step 2 - DAO se validate karo
        UserDAO userDAO = new UserDAO();
        User user = userDAO.validateLogin(username, password);

        if (user != null) {
            // Step 3 - Login sahi: session banao
            HttpSession session = request.getSession();
            session.setAttribute("loggedUser", user);
            session.setAttribute("fullName",   user.getFullName());
            session.setAttribute("username",   user.getUsername());
            session.setAttribute("role",       user.getRole());
            session.setMaxInactiveInterval(30 * 60); // 30 min

            // Step 4 - Dashboard pe redirect karo
            response.sendRedirect(request.getContextPath() + "/dashboard.jsp");

        } else {
            // Step 5 - Login galat: wapas login pe error ke saath
            response.sendRedirect(request.getContextPath() + "/login.html?error=1");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Koi seedha /login URL khole toh login page pe bhejo
        response.sendRedirect(request.getContextPath() + "/login.html");
    }
}
