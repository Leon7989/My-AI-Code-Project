CREATE TABLE data_version (
    id BIGINT NOT NULL AUTO_INCREMENT,
    public_id CHAR(26) NOT NULL,
    version_code VARCHAR(128) NOT NULL,
    dataset_type VARCHAR(64) NOT NULL,
    exam_year INT NOT NULL,
    version_no INT NOT NULL,
    status VARCHAR(32) NOT NULL,
    published_at DATETIME(3) NULL,
    supersedes_version_id BIGINT NULL,
    content_hash CHAR(64) NOT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    created_by BIGINT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_data_version_public_id (public_id),
    UNIQUE KEY uk_data_version_code (version_code),
    KEY idx_data_version_dataset_year_status (dataset_type, exam_year, status),
    CONSTRAINT fk_data_version_supersedes FOREIGN KEY (supersedes_version_id) REFERENCES data_version (id),
    CONSTRAINT fk_data_version_created_by FOREIGN KEY (created_by) REFERENCES app_user (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE data_version_source (
    id BIGINT NOT NULL AUTO_INCREMENT,
    data_version_id BIGINT NOT NULL,
    policy_source_id BIGINT NOT NULL,
    source_role VARCHAR(32) NOT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    UNIQUE KEY uk_data_version_source_role (data_version_id, policy_source_id, source_role),
    CONSTRAINT fk_data_version_source_version FOREIGN KEY (data_version_id) REFERENCES data_version (id),
    CONSTRAINT fk_data_version_source_policy FOREIGN KEY (policy_source_id) REFERENCES policy_source (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
