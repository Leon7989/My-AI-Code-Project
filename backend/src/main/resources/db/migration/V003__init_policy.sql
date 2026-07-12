CREATE TABLE policy_source (
    id BIGINT NOT NULL AUTO_INCREMENT,
    public_id CHAR(26) NOT NULL,
    title VARCHAR(500) NOT NULL,
    issuer VARCHAR(255) NULL,
    source_type VARCHAR(64) NOT NULL,
    publication_date DATE NULL,
    effective_from DATETIME(3) NULL,
    effective_to DATETIME(3) NULL,
    canonical_location VARCHAR(1000) NOT NULL,
    status VARCHAR(32) NOT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    UNIQUE KEY uk_policy_source_public_id (public_id),
    KEY idx_policy_source_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE policy_document_snapshot (
    id BIGINT NOT NULL AUTO_INCREMENT,
    policy_source_id BIGINT NOT NULL,
    snapshot_version INT NOT NULL,
    object_file_id BIGINT NULL,
    content_hash CHAR(64) NOT NULL,
    retrieved_at DATETIME(3) NOT NULL,
    parser_version VARCHAR(64) NULL,
    review_status VARCHAR(32) NOT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    UNIQUE KEY uk_policy_document_snapshot_version (policy_source_id, snapshot_version),
    KEY idx_policy_document_snapshot_hash (content_hash),
    CONSTRAINT fk_policy_document_snapshot_source FOREIGN KEY (policy_source_id) REFERENCES policy_source (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE rule_set (
    id BIGINT NOT NULL AUTO_INCREMENT,
    public_id CHAR(26) NOT NULL,
    rule_set_code VARCHAR(64) NOT NULL,
    exam_year INT NOT NULL,
    exam_regime VARCHAR(32) NOT NULL,
    version_no INT NOT NULL,
    status VARCHAR(32) NOT NULL,
    effective_from DATETIME(3) NULL,
    effective_to DATETIME(3) NULL,
    published_at DATETIME(3) NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    UNIQUE KEY uk_rule_set_public_id (public_id),
    UNIQUE KEY uk_rule_set_code (rule_set_code),
    UNIQUE KEY uk_rule_set_year_version (exam_year, version_no),
    KEY idx_rule_set_year_regime_status (exam_year, exam_regime, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE business_rule (
    id BIGINT NOT NULL AUTO_INCREMENT,
    rule_set_id BIGINT NOT NULL,
    rule_code VARCHAR(128) NOT NULL,
    rule_name VARCHAR(255) NOT NULL,
    rule_type VARCHAR(32) NOT NULL,
    implementation_key VARCHAR(128) NOT NULL,
    priority INT NOT NULL,
    parameters_json JSON NULL,
    severity VARCHAR(32) NOT NULL,
    status VARCHAR(32) NOT NULL,
    policy_source_id BIGINT NULL,
    effective_from DATETIME(3) NULL,
    effective_to DATETIME(3) NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    UNIQUE KEY uk_business_rule_code (rule_set_id, rule_code),
    KEY idx_business_rule_execution (rule_set_id, status, priority),
    CONSTRAINT fk_business_rule_rule_set FOREIGN KEY (rule_set_id) REFERENCES rule_set (id),
    CONSTRAINT fk_business_rule_policy_source FOREIGN KEY (policy_source_id) REFERENCES policy_source (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE policy_conflict (
    id BIGINT NOT NULL AUTO_INCREMENT,
    public_id CHAR(26) NOT NULL,
    conflict_code VARCHAR(64) NOT NULL,
    topic VARCHAR(255) NOT NULL,
    source_a_id BIGINT NOT NULL,
    source_b_id BIGINT NOT NULL,
    description TEXT NOT NULL,
    severity VARCHAR(32) NOT NULL,
    resolution_status VARCHAR(32) NOT NULL,
    resolution_text TEXT NULL,
    resolved_by_admin_id BIGINT NULL,
    resolved_at DATETIME(3) NULL,
    effective_rule_set_id BIGINT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    UNIQUE KEY uk_policy_conflict_public_id (public_id),
    UNIQUE KEY uk_policy_conflict_code (conflict_code),
    KEY idx_policy_conflict_status (resolution_status),
    CONSTRAINT fk_policy_conflict_source_a FOREIGN KEY (source_a_id) REFERENCES policy_source (id),
    CONSTRAINT fk_policy_conflict_source_b FOREIGN KEY (source_b_id) REFERENCES policy_source (id),
    CONSTRAINT fk_policy_conflict_rule_set FOREIGN KEY (effective_rule_set_id) REFERENCES rule_set (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE admission_batch (
    id BIGINT NOT NULL AUTO_INCREMENT,
    exam_year INT NOT NULL,
    batch_code VARCHAR(64) NOT NULL,
    batch_name VARCHAR(255) NOT NULL,
    batch_category VARCHAR(64) NOT NULL,
    sequence_order INT NOT NULL,
    status VARCHAR(32) NOT NULL,
    policy_source_id BIGINT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    UNIQUE KEY uk_admission_batch_year_code (exam_year, batch_code),
    KEY idx_admission_batch_year_status (exam_year, status),
    CONSTRAINT fk_admission_batch_policy_source FOREIGN KEY (policy_source_id) REFERENCES policy_source (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE batch_rule (
    id BIGINT NOT NULL AUTO_INCREMENT,
    admission_batch_id BIGINT NOT NULL,
    rule_set_id BIGINT NOT NULL,
    submission_mode VARCHAR(32) NOT NULL,
    max_school_choices INT NULL,
    max_major_choices_per_choice INT NULL,
    parallel_group_count INT NULL,
    allow_adjustment BOOLEAN NOT NULL,
    eligibility_expression_key VARCHAR(128) NULL,
    status VARCHAR(32) NOT NULL,
    policy_source_id BIGINT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    UNIQUE KEY uk_batch_rule_batch_rule_set (admission_batch_id, rule_set_id),
    CONSTRAINT fk_batch_rule_batch FOREIGN KEY (admission_batch_id) REFERENCES admission_batch (id),
    CONSTRAINT fk_batch_rule_rule_set FOREIGN KEY (rule_set_id) REFERENCES rule_set (id),
    CONSTRAINT fk_batch_rule_policy_source FOREIGN KEY (policy_source_id) REFERENCES policy_source (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE candidate_eligibility_item
    ADD CONSTRAINT fk_candidate_eligibility_item_policy_source
    FOREIGN KEY (policy_source_id) REFERENCES policy_source (id);
