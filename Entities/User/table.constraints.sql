CREATE TABLE USER_ENTITY (
  email VARCHAR(30) PRIMARY KEY,
  u_password VARCHAR(30) NOT NULL,
  u_role VARCHAR(10) NOT NULL CHECK (u_role IN ('Student', 'Teacher', 'Admin')),
  u_name VARCHAR(30) NOT NULL,
  user_image LONGBLOB,
  mimetype VARCHAR(50),
  filename VARCHAR(200),
  created_date DATE,
);

ALTER TABLE USER_ENTITY
ADD CONSTRAINT U_CREDENTIAL UNIQUE (email, u_password,u_role, u_name);