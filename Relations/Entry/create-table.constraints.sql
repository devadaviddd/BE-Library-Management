CREATE TABLE ENTRY (
  email VARCHAR(30) NOT NULL,
  book_ID INT NOT NULL PRIMARY KEY,
  u_name VARCHAR(30),
  u_role VARCHAR(30),
  duration INT,
  title VARCHAR(30),
  fine_rate DECIMAL(18, 2),
  issue_day DATE,
  accumulate_day DATE,
  current_fine DECIMAL(18, 2),
  deadline DATE,
  FOREIGN KEY (email) REFERENCES USER(email),
  FOREIGN KEY (book_ID) REFERENCES BOOK(ID),
  CHECK (u_role != 'ADMIN'),
  CHECK (current_fine = 0)
);

CREATE TABLE USER_JOIN_TABLE
SELECT USER.email AS email,
  USER.u_role AS u_role,
  STUDENT.u_name AS s_u_name,
  TEACHER.u_name AS t_u_name,
  STUDENT.fine_rate AS s_fine_rate,
  TEACHER.fine_rate AS t_fine_rate,
  STUDENT.total_days AS s_total_days,
  Teacher.total_days AS t_total_days
FROM USER
  LEFT JOIN STUDENT ON USER.email = STUDENT.email
  LEFT JOIN TEACHER ON USER.email = TEACHER.email;

SELECT *
FROM USER_JOIN_TABLE;

DROP TABLE ENTRY;