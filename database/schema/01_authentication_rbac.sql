-- ============================================================================
-- AUTHENTICATION AND RBAC MODULE
-- Production-grade schema for user authentication and role-based access control
-- ============================================================================

-- Users table - stores all system users (candidates, HR, admins)
CREATE TABLE IF NOT EXISTS users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique user identifier',
    email VARCHAR(255) NOT NULL UNIQUE COMMENT 'User email address',
    phone VARCHAR(20) COMMENT 'User phone number',
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

-- Roles table - defines all available roles in the system
CREATE TABLE IF NOT EXISTS roles (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique role identifier',
    name VARCHAR(100) NOT NULL UNIQUE COMMENT 'Role name (e.g., CANDIDATE, HR_RECRUITER, ADMIN)',
    description TEXT COMMENT 'Role description',
    is_system_role BOOLEAN DEFAULT FALSE COMMENT 'Flag for built-in system roles',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    INDEX idx_name (name),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='System roles definition';

-- Permissions table - defines granular permissions
CREATE TABLE IF NOT EXISTS permissions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique permission identifier',
    name VARCHAR(100) NOT NULL UNIQUE COMMENT 'Permission name (e.g., view_jobs, create_job)',
    resource VARCHAR(100) NOT NULL COMMENT 'Resource type (e.g., job, candidate, company)',
    action VARCHAR(50) NOT NULL COMMENT 'Action type (e.g., view, create, update, delete)',
    description TEXT COMMENT 'Permission description',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP NULL COMMENT 'Soft delete timestamp',
    
    UNIQUE KEY uk_resource_action (resource, action),
    INDEX idx_resource (resource),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Fine-grained permissions';

-- User Roles mapping table - associates users with roles
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

-- Role Permissions mapping table - associates roles with permissions
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

-- Refresh Tokens table - for JWT refresh token management
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

-- OTP Verification table - for email and phone OTP verification
CREATE TABLE IF NOT EXISTS otp_verifications (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique OTP identifier',
    user_id BIGINT COMMENT 'Reference to users table (can be NULL for signup)',
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

-- Sessions table - for tracking active user sessions
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
