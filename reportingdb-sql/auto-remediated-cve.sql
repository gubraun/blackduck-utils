SELECT v1.vuln_id, TRIM(SUBSTR(v1.comment, 23, 15)), v1.vuln_source, v1.remediation_status, v1.base_score_cvss3, COUNT(*)
FROM reporting.component_vulnerability v1
WHERE v1.comment LIKE 'BDSA Auto%'
    AND v1.remediation_status = 'IGNORED'
    AND v1.related_vuln_id IS null
GROUP BY v1.vuln_id, TRIM(SUBSTR(v1.comment, 23, 15)), v1.vuln_source, v1.remediation_status, v1.base_score_cvss3
ORDER BY v1.base_score_cvss3 DESC;