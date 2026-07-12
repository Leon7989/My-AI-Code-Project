package com.xjgaokao.shared.api;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.util.List;

/** Contract-aligned envelope for successful user and admin API responses. */
@JsonInclude(JsonInclude.Include.NON_EMPTY)
public record ApiResponse<T>(
        String code,
        String message,
        T data,
        List<ApiWarning> warnings,
        String traceId
) {
    public static <T> ApiResponse<T> success(T data, String traceId) {
        return new ApiResponse<>("OK", "success", data, List.of(), traceId);
    }

    public static <T> ApiResponse<T> success(T data, List<ApiWarning> warnings, String traceId) {
        return new ApiResponse<>("OK", "success", data, List.copyOf(warnings), traceId);
    }
}
