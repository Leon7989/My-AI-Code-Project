package com.xjgaokao.shared.trace;

import jakarta.servlet.http.HttpServletRequest;

/** Request attribute key shared by filters, handlers, and future controllers. */
public final class TraceId {
    public static final String REQUEST_ATTRIBUTE = TraceId.class.getName();

    private TraceId() {
    }

    public static String from(HttpServletRequest request) {
        Object value = request.getAttribute(REQUEST_ATTRIBUTE);
        return value instanceof String traceId ? traceId : "unknown";
    }
}
