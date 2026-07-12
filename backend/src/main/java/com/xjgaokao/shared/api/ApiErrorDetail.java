package com.xjgaokao.shared.api;

/** A field-level error detail permitted by the API contract. */
public record ApiErrorDetail(String field, String reason) {
}
