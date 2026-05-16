-- ============================================================================
-- COMPANY PROFILE MODULE
-- Production-grade schema for company information and HR management
-- ============================================================================

-- Companies table - core company information
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
    annual_revenue VARCHAR(100) COMMENT 'Annual revenue',
    company_type ENUM('PUBLIC', 'PRIVATE', 'STARTUP', 'NGO', 'GOVERNMENT', 'PARTNERSHIP') COMMENT 'Company type',
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
    INDEX idx_is_featured (is_featured),
    INDEX idx_headquarters_country (headquarters_country),
    INDEX idx_created_at (created_at),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Company profile information';

-- HR Users table - HR representatives from companies
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
    INDEX idx_is_admin (is_admin),
    INDEX idx_last_activity_at (last_activity_at),
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
    INDEX idx_is_active (is_active),
    SPATIAL INDEX idx_location (latitude, longitude),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Company office locations';

-- Company Documents table - store company documents/certifications
CREATE TABLE IF NOT EXISTS company_documents (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique document identifier',
    company_id BIGINT NOT NULL COMMENT 'Reference to companies table',
    document_name VARCHAR(255) NOT NULL COMMENT 'Document name',
    document_type ENUM('LICENSE', 'CERTIFICATE', 'AWARD', 'PATENT', 'REGISTRATION', 'COMPLIANCE', 'OTHER') COMMENT 'Document type',
    file_name VARCHAR(255) NOT NULL COMMENT 'Original file name',
    file_path VARCHAR(500) NOT NULL COMMENT 'Path to document file',
    file_size_bytes INT COMMENT 'File size in bytes',
    file_type VARCHAR(50) COMMENT 'File type (PDF, image, etc)',
    storage_type ENUM('LOCAL', 'S3', 'AZURE') DEFAULT 'AZURE' COMMENT 'Storage service',
    s3_bucket_name VARCHAR(255) COMMENT 'S3 bucket name',
    azure_container_name VARCHAR(255) COMMENT 'Azure container name',
    issue_date DATE COMMENT 'Document issue date',
    expiration_date DATE COMMENT 'Document expiration date (if applicable)',
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
    INDEX idx_is_public (is_public),
    INDEX idx_expiration_date (expiration_date),
    INDEX idx_created_at (created_at),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Company documents and certifications';

-- Company Gallery table - company photos/media
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

-- Company Benefits table - benefits offered by company
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
    INDEX idx_is_verified (is_verified),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Company benefits and perks';
