package com.xjgaokao.shared.auth;

import java.util.Objects;

/** Authenticated principal abstraction; token format remains an Open Decision. */
public record RequestPrincipal(String subjectId, PrincipalType type) {
    public RequestPrincipal {
        Objects.requireNonNull(subjectId, "subjectId must not be null");
        Objects.requireNonNull(type, "type must not be null");
    }
}
