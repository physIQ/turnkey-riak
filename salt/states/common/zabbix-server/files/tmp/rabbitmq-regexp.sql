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
(rid+1,'rabbitmq vhosts for discovery','');
INSERT INTO expressions
(expressionid,regexpid,expression,expression_type,exp_delimiter,case_sensitive) 
VALUES 
(eid+1,rid+1,'^.*$',3,',',1);
END $$;
