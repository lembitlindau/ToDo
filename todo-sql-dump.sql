-- Create and use database

DROP DATABASE IF EXISTS todo_app;
CREATE DATABASE IF NOT EXISTS todo_app;
USE todo_app;

-- Tasks table
CREATE TABLE tasks (
    task_id INT UNSIGNED AUTO_INCREMENT,
    title VARCHAR(255) COMMENT 'VARCHAR used instead of TEXT as titles are typically under 255 chars and VARCHAR is more efficient for indexing',
    description TEXT COMMENT 'TEXT used as descriptions can be longer and dont need to be indexed',
    created_at DATETIME COMMENT 'DATETIME used to track creation time with timezone consideration',
    due_date DATE COMMENT 'DATE used as we only need the day, not time components',
    status ENUM('pending', 'in_progress', 'completed', 'cancelled') DEFAULT 'pending',
    priority TINYINT UNSIGNED DEFAULT 1,
    PRIMARY KEY (task_id)
) ENGINE=InnoDB;

-- Categories table
CREATE TABLE categories (
    category_id INT UNSIGNED AUTO_INCREMENT,
    name VARCHAR(50) COMMENT 'VARCHAR(50) sufficient for category names, needs indexing for lookups',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'TIMESTAMP used for automatic creation time tracking',
    color_code CHAR(7) COMMENT 'Fixed length CHAR(7) for hex color codes (#RRGGBB)',
    is_active BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (category_id)
) ENGINE=InnoDB;

-- Users table
CREATE TABLE users (
    user_id INT UNSIGNED AUTO_INCREMENT,
    username VARCHAR(50) COMMENT 'VARCHAR optimal for usernames needing index',
    email VARCHAR(255) COMMENT 'VARCHAR used as emails have variable length but max 254 chars by standard',
    password_hash CHAR(60) COMMENT 'Fixed length CHAR(60) for bcrypt hash',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'TIMESTAMP for automatic user creation tracking',
    last_login DATETIME COMMENT 'DATETIME to track login time across timezones',
    PRIMARY KEY (user_id),
    UNIQUE KEY unique_username (username),
    UNIQUE KEY unique_email (email)
) ENGINE=InnoDB;

-- Task_categories junction table
CREATE TABLE task_categories (
    task_id INT UNSIGNED,
    category_id INT UNSIGNED,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'TIMESTAMP for automatic assignment tracking',
    PRIMARY KEY (task_id, category_id),
    /* CASCADE delete as category assignments should be removed with task */
    FOREIGN KEY (task_id)
        REFERENCES tasks(task_id)
        ON DELETE CASCADE,
    FOREIGN KEY (category_id) 
        REFERENCES categories(category_id) 
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Task_users table
USE todo_app;

CREATE TABLE task_users (

                            task_id INT UNSIGNED,
                            user_id INT UNSIGNED,
                            assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'TIMESTAMP for automatic assignment tracking',
                            due_date DATE COMMENT 'DATE type as only day precision needed',
                            notes TEXT COMMENT 'TEXT for potentially long assignment notes',
                            PRIMARY KEY (task_id, user_id),
                            UNIQUE KEY unique_task_user (task_id, user_id),
                            FOREIGN KEY (task_id)
                                REFERENCES tasks(task_id)
                                ON DELETE CASCADE ON UPDATE CASCADE,
                            FOREIGN KEY (user_id)
                                REFERENCES users(user_id)
                                ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Sample data for tasks
INSERT INTO tasks (title, description, created_at, due_date, status, priority) VALUES
('Complete project documentation', 'Write comprehensive documentation for the TODO app', '2024-01-15 09:00:00', '2024-01-20', 'in_progress', 2),
('Implement user authentication', 'Add login and registration functionality', '2024-01-15 10:00:00', '2024-01-25', 'pending', 3),
('Design database schema', 'Create ERD and SQL scripts', '2024-01-15 11:00:00', '2024-01-18', 'completed', 1),
('Set up CI/CD pipeline', 'Configure GitHub Actions for automated testing', '2024-01-15 12:00:00', '2024-01-30', 'pending', 2),
('Code review', 'Review pull requests from team members', '2024-01-15 13:00:00', '2024-01-17', 'pending', 1);

-- Sample data for categories
INSERT INTO categories (name, color_code, is_active) VALUES
('Development', '#FF0000', TRUE),
('Documentation', '#00FF00', TRUE),
('Testing', '#0000FF', TRUE),
('Design', '#FFFF00', TRUE),
('DevOps', '#FF00FF', TRUE);

-- Sample data for users
INSERT INTO users (username, email, password_hash, last_login) VALUES
('john_doe', 'john@example.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPhamglOBJZC.', '2024-01-15 10:00:00'),
('jane_smith', 'jane@example.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPhamglOBJZC.', '2024-01-15 11:00:00'),
('bob_wilson', 'bob@example.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPhamglOBJZC.', '2024-01-15 12:00:00'),
('alice_jones', 'alice@example.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPhamglOBJZC.', '2024-01-15 13:00:00'),
('sam_brown', 'sam@example.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPhamglOBJZC.', '2024-01-15 14:00:00');

-- Sample data for task_categories
INSERT INTO task_categories (task_id, category_id) VALUES
(1, 2), -- Documentation task in Documentation category
(2, 1), -- Authentication task in Development category
(3, 4), -- Database task in Design category
(4, 5), -- CI/CD task in DevOps category
(5, 1); -- Code review task in Development category

-- Sample data for task_assignments
INSERT INTO task_users (task_id, user_id, due_date, notes) VALUES
(1, 1, '2024-01-20', 'Focus on API documentation first'),
(2, 2, '2024-01-25', 'Use JWT for authentication'),
(3, 3, '2024-01-18', 'Include indexing strategy'),
(4, 4, '2024-01-30', 'Configure both testing and deployment workflows'),
(5, 5, '2024-01-17', 'Pay special attention to security practices');
