package com.pharmacy.servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * LogoutServlet.java
 * GET /logout → session destroy karo → login pe bhejo
 */
@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Session lo aur destroy karo
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }

        // Login page pe bhejo
        response.sendRedirect(request.getContextPath() + "/login.html");
    }
}
