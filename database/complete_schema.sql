-- ============================================================================
-- CANDIDATE-NAUKARI RECRUITMENT PLATFORM
-- Complete Enterprise-Grade Database Schema
-- Version: 1.0.0
-- Database: candidate_naukari
-- ============================================================================
-- EXECUTION ORDER:
-- 1. Create database and set charset
-- 2. Create core tables (no dependencies)
-- 3. Create dependent tables (with foreign keys)
-- 4. Create indexes
-- 5. Insert seed data
-- ============================================================================

-- Drop existing database if needed (for fresh setup)
-- DROP DATABASE IF EXISTS candidate_naukari;

-- Create database
CREATE DATABASE IF NOT EXISTS candidate_naukari 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE candidate_naukari;

-- Disable foreign key checks temporarily for easier loading
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================================
-- SECTION 1: AUTHENTICATION & RBAC (Core - No Dependencies)
-- ============================================================================

-- Users table - stores all system users
CREATE TABLE IF NOT EXISTS users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique user identifier',
    email VARCHAR(255) NOT NULL UNIQUE COMMENT 'User email address',
    phone VARCHAR(20) UNIQUE COMMENT 'User phone number',
    password_hash VARCHAR(255) NOT NULL COMMENT 'Bcrypt hashed password',
    first_name VARCHAR(100) NOT NULL COMMENT 'User first name',
    last_name VARCHAR(100) NOT NULL COMMENT 'User last name',
    profile_picture_url VARCHAR(500) COMMENT 'URL to user profile picture',
    user_type ENUM('CANDIDATE', 'HR', 'ADMIN', 'SUPER_ADMIN') NOT NULL DEFAULT 'CANDIDATE' COMMENT 'Type of user',
    is_email_verified BOOLEAN DEFAULT FALSE COMMENT 'Email verification status',
    is_phone_verified BOOLEAN DEFAULT FALSE COMMENT 'Phone verification status',
    is_active BOOLEAN DEFAULT TRUE COMMENT 'User account status',
    last_login_at TIMESTAMP NULL COMMENT 'Last login timestamp',
    password_changed_at TIMESTAMP NULL COMMENT 'Last password change timestamp',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    INDEX idx_email (email),
    INDEX idx_user_type (user_type),
    INDEX idx_is_active (is_active),
    INDEX idx_created_at (created_at),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Core users table for authentication';

-- Roles table
CREATE TABLE IF NOT EXISTS roles (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique role identifier',
    name VARCHAR(100) NOT NULL UNIQUE COMMENT 'Role name',
    description TEXT COMMENT 'Role description',
    is_system_role BOOLEAN DEFAULT FALSE COMMENT 'Flag for built-in system roles',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    INDEX idx_name (name),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='System roles definition';

-- Permissions table
CREATE TABLE IF NOT EXISTS permissions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique permission identifier',
    name VARCHAR(100) NOT NULL UNIQUE COMMENT 'Permission name',
    resource VARCHAR(100) NOT NULL COMMENT 'Resource type',
    action VARCHAR(50) NOT NULL COMMENT 'Action type',
    description TEXT COMMENT 'Permission description',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    UNIQUE KEY uk_resource_action (resource, action),
    INDEX idx_resource (resource),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Fine-grained permissions';

-- User Roles mapping table
CREATE TABLE IF NOT EXISTS user_roles (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique mapping identifier',
    user_id BIGINT NOT NULL COMMENT 'Reference to users table',
    role_id BIGINT NOT NULL COMMENT 'Reference to roles table',
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'When role was assigned',
    assigned_by BIGINT COMMENT 'User ID who assigned this role',
    expires_at TIMESTAMP NULL COMMENT 'Optional role expiration date',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    UNIQUE KEY uk_user_role (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_role_id (role_id),
    INDEX idx_expires_at (expires_at),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User-Role association mapping';

-- Role Permissions mapping table
CREATE TABLE IF NOT EXISTS role_permissions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique mapping identifier',
    role_id BIGINT NOT NULL COMMENT 'Reference to roles table',
    permission_id BIGINT NOT NULL COMMENT 'Reference to permissions table',
    granted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'When permission was granted',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    UNIQUE KEY uk_role_permission (role_id, permission_id),
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE,
    INDEX idx_role_id (role_id),
    INDEX idx_permission_id (permission_id),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Role-Permission association mapping';

-- Refresh Tokens table
CREATE TABLE IF NOT EXISTS refresh_tokens (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique token identifier',
    user_id BIGINT NOT NULL COMMENT 'Reference to users table',
    token_hash VARCHAR(255) NOT NULL UNIQUE COMMENT 'Hashed refresh token',
    token_family VARCHAR(100) COMMENT 'Token family for rotation tracking',
    ip_address VARCHAR(45) COMMENT 'IPv4 or IPv6 address',
    user_agent VARCHAR(500) COMMENT 'Browser user agent string',
    is_revoked BOOLEAN DEFAULT FALSE COMMENT 'Token revocation status',
    expires_at TIMESTAMP NOT NULL COMMENT 'Token expiration timestamp',
    revoked_at TIMESTAMP NULL COMMENT 'When token was revoked',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_token_hash (token_hash),
    INDEX idx_expires_at (expires_at),
    INDEX idx_is_revoked (is_revoked),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='JWT refresh token management';

-- OTP Verification table
CREATE TABLE IF NOT EXISTS otp_verifications (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique OTP identifier',
    user_id BIGINT COMMENT 'Reference to users table',
    email VARCHAR(255) COMMENT 'Email address for verification',
    phone VARCHAR(20) COMMENT 'Phone number for verification',
    otp_code VARCHAR(10) NOT NULL COMMENT '6-digit OTP code',
    otp_type ENUM('EMAIL', 'PHONE', 'SIGNUP', 'PASSWORD_RESET') NOT NULL DEFAULT 'EMAIL' COMMENT 'Type of OTP verification',
    attempt_count INT DEFAULT 0 COMMENT 'Number of verification attempts',
    max_attempts INT DEFAULT 5 COMMENT 'Maximum allowed attempts',
    is_verified BOOLEAN DEFAULT FALSE COMMENT 'Verification status',
    verified_at TIMESTAMP NULL COMMENT 'When OTP was verified',
    expires_at TIMESTAMP NOT NULL COMMENT 'OTP expiration timestamp',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_email (email),
    INDEX idx_phone (phone),
    INDEX idx_otp_type (otp_type),
    INDEX idx_expires_at (expires_at),
    INDEX idx_is_verified (is_verified),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='OTP-based email and phone verification';

-- Sessions table
CREATE TABLE IF NOT EXISTS sessions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique session identifier',
    user_id BIGINT NOT NULL COMMENT 'Reference to users table',
    session_token VARCHAR(255) NOT NULL UNIQUE COMMENT 'Unique session token',
    ip_address VARCHAR(45) COMMENT 'User IP address',
    user_agent VARCHAR(500) COMMENT 'Browser user agent',
    device_info VARCHAR(255) COMMENT 'Device information',
    is_active BOOLEAN DEFAULT TRUE COMMENT 'Session status',
    last_activity_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Last activity timestamp',
    expires_at TIMESTAMP NOT NULL COMMENT 'Session expiration timestamp',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_session_token (session_token),
    INDEX idx_is_active (is_active),
    INDEX idx_expires_at (expires_at),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User session management';

-- ============================================================================
-- SECTION 2: CANDIDATE PROFILE
-- ============================================================================

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
    city VARCHAR(100) COMMENT 'Current city',
    state VARCHAR(100) COMMENT 'Current state/province',
    country VARCHAR(100) COMMENT 'Current country',
    postal_code VARCHAR(20) COMMENT 'Postal/zip code',
    linkedin_profile_url VARCHAR(500) COMMENT 'LinkedIn profile URL',
    github_profile_url VARCHAR(500) COMMENT 'GitHub profile URL',
    portfolio_url VARCHAR(500) COMMENT 'Portfolio website URL',
    twitter_handle VARCHAR(100) COMMENT 'Twitter handle',
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
    skill_category VARCHAR(100) COMMENT 'Skill category',
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
    expiration_date DATE COMMENT 'Expiration date',
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
    s3_bucket_name VARCHAR(255) COMMENT 'S3 bucket name',
    azure_container_name VARCHAR(255) COMMENT 'Azure container name',
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

-- Candidate Preferences table
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
    career_level ENUM('ENTRY_LEVEL', 'JUNIOR', 'SENIOR', 'LEAD', 'MANAGER') COMMENT 'Career level preference',
    job_search_status ENUM('ACTIVELY_LOOKING', 'PASSIVE', 'NOT_LOOKING') DEFAULT 'PASSIVE' COMMENT 'Job search status',
    notification_frequency ENUM('IMMEDIATE', 'DAILY', 'WEEKLY', 'MONTHLY', 'NEVER') DEFAULT 'WEEKLY' COMMENT 'Notification frequency',
    allow_recruiter_contact BOOLEAN DEFAULT TRUE COMMENT 'Allow recruiter contact',
    allow_company_contact BOOLEAN DEFAULT TRUE COMMENT 'Allow company contact',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE,
    INDEX idx_candidate_id (candidate_id),
    INDEX idx_job_search_status (job_search_status),
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

-- ============================================================================
-- SECTION 3: COMPANY PROFILE
-- ============================================================================

CREATE TABLE IF NOT EXISTS companies (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique company identifier',
    company_name VARCHAR(255) NOT NULL UNIQUE COMMENT 'Official company name',
    display_name VARCHAR(255) COMMENT 'Display name for UI',
    company_slug VARCHAR(100) NOT NULL UNIQUE COMMENT 'URL-friendly company slug',
    logo_url VARCHAR(500) COMMENT 'Company logo URL',
    background_image_url VARCHAR(500) COMMENT 'Company background image URL',
    description TEXT COMMENT 'Company description',
    about TEXT COMMENT 'About company',
    founding_year INT COMMENT 'Year company was founded',
    company_size ENUM('STARTUP', 'SMALL', 'MEDIUM', 'LARGE', 'ENTERPRISE') COMMENT 'Company size',
    industry VARCHAR(100) NOT NULL COMMENT 'Industry sector',
    industry_category VARCHAR(100) COMMENT 'Industry category',
    website_url VARCHAR(500) COMMENT 'Company website URL',
    phone_primary VARCHAR(20) COMMENT 'Primary phone number',
    phone_hr VARCHAR(20) COMMENT 'HR department phone',
    email_primary VARCHAR(255) COMMENT 'Primary email',
    email_hr VARCHAR(255) COMMENT 'HR department email',
    email_careers VARCHAR(255) COMMENT 'Careers contact email',
    headquarters_address VARCHAR(500) COMMENT 'Headquarters address',
    headquarters_city VARCHAR(100) COMMENT 'Headquarters city',
    headquarters_state VARCHAR(100) COMMENT 'Headquarters state',
    headquarters_country VARCHAR(100) COMMENT 'Headquarters country',
    headquarters_postal_code VARCHAR(20) COMMENT 'Headquarters postal code',
    number_of_employees INT COMMENT 'Total number of employees',
    company_type ENUM('PUBLIC', 'PRIVATE', 'STARTUP', 'NGO', 'GOVERNMENT') COMMENT 'Company type',
    is_actively_hiring BOOLEAN DEFAULT TRUE COMMENT 'Currently hiring flag',
    is_verified BOOLEAN DEFAULT FALSE COMMENT 'Company verification status',
    verified_at TIMESTAMP NULL COMMENT 'When company was verified',
    is_featured BOOLEAN DEFAULT FALSE COMMENT 'Featured company flag',
    completion_percentage INT DEFAULT 0 COMMENT 'Profile completion percentage',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    UNIQUE KEY uk_company_slug (company_slug),
    INDEX idx_company_name (company_name),
    INDEX idx_industry (industry),
    INDEX idx_company_size (company_size),
    INDEX idx_is_actively_hiring (is_actively_hiring),
    INDEX idx_is_verified (is_verified),
    INDEX idx_created_at (created_at),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Company profile information';

-- HR Users table
CREATE TABLE IF NOT EXISTS hr_users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique HR user identifier',
    user_id BIGINT NOT NULL UNIQUE COMMENT 'Reference to users table',
    company_id BIGINT NOT NULL COMMENT 'Reference to companies table',
    job_title VARCHAR(100) COMMENT 'HR job title',
    department VARCHAR(100) COMMENT 'Department',
    phone_extension VARCHAR(20) COMMENT 'Phone extension',
    is_admin BOOLEAN DEFAULT FALSE COMMENT 'Admin privilege flag',
    can_post_jobs BOOLEAN DEFAULT TRUE COMMENT 'Permission to post jobs',
    can_view_candidates BOOLEAN DEFAULT TRUE COMMENT 'Permission to view candidates',
    can_shortlist_candidates BOOLEAN DEFAULT TRUE COMMENT 'Permission to shortlist',
    can_schedule_interviews BOOLEAN DEFAULT TRUE COMMENT 'Permission to schedule interviews',
    can_approve_jobs BOOLEAN DEFAULT FALSE COMMENT 'Permission to approve jobs',
    status ENUM('ACTIVE', 'INACTIVE', 'PENDING_APPROVAL', 'SUSPENDED') DEFAULT 'PENDING_APPROVAL' COMMENT 'HR user status',
    approval_status ENUM('PENDING', 'APPROVED', 'REJECTED') DEFAULT 'PENDING' COMMENT 'Company approval status',
    approved_at TIMESTAMP NULL COMMENT 'When HR user was approved',
    approved_by BIGINT COMMENT 'User ID who approved this HR user',
    last_activity_at TIMESTAMP NULL COMMENT 'Last activity timestamp',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_company_id (company_id),
    INDEX idx_status (status),
    INDEX idx_approval_status (approval_status),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='HR users from companies';

-- Company Locations table
CREATE TABLE IF NOT EXISTS company_locations (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique location identifier',
    company_id BIGINT NOT NULL COMMENT 'Reference to companies table',
    location_name VARCHAR(255) NOT NULL COMMENT 'Location name',
    location_type ENUM('HEADQUARTERS', 'OFFICE', 'REMOTE', 'HYBRID', 'COWORKING') DEFAULT 'OFFICE' COMMENT 'Type of location',
    address VARCHAR(500) NOT NULL COMMENT 'Full address',
    city VARCHAR(100) NOT NULL COMMENT 'City',
    state VARCHAR(100) COMMENT 'State/Province',
    country VARCHAR(100) NOT NULL COMMENT 'Country',
    postal_code VARCHAR(20) COMMENT 'Postal/zip code',
    phone VARCHAR(20) COMMENT 'Location phone number',
    email VARCHAR(255) COMMENT 'Location email',
    latitude DECIMAL(10, 8) COMMENT 'GPS latitude',
    longitude DECIMAL(11, 8) COMMENT 'GPS longitude',
    employees_count INT COMMENT 'Number of employees at this location',
    is_primary BOOLEAN DEFAULT FALSE COMMENT 'Primary location flag',
    is_active BOOLEAN DEFAULT TRUE COMMENT 'Location active status',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    INDEX idx_company_id (company_id),
    INDEX idx_city (city),
    INDEX idx_country (country),
    INDEX idx_location_type (location_type),
    INDEX idx_is_primary (is_primary),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Company office locations';

-- Company Documents table
CREATE TABLE IF NOT EXISTS company_documents (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique document identifier',
    company_id BIGINT NOT NULL COMMENT 'Reference to companies table',
    document_name VARCHAR(255) NOT NULL COMMENT 'Document name',
    document_type ENUM('LICENSE', 'CERTIFICATE', 'AWARD', 'PATENT', 'REGISTRATION', 'COMPLIANCE', 'OTHER') COMMENT 'Document type',
    file_name VARCHAR(255) NOT NULL COMMENT 'Original file name',
    file_path VARCHAR(500) NOT NULL COMMENT 'Path to document file',
    file_size_bytes INT COMMENT 'File size in bytes',
    file_type VARCHAR(50) COMMENT 'File type',
    storage_type ENUM('LOCAL', 'S3', 'AZURE') DEFAULT 'AZURE' COMMENT 'Storage service',
    s3_bucket_name VARCHAR(255) COMMENT 'S3 bucket name',
    azure_container_name VARCHAR(255) COMMENT 'Azure container name',
    issue_date DATE COMMENT 'Document issue date',
    expiration_date DATE COMMENT 'Document expiration date',
    is_verified BOOLEAN DEFAULT FALSE COMMENT 'Document verification status',
    verified_at TIMESTAMP NULL COMMENT 'When document was verified',
    is_public BOOLEAN DEFAULT FALSE COMMENT 'Public document flag',
    description TEXT COMMENT 'Document description',
    uploaded_by BIGINT COMMENT 'User ID who uploaded',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_company_id (company_id),
    INDEX idx_document_type (document_type),
    INDEX idx_is_verified (is_verified),
    INDEX idx_expiration_date (expiration_date),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Company documents and certifications';

-- Company Gallery table
CREATE TABLE IF NOT EXISTS company_gallery (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique gallery item identifier',
    company_id BIGINT NOT NULL COMMENT 'Reference to companies table',
    image_url VARCHAR(500) NOT NULL COMMENT 'Image URL',
    image_type ENUM('OFFICE', 'TEAM', 'PRODUCT', 'EVENT', 'CULTURE', 'OTHER') COMMENT 'Image type',
    title VARCHAR(255) COMMENT 'Image title',
    description TEXT COMMENT 'Image description',
    display_order INT COMMENT 'Display order',
    is_featured BOOLEAN DEFAULT FALSE COMMENT 'Featured image flag',
    uploaded_by BIGINT COMMENT 'User ID who uploaded',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_company_id (company_id),
    INDEX idx_image_type (image_type),
    INDEX idx_is_featured (is_featured),
    INDEX idx_display_order (display_order),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Company gallery/media';

-- Company Social Links table
CREATE TABLE IF NOT EXISTS company_social_links (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique social link identifier',
    company_id BIGINT NOT NULL COMMENT 'Reference to companies table',
    platform VARCHAR(50) NOT NULL COMMENT 'Social platform',
    profile_url VARCHAR(500) NOT NULL COMMENT 'Profile URL',
    handle VARCHAR(100) COMMENT 'Platform handle/username',
    follower_count INT DEFAULT 0 COMMENT 'Follower count',
    last_updated_at TIMESTAMP NULL COMMENT 'Last follower count update',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    UNIQUE KEY uk_company_platform (company_id, platform),
    INDEX idx_company_id (company_id),
    INDEX idx_platform (platform),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Company social media profiles';

-- Company Benefits table
CREATE TABLE IF NOT EXISTS company_benefits (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique benefit identifier',
    company_id BIGINT NOT NULL COMMENT 'Reference to companies table',
    benefit_name VARCHAR(255) NOT NULL COMMENT 'Benefit name',
    benefit_category ENUM('HEALTH', 'FINANCIAL', 'LEAVE', 'GROWTH', 'WORK_LIFE', 'OTHER') COMMENT 'Benefit category',
    description TEXT COMMENT 'Benefit description',
    is_verified BOOLEAN DEFAULT FALSE COMMENT 'Benefit verification status',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    UNIQUE KEY uk_company_benefit (company_id, benefit_name),
    INDEX idx_company_id (company_id),
    INDEX idx_benefit_category (benefit_category),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Company benefits and perks';

-- ============================================================================
-- SECTION 4: JOB MANAGEMENT
-- ============================================================================

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
    INDEX idx_application_deadline (application_deadline),
    INDEX idx_published_at (published_at),
    INDEX idx_created_at (created_at),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Job postings';

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

CREATE TABLE IF NOT EXISTS job_views (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique view record identifier',
    job_id BIGINT NOT NULL COMMENT 'Reference to jobs table',
    candidate_id BIGINT COMMENT 'Reference to candidates table',
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

-- ============================================================================
-- SECTION 5: APPLICATION MANAGEMENT
-- ============================================================================

CREATE TABLE IF NOT EXISTS applications (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique application identifier',
    job_id BIGINT NOT NULL COMMENT 'Reference to jobs table',
    candidate_id BIGINT NOT NULL COMMENT 'Reference to candidates table',
    applied_resume_id BIGINT COMMENT 'Reference to candidate_resumes table',
    application_text TEXT COMMENT 'Application cover letter/text',
    application_status ENUM('APPLIED', 'REVIEWED', 'SHORTLISTED', 'REJECTED', 'WITHDRAWN', 'ACCEPTED') DEFAULT 'APPLIED' COMMENT 'Application status',
    rejection_reason VARCHAR(500) COMMENT 'Reason for rejection',
    rejection_notes TEXT COMMENT 'Detailed rejection notes',
    rejected_at TIMESTAMP NULL COMMENT 'When application was rejected',
    rejected_by BIGINT COMMENT 'User ID who rejected',
    is_read BOOLEAN DEFAULT FALSE COMMENT 'Application read status',
    is_flagged BOOLEAN DEFAULT FALSE COMMENT 'Flagged for follow-up',
    flag_reason VARCHAR(255) COMMENT 'Reason for flag',
    interview_count INT DEFAULT 0 COMMENT 'Number of interviews',
    rating INT COMMENT 'Application rating (1-5)',
    rating_notes TEXT COMMENT 'Rating notes',
    rated_by BIGINT COMMENT 'User ID who rated',
    rated_at TIMESTAMP NULL COMMENT 'When rated',
    match_score DECIMAL(5, 2) COMMENT 'Skill match score (0-100)',
    match_details JSON COMMENT 'Match score details',
    source ENUM('DIRECT_APPLICATION', 'RECRUITER_INVITE', 'BULK_INVITE', 'REFERRAL', 'EXTERNAL') DEFAULT 'DIRECT_APPLICATION' COMMENT 'Application source',
    referred_by BIGINT COMMENT 'Referrer user ID',
    external_reference_id VARCHAR(100) COMMENT 'External system reference',
    priority_level ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') DEFAULT 'MEDIUM' COMMENT 'Application priority',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE,
    FOREIGN KEY (applied_resume_id) REFERENCES candidate_resumes(id) ON DELETE SET NULL,
    FOREIGN KEY (rejected_by) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (rated_by) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (referred_by) REFERENCES users(id) ON DELETE SET NULL,
    UNIQUE KEY uk_job_candidate (job_id, candidate_id),
    INDEX idx_job_id (job_id),
    INDEX idx_candidate_id (candidate_id),
    INDEX idx_application_status (application_status),
    INDEX idx_is_read (is_read),
    INDEX idx_is_flagged (is_flagged),
    INDEX idx_match_score (match_score),
    INDEX idx_priority_level (priority_level),
    INDEX idx_source (source),
    INDEX idx_created_at (created_at),
    INDEX idx_updated_at (updated_at),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Job applications';

CREATE TABLE IF NOT EXISTS saved_jobs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique saved job identifier',
    job_id BIGINT NOT NULL COMMENT 'Reference to jobs table',
    candidate_id BIGINT NOT NULL COMMENT 'Reference to candidates table',
    saved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'When job was saved',
    notes TEXT COMMENT 'Candidate notes about job',
    reminder_at TIMESTAMP NULL COMMENT 'Reminder timestamp',
    reminder_sent BOOLEAN DEFAULT FALSE COMMENT 'Reminder sent flag',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE,
    UNIQUE KEY uk_candidate_job (candidate_id, job_id),
    INDEX idx_job_id (job_id),
    INDEX idx_candidate_id (candidate_id),
    INDEX idx_saved_at (saved_at),
    INDEX idx_reminder_at (reminder_at),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Candidates saved jobs';

CREATE TABLE IF NOT EXISTS shortlisted_candidates (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique shortlist identifier',
    application_id BIGINT NOT NULL COMMENT 'Reference to applications table',
    job_id BIGINT NOT NULL COMMENT 'Reference to jobs table',
    candidate_id BIGINT NOT NULL COMMENT 'Reference to candidates table',
    shortlist_stage INT DEFAULT 1 COMMENT 'Shortlist stage number',
    shortlisted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'When shortlisted',
    shortlisted_by BIGINT NOT NULL COMMENT 'User ID who shortlisted',
    shortlist_notes TEXT COMMENT 'Shortlist notes',
    expected_feedback_date DATE COMMENT 'Expected feedback date',
    feedback_received BOOLEAN DEFAULT FALSE COMMENT 'Feedback received flag',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (application_id) REFERENCES applications(id) ON DELETE CASCADE,
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE,
    FOREIGN KEY (shortlisted_by) REFERENCES users(id) ON DELETE RESTRICT,
    UNIQUE KEY uk_application_stage (application_id, shortlist_stage),
    INDEX idx_job_id (job_id),
    INDEX idx_candidate_id (candidate_id),
    INDEX idx_shortlist_stage (shortlist_stage),
    INDEX idx_shortlisted_at (shortlisted_at),
    INDEX idx_feedback_received (feedback_received),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Shortlisted candidates';

CREATE TABLE IF NOT EXISTS interview_schedules (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique interview identifier',
    application_id BIGINT NOT NULL COMMENT 'Reference to applications table',
    job_id BIGINT NOT NULL COMMENT 'Reference to jobs table',
    candidate_id BIGINT NOT NULL COMMENT 'Reference to candidates table',
    interview_type ENUM('PHONE', 'VIDEO', 'IN_PERSON', 'PRACTICAL', 'GROUP', 'FINAL') DEFAULT 'VIDEO' COMMENT 'Type of interview',
    interview_round INT NOT NULL COMMENT 'Interview round number',
    scheduled_at TIMESTAMP NOT NULL COMMENT 'Scheduled interview time',
    duration_minutes INT DEFAULT 30 COMMENT 'Interview duration in minutes',
    scheduled_by BIGINT NOT NULL COMMENT 'User ID who scheduled',
    interviewer_id BIGINT COMMENT 'Primary interviewer user ID',
    interviewer_ids JSON COMMENT 'JSON array of interviewer user IDs',
    meeting_url VARCHAR(500) COMMENT 'Meeting URL (Zoom, Teams, etc)',
    meeting_provider VARCHAR(100) COMMENT 'Meeting provider (ZOOM, TEAMS, MEET)',
    meeting_id VARCHAR(100) COMMENT 'Meeting ID in provider',
    interview_location VARCHAR(255) COMMENT 'Location for in-person interviews',
    additional_instructions TEXT COMMENT 'Instructions for candidate',
    confirmation_sent BOOLEAN DEFAULT FALSE COMMENT 'Confirmation sent flag',
    confirmation_sent_at TIMESTAMP NULL COMMENT 'When confirmation was sent',
    is_confirmed BOOLEAN DEFAULT FALSE COMMENT 'Candidate confirmation flag',
    confirmed_at TIMESTAMP NULL COMMENT 'When candidate confirmed',
    candidate_attended BOOLEAN DEFAULT FALSE COMMENT 'Candidate attended flag',
    started_at TIMESTAMP NULL COMMENT 'When interview started',
    ended_at TIMESTAMP NULL COMMENT 'When interview ended',
    is_cancelled BOOLEAN DEFAULT FALSE COMMENT 'Interview cancelled flag',
    cancelled_at TIMESTAMP NULL COMMENT 'When cancelled',
    cancellation_reason VARCHAR(500) COMMENT 'Cancellation reason',
    cancelled_by BIGINT COMMENT 'User ID who cancelled',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (application_id) REFERENCES applications(id) ON DELETE CASCADE,
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE,
    FOREIGN KEY (scheduled_by) REFERENCES users(id) ON DELETE RESTRICT,
    FOREIGN KEY (interviewer_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (cancelled_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_application_id (application_id),
    INDEX idx_candidate_id (candidate_id),
    INDEX idx_scheduled_at (scheduled_at),
    INDEX idx_interview_type (interview_type),
    INDEX idx_interview_round (interview_round),
    INDEX idx_is_confirmed (is_confirmed),
    INDEX idx_candidate_attended (candidate_attended),
    INDEX idx_is_cancelled (is_cancelled),
    INDEX idx_created_at (created_at),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Interview scheduling';

CREATE TABLE IF NOT EXISTS interview_feedback (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique feedback identifier',
    interview_id BIGINT NOT NULL UNIQUE COMMENT 'Reference to interview_schedules table',
    application_id BIGINT NOT NULL COMMENT 'Reference to applications table',
    candidate_id BIGINT NOT NULL COMMENT 'Reference to candidates table',
    interviewer_id BIGINT NOT NULL COMMENT 'Interviewer user ID',
    overall_rating INT NOT NULL COMMENT 'Overall rating (1-10)',
    technical_rating INT COMMENT 'Technical rating (1-10)',
    communication_rating INT COMMENT 'Communication rating (1-10)',
    cultural_fit_rating INT COMMENT 'Cultural fit rating (1-10)',
    strengths TEXT COMMENT 'Candidate strengths',
    weaknesses TEXT COMMENT 'Areas for improvement',
    interview_feedback TEXT NOT NULL COMMENT 'Detailed feedback',
    recommendation ENUM('STRONG_YES', 'YES', 'MAYBE', 'NO', 'STRONG_NO') DEFAULT 'MAYBE' COMMENT 'Interview recommendation',
    next_steps TEXT COMMENT 'Next steps',
    follow_up_date DATE COMMENT 'Follow-up date',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (interview_id) REFERENCES interview_schedules(id) ON DELETE CASCADE,
    FOREIGN KEY (application_id) REFERENCES applications(id) ON DELETE CASCADE,
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE,
    FOREIGN KEY (interviewer_id) REFERENCES users(id) ON DELETE RESTRICT,
    INDEX idx_application_id (application_id),
    INDEX idx_candidate_id (candidate_id),
    INDEX idx_interviewer_id (interviewer_id),
    INDEX idx_overall_rating (overall_rating),
    INDEX idx_recommendation (recommendation),
    INDEX idx_created_at (created_at),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Interview feedback and ratings';

CREATE TABLE IF NOT EXISTS application_history (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique history record identifier',
    application_id BIGINT NOT NULL COMMENT 'Reference to applications table',
    changed_by BIGINT NOT NULL COMMENT 'User ID who made change',
    old_status VARCHAR(50) COMMENT 'Previous status',
    new_status VARCHAR(50) COMMENT 'New status',
    change_reason VARCHAR(500) COMMENT 'Reason for change',
    change_details JSON COMMENT 'JSON details of changes',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    
    FOREIGN KEY (application_id) REFERENCES applications(id) ON DELETE CASCADE,
    FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE RESTRICT,
    INDEX idx_application_id (application_id),
    INDEX idx_changed_by (changed_by),
    INDEX idx_new_status (new_status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Application status history and audit trail';

-- ============================================================================
-- SECTION 6: RESUME PARSER MODULE
-- ============================================================================

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

CREATE TABLE IF NOT EXISTS parsed_skills (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique parsed skill identifier',
    parsed_resume_id BIGINT NOT NULL COMMENT 'Reference to parsed_resumes table',
    candidate_id BIGINT NOT NULL COMMENT 'Reference to candidates table',
    skill_name VARCHAR(100) NOT NULL COMMENT 'Extracted skill name',
    skill_category VARCHAR(100) COMMENT 'Skill category',
    proficiency_level ENUM('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT', 'UNKNOWN') DEFAULT 'UNKNOWN' COMMENT 'Inferred proficiency',
    mentions_count INT DEFAULT 1 COMMENT 'Number of times skill mentioned',
    first_mentioned_in VARCHAR(100) COMMENT 'First mentioned context',
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

-- ============================================================================
-- SECTION 7: TRACKING & AUDIT
-- ============================================================================

CREATE TABLE IF NOT EXISTS notifications (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique notification identifier',
    user_id BIGINT NOT NULL COMMENT 'Reference to users table',
    title VARCHAR(255) NOT NULL COMMENT 'Notification title',
    message TEXT NOT NULL COMMENT 'Notification message',
    notification_type ENUM('APPLICATION', 'INTERVIEW', 'JOB', 'MESSAGE', 'SYSTEM', 'ALERT') DEFAULT 'SYSTEM' COMMENT 'Type of notification',
    related_entity_type VARCHAR(50) COMMENT 'Entity type (job, application, etc)',
    related_entity_id BIGINT COMMENT 'Entity ID',
    is_read BOOLEAN DEFAULT FALSE COMMENT 'Read status',
    read_at TIMESTAMP NULL COMMENT 'When notification was read',
    action_url VARCHAR(500) COMMENT 'URL to take action',
    priority ENUM('LOW', 'MEDIUM', 'HIGH', 'URGENT') DEFAULT 'MEDIUM' COMMENT 'Notification priority',
    is_sent_email BOOLEAN DEFAULT FALSE COMMENT 'Email sent flag',
    is_sent_sms BOOLEAN DEFAULT FALSE COMMENT 'SMS sent flag',
    is_sent_push BOOLEAN DEFAULT FALSE COMMENT 'Push notification sent flag',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_notification_type (notification_type),
    INDEX idx_is_read (is_read),
    INDEX idx_priority (priority),
    INDEX idx_created_at (created_at),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='System notifications';

CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique audit log identifier',
    user_id BIGINT COMMENT 'Reference to users table',
    action VARCHAR(100) NOT NULL COMMENT 'Action performed',
    entity_type VARCHAR(100) NOT NULL COMMENT 'Entity type (user, job, application, etc)',
    entity_id BIGINT COMMENT 'Entity ID',
    old_values JSON COMMENT 'Old values before change',
    new_values JSON COMMENT 'New values after change',
    change_description TEXT COMMENT 'Description of change',
    ip_address VARCHAR(45) COMMENT 'IP address of user',
    user_agent VARCHAR(500) COMMENT 'User agent string',
    status VARCHAR(50) COMMENT 'Action status (SUCCESS, FAILED)',
    error_message TEXT COMMENT 'Error message if failed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_action (action),
    INDEX idx_entity_type (entity_type),
    INDEX idx_entity_id (entity_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Audit trail of all system changes';

CREATE TABLE IF NOT EXISTS login_history (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique login record identifier',
    user_id BIGINT NOT NULL COMMENT 'Reference to users table',
    login_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Login timestamp',
    logout_at TIMESTAMP NULL COMMENT 'Logout timestamp',
    ip_address VARCHAR(45) COMMENT 'IP address',
    user_agent VARCHAR(500) COMMENT 'User agent string',
    device_type VARCHAR(50) COMMENT 'Device type',
    device_name VARCHAR(255) COMMENT 'Device name',
    location VARCHAR(255) COMMENT 'Geolocation',
    login_method ENUM('EMAIL_PASSWORD', 'GOOGLE', 'LINKEDIN', 'GITHUB', 'FACEBOOK') DEFAULT 'EMAIL_PASSWORD' COMMENT 'Login method',
    is_suspicious BOOLEAN DEFAULT FALSE COMMENT 'Suspicious login flag',
    is_successful BOOLEAN DEFAULT TRUE COMMENT 'Successful login flag',
    failure_reason VARCHAR(255) COMMENT 'Reason if login failed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_login_at (login_at),
    INDEX idx_login_method (login_method),
    INDEX idx_is_suspicious (is_suspicious),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User login history';

CREATE TABLE IF NOT EXISTS activity_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique activity record identifier',
    user_id BIGINT NOT NULL COMMENT 'Reference to users table',
    activity_type VARCHAR(100) NOT NULL COMMENT 'Type of activity',
    activity_description TEXT COMMENT 'Description of activity',
    entity_type VARCHAR(100) COMMENT 'Entity type involved',
    entity_id BIGINT COMMENT 'Entity ID',
    metadata JSON COMMENT 'Additional metadata',
    ip_address VARCHAR(45) COMMENT 'IP address',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_activity_type (activity_type),
    INDEX idx_entity_type (entity_type),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User activity tracking';

CREATE TABLE IF NOT EXISTS profile_views (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique view record identifier',
    profile_type ENUM('CANDIDATE', 'COMPANY', 'JOB') DEFAULT 'CANDIDATE' COMMENT 'Type of profile viewed',
    profile_owner_id BIGINT NOT NULL COMMENT 'ID of profile owner (candidate/company)',
    viewer_id BIGINT COMMENT 'ID of viewer (user)',
    viewer_type VARCHAR(50) COMMENT 'Type of viewer (HR, recruiter, etc)',
    view_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'When profile was viewed',
    view_duration_seconds INT COMMENT 'Duration of view',
    ip_address VARCHAR(45) COMMENT 'IP address of viewer',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    
    INDEX idx_profile_owner_id (profile_owner_id),
    INDEX idx_viewer_id (viewer_id),
    INDEX idx_profile_type (profile_type),
    INDEX idx_view_timestamp (view_timestamp),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Profile view tracking';

-- ============================================================================
-- ENABLE FOREIGN KEY CHECKS
-- ============================================================================

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================================
-- DATABASE SUMMARY
-- ============================================================================
-- Total Tables: 56
-- 
-- SECTION 1: Authentication & RBAC (7 tables)
--   - users, roles, permissions, user_roles, role_permissions, refresh_tokens, otp_verifications, sessions
--
-- SECTION 2: Candidate Profile (9 tables)
--   - candidates, candidate_education, candidate_experience, candidate_skills
--   - candidate_projects, candidate_certifications, candidate_resumes, candidate_preferences
--   - candidate_social_links
--
-- SECTION 3: Company Profile (7 tables)
--   - companies, hr_users, company_locations, company_documents
--   - company_gallery, company_social_links, company_benefits
--
-- SECTION 4: Job Management (8 tables)
--   - job_categories, job_types, jobs, job_required_skills
--   - job_benefits, job_salary_ranges, job_locations, job_views
--
-- SECTION 5: Application Management (7 tables)
--   - applications, saved_jobs, shortlisted_candidates
--   - interview_schedules, interview_feedback, application_history
--
-- SECTION 6: Resume Parser (9 tables)
--   - parsed_resumes, parsed_skills, parsed_education
--   - parsed_experience, parsed_projects, parsed_certifications, parse_queue
--
-- SECTION 7: Tracking & Audit (5 tables)
--   - notifications, audit_logs, login_history, activity_logs, profile_views
--
-- ============================================================================
