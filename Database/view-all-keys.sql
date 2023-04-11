SELECT table_name,
    index_name,
    GROUP_CONCAT(
        column_name
        ORDER BY seq_in_index
    ) AS COLUMNS,
    non_unique,
    index_type
FROM information_schema.statistics
WHERE table_schema = @DATABASE
GROUP BY table_name,
    index_name,
    non_unique,
    index_type;


