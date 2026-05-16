-- ============================================================================
-- CANDIDATE PROFILE MODULE
-- Production-grade schema for candidate information and profiles
-- ============================================================================

-- Candidates table - core candidate profile information
CREATE TABLE IF NOT EXISTS candidates (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique candidate identifier',
    user_id BIGINT NOT NULL UNIQUE COMMENT 'Reference to users table',
    phone VARCHAR(20) COMMENT 'Contact phone number',
    headline VARCHAR(255) COMMENT 'Professional headline',
    bio TEXT COMMENT 'About/biography section',
    current_title VARCHAR(100) COMMENT 'Current job title',
    current_company VARCHAR(255) COMMENT 'Current company name',
    total_experience_years DECIMAL(4, 1) COMMENT 'Total years of experience',
    notice_period_days INT COMMENT 'Notice period in days',
    is_willing_to_relocate BOOLEAN DEFAULT FALSE COMMENT 'Willingness to relocate',
    gender ENUM('MALE', 'FEMALE', 'OTHER', 'PREFER_NOT_TO_SAY') COMMENT 'Gender',
    date_of_birth DATE COMMENT 'Date of birth',
    nationality VARCHAR(100) COMMENT 'Nationality',
    passport_number VARCHAR(50) COMMENT 'Passport number',
    city VARCHAR(100) COMMENT 'Current city',
    state VARCHAR(100) COMMENT 'Current state/province',
    country VARCHAR(100) COMMENT 'Current country',
    postal_code VARCHAR(20) COMMENT 'Postal/zip code',
    linkedin_profile_url VARCHAR(500) COMMENT 'LinkedIn profile URL',
    github_profile_url VARCHAR(500) COMMENT 'GitHub profile URL',
    portfolio_url VARCHAR(500) COMMENT 'Portfolio website URL',
    twitter_handle VARCHAR(100) COMMENT 'Twitter handle',
    website_url VARCHAR(500) COMMENT 'Personal website URL',
    completion_percentage INT DEFAULT 0 COMMENT 'Profile completion percentage',
    is_profile_complete BOOLEAN DEFAULT FALSE COMMENT 'Profile complete flag',
    last_profile_update_at TIMESTAMP NULL COMMENT 'Last profile update timestamp',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_current_company (current_company),
    INDEX idx_total_experience_years (total_experience_years),
    INDEX idx_city (city),
    INDEX idx_country (country),
    INDEX idx_is_willing_to_relocate (is_willing_to_relocate),
    INDEX idx_completion_percentage (completion_percentage),
    INDEX idx_created_at (created_at),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Candidate profile core information';

-- Candidate Education table
CREATE TABLE IF NOT EXISTS candidate_education (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique education record identifier',
    candidate_id BIGINT NOT NULL COMMENT 'Reference to candidates table',
    institution_name VARCHAR(255) NOT NULL COMMENT 'School/college/university name',
    education_level ENUM('HIGH_SCHOOL', 'DIPLOMA', 'BACHELORS', 'MASTERS', 'PHD', 'CERTIFICATION', 'BOOTCAMP') NOT NULL COMMENT 'Education level',
    field_of_study VARCHAR(255) COMMENT 'Major/field of study',
    grade_cgpa DECIMAL(3, 2) COMMENT 'CGPA or grade',
    grade_type ENUM('CGPA', 'PERCENTAGE', 'GPA') COMMENT 'Type of grade system',
    start_year INT COMMENT 'Start year',
    end_year INT COMMENT 'End year',
    is_currently_studying BOOLEAN DEFAULT FALSE COMMENT 'Currently studying flag',
    description TEXT COMMENT 'Additional details',
    sequence_order INT COMMENT 'Display order (1 = most recent)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE,
    INDEX idx_candidate_id (candidate_id),
    INDEX idx_education_level (education_level),
    INDEX idx_institution_name (institution_name),
    INDEX idx_sequence_order (sequence_order),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Candidate education history';

-- Candidate Experience table
CREATE TABLE IF NOT EXISTS candidate_experience (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique experience record identifier',
    candidate_id BIGINT NOT NULL COMMENT 'Reference to candidates table',
    job_title VARCHAR(255) NOT NULL COMMENT 'Job title',
    company_name VARCHAR(255) NOT NULL COMMENT 'Company name',
    employment_type ENUM('FULL_TIME', 'PART_TIME', 'CONTRACT', 'FREELANCE', 'INTERNSHIP') NOT NULL COMMENT 'Type of employment',
    industry VARCHAR(100) COMMENT 'Industry sector',
    location VARCHAR(255) COMMENT 'Work location',
    start_date DATE NOT NULL COMMENT 'Employment start date',
    end_date DATE COMMENT 'Employment end date',
    is_currently_working BOOLEAN DEFAULT FALSE COMMENT 'Currently working here flag',
    description TEXT COMMENT 'Job description and responsibilities',
    key_achievements TEXT COMMENT 'Key achievements',
    sequence_order INT COMMENT 'Display order (1 = most recent)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE,
    INDEX idx_candidate_id (candidate_id),
    INDEX idx_company_name (company_name),
    INDEX idx_job_title (job_title),
    INDEX idx_start_date (start_date),
    INDEX idx_is_currently_working (is_currently_working),
    INDEX idx_sequence_order (sequence_order),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Candidate work experience history';

-- Candidate Skills table
CREATE TABLE IF NOT EXISTS candidate_skills (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique skill record identifier',
    candidate_id BIGINT NOT NULL COMMENT 'Reference to candidates table',
    skill_name VARCHAR(100) NOT NULL COMMENT 'Skill name',
    proficiency_level ENUM('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT') DEFAULT 'INTERMEDIATE' COMMENT 'Proficiency level',
    years_of_experience DECIMAL(4, 1) COMMENT 'Years of experience with this skill',
    endorsements_count INT DEFAULT 0 COMMENT 'Number of endorsements',
    skill_category VARCHAR(100) COMMENT 'Skill category (e.g., programming, soft skill)',
    is_primary_skill BOOLEAN DEFAULT FALSE COMMENT 'Primary skill indicator',
    last_used_date DATE COMMENT 'Last date skill was used',
    sequence_order INT COMMENT 'Display order',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE,
    INDEX idx_candidate_id (candidate_id),
    INDEX idx_skill_name (skill_name),
    INDEX idx_proficiency_level (proficiency_level),
    INDEX idx_is_primary_skill (is_primary_skill),
    INDEX idx_sequence_order (sequence_order),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Candidate skills and proficiencies';

-- Candidate Projects table
CREATE TABLE IF NOT EXISTS candidate_projects (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique project record identifier',
    candidate_id BIGINT NOT NULL COMMENT 'Reference to candidates table',
    project_title VARCHAR(255) NOT NULL COMMENT 'Project title',
    description TEXT COMMENT 'Project description',
    project_url VARCHAR(500) COMMENT 'Project URL/link',
    github_url VARCHAR(500) COMMENT 'GitHub repository URL',
    start_date DATE COMMENT 'Project start date',
    end_date DATE COMMENT 'Project end date',
    is_active BOOLEAN DEFAULT FALSE COMMENT 'Active project flag',
    technologies_used TEXT COMMENT 'Comma-separated technologies',
    team_size INT COMMENT 'Team size',
    role VARCHAR(100) COMMENT 'Role in project',
    key_highlights TEXT COMMENT 'Key highlights/achievements',
    sequence_order INT COMMENT 'Display order',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE,
    INDEX idx_candidate_id (candidate_id),
    INDEX idx_project_title (project_title),
    INDEX idx_is_active (is_active),
    INDEX idx_sequence_order (sequence_order),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Candidate portfolio projects';

-- Candidate Certifications table
CREATE TABLE IF NOT EXISTS candidate_certifications (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique certification record identifier',
    candidate_id BIGINT NOT NULL COMMENT 'Reference to candidates table',
    certification_name VARCHAR(255) NOT NULL COMMENT 'Certification name',
    issuing_organization VARCHAR(255) NOT NULL COMMENT 'Organization that issued certification',
    credential_id VARCHAR(100) COMMENT 'Credential ID',
    credential_url VARCHAR(500) COMMENT 'URL to verify credential',
    issue_date DATE NOT NULL COMMENT 'Date certification was issued',
    expiration_date DATE COMMENT 'Expiration date (if applicable)',
    does_not_expire BOOLEAN DEFAULT FALSE COMMENT 'Certification does not expire',
    is_active BOOLEAN DEFAULT TRUE COMMENT 'Certification is still active',
    description TEXT COMMENT 'Additional description',
    sequence_order INT COMMENT 'Display order',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE,
    INDEX idx_candidate_id (candidate_id),
    INDEX idx_certification_name (certification_name),
    INDEX idx_is_active (is_active),
    INDEX idx_issue_date (issue_date),
    INDEX idx_expiration_date (expiration_date),
    INDEX idx_sequence_order (sequence_order),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Candidate certifications and licenses';

-- Candidate Resumes table
CREATE TABLE IF NOT EXISTS candidate_resumes (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique resume record identifier',
    candidate_id BIGINT NOT NULL COMMENT 'Reference to candidates table',
    resume_name VARCHAR(255) NOT NULL COMMENT 'Resume name/title',
    file_name VARCHAR(255) NOT NULL COMMENT 'Original file name',
    file_path VARCHAR(500) NOT NULL COMMENT 'Path to resume file in storage',
    file_size_bytes INT COMMENT 'File size in bytes',
    file_type VARCHAR(50) COMMENT 'File type (PDF, DOCX, etc)',
    storage_type ENUM('LOCAL', 'S3', 'AZURE') DEFAULT 'AZURE' COMMENT 'Storage service type',
    s3_bucket_name VARCHAR(255) COMMENT 'S3 bucket name (if applicable)',
    azure_container_name VARCHAR(255) COMMENT 'Azure container name (if applicable)',
    is_primary BOOLEAN DEFAULT FALSE COMMENT 'Primary resume flag',
    is_parsed BOOLEAN DEFAULT FALSE COMMENT 'Resume parsed flag',
    parse_status ENUM('PENDING', 'IN_PROGRESS', 'SUCCESS', 'FAILED') DEFAULT 'PENDING' COMMENT 'Parse status',
    parsed_at TIMESTAMP NULL COMMENT 'When resume was parsed',
    upload_ip_address VARCHAR(45) COMMENT 'IP address of upload',
    virus_scan_status ENUM('PENDING', 'CLEAN', 'INFECTED') COMMENT 'Virus scan status',
    virus_scanned_at TIMESTAMP NULL COMMENT 'When virus scan completed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE,
    INDEX idx_candidate_id (candidate_id),
    INDEX idx_is_primary (is_primary),
    INDEX idx_is_parsed (is_parsed),
    INDEX idx_parse_status (parse_status),
    INDEX idx_file_type (file_type),
    INDEX idx_created_at (created_at),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Candidate resume files and metadata';

-- Candidate Preferences table - job search preferences
CREATE TABLE IF NOT EXISTS candidate_preferences (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique preference record identifier',
    candidate_id BIGINT NOT NULL UNIQUE COMMENT 'Reference to candidates table',
    preferred_job_titles JSON COMMENT 'JSON array of preferred job titles',
    preferred_companies JSON COMMENT 'JSON array of preferred company IDs',
    preferred_locations JSON COMMENT 'JSON array of preferred locations',
    preferred_salary_min INT COMMENT 'Minimum preferred salary',
    preferred_salary_max INT COMMENT 'Maximum preferred salary',
    salary_currency VARCHAR(10) DEFAULT 'INR' COMMENT 'Salary currency code',
    desired_employment_types JSON COMMENT 'JSON array of employment types',
    industry_preferences JSON COMMENT 'JSON array of industry preferences',
    skill_preferences JSON COMMENT 'JSON array of skill names',
    availability_notice_period INT COMMENT 'Available after (days)',
    open_to_remote BOOLEAN DEFAULT TRUE COMMENT 'Open to remote jobs',
    open_to_relocation BOOLEAN DEFAULT FALSE COMMENT 'Open to relocation',
    career_level ENUM('ENTRY_LEVEL', 'JUNIOR', 'SENIOR', 'LEAD', 'MANAGER', 'DIRECTOR', 'EXECUTIVE') COMMENT 'Career level preference',
    job_search_status ENUM('ACTIVELY_LOOKING', 'PASSIVE', 'NOT_LOOKING', 'FUTURE_LOOKING') DEFAULT 'PASSIVE' COMMENT 'Job search status',
    notification_frequency ENUM('IMMEDIATE', 'DAILY', 'WEEKLY', 'MONTHLY', 'NEVER') DEFAULT 'WEEKLY' COMMENT 'Notification frequency',
    allow_recruiter_contact BOOLEAN DEFAULT TRUE COMMENT 'Allow recruiter contact',
    allow_company_contact BOOLEAN DEFAULT TRUE COMMENT 'Allow company contact',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE,
    INDEX idx_candidate_id (candidate_id),
    INDEX idx_job_search_status (job_search_status),
    INDEX idx_career_level (career_level),
    INDEX idx_preferred_salary_min (preferred_salary_min),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Candidate job search preferences';

-- Candidate Social Links table
CREATE TABLE IF NOT EXISTS candidate_social_links (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique social link record identifier',
    candidate_id BIGINT NOT NULL COMMENT 'Reference to candidates table',
    platform VARCHAR(50) NOT NULL COMMENT 'Social platform name',
    profile_url VARCHAR(500) NOT NULL COMMENT 'Profile URL',
    handle VARCHAR(100) COMMENT 'Platform handle/username',
    is_verified BOOLEAN DEFAULT FALSE COMMENT 'Profile verification status',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE,
    UNIQUE KEY uk_candidate_platform (candidate_id, platform),
    INDEX idx_candidate_id (candidate_id),
    INDEX idx_platform (platform),
    INDEX idx_is_verified (is_verified),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Candidate social media profiles';
