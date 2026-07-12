package com.xjgaokao.shared.api;

import java.util.List;

/** Known application error mapped to the public API error envelope. */
public class ApiException extends RuntimeException {
    private final ErrorCode errorCode;
    private final List<ApiErrorDetail> details;

    public ApiException(ErrorCode errorCode) {
        this(errorCode, errorCode.defaultMessage(), List.of());
    }

    public ApiException(ErrorCode errorCode, String message, List<ApiErrorDetail> details) {
        super(message);
        this.errorCode = errorCode;
        this.details = List.copyOf(details);
    }

    public ErrorCode errorCode() {
        return errorCode;
    }

    public List<ApiErrorDetail> details() {
        return details;
    }
}
