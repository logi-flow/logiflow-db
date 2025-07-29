CREATE DATABASE IF NOT EXISTS `logi_flow_db`
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `logi_flow_db`;

--# 권한
CREATE TABLE IF NOT EXISTS `roles` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT uq_roles_name UNIQUE (name)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

INSERT INTO `roles` (id, name)
VALUES (DEFAULT, 'ADMIN');
--# 유저
CREATE TABLE IF NOT EXISTS `users` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    role_id BIGINT NOT NULL,
	username VARCHAR(20) NOT NULL,
    password VARCHAR(255) NOT NULL,
	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT uq_users_username UNIQUE (username),
    CONSTRAINT fk_users_role_id FOREIGN KEY (role_id) REFERENCES roles(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 고객사
CREATE TABLE IF NOT EXISTS `customers` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL,
	business_number VARCHAR(50) NOT NULL,
    name VARCHAR(50) NOT NULL, 
    representative_name VARCHAR(20) NOT NULL,
    telephone VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL,
    fax VARCHAR(50),
    business_zipcode INT NOT NULL,
    business_address VARCHAR(255) NOT NULL,
    business_address_detail VARCHAR(255) NOT NULL,
    business_type VARCHAR(50) NOT NULL,
    business_items VARCHAR(50) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    # 담당자 직책 직무 이름 연락처 이메일
    
    CONSTRAINT uq_business_number UNIQUE (business_number),
    CONSTRAINT fk_customers_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT ck_customers_status CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 기사
CREATE TABLE IF NOT EXISTS `drivers` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL,
	name VARCHAR(50) NOT NULL,
    identity_number VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    zipcode INT NOT NULL,
    address VARCHAR(255) NOT NULL,
    address_detail VARCHAR(255) NOT NULL,
    district VARCHAR(20) NOT NULL, 
    pay INT NOT NULL,
    company_join DATE NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT uq_identity_number UNIQUE (identity_number),
    CONSTRAINT fk_drivers_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT ck_drivers_status CHECK (status IN ('ACTIVED', 'INACTIVED', 'ASSIGNED')),
    CONSTRAINT ck_drivers_district CHECK (district IN ('', '', ''))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 직원
CREATE TABLE IF NOT EXISTS `employees` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    name VARCHAR(50) NOT NULL,
    identity_number VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    zipcode INT NOT NULL,
    address VARCHAR(255) NOT NULL,
    address_detail VARCHAR(255) NOT NULL,
    department VARCHAR(20) NOT NULL,
    position VARCHAR(20) NOT NULL,
    company_join DATE NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_employees_user_id FOREIGN KEY (user_id) REFERENCES drivers(id) ON DELETE CASCADE,
    CONSTRAINT ck_employees_department CHECK (department IN ('HUMAN_RESOURCES', 'LOGISTICS_MANAGEMENT')),
    # HUMAN_RESOURCES: 인사팀, LOGISTICS_MANAGEMENT: 물류팀
    CONSTRAINT ck_employees_position CHECK (position IN ('GENERAL_MANAGER', 'DEPUTY_GENERAL_MANAGER', 'MANGER', 'ASSISTANT_MANAGER', 'STAFF', 'INTERN'))
    # GENERAL_MANAGER: 부장, DEPUTY_GENERAL_MANAGER: 차장, MANGER: 과장, ASSISTANT_MANAGER: 대리, STAFF: 사원, INTERN: 인턴
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;


--# 운전면허증
CREATE TABLE IF NOT EXISTS `driver_licenses` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    driver_id BIGINT NOT NULL,
    driver_number VARCHAR(50) NOT NULL,
    type VARCHAR(50) NOT NULL, 
    expired_date DATE NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_driver_licenses_driver_id FOREIGN KEY (driver_id) REFERENCES drivers(id) ON DELETE CASCADE,
    CONSTRAINT ck_driver_licenses_type CHECK (type IN ('', '', ''))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 운송수단
CREATE TABLE IF NOT EXISTS `vehicles` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
  vehicle_number VARCHAR(255) NOT NULL,
  capacity INT NOT NULL,
  fuel VARCHAR(20) NOT NULL,
  mileage VARCHAR(20) NOT NULL,
  model_name VARCHAR(20) NOT NULL,
  model_year YEAR NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT uq_vehicles_number UNIQUE (vehicle_number),
  CONSTRAINT ck_vehicles_fuel CHECK (fuel IN ('GASOLINE', 'LPG', 'ELECTRIC', 'DIESEL')),
  CONSTRAINT ck_vehicles_mileage CHECK (mileage IN ('AVAILABLE', 'IN_USE', 'UNDER_MAINTENANCE', 'INACTIVE'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 배송
CREATE TABLE IF NOT EXISTS `deliveries` (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  customer_id BIGINT NOT NULL,
  request_date DATETIME NOT NULL,
  item VARCHAR(255) NOT NULL,
  weight FLOAT NOT NULL,
  message VARCHAR(255),
  status VARCHAR(20) NOT NULL,

  pickup_name VARCHAR(100) NOT NULL,
  pickup_phone VARCHAR(20) NOT NULL,
  pickup_zipcode INT NOT NULL,
  pickup_address VARCHAR(255) NOT NULL,
  pickup_address_detail VARCHAR(255) NOT NULL,

  recipient_name VARCHAR(100) NOT NULL,
  recipient_phone VARCHAR(20) NOT NULL,
  recipient_zipcode INT NOT NULL,
  recipient_address VARCHAR(255) NOT NULL,
  recipient_address_detail VARCHAR(255) NOT NULL,

  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT fk_deliveries_customer_id FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
  CONSTRAINT ck_delivery_status CHECK (status IN ('REQUESTED', 'CANCELLED', 'ASSIGNED', 'REJECTED'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 배정
CREATE TABLE IF NOT EXISTS `assignments` (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  driver_id BIGINT NOT NULL,
  vehicle_id BIGINT NOT NULL,
  is_primary BOOLEAN DEFAULT TRUE,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  CONSTRAINT fk_assignments_driver_id FOREIGN KEY (driver_id) REFERENCES drivers(id) ON DELETE CASCADE,
  CONSTRAINT fk_assignments_vehicle_id FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 배차
CREATE TABLE IF NOT EXISTS `allocations` (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  delivery_id BIGINT NOT NULL,
  assignment_id BIGINT NOT NULL,
  district_name VARCHAR(20) NOT NULL,
  status VARCHAR(20) NOT NULL,

  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  CONSTRAINT fk_allocations_delivery_id FOREIGN KEY (delivery_id) REFERENCES deliveries(id) ON DELETE CASCADE,
  CONSTRAINT fk_allocations_assignment_id FOREIGN KEY (assignment_id) REFERENCES assignments(id) ON DELETE CASCADE,
  CONSTRAINT ck_allocations_status CHECK (status IN ('ASSIGNED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 배차스케줄
CREATE TABLE IF NOT EXISTS `schedules` (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  allocation_id BIGINT NOT NULL,
  allocation_date DATE NOT NULL,
  departure_time DATETIME,
  arrival_time DATETIME,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  CONSTRAINT fk_schedules_allocations_id FOREIGN KEY (allocation_id) REFERENCES allocations(id) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;