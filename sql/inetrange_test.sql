-- Verify that it works on custom range types:

CREATE OR REPLACE FUNCTION inet_diff(x inet, y inet)
  RETURNS DOUBLE PRECISION AS
$$
DECLARE
BEGIN 
  RETURN x - y; 
END;
$$
LANGUAGE 'plpgsql' STRICT IMMUTABLE;

CREATE TYPE inetrange AS RANGE (
  subtype = inet,
  subtype_diff = inet_diff
);

SELECT	range_agg(r)
FROM		(VALUES 
  (inetrange('1.2.3.0', '1.2.4.0', '[)')),
  (inetrange('1.2.4.0', '1.2.5.0', '[)'))
) t(r);

CREATE OR REPLACE FUNCTION range_agg_transfn(internal, inetrange, boolean)
RETURNS internal
AS 'range_agg', 'range_agg_transfn'
LANGUAGE c IMMUTABLE;

CREATE OR REPLACE FUNCTION range_agg_finalfn(internal, inetrange, boolean)
RETURNS inetrange[]
AS 'range_agg', 'range_agg_finalfn'
LANGUAGE c IMMUTABLE;

CREATE AGGREGATE range_agg(inetrange, boolean) (
  stype = internal,
  sfunc = range_agg_transfn,
  finalfunc = range_agg_finalfn,
  finalfunc_extra
);

SELECT	range_agg(r, true)
FROM		(VALUES 
  (inetrange('1.2.3.0', '1.2.3.128', '[)')),
  (inetrange('1.2.4.0', '1.2.5.0', '[)'))
) t(r);

CREATE OR REPLACE FUNCTION range_agg_transfn(internal, inetrange, boolean, boolean)
RETURNS internal
AS 'range_agg', 'range_agg_transfn'
LANGUAGE c IMMUTABLE;

CREATE OR REPLACE FUNCTION range_agg_finalfn(internal, inetrange, boolean, boolean)
RETURNS inetrange[]
AS 'range_agg', 'range_agg_finalfn'
LANGUAGE c IMMUTABLE;

CREATE AGGREGATE range_agg(inetrange, boolean, boolean) (
  stype = internal,
  sfunc = range_agg_transfn,
  finalfunc = range_agg_finalfn,
  finalfunc_extra
);

SELECT	range_agg(r, true, true)
FROM		(VALUES 
  (inetrange('1.2.3.0', '1.2.3.128', '[)')),
  (inetrange('1.2.4.0', '1.2.5.0', '[)'))
) t(r);

