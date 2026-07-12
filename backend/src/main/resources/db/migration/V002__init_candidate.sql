CREATE TABLE candidate (
    id BIGINT NOT NULL AUTO_INCREMENT,
    public_id CHAR(26) NOT NULL,
    owner_user_id BIGINT NOT NULL,
    display_name VARCHAR(128) NOT NULL,
    status VARCHAR(32) NOT NULL,
    active_exam_profile_id BIGINT NULL,
    active_eligibility_profile_id BIGINT NULL,
    active_preference_profile_id BIGINT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    UNIQUE KEY uk_candidate_public_id (public_id),
    KEY idx_candidate_owner_status (owner_user_id, status),
    CONSTRAINT fk_candidate_owner FOREIGN KEY (owner_user_id) REFERENCES app_user (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE candidate_exam_profile (
    id BIGINT NOT NULL AUTO_INCREMENT,
    public_id CHAR(26) NOT NULL,
    candidate_id BIGINT NOT NULL,
    profile_version INT NOT NULL,
    exam_year INT NOT NULL,
    exam_regime VARCHAR(32) NOT NULL,
    raw_score DECIMAL(7,2) NULL,
    policy_bonus_score DECIMAL(7,2) NULL,
    effective_submission_score DECIMAL(7,2) NULL,
    rank_value BIGINT NULL,
    rank_scope_code VARCHAR(64) NULL,
    plan_type VARCHAR(32) NOT NULL,
    subject_track VARCHAR(32) NULL,
    exam_language_path VARCHAR(32) NULL,
    foreign_language_type VARCHAR(32) NULL,
    application_scope VARCHAR(64) NULL,
    profile_status VARCHAR(32) NOT NULL,
    source_type VARCHAR(32) NOT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    created_by BIGINT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_candidate_exam_profile_public_id (public_id),
    UNIQUE KEY uk_candidate_exam_profile_version (candidate_id, exam_year, profile_version),
    KEY idx_candidate_exam_profile_candidate_year (candidate_id, exam_year),
    KEY idx_candidate_exam_profile_year_regime (exam_year, exam_regime),
    CONSTRAINT fk_candidate_exam_profile_candidate FOREIGN KEY (candidate_id) REFERENCES candidate (id),
    CONSTRAINT fk_candidate_exam_profile_created_by FOREIGN KEY (created_by) REFERENCES app_user (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE candidate_subject_selection (
    id BIGINT NOT NULL AUTO_INCREMENT,
    exam_profile_id BIGINT NOT NULL,
    subject_role VARCHAR(32) NOT NULL,
    subject_code VARCHAR(32) NOT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    UNIQUE KEY uk_candidate_subject_selection (exam_profile_id, subject_role, subject_code),
    CONSTRAINT fk_candidate_subject_selection_profile FOREIGN KEY (exam_profile_id) REFERENCES candidate_exam_profile (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE candidate_eligibility_profile (
    id BIGINT NOT NULL AUTO_INCREMENT,
    public_id CHAR(26) NOT NULL,
    candidate_id BIGINT NOT NULL,
    exam_year INT NOT NULL,
    profile_version INT NOT NULL,
    verification_level VARCHAR(32) NOT NULL,
    profile_status VARCHAR(32) NOT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    created_by BIGINT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_candidate_eligibility_profile_public_id (public_id),
    UNIQUE KEY uk_candidate_eligibility_profile_version (candidate_id, exam_year, profile_version),
    CONSTRAINT fk_candidate_eligibility_profile_candidate FOREIGN KEY (candidate_id) REFERENCES candidate (id),
    CONSTRAINT fk_candidate_eligibility_profile_created_by FOREIGN KEY (created_by) REFERENCES app_user (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE candidate_eligibility_item (
    id BIGINT NOT NULL AUTO_INCREMENT,
    eligibility_profile_id BIGINT NOT NULL,
    eligibility_type VARCHAR(64) NOT NULL,
    eligibility_status VARCHAR(32) NOT NULL,
    region_code VARCHAR(32) NULL,
    effective_from DATETIME(3) NULL,
    effective_to DATETIME(3) NULL,
    verification_source VARCHAR(64) NULL,
    policy_source_id BIGINT NULL,
    notes VARCHAR(1000) NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    KEY idx_candidate_eligibility_item_type (eligibility_profile_id, eligibility_type),
    CONSTRAINT fk_candidate_eligibility_item_profile FOREIGN KEY (eligibility_profile_id) REFERENCES candidate_eligibility_profile (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE candidate_preference_profile (
    id BIGINT NOT NULL AUTO_INCREMENT,
    public_id CHAR(26) NOT NULL,
    candidate_id BIGINT NOT NULL,
    profile_version INT NOT NULL,
    adjustment_acceptance VARCHAR(32) NOT NULL,
    max_tuition DECIMAL(12,2) NULL,
    school_priority_weight DECIMAL(7,2) NULL,
    major_priority_weight DECIMAL(7,2) NULL,
    city_priority_weight DECIMAL(7,2) NULL,
    future_plan VARCHAR(64) NULL,
    profile_status VARCHAR(32) NOT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    UNIQUE KEY uk_candidate_preference_profile_public_id (public_id),
    UNIQUE KEY uk_candidate_preference_profile_version (candidate_id, profile_version),
    CONSTRAINT fk_candidate_preference_profile_candidate FOREIGN KEY (candidate_id) REFERENCES candidate (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE candidate_preference_item (
    id BIGINT NOT NULL AUTO_INCREMENT,
    preference_profile_id BIGINT NOT NULL,
    preference_type VARCHAR(32) NOT NULL,
    target_code VARCHAR(128) NULL,
    target_id BIGINT NULL,
    priority INT NOT NULL,
    preference_mode VARCHAR(32) NOT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    KEY idx_candidate_preference_item_profile (preference_profile_id, preference_type, priority),
    CONSTRAINT fk_candidate_preference_item_profile FOREIGN KEY (preference_profile_id) REFERENCES candidate_preference_profile (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
