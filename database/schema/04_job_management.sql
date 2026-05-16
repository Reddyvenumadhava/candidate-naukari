-- ============================================================================
-- JOB MANAGEMENT MODULE
-- Production-grade schema for job postings and requirements
-- ============================================================================

-- Job Categories table
CREATE TABLE IF NOT EXISTS job_categories (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique category identifier',
    category_name VARCHAR(100) NOT NULL UNIQUE COMMENT 'Category name',
    description TEXT COMMENT 'Category description',
    icon_url VARCHAR(500) COMMENT 'Category icon URL',
    display_order INT COMMENT 'Display order',
    is_active BOOLEAN DEFAULT TRUE COMMENT 'Active status',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    INDEX idx_is_active (is_active),
    INDEX idx_display_order (display_order),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Job categories';

-- Job Types table
CREATE TABLE IF NOT EXISTS job_types (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique type identifier',
    type_name VARCHAR(50) NOT NULL UNIQUE COMMENT 'Job type name',
    description TEXT COMMENT 'Type description',
    is_active BOOLEAN DEFAULT TRUE COMMENT 'Active status',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    INDEX idx_is_active (is_active),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Job employment types';

-- Jobs table - main job postings
CREATE TABLE IF NOT EXISTS jobs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique job identifier',
    company_id BIGINT NOT NULL COMMENT 'Reference to companies table',
    job_title VARCHAR(255) NOT NULL COMMENT 'Job title',
    job_slug VARCHAR(100) COMMENT 'URL-friendly job slug',
    job_description LONGTEXT NOT NULL COMMENT 'Detailed job description',
    job_summary VARCHAR(500) COMMENT 'Short job summary',
    category_id BIGINT NOT NULL COMMENT 'Reference to job_categories table',
    job_type_id BIGINT NOT NULL COMMENT 'Reference to job_types table',
    experience_level ENUM('ENTRY_LEVEL', 'JUNIOR', 'SENIOR', 'LEAD', 'MANAGER', 'DIRECTOR', 'EXECUTIVE') COMMENT 'Required experience level',
    min_experience_years INT COMMENT 'Minimum years of experience',
    max_experience_years INT COMMENT 'Maximum years of experience',
    salary_min INT COMMENT 'Minimum salary',
    salary_max INT COMMENT 'Maximum salary',
    salary_currency VARCHAR(10) DEFAULT 'INR' COMMENT 'Salary currency',
    salary_frequency ENUM('MONTHLY', 'YEARLY') DEFAULT 'YEARLY' COMMENT 'Salary frequency',
    is_salary_visible BOOLEAN DEFAULT TRUE COMMENT 'Show salary to candidates',
    number_of_positions INT DEFAULT 1 COMMENT 'Number of open positions',
    education_requirement VARCHAR(255) COMMENT 'Education requirement',
    location_id BIGINT COMMENT 'Reference to company_locations table',
    location_type ENUM('ON_SITE', 'REMOTE', 'HYBRID') DEFAULT 'ON_SITE' COMMENT 'Work location type',
    is_work_from_home_available BOOLEAN DEFAULT FALSE COMMENT 'Work from home option',
    travel_required ENUM('NO', 'OCCASIONAL', 'FREQUENT') DEFAULT 'NO' COMMENT 'Travel requirement',
    visa_sponsorship BOOLEAN DEFAULT FALSE COMMENT 'Visa sponsorship available',
    is_featured BOOLEAN DEFAULT FALSE COMMENT 'Featured job flag',
    featured_until TIMESTAMP NULL COMMENT 'Featured job expiration',
    status ENUM('DRAFT', 'PUBLISHED', 'CLOSED', 'ARCHIVED') DEFAULT 'DRAFT' COMMENT 'Job status',
    published_at TIMESTAMP NULL COMMENT 'When job was published',
    published_by BIGINT COMMENT 'User ID who published',
    application_deadline DATE COMMENT 'Application deadline date',
    apply_url VARCHAR(500) COMMENT 'External apply URL',
    view_count INT DEFAULT 0 COMMENT 'Number of views',
    application_count INT DEFAULT 0 COMMENT 'Number of applications',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES job_categories(id) ON DELETE RESTRICT,
    FOREIGN KEY (job_type_id) REFERENCES job_types(id) ON DELETE RESTRICT,
    FOREIGN KEY (location_id) REFERENCES company_locations(id) ON DELETE SET NULL,
    FOREIGN KEY (published_by) REFERENCES users(id) ON DELETE SET NULL,
    UNIQUE KEY uk_job_slug (job_slug),
    INDEX idx_company_id (company_id),
    INDEX idx_category_id (category_id),
    INDEX idx_job_type_id (job_type_id),
    INDEX idx_status (status),
    INDEX idx_is_featured (is_featured),
    INDEX idx_experience_level (experience_level),
    INDEX idx_location_id (location_id),
    INDEX idx_location_type (location_type),
    INDEX idx_salary_min (salary_min),
    INDEX idx_salary_max (salary_max),
    INDEX idx_application_deadline (application_deadline),
    INDEX idx_published_at (published_at),
    INDEX idx_created_at (created_at),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Job postings';

-- Job Required Skills table
CREATE TABLE IF NOT EXISTS job_required_skills (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique mapping identifier',
    job_id BIGINT NOT NULL COMMENT 'Reference to jobs table',
    skill_name VARCHAR(100) NOT NULL COMMENT 'Required skill name',
    proficiency_level ENUM('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT') DEFAULT 'INTERMEDIATE' COMMENT 'Required proficiency level',
    is_mandatory BOOLEAN DEFAULT TRUE COMMENT 'Mandatory skill flag',
    years_required INT COMMENT 'Years of experience required',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
    UNIQUE KEY uk_job_skill (job_id, skill_name),
    INDEX idx_job_id (job_id),
    INDEX idx_skill_name (skill_name),
    INDEX idx_is_mandatory (is_mandatory),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Job required skills';

-- Job Benefits table
CREATE TABLE IF NOT EXISTS job_benefits (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique mapping identifier',
    job_id BIGINT NOT NULL COMMENT 'Reference to jobs table',
    benefit_name VARCHAR(255) NOT NULL COMMENT 'Benefit name',
    benefit_description TEXT COMMENT 'Benefit description',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
    UNIQUE KEY uk_job_benefit (job_id, benefit_name),
    INDEX idx_job_id (job_id),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Job benefits/perks';

-- Job Salary Ranges table - for detailed salary info
CREATE TABLE IF NOT EXISTS job_salary_ranges (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique salary range identifier',
    job_id BIGINT NOT NULL COMMENT 'Reference to jobs table',
    experience_level ENUM('ENTRY_LEVEL', 'JUNIOR', 'SENIOR', 'LEAD', 'MANAGER') COMMENT 'Experience level for this range',
    salary_min INT NOT NULL COMMENT 'Minimum salary',
    salary_max INT NOT NULL COMMENT 'Maximum salary',
    salary_currency VARCHAR(10) DEFAULT 'INR' COMMENT 'Salary currency',
    salary_frequency ENUM('MONTHLY', 'YEARLY') DEFAULT 'YEARLY' COMMENT 'Salary frequency',
    is_visible BOOLEAN DEFAULT TRUE COMMENT 'Visible to candidates',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
    UNIQUE KEY uk_job_experience_level (job_id, experience_level),
    INDEX idx_job_id (job_id),
    INDEX idx_salary_min (salary_min),
    INDEX idx_salary_max (salary_max),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Job salary ranges by experience level';

-- Job Locations table - for multi-location jobs
CREATE TABLE IF NOT EXISTS job_locations (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique mapping identifier',
    job_id BIGINT NOT NULL COMMENT 'Reference to jobs table',
    location_id BIGINT NOT NULL COMMENT 'Reference to company_locations table',
    is_primary BOOLEAN DEFAULT FALSE COMMENT 'Primary location flag',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
    FOREIGN KEY (location_id) REFERENCES company_locations(id) ON DELETE CASCADE,
    UNIQUE KEY uk_job_location (job_id, location_id),
    INDEX idx_job_id (job_id),
    INDEX idx_location_id (location_id),
    INDEX idx_is_primary (is_primary),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Job multi-location mapping';

-- Job Views table - track job views
CREATE TABLE IF NOT EXISTS job_views (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique view record identifier',
    job_id BIGINT NOT NULL COMMENT 'Reference to jobs table',
    candidate_id BIGINT COMMENT 'Reference to candidates table (NULL for anonymous)',
    user_id BIGINT COMMENT 'Reference to users table',
    view_source ENUM('SEARCH', 'RECOMMENDATION', 'DIRECT', 'SOCIAL', 'EMAIL', 'OTHER') DEFAULT 'DIRECT' COMMENT 'Source of view',
    is_saved BOOLEAN DEFAULT FALSE COMMENT 'Job saved flag',
    view_duration_seconds INT COMMENT 'Time spent viewing job',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE SET NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_job_id (job_id),
    INDEX idx_candidate_id (candidate_id),
    INDEX idx_user_id (user_id),
    INDEX idx_view_source (view_source),
    INDEX idx_is_saved (is_saved),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Job view analytics';
