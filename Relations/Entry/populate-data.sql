INSERT INTO ENTRY
VALUES (
    'student@gmail.com',
    1,
    (SELECT u_role FROM USER_JOIN_TABLE WHERE email = 'student@gmail.com'),
    (SELECT COALESCE(s_name, t_name) FROM USER_JOIN_TABLE WHERE email = 'student@gmail.com'),
    (SELECT COALESCE(s_total_days, t_total_days) FROM USER_JOIN_TABLE WHERE email = 'student@gmail.com'),
    (SELECT title FROM BOOK WHERE ID = 1),
    (SELECT COALESCE(s_fine_rate, t_fine_rate) FROM USER_JOIN_TABLE WHERE email = 'student@gmail.com'),
    @CURRENT_DAY,
    @ACCUMULATE_DAY,
    0,
    @CURRENT_DAY + (SELECT COALESCE(s_total_days, t_total_days) FROM USER_JOIN_TABLE WHERE email = 'student@gmail.com')
  );
INSERT INTO ENTRY
VALUES (
    'teacher@gmail.com',
    2,
    (SELECT u_role FROM USER_JOIN_TABLE WHERE email = 'teacher@gmail.com'),
    (SELECT COALESCE(s_name, t_name) FROM USER_JOIN_TABLE WHERE email = 'teacher@gmail.com'),
    (SELECT COALESCE(s_total_days, t_total_days) FROM USER_JOIN_TABLE WHERE email = 'teacher@gmail.com'),
    (SELECT title FROM BOOK WHERE ID = 1),
    (SELECT COALESCE(s_fine_rate, t_fine_rate) FROM USER_JOIN_TABLE WHERE email = 'teacher@gmail.com'),
    @CURRENT_DAY,
    @ACCUMULATE_DAY,
    0,
    @CURRENT_DAY + (SELECT COALESCE(s_total_days, t_total_days) FROM USER_JOIN_TABLE WHERE email = 'student@gmail.com')
  );
