SELECT a.count AS auto_remediated_cve, c.count AS total_cve FROM (
    SELECT COUNT(*)
    FROM reporting.component_vulnerability v1
    WHERE v1.comment LIKE 'BDSA Auto%'
        AND v1.remediation_status = 'IGNORED'
        AND v1.related_vuln_id IS null
    GROUP BY vuln_source
) AS a, (
    SELECT COUNT(*)
    FROM reporting.component_vulnerability v2
    WHERE v2.vuln_source = 'NVD'
) AS c
;
