CREATE TABLE BOOK_ENTITY (
  ID INT GENERATED BY DEFAULT ON NULL AS IDENTITY,
  title VARCHAR(30) NOT NULL,
  author VARCHAR(30),
  b_category VARCHAR(30)  NOT NULL CHECK (b_category IN ('FICTION', 'NON-FICTION', 'MYSTERY', 'ROMANCE' 
  'THRILLER')),
  book_picture LONGBLOB,
  mimetype VARCHAR(50),
  filename VARCHAR(200),
  created_date DATE,
  b_status VARCHAR(30) NOT NULL DEFAULT 'Available',
  CONSTRAINT BOOK_ENTITY_CON CHECK (B_STATUS IN ('Available', 'Unavailable'))
);

ALTER TABLE BOOK_ENTITY ADD (
  CONSTRAINT BOOK_PK PRIMARY KEY (id)
);