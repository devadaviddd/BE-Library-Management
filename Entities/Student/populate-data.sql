INSERT INTO STUDENT VALUES (
  'student@gmail.com', 'pass123', 'Student', 'Student name', 0.02, 5
);
INSERT INTO STUDENT VALUES (
  'student2@gmail.com', 'pass123', 'Student', 'Student name', 0.02, 5
);
INSERT INTO STUDENT VALUES (
  'student3@gmail.com', 'pass123', 'Student', 'Student name', 0.02, 5
);
SELECT * FROM STUDENT;

DELETE FROM STUDENT WHERE STUDENT.email = 'student3@gmail.com';

-- DELETE FROM STUDENT;