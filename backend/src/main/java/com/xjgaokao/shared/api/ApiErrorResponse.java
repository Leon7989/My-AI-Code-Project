package com.xjgaokao.shared.api;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.util.List;

/** Contract-aligned envelope for errors. Never expose exception classes or stack traces. */
@JsonInclude(JsonInclude.Include.NON_EMPTY)
public record ApiErrorResponse(
        String code,
        String message,
        List<ApiErrorDetail> details,
        String traceId
) {
}
