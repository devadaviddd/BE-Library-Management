CREATE TABLE STUDENT (
  email VARCHAR(30) PRIMARY KEY,
  u_password VARCHAR(30) NOT NULL,
  u_role ENUM("Student", "Teacher", "Admin") NOT NULL,
  u_name VARCHAR(30) NOT NULL,
  fine_rate DECIMAL(18, 2),
  total_days INT NOT NULL,
  FOREIGN KEY (email) REFERENCES USER(email) ON DELETE CASCADE,
  CHECK (
    total_days <= 7
    AND total_days > 0
  ),
  CHECK (fine_rate = 0.02),
  CHECK (u_role = 'Student')
);
ALTER TABLE STUDENT
ADD FOREIGN KEY S_CREDENTIAL(email, u_password, u_role, u_name) REFERENCES USER(
  email,
  u_password,
  u_role,
  u_name
);

-- DROP TABLE STUDENT;