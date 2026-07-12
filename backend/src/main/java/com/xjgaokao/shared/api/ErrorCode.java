package com.xjgaokao.shared.api;

import org.springframework.http.HttpStatus;

/** Shared error namespace; module-specific codes remain owned by their modules. */
public enum ErrorCode {
    INVALID_REQUEST("COMMON_001", "Invalid request", HttpStatus.BAD_REQUEST),
    VALIDATION_FAILED("COMMON_002", "Validation failed", HttpStatus.BAD_REQUEST),
    RESOURCE_NOT_FOUND("COMMON_003", "Resource not found", HttpStatus.NOT_FOUND),
    STATE_CONFLICT("COMMON_004", "State conflict", HttpStatus.CONFLICT),
    RATE_LIMITED("COMMON_005", "Rate limited", HttpStatus.TOO_MANY_REQUESTS),
    INTERNAL_ERROR("COMMON_500", "Internal server error", HttpStatus.INTERNAL_SERVER_ERROR),
    UNAUTHENTICATED("AUTH_001", "Unauthenticated", HttpStatus.UNAUTHORIZED),
    FORBIDDEN("AUTH_004", "Forbidden", HttpStatus.FORBIDDEN),
    PRINCIPAL_TYPE_MISMATCH("AUTH_005", "Principal type mismatch", HttpStatus.FORBIDDEN);

    private final String value;
    private final String defaultMessage;
    private final HttpStatus status;

    ErrorCode(String value, String defaultMessage, HttpStatus status) {
        this.value = value;
        this.defaultMessage = defaultMessage;
        this.status = status;
    }

    public String value() {
        return value;
    }

    public String defaultMessage() {
        return defaultMessage;
    }

    public HttpStatus status() {
        return status;
    }
}
