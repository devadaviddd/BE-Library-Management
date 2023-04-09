CREATE TABLE ADMIN (
  email VARCHAR(30) PRIMARY KEY,
  a_password VARCHAR(30) NOT NULL,
  a_role ENUM("Student", "Teacher", "Admin") NOT NULL,
  a_name VARCHAR(30) NOT NULL,
  FOREIGN KEY (email) REFERENCES USER(email) ON DELETE CASCADE,
  CHECK (a_role = 'Admin')
);

ALTER TABLE ADMIN
ADD FOREIGN KEY S_CREDENTIAL(email, a_password, a_role) REFERENCES USER(
  email,
  u_password,
  u_role
);
