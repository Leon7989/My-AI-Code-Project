package com.xjgaokao.shared.api;

/** A non-blocking warning accompanying an otherwise successful response. */
public record ApiWarning(String code, String message, String field, String severity) {
}
