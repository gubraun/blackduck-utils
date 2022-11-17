SELECT /*m.project_version_id, m.component_id,*/ c.component_name, c.component_version_name /*, p.project_name, v.version_name, m.match_type */
FROM reporting.component_match_types m
INNER JOIN reporting.component c ON m.component_id = c.id
INNER JOIN reporting.project_version v ON m.project_version_id = v.version_id
INNER JOIN reporting.project p ON p.project_id = v.project_id
-- only components discovered by signature scan and not (also) by packakge manager scan
WHERE m.match_type IN ('FILE_EXACT', 'FILE_EXACT_FILE_MATCH', 'FILE_SOME_FILES_MODIFIED', 'FILE_FILES_ADDED_DELETED_AND_MODIFIED')
    AND m.component_id NOT IN (
	    SELECT component_id 
	    FROM reporting.component_match_types 
	    WHERE match_type IN ('FILE_DEPENDENCY', 'FILE_DEPENDENCY_DIRECT', 'FILE_DEPENDENCY_TRANSITIVE')
		    AND project_version_id = m.project_version_id
	)
	-- ... and that are not ignored
	AND c.ignored = 'f'
	--AND m.project_version_id = '7d883fd4-2a48-4c5d-9f98-1479cbc929f4'
	-- ... and that violate one or more policies
	--AND c.policy_approval_status = 'IN_VIOLATION'
	-- ... and have at least one vulnerability
	AND (c.security_critical_count > 0 
		OR c.security_high_count > 0
		OR c.security_medium_count > 0
		OR c.security_low_count > 0
	)
GROUP BY c.component_name, c.component_version_name  -, p.project_name, v.version_name
ORDER BY component_name ASC
LIMIT 10000;
