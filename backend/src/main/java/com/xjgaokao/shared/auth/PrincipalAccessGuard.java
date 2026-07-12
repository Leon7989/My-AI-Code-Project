package com.xjgaokao.shared.auth;

import com.xjgaokao.shared.api.ApiException;
import com.xjgaokao.shared.api.ErrorCode;
import org.springframework.stereotype.Component;

/** Enforces the non-interchangeability of user and administrator principals. */
@Component
public class PrincipalAccessGuard {

    public void require(RequestPrincipal principal, PrincipalType expectedType) {
        if (principal == null) {
            throw new ApiException(ErrorCode.UNAUTHENTICATED);
        }
        if (principal.type() != expectedType) {
            throw new ApiException(ErrorCode.PRINCIPAL_TYPE_MISMATCH);
        }
    }
}
