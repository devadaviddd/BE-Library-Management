  CREATE TABLE "USER_ENTITY" 
   (	"EMAIL" VARCHAR2(30), 
	"U_PASSWORD" VARCHAR2(30) NOT NULL ENABLE, 
	"U_ROLE" VARCHAR2(10) NOT NULL ENABLE, 
	"U_NAME" VARCHAR2(30) NOT NULL ENABLE, 
	"USER_IMAGE" BLOB, 
	"MIMETYPE" VARCHAR2(50), 
	"FILENAME" VARCHAR2(200), 
	"CREATED_DATE" DATE, 
	 CHECK (u_role IN ('Student', 'Teacher', 'Admin')) ENABLE, 
	 PRIMARY KEY ("EMAIL")
  USING INDEX  ENABLE, 
	 CONSTRAINT "U_CREDENTIAL" UNIQUE ("EMAIL", "U_PASSWORD", "U_ROLE", "U_NAME")
  USING INDEX  ENABLE
   ) ;

  CREATE OR REPLACE EDITIONABLE TRIGGER "USER_AFTER_DELETE" 
FOR DELETE ON USER_ENTITY  
COMPOUND TRIGGER  
 
    -- Declare a collection to hold the email addresses 
    TYPE email_array_t IS TABLE OF USER_ENTITY.email%TYPE; 
    email_array email_array_t := email_array_t(); 
 
    TYPE u_role_array_t IS TABLE OF USER_ENTITY.u_role%TYPE; 
    u_role_array u_role_array_t := u_role_array_t(); 
 
    -- After each row, add the email address to the collection 
    AFTER EACH ROW IS  
    BEGIN 
        email_array.extend(); 
        email_array(email_array.count) := :OLD.email; 
 
        u_role_array.extend(); 
        u_role_array(u_role_array.count) := :OLD.u_role; 
 
    END AFTER EACH ROW; 
 
    -- After the statement, delete the user entities with the email addresses in the collection 
    AFTER STATEMENT IS  
    BEGIN  
        FOR i IN 1..email_array.count LOOP  
            IF u_role_array(i) = 'Student' THEN  
                DELETE FROM STUDENT_ENTITY 
                WHERE STUDENT_ENTITY.email = email_array(i); 
            ELSIF u_role_array(i) = 'Teacher' THEN  
                DELETE FROM TEACHER_ENTITY 
                WHERE TEACHER_ENTITY.email = email_array(i); 
            ELSIF u_role_array(i) = 'Admin' THEN  
                DELETE FROM ADMIN_ENTITY 
                WHERE ADMIN_ENTITY.email = email_array(i); 
            END IF; 
        END LOOP; 
    END AFTER STATEMENT; 
END USER_AFTER_DELETE;

/
ALTER TRIGGER "USER_AFTER_DELETE" ENABLE;
  CREATE OR REPLACE EDITIONABLE TRIGGER "USER_AFTER_INSERT" 
FOR INSERT ON USER_ENTITY  
COMPOUND TRIGGER  
    AFTER EACH ROW IS BEGIN 
        IF :NEW.u_role = 'Student' THEN      
            INSERT INTO STUDENT_ENTITY (email, u_password, u_role, u_name, fine_rate, total_days)  
            VALUES (:NEW.email, :NEW.u_password, :NEW.u_role, :NEW.u_name, 0.02, 7); 
        ELSIF :NEW.u_role = 'Teacher' THEN  
            INSERT INTO TEACHER_ENTITY (email, u_password, u_role, u_name, fine_rate, total_days)  
            VALUES (:NEW.email, :NEW.u_password, :NEW.u_role, :NEW.u_name, 0.03, 14); 
        ELSIF :NEW.u_role = 'Admin' THEN  
            INSERT INTO ADMIN_ENTITY (email, u_password, u_role, u_name)  
            VALUES (:NEW.email, :NEW.u_password, :NEW.u_role, :NEW.u_name); 
        END IF; 
    END AFTER EACH ROW; 
END USER_AFTER_INSERT; 

/
ALTER TRIGGER "USER_AFTER_INSERT" ENABLE;
  CREATE OR REPLACE EDITIONABLE TRIGGER "USER_AFTER_UPDATE" 
FOR UPDATE ON USER_ENTITY  
COMPOUND TRIGGER  
    admin_size INT := 0; 
    student_size INT := 0; 
    teacher_size INT := 0; 
    is_mail_admin_exist INT :=  0; 
 
    TYPE email_array_t IS TABLE OF USER_ENTITY.email%TYPE; 
    email_array email_array_t := email_array_t(); 
 
    TYPE u_role_array_t IS TABLE OF USER_ENTITY.u_role%TYPE; 
    u_role_array u_role_array_t := u_role_array_t(); 
 
    TYPE u_role_old_array_t IS TABLE OF USER_ENTITY.u_role%TYPE; 
    u_role_old_array u_role_old_array_t := u_role_old_array_t(); 
 
    TYPE u_password_t IS TABLE OF USER_ENTITY.u_password%TYPE; 
    u_password_array u_password_t := u_password_t(); 
 
    TYPE u_name_t IS TABLE OF USER_ENTITY.u_name%TYPE; 
    u_name_array u_name_t := u_name_t(); 
 
    AFTER EACH ROW IS BEGIN 
        email_array.extend(); 
        email_array(email_array.count) := :OLD.email; 
 
        u_role_old_array.extend(); 
        u_role_old_array(u_role_old_array.count) := :OLD.u_role; 
 
        u_role_array.extend(); 
        u_role_array(u_role_array.count) := :NEW.u_role; 
 
        u_password_array.extend(); 
        u_password_array(u_password_array.count) := :NEW.u_password; 
 
        u_name_array.extend(); 
        u_name_array(u_name_array.count) := :NEW.u_name; 
 
    END AFTER EACH ROW; 
 
    AFTER STATEMENT IS  
    BEGIN  
        FOR i IN 1..email_array.count LOOP  
            SELECT COUNT(email) INTO admin_size FROM ADMIN_ENTITY WHERE email = email_array(i); 
            SELECT COUNT(email) INTO student_size FROM STUDENT_ENTITY WHERE email = email_array(i); 
            SELECT COUNT(email) INTO teacher_size FROM TEACHER_ENTITY WHERE email = email_array(i); 
            SELECT COUNT(email_array(i)) INTO is_mail_admin_exist  FROM ENTRY_RELATION WHERE email = email_array(i); 
          
            IF u_role_array(i) = 'Student' AND student_size = 0 THEN  
                INSERT INTO STUDENT_ENTITY (email, u_password, u_role, u_name, fine_rate, total_days)  
                VALUES (email_array(i), u_password_array(i), u_role_array(i), u_name_array(i), 0.02, 7); 
 
                UPDATE ENTRY_RELATION 
                SET U_NAME = u_name_array(i), U_ROLE = u_role_array(i), FINE_RATE = 0.02, DEADLINE = ISSUE_DAY + 7 
                WHERE email = email_array(i); 
 
                DELETE FROM TEACHER_ENTITY 
                WHERE TEACHER_ENTITY.email = email_array(i); 
 
                DELETE FROM ADMIN_ENTITY 
                WHERE ADMIN_ENTITY.email = email_array(i); 
 
            ELSIF u_role_array(i) = 'Teacher' AND teacher_size = 0 THEN  
                INSERT INTO TEACHER_ENTITY (email, u_password, u_role, u_name, fine_rate, total_days)  
                VALUES (email_array(i), u_password_array(i), u_role_array(i), u_name_array(i), 0.03, 14); 
 
                UPDATE ENTRY_RELATION 
                SET U_NAME = u_name_array(i), U_ROLE = u_role_array(i), FINE_RATE = 0.03, DEADLINE = ISSUE_DAY + 14 
                WHERE email = email_array(i);              
 
                DELETE FROM STUDENT_ENTITY 
                WHERE STUDENT_ENTITY.email = email_array(i); 
 
                DELETE FROM ADMIN_ENTITY 
                WHERE ADMIN_ENTITY.email = email_array(i); 
            ELSIF u_role_array(i) = 'Admin' AND admin_size = 0 THEN  
                IF is_mail_admin_exist != 0 THEN  
                    apex_error.add_error ( 
                    p_message          => 'User can be promoted to admin because there are entries include in this account.', 
                    p_display_location => apex_error.c_inline_in_notification ); 
                END IF; 
 
                INSERT INTO ADMIN_ENTITY (email, u_password, u_role, u_name)  
                VALUES (email_array(i), u_password_array(i), u_role_array(i), u_name_array(i));     
 
                DELETE FROM TEACHER_ENTITY 
                WHERE TEACHER_ENTITY.email = email_array(i); 
 
                DELETE FROM STUDENT_ENTITY 
                WHERE STUDENT_ENTITY.email = email_array(i);                 
            END IF; 
 
 
            IF u_role_old_array(i) = 'Student' THEN  
                UPDATE STUDENT_ENTITY  
                SET U_NAME = u_name_array(i), U_ROLE = u_role_array(i), U_PASSWORD = u_password_array(i) 
                WHERE STUDENT_ENTITY.email = email_array(i); 
            ELSIF u_role_old_array(i) = 'Teacher' THEN  
                UPDATE TEACHER_ENTITY  
                SET U_NAME = u_name_array(i), U_ROLE = u_role_array(i), U_PASSWORD = u_password_array(i) 
                WHERE TEACHER_ENTITY.email = email_array(i); 
            ELSIF u_role_old_array(i) = 'Admin' THEN  
                UPDATE ADMIN_ENTITY  
                SET U_NAME = u_name_array(i), U_ROLE = u_role_array(i), U_PASSWORD = u_password_array(i) 
                WHERE ADMIN_ENTITY.email = email_array(i); 
            END IF; 
 
            -- IF u_role_old_array(i) = 'Student' AND student_size != 0 THEN  
            --     DELETE FROM STUDENT_ENTITY 
            --     WHERE STUDENT_ENTITY.email = email_array(i); 
            -- ELSIF u_role_old_array(i) = 'Teacher'AND teacher_size != 0 THEN  
            --     DELETE FROM TEACHER_ENTITY 
            --     WHERE TEACHER_ENTITY.email = email_array(i); 
            -- ELSIF u_role_old_array(i) = 'Admin' AND admin_size != 0 THEN  
            --     DELETE FROM ADMIN_ENTITY 
            --     WHERE ADMIN_ENTITY.email = email_array(i); 
            -- END IF; 
                        
        END LOOP; 
    END AFTER STATEMENT; 
 
END USER_AFTER_UPDATE; 

/
ALTER TRIGGER "USER_AFTER_UPDATE" ENABLE;