-- ============================================================================
-- RESUME PARSER MODULE
-- Production-grade schema for resume parsing and extraction
-- ============================================================================

-- Parsed Resumes table - stores parsed resume data
CREATE TABLE IF NOT EXISTS parsed_resumes (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique parsed resume identifier',
    resume_id BIGINT NOT NULL COMMENT 'Reference to candidate_resumes table',
    candidate_id BIGINT NOT NULL COMMENT 'Reference to candidates table',
    parser_version VARCHAR(50) COMMENT 'Resume parser version',
    parser_engine ENUM('RESUME_IO', 'LEVANTA', 'TEXTKERNEL', 'CUSTOM', 'ML_MODEL') COMMENT 'Which parser was used',
    parse_confidence DECIMAL(5, 2) COMMENT 'Parsing confidence score (0-100)',
    raw_text LONGTEXT COMMENT 'Raw extracted text',
    json_data LONGTEXT COMMENT 'Complete parsed JSON data',
    extraction_status ENUM('SUCCESS', 'PARTIAL', 'FAILED') DEFAULT 'PARTIAL' COMMENT 'Extraction status',
    parsing_errors JSON COMMENT 'JSON array of parsing errors',
    warnings JSON COMMENT 'JSON array of parsing warnings',
    total_fields_extracted INT COMMENT 'Total fields successfully extracted',
    total_fields_failed INT COMMENT 'Total fields that failed extraction',
    processing_time_ms INT COMMENT 'Time taken to parse (milliseconds)',
    parsed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'When resume was parsed',
    is_verified BOOLEAN DEFAULT FALSE COMMENT 'Manually verified flag',
    verified_by BIGINT COMMENT 'User ID who verified',
    verified_at TIMESTAMP NULL COMMENT 'When manually verified',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (resume_id) REFERENCES candidate_resumes(id) ON DELETE CASCADE,
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE,
    FOREIGN KEY (verified_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_resume_id (resume_id),
    INDEX idx_candidate_id (candidate_id),
    INDEX idx_parser_engine (parser_engine),
    INDEX idx_extraction_status (extraction_status),
    INDEX idx_parse_confidence (parse_confidence),
    INDEX idx_is_verified (is_verified),
    INDEX idx_parsed_at (parsed_at),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Parsed resume data storage';

-- Parsed Skills table - extracted skills from resume
CREATE TABLE IF NOT EXISTS parsed_skills (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique parsed skill identifier',
    parsed_resume_id BIGINT NOT NULL COMMENT 'Reference to parsed_resumes table',
    candidate_id BIGINT NOT NULL COMMENT 'Reference to candidates table',
    skill_name VARCHAR(100) NOT NULL COMMENT 'Extracted skill name',
    skill_category VARCHAR(100) COMMENT 'Skill category',
    proficiency_level ENUM('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT', 'UNKNOWN') DEFAULT 'UNKNOWN' COMMENT 'Inferred proficiency',
    mentions_count INT DEFAULT 1 COMMENT 'Number of times skill mentioned',
    first_mentioned_in VARCHAR(100) COMMENT 'First mentioned context (job, project, etc)',
    last_mentioned_in VARCHAR(100) COMMENT 'Last mentioned context',
    extraction_confidence DECIMAL(5, 2) COMMENT 'Extraction confidence (0-100)',
    should_import_to_profile BOOLEAN DEFAULT TRUE COMMENT 'Flag to import to candidate profile',
    is_imported BOOLEAN DEFAULT FALSE COMMENT 'Already imported flag',
    is_normalized BOOLEAN DEFAULT FALSE COMMENT 'Skill name normalized flag',
    normalized_skill_name VARCHAR(100) COMMENT 'Normalized skill name',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (parsed_resume_id) REFERENCES parsed_resumes(id) ON DELETE CASCADE,
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE,
    INDEX idx_parsed_resume_id (parsed_resume_id),
    INDEX idx_candidate_id (candidate_id),
    INDEX idx_skill_name (skill_name),
    INDEX idx_normalized_skill_name (normalized_skill_name),
    INDEX idx_proficiency_level (proficiency_level),
    INDEX idx_is_normalized (is_normalized),
    INDEX idx_is_imported (is_imported),
    INDEX idx_extraction_confidence (extraction_confidence),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Parsed skills from resumes';

-- Parsed Education table - extracted education from resume
CREATE TABLE IF NOT EXISTS parsed_education (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique parsed education identifier',
    parsed_resume_id BIGINT NOT NULL COMMENT 'Reference to parsed_resumes table',
    candidate_id BIGINT NOT NULL COMMENT 'Reference to candidates table',
    institution_name VARCHAR(255) NOT NULL COMMENT 'Institution name',
    education_level VARCHAR(100) COMMENT 'Education level',
    field_of_study VARCHAR(255) COMMENT 'Field of study/major',
    grade_cgpa VARCHAR(50) COMMENT 'Grade/CGPA',
    start_date DATE COMMENT 'Start date',
    end_date DATE COMMENT 'End date',
    is_currently_studying BOOLEAN DEFAULT FALSE COMMENT 'Currently studying flag',
    activities_societies TEXT COMMENT 'Activities and societies',
    description TEXT COMMENT 'Description',
    extraction_confidence DECIMAL(5, 2) COMMENT 'Extraction confidence (0-100)',
    should_import_to_profile BOOLEAN DEFAULT TRUE COMMENT 'Flag to import to candidate profile',
    is_imported BOOLEAN DEFAULT FALSE COMMENT 'Already imported flag',
    matched_education_record_id BIGINT COMMENT 'Matched candidate_education record ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (parsed_resume_id) REFERENCES parsed_resumes(id) ON DELETE CASCADE,
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE,
    FOREIGN KEY (matched_education_record_id) REFERENCES candidate_education(id) ON DELETE SET NULL,
    INDEX idx_parsed_resume_id (parsed_resume_id),
    INDEX idx_candidate_id (candidate_id),
    INDEX idx_institution_name (institution_name),
    INDEX idx_education_level (education_level),
    INDEX idx_is_imported (is_imported),
    INDEX idx_extraction_confidence (extraction_confidence),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Parsed education from resumes';

-- Parsed Experience table - extracted experience from resume
CREATE TABLE IF NOT EXISTS parsed_experience (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique parsed experience identifier',
    parsed_resume_id BIGINT NOT NULL COMMENT 'Reference to parsed_resumes table',
    candidate_id BIGINT NOT NULL COMMENT 'Reference to candidates table',
    job_title VARCHAR(255) NOT NULL COMMENT 'Job title',
    company_name VARCHAR(255) NOT NULL COMMENT 'Company name',
    employment_type VARCHAR(100) COMMENT 'Employment type',
    location VARCHAR(255) COMMENT 'Work location',
    start_date DATE COMMENT 'Start date',
    end_date DATE COMMENT 'End date',
    is_currently_working BOOLEAN DEFAULT FALSE COMMENT 'Currently working flag',
    duration_months INT COMMENT 'Duration in months',
    description TEXT COMMENT 'Job description',
    key_achievements TEXT COMMENT 'Key achievements',
    extraction_confidence DECIMAL(5, 2) COMMENT 'Extraction confidence (0-100)',
    should_import_to_profile BOOLEAN DEFAULT TRUE COMMENT 'Flag to import to candidate profile',
    is_imported BOOLEAN DEFAULT FALSE COMMENT 'Already imported flag',
    matched_experience_record_id BIGINT COMMENT 'Matched candidate_experience record ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (parsed_resume_id) REFERENCES parsed_resumes(id) ON DELETE CASCADE,
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE,
    FOREIGN KEY (matched_experience_record_id) REFERENCES candidate_experience(id) ON DELETE SET NULL,
    INDEX idx_parsed_resume_id (parsed_resume_id),
    INDEX idx_candidate_id (candidate_id),
    INDEX idx_company_name (company_name),
    INDEX idx_job_title (job_title),
    INDEX idx_is_imported (is_imported),
    INDEX idx_extraction_confidence (extraction_confidence),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Parsed work experience from resumes';

-- Parsed Projects table - extracted projects from resume
CREATE TABLE IF NOT EXISTS parsed_projects (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique parsed project identifier',
    parsed_resume_id BIGINT NOT NULL COMMENT 'Reference to parsed_resumes table',
    candidate_id BIGINT NOT NULL COMMENT 'Reference to candidates table',
    project_title VARCHAR(255) NOT NULL COMMENT 'Project title',
    description TEXT COMMENT 'Project description',
    start_date DATE COMMENT 'Start date',
    end_date DATE COMMENT 'End date',
    is_active BOOLEAN DEFAULT FALSE COMMENT 'Active project flag',
    technologies_used TEXT COMMENT 'Technologies used',
    role VARCHAR(100) COMMENT 'Role in project',
    project_url VARCHAR(500) COMMENT 'Project URL',
    extraction_confidence DECIMAL(5, 2) COMMENT 'Extraction confidence (0-100)',
    should_import_to_profile BOOLEAN DEFAULT TRUE COMMENT 'Flag to import to candidate profile',
    is_imported BOOLEAN DEFAULT FALSE COMMENT 'Already imported flag',
    matched_project_record_id BIGINT COMMENT 'Matched candidate_projects record ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (parsed_resume_id) REFERENCES parsed_resumes(id) ON DELETE CASCADE,
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE,
    FOREIGN KEY (matched_project_record_id) REFERENCES candidate_projects(id) ON DELETE SET NULL,
    INDEX idx_parsed_resume_id (parsed_resume_id),
    INDEX idx_candidate_id (candidate_id),
    INDEX idx_project_title (project_title),
    INDEX idx_is_imported (is_imported),
    INDEX idx_extraction_confidence (extraction_confidence),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Parsed projects from resumes';

-- Parsed Certifications table - extracted certifications
CREATE TABLE IF NOT EXISTS parsed_certifications (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique parsed certification identifier',
    parsed_resume_id BIGINT NOT NULL COMMENT 'Reference to parsed_resumes table',
    candidate_id BIGINT NOT NULL COMMENT 'Reference to candidates table',
    certification_name VARCHAR(255) NOT NULL COMMENT 'Certification name',
    issuing_organization VARCHAR(255) COMMENT 'Organization',
    issue_date DATE COMMENT 'Issue date',
    expiration_date DATE COMMENT 'Expiration date',
    credential_id VARCHAR(100) COMMENT 'Credential ID',
    credential_url VARCHAR(500) COMMENT 'Credential URL',
    extraction_confidence DECIMAL(5, 2) COMMENT 'Extraction confidence (0-100)',
    should_import_to_profile BOOLEAN DEFAULT TRUE COMMENT 'Flag to import to candidate profile',
    is_imported BOOLEAN DEFAULT FALSE COMMENT 'Already imported flag',
    matched_certification_record_id BIGINT COMMENT 'Matched candidate_certifications record ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (parsed_resume_id) REFERENCES parsed_resumes(id) ON DELETE CASCADE,
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE,
    FOREIGN KEY (matched_certification_record_id) REFERENCES candidate_certifications(id) ON DELETE SET NULL,
    INDEX idx_parsed_resume_id (parsed_resume_id),
    INDEX idx_candidate_id (candidate_id),
    INDEX idx_certification_name (certification_name),
    INDEX idx_is_imported (is_imported),
    INDEX idx_extraction_confidence (extraction_confidence),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Parsed certifications from resumes';

-- Parse Queue table - for async resume parsing
CREATE TABLE IF NOT EXISTS parse_queue (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique queue item identifier',
    resume_id BIGINT NOT NULL COMMENT 'Reference to candidate_resumes table',
    candidate_id BIGINT NOT NULL COMMENT 'Reference to candidates table',
    queue_status ENUM('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED', 'RETRYING') DEFAULT 'PENDING' COMMENT 'Queue status',
    retry_count INT DEFAULT 0 COMMENT 'Number of retry attempts',
    max_retries INT DEFAULT 3 COMMENT 'Maximum retries allowed',
    error_message TEXT COMMENT 'Error message if failed',
    processing_started_at TIMESTAMP NULL COMMENT 'When processing started',
    processing_completed_at TIMESTAMP NULL COMMENT 'When processing completed',
    next_retry_at TIMESTAMP NULL COMMENT 'Next retry attempt time',
    priority INT DEFAULT 5 COMMENT 'Queue priority (1-10, lower = higher priority)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (resume_id) REFERENCES candidate_resumes(id) ON DELETE CASCADE,
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE,
    INDEX idx_queue_status (queue_status),
    INDEX idx_retry_count (retry_count),
    INDEX idx_priority (priority),
    INDEX idx_next_retry_at (next_retry_at),
    INDEX idx_created_at (created_at),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Resume parsing queue for async processing';
