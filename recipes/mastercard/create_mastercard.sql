--read the table with 'None" values for yoy_txn_amt and yoy_txn_cnt
--insert in zipcodes for borough and borocode if it doesn't already exist.

DROP TABLE IF EXISTS mastercard.zip_to_borough;
CREATE TABLE mastercard.zip_to_borough (
        zip_code text,
        borough text,
        borocode int
    );
COMMIT;
BEGIN TRANSACTION

 
INSERT INTO mastercard.zip_to_borough values ('10471','BX',2);
INSERT INTO mastercard.zip_to_borough values ('10470','BX',2);
INSERT INTO mastercard.zip_to_borough values ('10466','BX',2);
INSERT INTO mastercard.zip_to_borough values ('10467','BX',2);
INSERT INTO mastercard.zip_to_borough values ('10475','BX',2);
INSERT INTO mastercard.zip_to_borough values ('10464','BX',2);
INSERT INTO mastercard.zip_to_borough values ('10469','BX',2);
INSERT INTO mastercard.zip_to_borough values ('10468','BX',2);
INSERT INTO mastercard.zip_to_borough values ('10458','BX',2);
INSERT INTO mastercard.zip_to_borough values ('10462','BX',2);
INSERT INTO mastercard.zip_to_borough values ('10453','BX',2);
INSERT INTO mastercard.zip_to_borough values ('10465','BX',2);
INSERT INTO mastercard.zip_to_borough values ('10461','BX',2);
INSERT INTO mastercard.zip_to_borough values ('10457','BX',2);
INSERT INTO mastercard.zip_to_borough values ('10460','BX',2);
INSERT INTO mastercard.zip_to_borough values ('10452','BX',2);
INSERT INTO mastercard.zip_to_borough values ('10456','BX',2);
INSERT INTO mastercard.zip_to_borough values ('10471','BX',2);
INSERT INTO mastercard.zip_to_borough values ('10472','BX',2);
INSERT INTO mastercard.zip_to_borough values ('10459','BX',2);
INSERT INTO mastercard.zip_to_borough values ('10451','BX',2);
INSERT INTO mastercard.zip_to_borough values ('10473','BX',2);
INSERT INTO mastercard.zip_to_borough values ('10474','BX',2);
INSERT INTO mastercard.zip_to_borough values ('10455','BX',2);
INSERT INTO mastercard.zip_to_borough values ('10454','BX',2);
INSERT INTO mastercard.zip_to_borough values ('11213','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11212','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11225','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11218','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11226','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11219','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11210','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11230','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11204','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11222','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11237','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11206','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11251','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11201','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11205','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11208','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11207','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11217','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11238','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11215','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11231','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11232','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11203','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11239','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11236','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11220','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11234','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11209','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11228','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11229','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11214','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11223','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11235','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11224','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11221','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11216','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11233','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11211','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11693','BK',3);
INSERT INTO mastercard.zip_to_borough values ('11249','BK',3);
INSERT INTO mastercard.zip_to_borough values ('10463','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10034','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10033','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10040','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10032','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10031','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10039','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10030','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10027','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10037','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10024','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10026','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10048','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10025','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10029','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10128','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10023','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10028','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10021','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10044','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10018','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10020','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10017','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10001','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10011','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10016','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10010','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10014','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10003','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10002','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10009','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10012','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10013','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10007','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10038','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10006','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10005','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10004','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10280','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10055','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10019','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10111','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10153','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10154','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10152','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10115','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10022','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10065','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10075','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10069','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10281','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10282','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10279','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10165','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10168','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10105','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10118','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10176','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10170','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10112','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10122','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10107','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10103','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10174','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10166','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10169','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10167','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10177','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10172','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10171','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10270','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10104','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10271','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10110','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10175','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10151','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10173','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10178','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10121','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10123','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10106','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10158','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10041','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10120','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10278','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10155','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10043','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10081','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10096','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10097','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10196','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10275','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10265','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10045','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10047','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10080','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10203','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10259','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10260','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10285','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10286','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10035','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10036','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10162','MN',1);
INSERT INTO mastercard.zip_to_borough values ('10119','MN',1);
INSERT INTO mastercard.zip_to_borough values ('11436','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11357','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11356','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11359','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11360','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11105','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11363','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11354','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11102','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11370','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11358','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11362','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11369','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11103','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11106','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11368','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11377','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11355','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11101','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11364','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11005','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11104','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11109','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11367','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11378','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11385','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11412','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11411','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11413','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11422','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11420','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11417','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11430','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11691','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11096','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11692','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11694','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11697','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11372','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11004','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11040','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11424','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11426','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11365','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11001','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11375','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11427','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11374','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11366','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11423','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11428','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11432','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11379','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11429','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11435','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11415','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11418','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11433','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11451','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11421','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11419','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11434','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11416','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11373','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11371','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11361','QN',4);
INSERT INTO mastercard.zip_to_borough values ('11414','QN',4);
INSERT INTO mastercard.zip_to_borough values ('10301','SI',5);
INSERT INTO mastercard.zip_to_borough values ('10303','SI',5);
INSERT INTO mastercard.zip_to_borough values ('10302','SI',5);
INSERT INTO mastercard.zip_to_borough values ('10304','SI',5);
INSERT INTO mastercard.zip_to_borough values ('10314','SI',5);
INSERT INTO mastercard.zip_to_borough values ('10305','SI',5);
INSERT INTO mastercard.zip_to_borough values ('10306','SI',5);
INSERT INTO mastercard.zip_to_borough values ('10308','SI',5);
INSERT INTO mastercard.zip_to_borough values ('10312','SI',5);
INSERT INTO mastercard.zip_to_borough values ('10309','SI',5);
INSERT INTO mastercard.zip_to_borough values ('10307','SI',5);
INSERT INTO mastercard.zip_to_borough values ('10310','SI',5);
END TRANSACTION;


BEGIN TRANSACTION;
CREATE TEMP TABLE tmp_csv (
    yr numeric,
    txn_date date,
    industry text,
    segment text,
    geo_type text,
    geo_name text,
    nation_name text,
    Zip_code text,
    txn_amt double precision,
    txn_cnt double precision,
    acct_cnt double precision,
    avg_ticket double precision,
    avg_freq double precision,
    avg_spend_amt double precision,
    yoy_txn_amt text,
    yoy_txn_cnt text
);

\COPY tmp_csv from PSTDIN DELIMITER '|' CSV HEADER;

--process tmp_processed to remove nulls.
/*
DROP TABLE IF EXISTS tmp_processed
CREATE TEMP TABLE tmp_processed (
    yr numeric,
    txn_date date,
    industry text,
    segment text,
    geo_type text,
    geo_name text,
    nation_name text,
    zip_code text,
    txn_amt_index double precision,
    txn_cnt_index double precision,
    acct_cnt_index double precision,
    avg_ticket_index double precision,
    avg_freq_index double precision,
    avg_spend_amt_index double precision,
    yoy_txn_amt double precision,
    yoy_txn_cnt double precision
);
*/


CREATE SCHEMA IF NOT EXISTS :NAME;
DROP TABLE IF EXISTS :NAME.:"VERSION" CASCADE;

SELECT
    tmp.yr as yr,
    tmp.txn_date as txn_date,
    tmp.industry as industry,
    tmp.segment as segment,
    tmp.geo_type as geo_type,
    tmp.geo_name as geo_name,
    tmp.nation_name as nation_name,
    tmp.zip_code as zip_code,
    tmp.txn_amt as txn_amt_index,
    tmp.txn_cnt as txn_cnt_index,
    tmp.acct_cnt as acct_cnt_index,
    tmp.avg_ticket as avg_ticket_index,
    tmp.avg_freq as avg_freq_index,
    tmp.avg_spend_amt as avg_spend_amt_index,
    (CASE 
        WHEN tmp.yoy_txn_amt = 'None' THEN 0.0
        ELSE CAST(tmp.yoy_txn_amt AS double precision)
    END
    ) as yoy_txn_amt,
    (CASE
        WHEN tmp.yoy_txn_cnt = 'None' THEN 0.0
        ELSE CAST(tmp.yoy_txn_cnt AS double precision)
    END
    ) as yoy_txn_cnt,
    zip.borough as borough,
    zip.borocode as borocode

INTO :NAME.:"VERSION"  FROM tmp_csv as tmp 
INNER JOIN mastercard.zip_to_borough as zip ON tmp.Zip_code = zip.zip_code;

END TRANSACTION;