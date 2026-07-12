package com.xjgaokao.shared.auth;

import com.xjgaokao.shared.api.ApiException;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class PrincipalAccessGuardTest {
    private final PrincipalAccessGuard guard = new PrincipalAccessGuard();

    @Test
    void acceptsTheExpectedPrincipalType() {
        assertThatCode(() -> guard.require(new RequestPrincipal("user-1", PrincipalType.USER), PrincipalType.USER))
                .doesNotThrowAnyException();
    }

    @Test
    void rejectsAnUnexpectedPrincipalType() {
        assertThatThrownBy(() -> guard.require(new RequestPrincipal("admin-1", PrincipalType.ADMIN), PrincipalType.USER))
                .isInstanceOf(ApiException.class)
                .extracting(exception -> ((ApiException) exception).errorCode().value())
                .isEqualTo("AUTH_005");
    }
}
