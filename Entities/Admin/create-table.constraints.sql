CREATE TABLE ADMIN (
  email VARCHAR(30) PRIMARY KEY,
  u_password VARCHAR(30) NOT NULL,
  u_role ENUM("Student", "Teacher", "Admin") NOT NULL,
  u_name VARCHAR(30) NOT NULL,
  FOREIGN KEY (email) REFERENCES USER(email) ON DELETE CASCADE,
  CHECK (u_role = 'Admin')
);

ALTER TABLE ADMIN
ADD FOREIGN KEY S_CREDENTIAL(email, u_password, u_role, u_name) REFERENCES USER(
  email,
  u_password,
  u_role,
  u_name
);
