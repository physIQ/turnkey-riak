DO $$
DECLARE
 eid int;
 rid int;
BEGIN
SELECT max(regexpid) INTO rid FROM regexps;
SELECT max(expressionid) INTO eid FROM expressions;
INSERT INTO regexps
(regexpid,name,test_string) 
VALUES 
(rid+1,'Disk devices for discovery','xvda');
INSERT INTO expressions
(expressionid,regexpid,expression,expression_type,exp_delimiter,case_sensitive) 
VALUES 
(eid+1,rid+1,'^(xvd.*[a-z]|sd.*[a-z]|hd.*[a-z])$',3,',',1);
END $$;
