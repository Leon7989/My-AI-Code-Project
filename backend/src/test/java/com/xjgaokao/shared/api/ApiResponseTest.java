package com.xjgaokao.shared.api;

import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class ApiResponseTest {

    @Test
    void createsTheFrozenSuccessEnvelope() {
        ApiResponse<String> response = ApiResponse.success("payload", "trace-123");

        assertThat(response.code()).isEqualTo("OK");
        assertThat(response.message()).isEqualTo("success");
        assertThat(response.data()).isEqualTo("payload");
        assertThat(response.warnings()).isEmpty();
        assertThat(response.traceId()).isEqualTo("trace-123");
    }

    @Test
    void preservesWarningsOnSuccessfulResponses() {
        ApiWarning warning = new ApiWarning("XJ_WARN_001", "Pending", "eligibilities", "WARNING");

        ApiResponse<String> response = ApiResponse.success("payload", List.of(warning), "trace-123");

        assertThat(response.warnings()).containsExactly(warning);
    }
}
