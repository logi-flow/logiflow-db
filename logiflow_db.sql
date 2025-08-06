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
    status VARCHAR(20) NOT NULL,
    
	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT uq_users_username UNIQUE (username),
    CONSTRAINT fk_users_role_id FOREIGN KEY (role_id) REFERENCES roles(id),
    CONSTRAINT ck_users_status CHECK (status IN ('ACTIVE', 'DELETED'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 고객사
CREATE TABLE IF NOT EXISTS `customers` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL,
	business_number VARCHAR(50) NOT NULL,
    name VARCHAR(50) NOT NULL,
    representative_name VARCHAR(20) NOT NULL,
    business_type VARCHAR(50) NOT NULL,
    business_items VARCHAR(50) NOT NULL,
    telephone VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL,
    fax VARCHAR(50),
    business_zipcode INT NOT NULL,
    business_address VARCHAR(255) NOT NULL,
    business_address_detail VARCHAR(255) NOT NULL,

    charge_position VARCHAR(20),
    charge_department VARCHAR(20),
    charge_name VARCHAR(50),
    charge_phone VARCHAR(20),
    charge_email VARCHAR(100),
    
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT uq_customers_business_number UNIQUE (business_number),
    CONSTRAINT fk_customers_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT ck_customers_status CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 계약
CREATE TABLE IF NOT EXISTS `contracts` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    customer_id BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    price INT NOT NULL,
    volume_limit INT NOT NULL,
    special_terms TEXT,
    
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
	CONSTRAINT fk_contracts_customer_id FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    CONSTRAINT ck_contracts_status CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED', 'EXPIRED', 'DELETED'))
)CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

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
    
    CONSTRAINT uq_drivers_identity_number UNIQUE (identity_number),
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
    
    CONSTRAINT uq_employees_identity_number UNIQUE (identity_number),
    CONSTRAINT fk_employees_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT ck_employees_department CHECK (department IN ('HUMAN_RESOURCES', 'LOGISTICS_MANAGEMENT')),
    # HUMAN_RESOURCES: 인사팀, logsISTICS_MANAGEMENT: 물류팀
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
    
    CONSTRAINT uq_driver_licenses_driver_number UNIQUE (driver_number),
    CONSTRAINT fk_driver_licenses_driver_id FOREIGN KEY (driver_id) REFERENCES drivers(id) ON DELETE CASCADE,
    CONSTRAINT ck_driver_licenses_type CHECK (type IN ('CLASS1', 'CLASS2', 'HGV'))
    # CLASS1: 1종 보통, CLASS2: 2종 보통, HGV: 1종 대형
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 운송수단
CREATE TABLE IF NOT EXISTS `vehicles` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
	vehicle_number VARCHAR(255) NOT NULL,
	capacity INT NOT NULL,
	fuel VARCHAR(20) NOT NULL,
	mileage DECIMAL(10,2) NOT NULL,
	status VARCHAR(20) NOT NULL,
	model_name VARCHAR(20) NOT NULL,
	model_year YEAR NOT NULL,

	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT uq_vehicles_vehicle_number UNIQUE (vehicle_number),
  CONSTRAINT ck_vehicles_fuel CHECK (fuel IN ('GASOLINE', 'LPG', 'ELECTRIC', 'DIESEL')),
  CONSTRAINT ck_vehicles_status CHECK (status IN ('AVAILABLE', 'IN_USE', 'UNDER_MAINTENANCE', 'DELETED'))
  # AVAILABLE: 배정 가능, IN_USE: 운행 중, UNDER_MAINTENANCE: 정비 중, DELETED: 비활성화
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 배송
CREATE TABLE IF NOT EXISTS `deliveries` (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  customer_id BIGINT NOT NULL,
  request_date DATETIME NOT NULL,
  item VARCHAR(255) NOT NULL,
  weight DECIMAL(10,2) NOT NULL,
  message VARCHAR(255),
  is_hidden BOOLEAN DEFAULT FALSE,
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
  CONSTRAINT ck_delivery_status CHECK (status IN ('REQUESTED', 'RECEIPTED', 'CANCELLED', 'ASSIGNED', 'REJECTED', 'DELETED'))
  # REQUESTED: 요청, RECEIPTED: 접수, CANCELLED: 취소, ASSIGNED: 승인, REJECTED: 거절
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 배정
CREATE TABLE IF NOT EXISTS `assignments` (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  driver_id BIGINT NOT NULL,
  vehicle_id BIGINT NOT NULL,
  is_primary BOOLEAN DEFAULT TRUE,
  status VARCHAR(20) NOT NULL,
  
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  CONSTRAINT fk_assignments_driver_id FOREIGN KEY (driver_id) REFERENCES drivers(id) ON DELETE CASCADE,
  CONSTRAINT fk_assignments_vehicle_id FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
  CONSTRAINT ck_assignments_status CHECK (status IN ('ACTIVE', 'DELETED'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 배차
CREATE TABLE IF NOT EXISTS `allocations` (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  delivery_id BIGINT NOT NULL,
  assignment_id BIGINT NOT NULL,
  district_name VARCHAR(20) NOT NULL,
  start_mileage DECIMAL(10,2) NOT NULL,
  end_mileage DECIMAL(10,2) NOT NULL,
  status VARCHAR(20) NOT NULL,
  
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  CONSTRAINT fk_allocations_delivery_id FOREIGN KEY (delivery_id) REFERENCES deliveries(id) ON DELETE CASCADE,
  CONSTRAINT fk_allocations_assignment_id FOREIGN KEY (assignment_id) REFERENCES assignments(id) ON DELETE CASCADE,
  CONSTRAINT ck_allocations_status CHECK (status IN ('ASSIGNED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'DELETED'))
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

--# 출근부
CREATE TABLE IF NOT EXISTS `attendance` (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  driver_id BIGINT NOT NULL,
  employee_id BIGINT NOT NULL, 
  work_start DATETIME,
  work_end DATETIME,

  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  CONSTRAINT fk_attendance_driver_id FOREIGN KEY (driver_id) REFERENCES drivers(id) ON DELETE CASCADE,
  CONSTRAINT fk_attendance_employee_id FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 수당 항목
CREATE TABLE IF NOT EXISTS `allowance_types` (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  code VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  description VARCHAR(255),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  status VARCHAR(20) NOT NULL,

  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  CONSTRAINT uq_allowance_types_code UNIQUE (code),
  CONSTRAINT ck_allowance_types_status CHECK (status IN ('ACTIVE', 'DELETED'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 공제 항목
CREATE TABLE IF NOT EXISTS `deduction_types` (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  code VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  description VARCHAR(255),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  status VARCHAR(20) NOT NULL,

  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  CONSTRAINT uq_deduction_types_code UNIQUE (code),
  CONSTRAINT ck_deduction_types_status CHECK (status IN ('ACTIVE', 'DELETED'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 급여대장
CREATE TABLE IF NOT EXISTS `driver_payrolls` (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  driver_id BIGINT NOT NULL,
  status VARCHAR(20) NOT NULL,
  title VARCHAR(255),
  period_start_date DATE NOT NULL,
  period_end_date DATE NOT NULL,
  total_allowance INT NOT NULL,
  total_deduction INT NOT NULL,
  final_amount INT NOT NULL,

  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  CONSTRAINT uq_driver_payrolls_period UNIQUE (driver_id, period_start_date, period_end_date),
  CONSTRAINT fk_driver_payrolls_driver_id FOREIGN KEY (driver_id) REFERENCES drivers(id) ON DELETE CASCADE,
  CONSTRAINT ck_driver_payrolls_status CHECK (status IN ('CREATED', 'CONFIRMED', 'DELETED')),
  # CREATED: 생성(작성 중), CONFIRMED: 확정, DELETED: 삭제
  CONSTRAINT ck_driver_payrolls_period_range CHECK (period_start_date <= period_end_date)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 수당 내역
CREATE TABLE IF NOT EXISTS `driver_allowances` (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  payroll_id BIGINT NOT NULL,
  allowance_type_id BIGINT NOT NULL,
  quantity DECIMAL(10,2) NOT NULL,
  unit_price INT NOT NULL,
  amount INT NOT NULL,
  memo TEXT,

  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT fk_driver_allowances_payroll_id FOREIGN KEY (payroll_id) REFERENCES driver_payrolls(id) ON DELETE CASCADE,
  CONSTRAINT fk_driver_allowances_allowance_type_id FOREIGN KEY (allowance_type_id) REFERENCES allowance_types(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 공제 내역
CREATE TABLE IF NOT EXISTS `driver_deductions` (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  payroll_id BIGINT NOT NULL,
  deduction_type_id BIGINT NOT NULL,
  quantity DECIMAL(10,2) NOT NULL,
  unit_price INT NOT NULL,
  amount INT NOT NULL,
  memo TEXT,

  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT fk_driver_deductions_payroll_id FOREIGN KEY (payroll_id) REFERENCES driver_payrolls(id) ON DELETE CASCADE,
  CONSTRAINT fk_driver_deductions_deduction_type_id FOREIGN KEY (deduction_type_id) REFERENCES deduction_types(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 알림
CREATE TABLE IF NOT EXISTS `alerts` (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  message TEXT NOT NULL,

  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  CONSTRAINT fk_alerts_driver_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE  
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 삭제 로그
CREATE TABLE IF NOT EXISTS `delete_logs` (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  table_name VARCHAR(50) NOT NULL,
  record_id BIGINT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expired_at DATE NOT NULL,
  deleted_by BIGINT,
  delete_type VARCHAR(20) NOT NULL DEFAULT 'SOFT',
  
  CONSTRAINT fk_delete_logs_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT ck_delete_logs_delete_type CHECK (delete_type IN ('SOFT', 'HARD'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 고객사 정보 수정 로그
CREATE TABLE IF NOT EXISTS `customers_update_logs` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    customer_id BIGINT,
    changed_by BIGINT,
    changed_by_username VARCHAR(20) NOT NULL,
    change_reason VARCHAR(255),
	type VARCHAR(50) NOT NULL,
    prev_data VARCHAR(100),
    new_data VARCHAR(100),
    
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_customers_update_logs_customer_id FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL,
    CONSTRAINT fk_customers_update_logs_changed_by FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 고객사 상태 로그
CREATE TABLE IF NOT EXISTS `customers_status_logs` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
	customer_id BIGINT,
    changed_by BIGINT,
    changed_by_username VARCHAR(20) NOT NULL,
    change_reason VARCHAR(255),
	prev_status VARCHAR(100) NOT NULL,
	new_status VARCHAR(100) NOT NULL,
    
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
       
	CONSTRAINT fk_customers_status_logs_customer_id FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL,
    CONSTRAINT fk_customers_status_logs_changed_by FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL,
	CONSTRAINT ck_customers_status_logs_prev_status CHECK (prev_status IN ('PENDING', 'APPROVED', 'REJECTED')),
	CONSTRAINT ck_customers_status_logs_new_status CHECK (new_status IN ('PENDING', 'APPROVED', 'REJECTED'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 차량 상태 로그
CREATE TABLE IF NOT EXISTS `vehicles_status_logs` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
	vehicle_id BIGINT,
    changed_by BIGINT,
    changed_by_username VARCHAR(20) NOT NULL,
    change_reason VARCHAR(255),
	prev_status VARCHAR(100) NOT NULL,
	new_status VARCHAR(100) NOT NULL,
    
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
       
	CONSTRAINT fk_vehicles_status_logs_vehicle_id FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE SET NULL,
	CONSTRAINT fk_vehicles_status_logs_changed_by FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL,
	CONSTRAINT ck_vehicles_status_logs_prev_status CHECK (prev_status IN ('AVAILABLE', 'IN_USE', 'UNDER_MAINTENANCE', 'DELETED')),
	CONSTRAINT ck_vehicles_status_logs_new_status CHECK (new_status IN ('AVAILABLE', 'IN_USE', 'UNDER_MAINTENANCE', 'DELETED'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 기사 정보 수정 로그
CREATE TABLE IF NOT EXISTS `drivers_update_logs` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    driver_id BIGINT,
    changed_by BIGINT,
    changed_by_username VARCHAR(20) NOT NULL,
    change_reason VARCHAR(255),
	type VARCHAR(50) NOT NULL,
    prev_data VARCHAR(100),
    new_data VARCHAR(100),
    
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_drivers_update_logs_driver_id FOREIGN KEY (driver_id) REFERENCES drivers(id) ON DELETE SET NULL,
    CONSTRAINT fk_drivers_update_logs_changed_by FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 기사 상태 로그
CREATE TABLE IF NOT EXISTS `drivers_status_logs` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
	driver_id BIGINT,
    changed_by BIGINT,
    changed_by_username VARCHAR(20) NOT NULL,
    change_reason VARCHAR(255),
	prev_status VARCHAR(100) NOT NULL,
	new_status VARCHAR(100) NOT NULL,
    
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
       
	CONSTRAINT fk_drivers_status_logs_driver_id FOREIGN KEY (driver_id) REFERENCES drivers(id) ON DELETE SET NULL,
	CONSTRAINT fk_drivers_status_logs_changed_by FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL,
	CONSTRAINT ck_drivers_status_logs_prev_status CHECK (prev_status IN ('ACTIVED', 'INACTIVED', 'ASSIGNED')),
	CONSTRAINT ck_drivers_status_logs_new_status CHECK (new_status IN ('ACTIVED', 'INACTIVED', 'ASSIGNED'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 직원 정보 수정 로그
CREATE TABLE IF NOT EXISTS `employees_update_logs` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    employee_id BIGINT,
    changed_by BIGINT,
    changed_by_username VARCHAR(20) NOT NULL,
    change_reason VARCHAR(255),
	type VARCHAR(50) NOT NULL,
    prev_data VARCHAR(100),
    new_data VARCHAR(100),
    
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_employees_update_logs_employee_id FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE SET NULL,
    CONSTRAINT fk_employees_update_logs_changed_by FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 직원 인사 정보 수정 로그
CREATE TABLE IF NOT EXISTS `employees_org_logs` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    employee_id BIGINT,
    changed_by BIGINT,
    changed_by_username VARCHAR(20) NOT NULL,
    change_reason VARCHAR(255),
	type VARCHAR(50) NOT NULL,
    prev_data VARCHAR(100),
    new_data VARCHAR(100),
    
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_employees_org_logs_employee_id FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE SET NULL,
    CONSTRAINT fk_employees_org_logs_changed_by FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 운전 면허증 수정 로그
CREATE TABLE IF NOT EXISTS `driver_license_logs` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    driver_license_id BIGINT,
    changed_by BIGINT,
    changed_by_username VARCHAR(20) NOT NULL,
    change_reason VARCHAR(255),
	type VARCHAR(50) NOT NULL,
    prev_data VARCHAR(100),
    new_data VARCHAR(100),
    
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_driver_license_logs_driver_license_id FOREIGN KEY (driver_license_id) REFERENCES driver_licenses(id) ON DELETE SET NULL,
    CONSTRAINT fk_driver_license_logs_changed_by FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 배송 정보 수정 로그
CREATE TABLE IF NOT EXISTS `deliveries_update_logs` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    delivery_id BIGINT,
    changed_by BIGINT,
    changed_by_username VARCHAR(20) NOT NULL,
    change_reason VARCHAR(255),
	type VARCHAR(50) NOT NULL,
    prev_data VARCHAR(100),
    new_data VARCHAR(100),
    
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_deliveries_update_logs_delivery_id FOREIGN KEY (delivery_id) REFERENCES deliveries(id) ON DELETE SET NULL,
    CONSTRAINT fk_deliveries_update_logs_changed_by FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 배송 상태 로그
CREATE TABLE IF NOT EXISTS `deliveries_status_logs` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
	delivery_id BIGINT,
    changed_by BIGINT,
    changed_by_username VARCHAR(20) NOT NULL,
    change_reason VARCHAR(255),
	prev_status VARCHAR(100) NOT NULL,
	new_status VARCHAR(100) NOT NULL,
    
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
       
	CONSTRAINT fk_deliveries_status_logs_delivery_id FOREIGN KEY (delivery_id) REFERENCES deliveries(id) ON DELETE SET NULL,
	CONSTRAINT fk_deliveries_status_logs_changed_by FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL,
	CONSTRAINT ck_deliveries_status_logs_prev_status CHECK (prev_status IN ('REQUESTED', 'RECEIPTED', 'CANCELLED', 'ASSIGNED', 'REJECTED')),
	CONSTRAINT ck_deliveries_status_logs_new_status CHECK (new_status IN ('REQUESTED', 'RECEIPTED', 'CANCELLED', 'ASSIGNED', 'REJECTED'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 배정 정보 수정 로그
CREATE TABLE IF NOT EXISTS `assignments_update_logs` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    assignment_id BIGINT,
    changed_by BIGINT,
    changed_by_username VARCHAR(20) NOT NULL,
    change_reason VARCHAR(255),
	type VARCHAR(50) NOT NULL,
    prev_data VARCHAR(100),
    new_data VARCHAR(100),
    
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_assignments_update_logs_assignment_id FOREIGN KEY (assignment_id) REFERENCES assignments(id) ON DELETE SET NULL,
    CONSTRAINT fk_assignments_update_logs_changed_by FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 배차 정보 수정 로그
CREATE TABLE IF NOT EXISTS `allocations_update_logs` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    allocation_id BIGINT,
    changed_by BIGINT,
    changed_by_username VARCHAR(20) NOT NULL,
    change_reason VARCHAR(255),
	type VARCHAR(50) NOT NULL,
    prev_data VARCHAR(100),
    new_data VARCHAR(100),
    
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_allocations_update_logs_allocation_id FOREIGN KEY (allocation_id) REFERENCES allocations(id) ON DELETE SET NULL,
    CONSTRAINT fk_allocations_update_logs_changed_by FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 배차 상태 로그
CREATE TABLE IF NOT EXISTS `allocations_status_logs` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
	allocation_id BIGINT,
    changed_by BIGINT,
    changed_by_username VARCHAR(20) NOT NULL,
    change_reason VARCHAR(255),
	prev_status VARCHAR(100) NOT NULL,
	new_status VARCHAR(100) NOT NULL,
    
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	
	CONSTRAINT fk_allocations_status_logs_allocation_id FOREIGN KEY (allocation_id) REFERENCES allocations(id) ON DELETE SET NULL,
	CONSTRAINT fk_allocations_status_logs_changed_by FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL,
	CONSTRAINT ck_allocations_status_logs_prev_status CHECK (prev_status IN ('ASSIGNED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
	CONSTRAINT ck_allocations_status_logs_new_status CHECK (new_status IN ('ASSIGNED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 수당 항목 수정 로그
CREATE TABLE IF NOT EXISTS `allowance_types_update_logs` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    allowance_type_id BIGINT,
    changed_by BIGINT,
    changed_by_username VARCHAR(20) NOT NULL,
    change_reason VARCHAR(255),
	type VARCHAR(50) NOT NULL,
    prev_data VARCHAR(100),
    new_data VARCHAR(100),
    
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_allowance_types_update_logs_allowance_type_id FOREIGN KEY (allowance_type_id) REFERENCES allowance_types(id) ON DELETE SET NULL,
    CONSTRAINT fk_allowance_types_update_logs_changed_by FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 공제 항목 수정 로그
CREATE TABLE IF NOT EXISTS `deduction_types_update_logs` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    deduction_type_id BIGINT,
    changed_by BIGINT,
    changed_by_username VARCHAR(20) NOT NULL,
    change_reason VARCHAR(255),
	type VARCHAR(50) NOT NULL,
    prev_data VARCHAR(100),
    new_data VARCHAR(100),
    
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_deduction_types_update_logs_allowance_type_id FOREIGN KEY (deduction_type_id) REFERENCES deduction_types(id) ON DELETE SET NULL,
    CONSTRAINT fk_deduction_types_update_logs_changed_by FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 급여대장 수정 로그
CREATE TABLE IF NOT EXISTS `driver_payrolls_update_logs` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    driver_payroll_id BIGINT,
    changed_by BIGINT,
    changed_by_username VARCHAR(20) NOT NULL,
    change_reason VARCHAR(255),
	type VARCHAR(50) NOT NULL,
    prev_data VARCHAR(100),
    new_data VARCHAR(100),
    
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_driver_payrolls_update_logs_driver_payroll_id FOREIGN KEY (driver_payroll_id) REFERENCES driver_payrolls(id) ON DELETE SET NULL,
    CONSTRAINT fk_driver_payrolls_update_logs_changed_by FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 급여대장 상태 로그
CREATE TABLE IF NOT EXISTS `driver_payrolls_status_logs` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
	driver_payroll_id BIGINT,
    changed_by BIGINT,
    changed_by_username VARCHAR(20) NOT NULL,
    change_reason VARCHAR(255),
	prev_status VARCHAR(100) NOT NULL,
	new_status VARCHAR(100) NOT NULL,
    
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	
	CONSTRAINT fk_driver_payrolls_status_logs_driver_payroll_id FOREIGN KEY (driver_payroll_id) REFERENCES driver_payrolls(id) ON DELETE SET NULL,
	CONSTRAINT fk_driver_payrolls_status_logs_changed_by FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL,
	CONSTRAINT ck_driver_payrolls_status_logs_prev_status CHECK (prev_status IN ('CREATED', 'CONFIRMED', 'DELETED')),
	CONSTRAINT ck_driver_payrolls_status_logs_new_status CHECK (new_status IN ('CREATED', 'CONFIRMED', 'DELETED'))
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 수당 내역 수정 로그
CREATE TABLE IF NOT EXISTS `driver_allowances_update_logs` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    driver_allowance_id BIGINT,
    changed_by BIGINT,
    changed_by_username VARCHAR(20) NOT NULL,
    change_reason VARCHAR(255),
	type VARCHAR(50) NOT NULL,
    prev_data VARCHAR(100),
    new_data VARCHAR(100),
    
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_driver_allowances_update_logs_driver_allowance_id FOREIGN KEY (driver_allowance_id) REFERENCES driver_allowances(id) ON DELETE SET NULL,
    CONSTRAINT fk_driver_allowances_update_logs_changed_by FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

--# 공제 내역 수정 로그
CREATE TABLE IF NOT EXISTS `driver_deductions_update_logs` (
	id BIGINT PRIMARY KEY AUTO_INCREMENT,
    driver_deduction_id BIGINT,
    changed_by BIGINT,
    changed_by_username VARCHAR(20) NOT NULL,
    change_reason VARCHAR(255),
	type VARCHAR(50) NOT NULL,
    prev_data VARCHAR(100),
    new_data VARCHAR(100),
    
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_driver_deductions_update_logs_allowance_type_id FOREIGN KEY (driver_deduction_id) REFERENCES driver_deductions(id) ON DELETE SET NULL,
    CONSTRAINT fk_driver_deductions_update_logs_changed_by FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;