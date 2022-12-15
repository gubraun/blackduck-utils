# SQL Queries for Reporting DB
Useful SQL queries for the Black Duck reporting DB.

## BDSA Auto Remediation
`auto-remediated-stats.sql` prints the number of auto-remediated CVEs and the number of all CVEs detected for all projects on your Black Duck server. This gives you an indication of the amount of work the auto-remediation saves you, as you would have to review all of these CVEs manually otherwise.

`auto-remediated-cve.sql` prints all the CVEs that have been auto-remediated, including the number of their occurrence and CVSS3 score.

```
$ psql < auto-remediated-cve.sql 
     vuln_id      |     btrim      | vuln_source | remediation_status | base_score_cvss3 | count 
------------------+----------------+-------------+--------------------+------------------+-------
 CVE-2016-1000027 | BDSA-2016-1700 | NVD         | IGNORED            |              9.8 |    23
 CVE-2022-22978   | BDSA-2022-1369 | NVD         | IGNORED            |              9.8 |     2
 CVE-2021-45046   | BDSA-2021-3779 | NVD         | IGNORED            |                9 |     2
 CVE-2020-13692   | BDSA-2020-1318 | NVD         | IGNORED            |              7.7 |     2
 CVE-2020-15114   | BDSA-2020-1974 | NVD         | IGNORED            |              7.7 |     1
 CVE-2016-5007    | BDSA-2016-1577 | NVD         | IGNORED            |              7.5 |     2
 CVE-2018-11040   | BDSA-2018-1901 | NVD         | IGNORED            |              7.5 |     2
 CVE-2018-15756   | BDSA-2018-3577 | NVD         | IGNORED            |              7.5 |     2
 CVE-2020-11979   | BDSA-2020-2577 | NVD         | IGNORED            |              7.5 |     2
 CVE-2020-15115   | BDSA-2020-1979 | NVD         | IGNORED            |              7.5 |     1
 CVE-2020-28852   | BDSA-2020-3967 | NVD         | IGNORED            |              7.5 |     1
 CVE-2020-15113   | BDSA-2020-4293 | NVD         | IGNORED            |              7.1 |     1
 CVE-2020-15106   | BDSA-2020-4291 | NVD         | IGNORED            |              6.5 |     1
 CVE-2020-15112   | BDSA-2020-4292 | NVD         | IGNORED            |              6.5 |     1
 CVE-2020-15136   | BDSA-2020-1981 | NVD         | IGNORED            |              6.5 |     1
 CVE-2020-5408    | BDSA-2020-1094 | NVD         | IGNORED            |              6.5 |     6
 ```
 
 ## 
 ```
 $ psql < auto-remediated-stats.sql 
 auto_remediated_cve | total_cve 
---------------------+-----------
                 122 |       146
(1 row)
```

## Components found by Signature Scanner only

`signature-scan-vulnerable-components.sql` prints the components that would not have been detected by a pure dependency scan (aka package manager scan). It only shows components that have at least one security vulnerability.

```
$ psql < signature-scan-vulnerable-components.sql 
   component_name   | component_version_name | security_critical_count | security_high_count | security_medium_count | security_low_count 
--------------------+------------------------+-------------------------+---------------------+-----------------------+--------------------
 Apache HTTP Server | 2.4.54                 |                       0 |                   0 |                     1 |                  0
 Gradle             | 4.4.0                  |                       0 |                   1 |                     5 |                  0
 Gradle             | 4.4.0-rc1              |                       0 |                   1 |                     5 |                  0
(3 rows)
```
