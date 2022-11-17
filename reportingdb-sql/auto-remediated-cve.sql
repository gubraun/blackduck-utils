/*\copy (
    SELECT v1.vuln_id, v2.vuln_id, v1.source, v1.status, s.cvss3_base_score --, COUNT(*) 
    FROM vuln_remediation v1, vuln_remediation v2 
    INNER JOIN vuln_summary s ON v2.related_vuln_id = s.vuln_id
    WHERE v1.vuln_id <> v2.vuln_id 
        AND v1.vuln_id = v2.related_vuln_id 
        AND v1.source = 'BDSA_AUTO' 
        AND v1.status = 'IGNORED'
        AND v1.related_vuln_id IS null
    GROUP BY v1.vuln_id, v2.vuln_id, v1.source, v1.status, s.cvss3_base_score
    ORDER BY s.cvss3_base_score DESC
 ) TO 'auto-remediated-cve+cvss.csv' WITH DELIMITER ',' CSV HEADER;
*/
\copy (SELECT v1.vuln_id, v2.vuln_id, v1.source, v1.status, s.cvss3_base_score FROM vuln_remediation v1, vuln_remediation v2 INNER JOIN vuln_summary s ON v2.related_vuln_id = s.vuln_id WHERE v1.vuln_id <> v2.vuln_id AND v1.vuln_id = v2.related_vuln_id AND v1.source = 'BDSA_AUTO' AND v1.status = 'IGNORED' AND v1.related_vuln_id IS null GROUP BY v1.vuln_id, v2.vuln_id, v1.source, v1.status, s.cvss3_base_score ORDER BY s.cvss3_base_score DESC) TO 'auto-remediated-cve+cvss.csv' WITH DELIMITER ',' CSV HEADER;
