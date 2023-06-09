CREATE OR REPLACE VIEW USER_BOOK_VIEW (
    ENTRY_ID,
    EMAIL,
    BOOK_ID,
    TITLE,
    B_CATEGORY,
    BOOK_PICTURE,
    FILENAME,
    MIMETYPE,
    CURRENT_FINE,
    DEADLINE,
    ACCUMULATE_DAY
  ) AS
SELECT E.ID AS ENTRY_ID,
  E.EMAIL,
  B.ID AS BOOK_ID,
  B.TITLE,
  B.B_CATEGORY,
  B.BOOK_PICTURE,
  B.FILENAME,
  B.MIMETYPE,
  E.CURRENT_FINE,
  E.DEADLINE,
  E.ACCUMULATE_DAY
FROM ENTRY_RELATION E
  INNER JOIN BOOK_ENTITY B ON E.BOOK_ID = B.ID;