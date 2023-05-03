CREATE OR REPLACE TRIGGER BOOK_AFTER_INSERT
FOR INSERT ON BOOK_ENTITY
COMPOUND TRIGGER
    -- Declare a variable to hold the count of books with the same title
    TYPE title_t IS TABLE OF STOCK_ENTITY.title%TYPE;
    title_array title_t := title_t();

    TYPE id_t IS TABLE OF BOOK_ENTITY.ID%TYPE;
    id_array id_t := id_t();
  
    AFTER EACH ROW IS BEGIN
        -- Add the title of the inserted book to the title_array
        title_array.extend();
        title_array(title_array.count) := :NEW.title;

        id_array.extend();
        id_array(id_array.count) := :NEW.ID;

        -- Insert a new row into the STOCK_RELATION table for the inserted book
        IF :NEW.b_status = 'Available' THEN 
            INSERT INTO STOCK_ENTITY(book_ID, title, num_stock) 
            VALUES (:NEW.ID, :NEW.title, 0);
        END IF;
    END AFTER EACH ROW;

    AFTER STATEMENT IS BEGIN 
        -- Update the num_stock column in the STOCK_RELATION table based on the number of books with the same title
        FOR i IN 1..title_array.count LOOP
            UPDATE BOOK_ENTITY
            SET b_status = 'Available'
            WHERE ID = id_array(i);


            UPDATE STOCK_ENTITY
            SET num_stock = (SELECT COUNT(*) FROM BOOK_ENTITY WHERE title = title_array(i) AND b_status = 'Available')
            WHERE STOCK_ENTITY.title = title_array(i);

            DELETE FROM STOCK_ENTITY WHERE num_stock = 0;
   
        END LOOP;
    END AFTER STATEMENT;
END BOOK_AFTER_INSERT;
/

CREATE OR REPLACE TRIGGER BOOK_AFTER_DELETE
FOR DELETE ON BOOK_ENTITY
COMPOUND TRIGGER
    TYPE title_t IS TABLE OF STOCK_ENTITY.title%TYPE;
    title_array title_t := title_t();
  
    AFTER EACH ROW IS BEGIN
        title_array.extend();
        title_array(title_array.count) := :OLD.title;
    END AFTER EACH ROW;

    AFTER STATEMENT IS BEGIN 
        FOR i IN 1..title_array.count LOOP
            UPDATE STOCK_ENTITY 
            SET num_stock = (SELECT COUNT(*) FROM BOOK_ENTITY WHERE title = title_array(i) AND b_status = 'Available')
            WHERE title = title_array(i);

            DELETE FROM STOCK_ENTITY WHERE num_stock = 0;

        END LOOP;
    END AFTER STATEMENT;
END BOOK_AFTER_DELETE;
/

CREATE OR REPLACE TRIGGER BOOK_AFTER_UPDATE
FOR UPDATE ON BOOK_ENTITY
COMPOUND TRIGGER
    TYPE title_t IS TABLE OF STOCK_ENTITY.title%TYPE;
    title_array title_t := title_t();
    title_array_old title_t := title_t();

    TYPE b_status_t IS TABLE OF BOOK_ENTITY.b_status%TYPE;
    b_status_array b_status_t := b_status_t();

    TYPE id_t IS TABLE OF BOOK_ENTITY.ID%TYPE;
    id_array id_t := id_t();
    
    title_count INT := 0;

    AFTER EACH ROW IS BEGIN
        title_array.extend();
        title_array(title_array.count) := :NEW.title;

        title_array_old.extend();
        title_array_old(title_array_old.count) := :OLD.title;

        b_status_array.extend();
        b_status_array(b_status_array.count) := :NEW.b_status;

        id_array.extend();
        id_array(id_array.count) := :OLD.ID;

    END AFTER EACH ROW;

    AFTER STATEMENT IS BEGIN 
        FOR i IN 1..title_array.count LOOP
            SELECT COUNT(title) INTO title_count FROM BOOK_ENTITY WHERE title = title_array(i);

            IF title_array(i) != title_array_old(i) AND b_status_array(i) = 'Available' THEN 
                -- DELETE FROM STOCK_ENTITY WHERE book_id = id_array(i);
                UPDATE STOCK_ENTITY 
                SET num_stock = num_stock - 1
                WHERE title = title_array_old(i);

                INSERT INTO STOCK_ENTITY(book_ID, title, num_stock) 
                VALUES (id_array(i), title_array(i), 1);
            ELSIF title_array(i) = title_array_old(i) AND b_status_array(i) = 'Available' THEN
                INSERT INTO STOCK_ENTITY(book_ID, title, num_stock) 
                VALUES (id_array(i), title_array_old(i), 1);
            END IF;

            UPDATE STOCK_ENTITY 
            SET num_stock = (SELECT COUNT(*) FROM BOOK_ENTITY WHERE title = title_array(i) AND b_status = 'Available')
            WHERE title = title_array(i);

            DELETE FROM STOCK_ENTITY WHERE num_stock = 0;
        END LOOP;
    END AFTER STATEMENT;
END BOOK_AFTER_UPDATE;

