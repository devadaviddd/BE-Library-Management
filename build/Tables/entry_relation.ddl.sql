  CREATE TABLE "ENTRY_RELATION" 
   (	"ID" NUMBER(*,0) GENERATED BY DEFAULT ON NULL AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  NOT NULL ENABLE, 
	"EMAIL" VARCHAR2(30) NOT NULL ENABLE, 
	"BOOK_ID" NUMBER(*,0) NOT NULL ENABLE, 
	"B_CATEGORY" VARCHAR2(30) NOT NULL ENABLE, 
	"U_NAME" VARCHAR2(30), 
	"U_ROLE" VARCHAR2(10) NOT NULL ENABLE, 
	"TITLE" VARCHAR2(30), 
	"FINE_RATE" NUMBER(18,2), 
	"ISSUE_DAY" DATE, 
	"ACCUMULATE_DAY" DATE, 
	"CURRENT_FINE" NUMBER(18,2), 
	"DEADLINE" DATE, 
	"E_STATUS" VARCHAR2(10 CHAR) DEFAULT 'In Borrow', 
	 CHECK (b_category IN ('FICTION', 'NON-FICTION', 'MYSTERY', 'ROMANCE',  
  'THRILLER')) ENABLE, 
	 CHECK (u_role IN ('Student', 'Teacher', 'Admin')) ENABLE, 
	 CHECK (u_role != 'ADMIN') ENABLE, 
	 CHECK (current_fine <= 0) DISABLE, 
	 CONSTRAINT "ENTRY_PK" PRIMARY KEY ("ID")
  USING INDEX  ENABLE, 
	 CONSTRAINT "ENTRY_RELATION_CON" CHECK ( "E_STATUS" IN ('In Borrow', 'Late') ) ENABLE
   ) ;

  ALTER TABLE "ENTRY_RELATION" ADD FOREIGN KEY ("EMAIL")
	  REFERENCES "USER_ENTITY" ("EMAIL") ENABLE;
  ALTER TABLE "ENTRY_RELATION" ADD FOREIGN KEY ("BOOK_ID")
	  REFERENCES "BOOK_ENTITY" ("ID") ENABLE;

  CREATE OR REPLACE EDITIONABLE TRIGGER "ENTRY_AFTER_DELETE" 
FOR DELETE ON ENTRY_RELATION 
COMPOUND TRIGGER 
    TYPE email_t IS TABLE OF ENTRY_RELATION.email%TYPE; 
    email_array email_t := email_t(); 
 
    TYPE title_t IS TABLE OF ENTRY_RELATION.title%TYPE; 
    title_array title_t := title_t(); 
 
    TYPE book_id_t IS TABLE OF ENTRY_RELATION.title%TYPE; 
    book_id_array book_id_t := book_id_t(); 
 
    TYPE u_role_t IS TABLE OF ENTRY_RELATION.u_role%TYPE; 
    u_role_array u_role_t := u_role_t(); 
 
    AFTER EACH ROW IS BEGIN 
        email_array.extend(); 
        email_array(email_array.count) := :OLD.email; 
 
        title_array.extend(); 
        title_array(title_array.count) := :OLD.title; 
 
        book_id_array.extend(); 
        book_id_array(book_id_array.count) := :OLD.book_id; 
 
        u_role_array.extend(); 
        u_role_array(u_role_array.count) := :OLD.u_role; 
    END AFTER EACH ROW; 
 
    AFTER STATEMENT IS BEGIN  
        FOR i IN 1..email_array.count LOOP 
            UPDATE BOOK_ENTITY 
            SET b_status = 'Available' 
            WHERE BOOK_ENTITY.title = title_array(i) AND BOOK_ENTITY.ID = book_id_array(i); 
 
            UPDATE STOCK_ENTITY 
            SET num_stock = (SELECT COUNT(*) FROM BOOK_ENTITY WHERE title = title_array(i) AND b_status = 'Available') 
            WHERE STOCK_ENTITY.title = title_array(i); 
 
            if u_role_array(i) = 'Student' then 
                UPDATE STUDENT_ENTITY 
                SET total_issued = total_issued + 1 
                WHERE STUDENT_ENTITY.email = email_array(i); 
            elsif u_role_array(i) = 'Teacher' then 
                UPDATE TEACHER_ENTITY 
                SET total_issued = total_issued + 1 
                WHERE TEACHER_ENTITY.email = email_array(i); 
            end if; 
              
            DELETE FROM STOCK_ENTITY WHERE num_stock = 0; 
        END LOOP; 
    END AFTER STATEMENT; 
END ENTRY_AFTER_DELETE; 
 

/
ALTER TRIGGER "ENTRY_AFTER_DELETE" ENABLE;
  CREATE OR REPLACE EDITIONABLE TRIGGER "ENTRY_AFTER_INSERT" 
FOR INSERT ON ENTRY_RELATION 
COMPOUND TRIGGER 
    TYPE u_role_t IS TABLE OF ENTRY_RELATION.u_role%TYPE; 
    u_role_array u_role_t := u_role_t(); 
 
    TYPE email_t IS TABLE OF ENTRY_RELATION.email%TYPE; 
    email_array email_t := email_t(); 
 
    TYPE title_t IS TABLE OF ENTRY_RELATION.title%TYPE; 
    title_array title_t := title_t(); 
 
    TYPE book_id_t IS TABLE OF ENTRY_RELATION.title%TYPE; 
    book_id_array book_id_t := book_id_t(); 
 
    TYPE entry_id_t IS TABLE OF ENTRY_RELATION.ID%TYPE; 
    entry_id_array entry_id_t := entry_id_t(); 
 
    AFTER EACH ROW IS BEGIN 
        u_role_array.extend(); 
        u_role_array(u_role_array.count) := :NEW.u_role; 
 
        email_array.extend(); 
        email_array(email_array.count) := :NEW.email; 
 
        title_array.extend(); 
        title_array(title_array.count) := :NEW.title; 
 
        book_id_array.extend(); 
        book_id_array(book_id_array.count) := :NEW.book_id; 
 
        entry_id_array.extend(); 
        entry_id_array(entry_id_array.count) := :NEW.ID; 
    END AFTER EACH ROW; 
 
    AFTER STATEMENT IS BEGIN  
        FOR i IN 1..email_array.count LOOP 
            IF u_role_array(i) = 'Student' THEN  
                UPDATE ENTRY_RELATION  
                SET issue_day = SYSDATE + INTERVAL '7' HOUR, accumulate_day = SYSDATE + INTERVAL '7' HOUR  + 2, deadline = SYSDATE + INTERVAL '7' HOUR + 7,  
                    current_fine = 0, e_status = 'In Borrow' 
                WHERE ENTRY_RELATION.email = email_array(i) AND ENTRY_RELATION.ID = entry_id_array(i); 
                  
            ELSIF u_role_array(i) = 'Teacher' THEN 
                UPDATE ENTRY_RELATION  
                SET issue_day = SYSDATE + INTERVAL '7' HOUR, accumulate_day = SYSDATE + INTERVAL '7' HOUR  + 2, deadline =  SYSDATE  
                + INTERVAL '7' HOUR + 14, current_fine = 0, e_status = 'In Borrow' 
                WHERE ENTRY_RELATION.email = email_array(i) AND ENTRY_RELATION.ID = entry_id_array(i);       
            END IF; 
 
            UPDATE STOCK_ENTITY  
            SET num_stock =(SELECT COUNT(*) FROM BOOK_ENTITY WHERE title = title_array(i) AND b_status = 'Available') 
            WHERE title = title_array(i); 
 
            UPDATE BOOK_ENTITY  
            SET b_status = 'Unavailable' 
            WHERE ID = book_id_array(i); 
 
            DELETE FROM STOCK_ENTITY WHERE num_stock = 0; 
        END LOOP; 
    END AFTER STATEMENT; 
END ENTRY_AFTER_INSERT; 
 

/
ALTER TRIGGER "ENTRY_AFTER_INSERT" ENABLE;