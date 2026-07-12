package com.xjgaokao.shared.trace;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.UUID;

/** Generates a server trace identifier for every HTTP request. */
@Component
@Order(Integer.MIN_VALUE)
public class TraceIdFilter implements Filter {
    public static final String RESPONSE_HEADER = "X-Trace-Id";

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        String traceId = UUID.randomUUID().toString();
        request.setAttribute(TraceId.REQUEST_ATTRIBUTE, traceId);
        if (response instanceof HttpServletResponse httpResponse) {
            httpResponse.setHeader(RESPONSE_HEADER, traceId);
        }
        chain.doFilter(request, response);
    }
}
