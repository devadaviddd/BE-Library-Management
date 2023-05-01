CREATE TABLE STUDENT_ENTITY (
  email VARCHAR(30) PRIMARY KEY,
  u_password VARCHAR(30) NOT NULL,
  u_role VARCHAR(10) NOT NULL CHECK (u_role IN ('Student', 'Teacher', 'Admin')),
  u_name VARCHAR(30) NOT NULL,
  fine_rate DECIMAL(18, 2),
  total_days INT NOT NULL,
  book_limit INT NOT NULL DEFAULT 10,
  total_issued INT DEFAULT 0

  FOREIGN KEY (email) REFERENCES USER_ENTITY(email) ON DELETE CASCADE,
  CHECK ( total_days = 7),
  CHECK (fine_rate = 0.02)
);
