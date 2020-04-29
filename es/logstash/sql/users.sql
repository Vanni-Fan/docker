SELECT
	*
FROM
	users
WHERE
	updated_time >= :sql_last_value