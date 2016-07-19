-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
--
--
-- PostGIS Raster - Raster Type for PostGIS
-- http://trac.osgeo.org/postgis/wiki/WKTRaster
--
-- Copyright (c) 2009-2012 Sandro Santilli <strk@keybit.net>
-- Copyright (c) 2009-2010 Pierre Racine <pierre.racine@sbf.ulaval.ca>
-- Copyright (c) 2009-2010 Jorge Arevalo <jorge.arevalo@deimos-space.com>
-- Copyright (c) 2009-2010 Mateusz Loskot <mateusz@loskot.net>
-- Copyright (c) 2010 David Zwarg <dzwarg@azavea.com>
-- Copyright (C) 2011-2013 Regents of the University of California
--   <bkpark@ucdavis.edu>
-- Copyright (C) 2013 Bborie Park <dustymugs@gmail.com>
--
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software Foundation,
-- Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
--
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
--
-- WARNING: Any change in this file must be evaluated for compatibility.
--
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -






































SET client_min_messages TO warning;

-- INSTALL VERSION: '2.2.2'

BEGIN;

------------------------------------------------------------------------------
-- RASTER Type
------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION raster_in(cstring)
    RETURNS raster
    AS '$libdir/rtpostgis-2.2','RASTER_in'
    LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION raster_out(raster)
    RETURNS cstring
    AS '$libdir/rtpostgis-2.2','RASTER_out'
    LANGUAGE 'c' IMMUTABLE STRICT;

-- Availability: 2.0.0
CREATE TYPE raster (
    alignment = double,
    internallength = variable,
    input = raster_in,
    output = raster_out,
    storage = extended
);

------------------------------------------------------------------------------
-- FUNCTIONS
------------------------------------------------------------------------------

-----------------------------------------------------------------------
-- Raster Version
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION postgis_raster_lib_version()
    RETURNS text
    AS '$libdir/rtpostgis-2.2', 'RASTER_lib_version'
    LANGUAGE 'c' IMMUTABLE; -- a new lib will require a new session

CREATE OR REPLACE FUNCTION postgis_raster_scripts_installed() RETURNS text
       AS $$ SELECT '2.2.2'::text || ' r' || 14797::text AS version $$
       LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE FUNCTION postgis_raster_lib_build_date()
    RETURNS text
    AS '$libdir/rtpostgis-2.2', 'RASTER_lib_build_date'
    LANGUAGE 'c' IMMUTABLE; -- a new lib will require a new session

CREATE OR REPLACE FUNCTION postgis_gdal_version()
    RETURNS text
    AS '$libdir/rtpostgis-2.2', 'RASTER_gdal_version'
    LANGUAGE 'c' IMMUTABLE;

-----------------------------------------------------------------------
-- generic composite type of a raster and its band index
-----------------------------------------------------------------------

-- Availability: 2.1.0
CREATE TYPE rastbandarg AS (
	rast raster,
	nband integer
);

-----------------------------------------------------------------------
-- generic composite type of a geometry and value
-----------------------------------------------------------------------

-- Availability: 2.0.0
CREATE TYPE geomval AS (
	geom geometry,
	val double precision
);

-----------------------------------------------------------------------
-- Raster Accessors
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION st_envelope(raster)
	RETURNS geometry
	AS '$libdir/rtpostgis-2.2','RASTER_envelope'
	LANGUAGE 'c' IMMUTABLE STRICT;

-- Availability: 2.0.0
-- Changed: 2.1.4 raised cost 
CREATE OR REPLACE FUNCTION st_convexhull(raster)
    RETURNS geometry
    AS '$libdir/rtpostgis-2.2','RASTER_convex_hull'
    LANGUAGE 'c' IMMUTABLE STRICT
    COST 300;

CREATE OR REPLACE FUNCTION st_minconvexhull(
	rast raster,
	nband integer DEFAULT NULL
)
	RETURNS geometry
	AS '$libdir/rtpostgis-2.2','RASTER_convex_hull'
	LANGUAGE 'c' IMMUTABLE;

CREATE OR REPLACE FUNCTION box3d(raster)
    RETURNS box3d
    AS 'select box3d(st_convexhull($1))'
    LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_height(raster)
    RETURNS integer
    AS '$libdir/rtpostgis-2.2','RASTER_getHeight'
    LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_numbands(raster)
    RETURNS integer
    AS '$libdir/rtpostgis-2.2','RASTER_getNumBands'
    LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_scalex(raster)
    RETURNS float8
    AS '$libdir/rtpostgis-2.2','RASTER_getXScale'
    LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_scaley(raster)
    RETURNS float8
    AS '$libdir/rtpostgis-2.2','RASTER_getYScale'
    LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_skewx(raster)
    RETURNS float8
    AS '$libdir/rtpostgis-2.2','RASTER_getXSkew'
    LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_skewy(raster)
    RETURNS float8
    AS '$libdir/rtpostgis-2.2','RASTER_getYSkew'
    LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_srid(raster)
    RETURNS integer
    AS '$libdir/rtpostgis-2.2','RASTER_getSRID'
    LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_upperleftx(raster)
    RETURNS float8
    AS '$libdir/rtpostgis-2.2','RASTER_getXUpperLeft'
    LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_upperlefty(raster)
    RETURNS float8
    AS '$libdir/rtpostgis-2.2','RASTER_getYUpperLeft'
    LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_width(raster)
    RETURNS integer
    AS '$libdir/rtpostgis-2.2','RASTER_getWidth'
    LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_pixelwidth(raster)
    RETURNS float8
    AS '$libdir/rtpostgis-2.2', 'RASTER_getPixelWidth'
    LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_pixelheight(raster)
    RETURNS float8
    AS '$libdir/rtpostgis-2.2', 'RASTER_getPixelHeight'
    LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_geotransform(raster,
    OUT imag double precision,
    OUT jmag double precision,
    OUT theta_i double precision,
    OUT theta_ij double precision,
    OUT xoffset double precision,
    OUT yoffset double precision)
    AS '$libdir/rtpostgis-2.2', 'RASTER_getGeotransform'
    LANGUAGE 'c' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_rotation(raster)
    RETURNS float8
    AS $$ SELECT (ST_Geotransform($1)).theta_i $$
    LANGUAGE 'sql' VOLATILE;

CREATE OR REPLACE FUNCTION st_metadata(
	rast raster,
	OUT upperleftx double precision,
	OUT upperlefty double precision,
	OUT width int,
	OUT height int,
	OUT scalex double precision,
	OUT scaley double precision,
	OUT skewx double precision,
	OUT skewy double precision,
	OUT srid int,
	OUT numbands int
)
	AS '$libdir/rtpostgis-2.2', 'RASTER_metadata'
	LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_summary(rast raster)
	RETURNS text
	AS $$
	DECLARE
		extent box2d;
		metadata record;
		bandmetadata record;
		msg text;
		msgset text[];
	BEGIN
		extent := ST_Extent(rast::geometry);
		metadata := ST_Metadata(rast);

		msg := 'Raster of ' || metadata.width || 'x' || metadata.height || ' pixels has ' || metadata.numbands || ' ';

		IF metadata.numbands = 1 THEN
			msg := msg || 'band ';
		ELSE
			msg := msg || 'bands ';
		END IF;
		msg := msg || 'and extent of ' || extent;

		IF
			round(metadata.skewx::numeric, 10) <> round(0::numeric, 10) OR 
			round(metadata.skewy::numeric, 10) <> round(0::numeric, 10)
		THEN
			msg := 'Skewed ' || overlay(msg placing 'r' from 1 for 1);
		END IF;

		msgset := Array[]::text[] || msg;

		FOR bandmetadata IN SELECT * FROM ST_BandMetadata(rast, ARRAY[]::int[]) LOOP
			msg := 'band ' || bandmetadata.bandnum || ' of pixtype ' || bandmetadata.pixeltype || ' is ';
			IF bandmetadata.isoutdb IS FALSE THEN
				msg := msg || 'in-db ';
			ELSE
				msg := msg || 'out-db ';
			END IF;

			msg := msg || 'with ';
			IF bandmetadata.nodatavalue IS NOT NULL THEN
				msg := msg || 'NODATA value of ' || bandmetadata.nodatavalue;
			ELSE
				msg := msg || 'no NODATA value';
			END IF;

			msgset := msgset || ('    ' || msg);
		END LOOP;

		RETURN array_to_string(msgset, E'\n');
	END;
	$$ LANGUAGE 'plpgsql' STABLE STRICT;

-- Availability: 2.2.0
CREATE OR REPLACE FUNCTION ST_MemSize(raster)
	RETURNS int4
	AS '$libdir/rtpostgis-2.2', 'RASTER_memsize'
	LANGUAGE 'c' IMMUTABLE STRICT;

-----------------------------------------------------------------------
-- Constructor ST_MakeEmptyRaster
-----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION st_makeemptyraster(width int, height int, upperleftx float8, upperlefty float8, scalex float8, scaley float8, skewx float8, skewy float8, srid int4 DEFAULT 0)
    RETURNS RASTER
    AS '$libdir/rtpostgis-2.2', 'RASTER_makeEmpty'
    LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_makeemptyraster(width int, height int, upperleftx float8, upperlefty float8, pixelsize float8)
    RETURNS raster
    AS $$ SELECT st_makeemptyraster($1, $2, $3, $4, $5, -($5), 0, 0, ST_SRID('POINT(0 0)'::geometry)) $$
    LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_makeemptyraster(rast raster)
    RETURNS raster
    AS $$
		DECLARE
			w int;
			h int;
			ul_x double precision;
			ul_y double precision;
			scale_x double precision;
			scale_y double precision;
			skew_x double precision;
			skew_y double precision;
			sr_id int;
		BEGIN
			SELECT width, height, upperleftx, upperlefty, scalex, scaley, skewx, skewy, srid INTO w, h, ul_x, ul_y, scale_x, scale_y, skew_x, skew_y, sr_id FROM ST_Metadata(rast);
			RETURN st_makeemptyraster(w, h, ul_x, ul_y, scale_x, scale_y, skew_x, skew_y, sr_id);
		END;
    $$ LANGUAGE 'plpgsql' IMMUTABLE STRICT;

-----------------------------------------------------------------------
-- Constructor ST_AddBand
-----------------------------------------------------------------------

-- Availability: 2.1.0
CREATE TYPE addbandarg AS (
	index int,
	pixeltype text,
	initialvalue float8,
	nodataval float8
);

CREATE OR REPLACE FUNCTION st_addband(rast raster, addbandargset addbandarg[])
	RETURNS RASTER
	AS '$libdir/rtpostgis-2.2', 'RASTER_addBand'
	LANGUAGE 'c' IMMUTABLE STRICT;

-- This function can not be STRICT, because nodataval can be NULL indicating that no nodata value should be set
CREATE OR REPLACE FUNCTION st_addband(
	rast raster,
	index int,
	pixeltype text,
	initialvalue float8 DEFAULT 0.,
	nodataval float8 DEFAULT NULL
)
	RETURNS raster
	AS $$ SELECT st_addband($1, ARRAY[ROW($2, $3, $4, $5)]::addbandarg[]) $$
	LANGUAGE 'sql' IMMUTABLE;

-- This function can not be STRICT, because nodataval can be NULL indicating that no nodata value should be set
CREATE OR REPLACE FUNCTION st_addband(
	rast raster,
	pixeltype text,
	initialvalue float8 DEFAULT 0.,
	nodataval float8 DEFAULT NULL
)
	RETURNS raster
	AS $$ SELECT st_addband($1, ARRAY[ROW(NULL, $2, $3, $4)]::addbandarg[]) $$
	LANGUAGE 'sql' IMMUTABLE;

-- This function can not be STRICT, because torastindex can not be determined (could be st_numbands(raster) though)
CREATE OR REPLACE FUNCTION st_addband(
	torast raster,
	fromrast raster,
	fromband int DEFAULT 1,
	torastindex int DEFAULT NULL
)
	RETURNS raster
	AS '$libdir/rtpostgis-2.2', 'RASTER_copyBand'
	LANGUAGE 'c' IMMUTABLE; 

CREATE OR REPLACE FUNCTION st_addband(
	torast raster,
	fromrasts raster[], fromband integer DEFAULT 1,
	torastindex int DEFAULT NULL
)
	RETURNS raster
	AS '$libdir/rtpostgis-2.2', 'RASTER_addBandRasterArray'
	LANGUAGE 'c' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_addband(
	rast raster,
	index int,
	outdbfile text, outdbindex int[],
	nodataval double precision DEFAULT NULL
)
	RETURNS raster
	AS '$libdir/rtpostgis-2.2', 'RASTER_addBandOutDB'
	LANGUAGE 'c' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_addband(
	rast raster,
	outdbfile text, outdbindex int[],
	index int DEFAULT NULL,
	nodataval double precision DEFAULT NULL
)
	RETURNS raster
	AS $$ SELECT ST_AddBand($1, $4, $2, $3, $5) $$
	LANGUAGE 'sql' IMMUTABLE;

-----------------------------------------------------------------------
-- Constructor ST_Band
-----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION st_band(rast raster, nbands int[] DEFAULT ARRAY[1])
	RETURNS RASTER
	AS '$libdir/rtpostgis-2.2', 'RASTER_band'
	LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_band(rast raster, nband int)
	RETURNS RASTER
	AS $$ SELECT st_band($1, ARRAY[$2]) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_band(rast raster, nbands text, delimiter char DEFAULT ',')
	RETURNS RASTER
	AS $$ SELECT st_band($1, regexp_split_to_array(regexp_replace($2, '[[:space:]]', '', 'g'), E'\\' || array_to_string(regexp_split_to_array($3, ''), E'\\'))::int[]) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

-----------------------------------------------------------------------
-- ST_SummaryStats and ST_ApproxSummaryStats
-----------------------------------------------------------------------

-- NOTE: existed in 2.0.0 but was removed in 2.1.0.
-- See http://trac.osgeo.org/postgis/ticket/3082#comment:5
-- Availability: 2.0.0
-- Missing in: 2.1.0
CREATE TYPE summarystats AS (
	count bigint,
	sum double precision,
	mean double precision,
	stddev double precision,
	min double precision,
	max double precision
);

CREATE OR REPLACE FUNCTION _st_summarystats(
	rast raster,
	nband int DEFAULT 1,
	exclude_nodata_value boolean DEFAULT TRUE,
	sample_percent double precision DEFAULT 1
)
	RETURNS summarystats
	AS '$libdir/rtpostgis-2.2','RASTER_summaryStats'
	LANGUAGE 'c' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_summarystats(
	rast raster,
	nband int DEFAULT 1,
	exclude_nodata_value boolean DEFAULT TRUE
)
	RETURNS summarystats
	AS $$ SELECT _st_summarystats($1, $2, $3, 1) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_summarystats(
	rast raster,
	exclude_nodata_value boolean
)
	RETURNS summarystats
	AS $$ SELECT _st_summarystats($1, 1, $2, 1) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_approxsummarystats(
	rast raster,
	nband int DEFAULT 1,
	exclude_nodata_value boolean DEFAULT TRUE,
	sample_percent double precision DEFAULT 0.1
)
	RETURNS summarystats
	AS $$ SELECT _st_summarystats($1, $2, $3, $4) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_approxsummarystats(
	rast raster,
	nband int,
	sample_percent double precision
)
	RETURNS summarystats
	AS $$ SELECT _st_summarystats($1, $2, TRUE, $3) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_approxsummarystats(
	rast raster,
	exclude_nodata_value boolean,
	sample_percent double precision DEFAULT 0.1
)
	RETURNS summarystats
	AS $$ SELECT _st_summarystats($1, 1, $2, $3) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_approxsummarystats(
	rast raster,
	sample_percent double precision
)
	RETURNS summarystats
	AS $$ SELECT _st_summarystats($1, 1, TRUE, $2) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

-----------------------------------------------------------------------
-- ST_SummaryStatsAgg
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION _st_summarystats_finalfn(internal)
	RETURNS summarystats
	AS '$libdir/rtpostgis-2.2', 'RASTER_summaryStats_finalfn'
	LANGUAGE 'c' IMMUTABLE;

CREATE OR REPLACE FUNCTION _st_summarystats_transfn(
	internal,
	raster, integer,
	boolean, double precision
)
	RETURNS internal
	AS '$libdir/rtpostgis-2.2', 'RASTER_summaryStats_transfn'
	LANGUAGE 'c' IMMUTABLE;

-- Availability: 2.2.0
CREATE AGGREGATE st_summarystatsagg(raster, integer, boolean, double precision) (
	SFUNC = _st_summarystats_transfn,
	STYPE = internal,
	FINALFUNC = _st_summarystats_finalfn
);

CREATE OR REPLACE FUNCTION _st_summarystats_transfn(
	internal,
	raster, boolean, double precision
)
	RETURNS internal
	AS '$libdir/rtpostgis-2.2', 'RASTER_summaryStats_transfn'
	LANGUAGE 'c' IMMUTABLE;

-- Availability: 2.2.0
CREATE AGGREGATE st_summarystatsagg(raster, boolean, double precision) (
	SFUNC = _st_summarystats_transfn,
	STYPE = internal,
	FINALFUNC = _st_summarystats_finalfn
);

CREATE OR REPLACE FUNCTION _st_summarystats_transfn(
	internal,
	raster, int, boolean
)
	RETURNS internal
	AS '$libdir/rtpostgis-2.2', 'RASTER_summaryStats_transfn'
	LANGUAGE 'c' IMMUTABLE;

-- Availability: 2.2.0
CREATE AGGREGATE st_summarystatsagg(raster, int, boolean) (
	SFUNC = _st_summarystats_transfn,
	STYPE = internal,
	FINALFUNC = _st_summarystats_finalfn
);

-----------------------------------------------------------------------
-- ST_SummaryStats for table
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION _st_summarystats(
	rastertable text,
	rastercolumn text,
	nband integer DEFAULT 1,
	exclude_nodata_value boolean DEFAULT TRUE,
	sample_percent double precision DEFAULT 1
)
	RETURNS summarystats
	AS $$ 
	DECLARE
		stats summarystats;
	BEGIN
		EXECUTE 'SELECT (stats).* FROM (SELECT ST_SummaryStatsAgg('
			|| quote_ident($2) || ', '
			|| $3 || ', '
			|| $4 || ', '
			|| $5 || ') AS stats '
			|| 'FROM ' || quote_ident($1)
			|| ') foo'
			INTO stats;
		RETURN stats;
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_summarystats(
	rastertable text,
	rastercolumn text,
	nband integer DEFAULT 1,
	exclude_nodata_value boolean DEFAULT TRUE
)
	RETURNS summarystats
	AS $$ SELECT _st_summarystats($1, $2, $3, $4, 1) $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_summarystats(
	rastertable text,
	rastercolumn text,
	exclude_nodata_value boolean
)
	RETURNS summarystats
	AS $$ SELECT _st_summarystats($1, $2, 1, $3, 1) $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_approxsummarystats(
	rastertable text,
	rastercolumn text,
	nband integer DEFAULT 1,
	exclude_nodata_value boolean DEFAULT TRUE,
	sample_percent double precision DEFAULT 0.1
)
	RETURNS summarystats
	AS $$ SELECT _st_summarystats($1, $2, $3, $4, $5) $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_approxsummarystats(
	rastertable text,
	rastercolumn text,
	nband integer,
	sample_percent double precision
)
	RETURNS summarystats
	AS $$ SELECT _st_summarystats($1, $2, $3, TRUE, $4) $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_approxsummarystats(
	rastertable text,
	rastercolumn text,
	exclude_nodata_value boolean
)
	RETURNS summarystats
	AS $$ SELECT _st_summarystats($1, $2, 1, $3, 0.1) $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_approxsummarystats(
	rastertable text,
	rastercolumn text,
	sample_percent double precision
)
	RETURNS summarystats
	AS $$ SELECT _st_summarystats($1, $2, 1, TRUE, $3) $$
	LANGUAGE 'sql' STABLE STRICT;

-----------------------------------------------------------------------
-- ST_Count and ST_ApproxCount
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION _st_count(rast raster, nband int DEFAULT 1, exclude_nodata_value boolean DEFAULT TRUE, sample_percent double precision DEFAULT 1)
	RETURNS bigint
	AS $$
	DECLARE
		rtn bigint;
	BEGIN
		IF exclude_nodata_value IS FALSE THEN
			SELECT width * height INTO rtn FROM ST_Metadata(rast);
		ELSE
			SELECT count INTO rtn FROM _st_summarystats($1, $2, $3, $4);
		END IF;

		RETURN rtn;
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_count(rast raster, nband int DEFAULT 1, exclude_nodata_value boolean DEFAULT TRUE)
	RETURNS bigint
	AS $$ SELECT _st_count($1, $2, $3, 1) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_count(rast raster, exclude_nodata_value boolean)
	RETURNS bigint
	AS $$ SELECT _st_count($1, 1, $2, 1) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_approxcount(rast raster, nband int DEFAULT 1, exclude_nodata_value boolean DEFAULT TRUE, sample_percent double precision DEFAULT 0.1)
	RETURNS bigint
	AS $$ SELECT _st_count($1, $2, $3, $4) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_approxcount(rast raster, nband int, sample_percent double precision)
	RETURNS bigint
	AS $$ SELECT _st_count($1, $2, TRUE, $3) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_approxcount(rast raster, exclude_nodata_value boolean, sample_percent double precision DEFAULT 0.1)
	RETURNS bigint
	AS $$ SELECT _st_count($1, 1, $2, $3) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_approxcount(rast raster, sample_percent double precision)
	RETURNS bigint
	AS $$ SELECT _st_count($1, 1, TRUE, $2) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

-----------------------------------------------------------------------
-- ST_CountAgg
-----------------------------------------------------------------------

-- Availability: 2.2.0
CREATE TYPE agg_count AS (
	count bigint,
	nband integer,
	exclude_nodata_value boolean,
	sample_percent double precision
);

CREATE OR REPLACE FUNCTION _st_countagg_finalfn(agg agg_count)
	RETURNS bigint
	AS $$
	BEGIN
		IF agg IS NULL THEN
			RAISE EXCEPTION 'Cannot count coverage';
		END IF;

		RETURN agg.count;
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION __st_countagg_transfn(
	agg agg_count,
	rast raster,
 	nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT TRUE,
	sample_percent double precision DEFAULT 1
)
	RETURNS agg_count
	AS $$
	DECLARE
		_count bigint;
		rtn_agg agg_count;
	BEGIN

		-- only process parameter args once
		IF agg IS NULL THEN
			rtn_agg.count := 0;

			IF nband < 1 THEN
				RAISE EXCEPTION 'Band index must be greater than zero (1-based)';
			ELSE
				rtn_agg.nband := nband;
			END IF;

			IF exclude_nodata_value IS FALSE THEN
				rtn_agg.exclude_nodata_value := FALSE;
			ELSE
				rtn_agg.exclude_nodata_value := TRUE;
			END IF;

			IF sample_percent < 0. OR sample_percent > 1. THEN
				RAISE EXCEPTION 'Sample percent must be between zero and one';
			ELSE
				rtn_agg.sample_percent := sample_percent;
			END IF;
		ELSE
			rtn_agg := agg;
		END IF;

		IF rast IS NOT NULL THEN
			IF rtn_agg.exclude_nodata_value IS FALSE THEN
				SELECT width * height INTO _count FROM ST_Metadata(rast);
			ELSE
				SELECT count INTO _count FROM _st_summarystats(
					rast,
				 	rtn_agg.nband, rtn_agg.exclude_nodata_value,
					rtn_agg.sample_percent
				);
			END IF;
		END IF;

		rtn_agg.count := rtn_agg.count + _count;
		RETURN rtn_agg;
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION _st_countagg_transfn(
	agg agg_count,
	rast raster,
 	nband integer, exclude_nodata_value boolean,
	sample_percent double precision
)
	RETURNS agg_count
	AS $$
	DECLARE
		rtn_agg agg_count;
	BEGIN
		rtn_agg := __st_countagg_transfn(
			agg,
			rast,
			nband, exclude_nodata_value,
			sample_percent
		);
		RETURN rtn_agg;
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE;

-- Availability: 2.2.0
CREATE AGGREGATE st_countagg(raster, integer, boolean, double precision) (
	SFUNC = _st_countagg_transfn,
	STYPE = agg_count,
	FINALFUNC = _st_countagg_finalfn
);

CREATE OR REPLACE FUNCTION _st_countagg_transfn(
	agg agg_count,
	rast raster,
 	nband integer, exclude_nodata_value boolean
)
	RETURNS agg_count
	AS $$
	DECLARE
		rtn_agg agg_count;
	BEGIN
		rtn_agg := __st_countagg_transfn(
			agg,
			rast,
			nband, exclude_nodata_value,
			1
		);
		RETURN rtn_agg;
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE;

-- Availability: 2.2.0
CREATE AGGREGATE st_countagg(raster, integer, boolean) (
	SFUNC = _st_countagg_transfn,
	STYPE = agg_count,
	FINALFUNC = _st_countagg_finalfn
);

CREATE OR REPLACE FUNCTION _st_countagg_transfn(
	agg agg_count,
	rast raster,
 	exclude_nodata_value boolean
)
	RETURNS agg_count
	AS $$
	DECLARE
		rtn_agg agg_count;
	BEGIN
		rtn_agg := __st_countagg_transfn(
			agg,
			rast,
			1, exclude_nodata_value,
			1
		);
		RETURN rtn_agg;
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE;

-- Availability: 2.2.0
CREATE AGGREGATE st_countagg(raster, boolean) (
	SFUNC = _st_countagg_transfn,
	STYPE = agg_count,
	FINALFUNC = _st_countagg_finalfn
);

-----------------------------------------------------------------------
-- ST_Count for table
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION _st_count(rastertable text, rastercolumn text, nband integer DEFAULT 1, exclude_nodata_value boolean DEFAULT TRUE, sample_percent double precision DEFAULT 1)
	RETURNS bigint
	AS $$
	DECLARE
		count bigint;
	BEGIN
		EXECUTE 'SELECT ST_CountAgg('
			|| quote_ident($2) || ', '
			|| $3 || ', '
			|| $4 || ', '
			|| $5 || ') '
			|| 'FROM ' || quote_ident($1)
	 	INTO count;
		RETURN count;
	END;
 	$$ LANGUAGE 'plpgsql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_count(rastertable text, rastercolumn text, nband int DEFAULT 1, exclude_nodata_value boolean DEFAULT TRUE)
	RETURNS bigint
	AS $$ SELECT _st_count($1, $2, $3, $4, 1) $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_count(rastertable text, rastercolumn text, exclude_nodata_value boolean)
	RETURNS bigint
	AS $$ SELECT _st_count($1, $2, 1, $3, 1) $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_approxcount(rastertable text, rastercolumn text, nband int DEFAULT 1, exclude_nodata_value boolean DEFAULT TRUE, sample_percent double precision DEFAULT 0.1)
	RETURNS bigint
	AS $$ SELECT _st_count($1, $2, $3, $4, $5) $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_approxcount(rastertable text, rastercolumn text, nband int, sample_percent double precision)
	RETURNS bigint
	AS $$ SELECT _st_count($1, $2, $3, TRUE, $4) $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_approxcount(rastertable text, rastercolumn text, exclude_nodata_value boolean, sample_percent double precision DEFAULT 0.1)
	RETURNS bigint
	AS $$ SELECT _st_count($1, $2, 1, $3, $4) $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_approxcount(rastertable text, rastercolumn text, sample_percent double precision)
	RETURNS bigint
	AS $$ SELECT _st_count($1, $2, 1, TRUE, $3) $$
	LANGUAGE 'sql' STABLE STRICT;

-----------------------------------------------------------------------
-- ST_Histogram and ST_ApproxHistogram
-----------------------------------------------------------------------

-- Cannot be strict as "width", "min" and "max" can be NULL
CREATE OR REPLACE FUNCTION _st_histogram(
	rast raster, nband int DEFAULT 1,
	exclude_nodata_value boolean DEFAULT TRUE,
	sample_percent double precision DEFAULT 1,
	bins int DEFAULT 0, width double precision[] DEFAULT NULL,
	right boolean DEFAULT FALSE,
	min double precision DEFAULT NULL, max double precision DEFAULT NULL,
	OUT min double precision,
	OUT max double precision,
	OUT count bigint,
	OUT percent double precision
)
	RETURNS SETOF record
	AS '$libdir/rtpostgis-2.2','RASTER_histogram'
	LANGUAGE 'c' IMMUTABLE;

-- Cannot be strict as "width" can be NULL
CREATE OR REPLACE FUNCTION st_histogram(
	rast raster, nband int DEFAULT 1,
	exclude_nodata_value boolean DEFAULT TRUE,
	bins int DEFAULT 0, width double precision[] DEFAULT NULL,
	right boolean DEFAULT FALSE,
	OUT min double precision,
	OUT max double precision,
	OUT count bigint,
	OUT percent double precision
)
	RETURNS SETOF record
	AS $$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, 1, $4, $5, $6) $$
	LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_histogram(
	rast raster, nband int,
	exclude_nodata_value boolean,
	bins int,
	right boolean,
	OUT min double precision,
	OUT max double precision,
	OUT count bigint,
	OUT percent double precision
)
	RETURNS SETOF record
	AS $$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, 1, $4, NULL, $5) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

-- Cannot be strict as "width" can be NULL
CREATE OR REPLACE FUNCTION st_histogram(
	rast raster, nband int,
	bins int, width double precision[] DEFAULT NULL,
	right boolean DEFAULT FALSE,
	OUT min double precision,
	OUT max double precision,
	OUT count bigint,
	OUT percent double precision
)
	RETURNS SETOF record
	AS $$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, 1, $3, $4, $5) $$
	LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_histogram(
	rast raster, nband int,
	bins int,
	right boolean,
	OUT min double precision,
	OUT max double precision,
	OUT count bigint,
	OUT percent double precision
)
	RETURNS SETOF record
	AS $$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, 1, $3, NULL, $4) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

-- Cannot be strict as "width" can be NULL
CREATE OR REPLACE FUNCTION st_approxhistogram(
	rast raster, nband int DEFAULT 1,
	exclude_nodata_value boolean DEFAULT TRUE,
	sample_percent double precision DEFAULT 0.1,
	bins int DEFAULT 0, width double precision[] DEFAULT NULL,
	right boolean DEFAULT FALSE,
	OUT min double precision,
	OUT max double precision,
	OUT count bigint,
	OUT percent double precision
)
	RETURNS SETOF record
	AS $$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, $4, $5, $6, $7) $$
	LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_approxhistogram(
	rast raster, nband int,
	exclude_nodata_value boolean,
	sample_percent double precision,
	bins int,
	right boolean,
	OUT min double precision,
	OUT max double precision,
	OUT count bigint,
	OUT percent double precision
)
	RETURNS SETOF record
	AS $$ SELECT min, max, count, percent FROM _st_histogram($1, $2, $3, $4, $5, NULL, $6) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_approxhistogram(
	rast raster, nband int,
	sample_percent double precision,
	OUT min double precision,
	OUT max double precision,
	OUT count bigint,
	OUT percent double precision
)
	RETURNS SETOF record
	AS $$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, 0, NULL, FALSE) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_approxhistogram(
	rast raster,
	sample_percent double precision,
	OUT min double precision,
	OUT max double precision,
	OUT count bigint,
	OUT percent double precision
)
	RETURNS SETOF record
	AS $$ SELECT min, max, count, percent FROM _st_histogram($1, 1, TRUE, $2, 0, NULL, FALSE) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

-- Cannot be strict as "width" can be NULL
CREATE OR REPLACE FUNCTION st_approxhistogram(
	rast raster, nband int,
	sample_percent double precision,
	bins int, width double precision[] DEFAULT NULL,
	right boolean DEFAULT FALSE,
	OUT min double precision,
	OUT max double precision,
	OUT count bigint,
	OUT percent double precision
)
	RETURNS SETOF record
	AS $$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, $4, $5, $6) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_approxhistogram(
	rast raster, nband int,
	sample_percent double precision,
	bins int, right boolean,
	OUT min double precision,
	OUT max double precision,
	OUT count bigint,
	OUT percent double precision
)
	RETURNS SETOF record
	AS $$ SELECT min, max, count, percent FROM _st_histogram($1, $2, TRUE, $3, $4, NULL, $5) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

-- Cannot be strict as "width" can be NULL
CREATE OR REPLACE FUNCTION _st_histogram(
	rastertable text, rastercolumn text,
	nband int DEFAULT 1,
	exclude_nodata_value boolean DEFAULT TRUE,
	sample_percent double precision DEFAULT 1,
	bins int DEFAULT 0, width double precision[] DEFAULT NULL,
	right boolean DEFAULT FALSE,
	OUT min double precision,
	OUT max double precision,
	OUT count bigint,
	OUT percent double precision
)
	RETURNS SETOF record
	AS '$libdir/rtpostgis-2.2','RASTER_histogramCoverage'
	LANGUAGE 'c' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_histogram(
	rastertable text, rastercolumn text, nband int DEFAULT 1,
	exclude_nodata_value boolean DEFAULT TRUE,
	bins int DEFAULT 0, width double precision[] DEFAULT NULL,
	right boolean DEFAULT FALSE,
	OUT min double precision,
	OUT max double precision,
	OUT count bigint,
	OUT percent double precision
)
	RETURNS SETOF record
	AS $$ SELECT _st_histogram($1, $2, $3, $4, 1, $5, $6, $7) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_histogram(
	rastertable text, rastercolumn text, nband int,
	exclude_nodata_value boolean,
	bins int,
	right boolean,
	OUT min double precision,
	OUT max double precision,
	OUT count bigint,
	OUT percent double precision
)
	RETURNS SETOF record
	AS $$ SELECT _st_histogram($1, $2, $3, $4, 1, $5, NULL, $6) $$
	LANGUAGE 'sql' STABLE STRICT;

-- Cannot be strict as "width" can be NULL
CREATE OR REPLACE FUNCTION st_histogram(
	rastertable text, rastercolumn text, nband int,
	bins int, width double precision[] DEFAULT NULL,
	right boolean DEFAULT FALSE,
	OUT min double precision,
	OUT max double precision,
	OUT count bigint,
	OUT percent double precision
)
	RETURNS SETOF record
	AS $$ SELECT _st_histogram($1, $2, $3, TRUE, 1, $4, $5, $6) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_histogram(
	rastertable text, rastercolumn text, nband int,
	bins int,
	right boolean,
	OUT min double precision,
	OUT max double precision,
	OUT count bigint,
	OUT percent double precision
)
	RETURNS SETOF record
	AS $$ SELECT _st_histogram($1, $2, $3, TRUE, 1, $4, NULL, $5) $$
	LANGUAGE 'sql' STABLE STRICT;

-- Cannot be strict as "width" can be NULL
CREATE OR REPLACE FUNCTION st_approxhistogram(
	rastertable text, rastercolumn text,
	nband int DEFAULT 1,
	exclude_nodata_value boolean DEFAULT TRUE,
	sample_percent double precision DEFAULT 0.1,
	bins int DEFAULT 0, width double precision[] DEFAULT NULL,
	right boolean DEFAULT FALSE,
	OUT min double precision,
	OUT max double precision,
	OUT count bigint,
	OUT percent double precision
)
	RETURNS SETOF record
	AS $$ SELECT _st_histogram($1, $2, $3, $4, $5, $6, $7, $8) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_approxhistogram(
	rastertable text, rastercolumn text, nband int,
	exclude_nodata_value boolean,
	sample_percent double precision,
	bins int,
	right boolean,
	OUT min double precision,
	OUT max double precision,
	OUT count bigint,
	OUT percent double precision
)
	RETURNS SETOF record
	AS $$ SELECT _st_histogram($1, $2, $3, $4, $5, $6, NULL, $7) $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_approxhistogram(
	rastertable text, rastercolumn text, nband int,
	sample_percent double precision,
	OUT min double precision,
	OUT max double precision,
	OUT count bigint,
	OUT percent double precision
)
	RETURNS SETOF record
	AS $$ SELECT _st_histogram($1, $2, $3, TRUE, $4, 0, NULL, FALSE) $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_approxhistogram(
	rastertable text, rastercolumn text,
	sample_percent double precision,
	OUT min double precision,
	OUT max double precision,
	OUT count bigint,
	OUT percent double precision
)
	RETURNS SETOF record
	AS $$ SELECT _st_histogram($1, $2, 1, TRUE, $3, 0, NULL, FALSE) $$
	LANGUAGE 'sql' STABLE STRICT;

-- Cannot be strict as "width" can be NULL
CREATE OR REPLACE FUNCTION st_approxhistogram(
	rastertable text, rastercolumn text, nband int,
	sample_percent double precision,
	bins int, width double precision[] DEFAULT NULL,
	right boolean DEFAULT FALSE,
	OUT min double precision,
	OUT max double precision,
	OUT count bigint,
	OUT percent double precision
)
	RETURNS SETOF record
	AS $$ SELECT _st_histogram($1, $2, $3, TRUE, $4, $5, $6, $7) $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_approxhistogram(
	rastertable text, rastercolumn text, nband int,
	sample_percent double precision,
	bins int,
	right boolean,
	OUT min double precision,
	OUT max double precision,
	OUT count bigint,
	OUT percent double precision
)
	RETURNS SETOF record
	AS $$ SELECT _st_histogram($1, $2, $3, TRUE, $4, $5, NULL, $6) $$
	LANGUAGE 'sql' STABLE STRICT;

-----------------------------------------------------------------------
-- ST_Quantile and ST_ApproxQuantile
-----------------------------------------------------------------------
-- Cannot be strict as "quantiles" can be NULL
CREATE OR REPLACE FUNCTION _st_quantile(
	rast raster,
	nband int DEFAULT 1,
	exclude_nodata_value boolean DEFAULT TRUE,
	sample_percent double precision DEFAULT 1,
	quantiles double precision[] DEFAULT NULL,
	OUT quantile double precision,
	OUT value double precision
)
	RETURNS SETOF record
	AS '$libdir/rtpostgis-2.2','RASTER_quantile'
	LANGUAGE 'c' IMMUTABLE;

-- Cannot be strict as "quantiles" can be NULL
CREATE OR REPLACE FUNCTION st_quantile(
	rast raster,
	nband int DEFAULT 1,
	exclude_nodata_value boolean DEFAULT TRUE,
	quantiles double precision[] DEFAULT NULL,
	OUT quantile double precision,
	OUT value double precision
)
	RETURNS SETOF record
	AS $$ SELECT _st_quantile($1, $2, $3, 1, $4) $$
	LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_quantile(
	rast raster,
	nband int,
	quantiles double precision[],
	OUT quantile double precision,
	OUT value double precision
)
	RETURNS SETOF record
	AS $$ SELECT _st_quantile($1, $2, TRUE, 1, $3) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_quantile(
	rast raster,
	quantiles double precision[],
	OUT quantile double precision,
	OUT value double precision
)
	RETURNS SETOF record
	AS $$ SELECT _st_quantile($1, 1, TRUE, 1, $2) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_quantile(rast raster, nband int, exclude_nodata_value boolean, quantile double precision)
	RETURNS double precision
	AS $$ SELECT (_st_quantile($1, $2, $3, 1, ARRAY[$4]::double precision[])).value $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_quantile(rast raster, nband int, quantile double precision)
	RETURNS double precision
	AS $$ SELECT (_st_quantile($1, $2, TRUE, 1, ARRAY[$3]::double precision[])).value $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

-- Cannot be strict as "quantile" can be NULL
CREATE OR REPLACE FUNCTION st_quantile(rast raster, exclude_nodata_value boolean, quantile double precision DEFAULT NULL)
	RETURNS double precision
	AS $$ SELECT (_st_quantile($1, 1, $2, 1, ARRAY[$3]::double precision[])).value $$
	LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_quantile(rast raster, quantile double precision)
	RETURNS double precision
	AS $$ SELECT (_st_quantile($1, 1, TRUE, 1, ARRAY[$2]::double precision[])).value $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

-- Cannot be strict as "quantiles" can be NULL
CREATE OR REPLACE FUNCTION st_approxquantile(
	rast raster,
	nband int DEFAULT 1,
	exclude_nodata_value boolean DEFAULT TRUE,
	sample_percent double precision DEFAULT 0.1,
	quantiles double precision[] DEFAULT NULL,
	OUT quantile double precision,
	OUT value double precision
)
	RETURNS SETOF record
	AS $$ SELECT _st_quantile($1, $2, $3, $4, $5) $$
	LANGUAGE 'sql' IMMUTABLE;

-- Cannot be strict as "quantiles" can be NULL
CREATE OR REPLACE FUNCTION st_approxquantile(
	rast raster,
	nband int,
	sample_percent double precision,
	quantiles double precision[] DEFAULT NULL,
	OUT quantile double precision,
	OUT value double precision
)
	RETURNS SETOF record
	AS $$ SELECT _st_quantile($1, $2, TRUE, $3, $4) $$
	LANGUAGE 'sql' IMMUTABLE;

-- Cannot be strict as "quantiles" can be NULL
CREATE OR REPLACE FUNCTION st_approxquantile(
	rast raster,
	sample_percent double precision,
	quantiles double precision[] DEFAULT NULL,
	OUT quantile double precision,
	OUT value double precision
)
	RETURNS SETOF record
	AS $$ SELECT _st_quantile($1, 1, TRUE, $2, $3) $$
	LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_approxquantile(
	rast raster,
	quantiles double precision[],
	OUT quantile double precision,
	OUT value double precision
)
	RETURNS SETOF record
	AS $$ SELECT _st_quantile($1, 1, TRUE, 0.1, $2) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_approxquantile(rast raster, nband int, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
	RETURNS double precision
	AS $$ SELECT (_st_quantile($1, $2, $3, $4, ARRAY[$5]::double precision[])).value $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_approxquantile(rast raster, nband int, sample_percent double precision, quantile double precision)
	RETURNS double precision
	AS $$ SELECT (_st_quantile($1, $2, TRUE, $3, ARRAY[$4]::double precision[])).value $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_approxquantile(rast raster, sample_percent double precision, quantile double precision)
	RETURNS double precision
	AS $$ SELECT (_st_quantile($1, 1, TRUE, $2, ARRAY[$3]::double precision[])).value $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

-- Cannot be strict as "quantile" can be NULL
CREATE OR REPLACE FUNCTION st_approxquantile(rast raster, exclude_nodata_value boolean, quantile double precision DEFAULT NULL)
	RETURNS double precision
	AS $$ SELECT (_st_quantile($1, 1, $2, 0.1, ARRAY[$3]::double precision[])).value $$
	LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_approxquantile(rast raster, quantile double precision)
	RETURNS double precision
	AS $$ SELECT (_st_quantile($1, 1, TRUE, 0.1, ARRAY[$2]::double precision[])).value $$
	LANGUAGE 'sql' IMMUTABLE;

-- Cannot be strict as "quantiles" can be NULL
CREATE OR REPLACE FUNCTION _st_quantile(
	rastertable text,
	rastercolumn text,
	nband int DEFAULT 1,
	exclude_nodata_value boolean DEFAULT TRUE,
	sample_percent double precision DEFAULT 1,
	quantiles double precision[] DEFAULT NULL,
	OUT quantile double precision,
	OUT value double precision
)
	RETURNS SETOF record
	AS '$libdir/rtpostgis-2.2','RASTER_quantileCoverage'
	LANGUAGE 'c' STABLE;

-- Cannot be strict as "quantiles" can be NULL
CREATE OR REPLACE FUNCTION st_quantile(
	rastertable text,
	rastercolumn text,
	nband int DEFAULT 1,
	exclude_nodata_value boolean DEFAULT TRUE,
	quantiles double precision[] DEFAULT NULL,
	OUT quantile double precision,
	OUT value double precision
)
	RETURNS SETOF record
	AS $$ SELECT _st_quantile($1, $2, $3, $4, 1, $5) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_quantile(
	rastertable text,
	rastercolumn text,
	nband int,
	quantiles double precision[],
	OUT quantile double precision,
	OUT value double precision
)
	RETURNS SETOF record
	AS $$ SELECT _st_quantile($1, $2, $3, TRUE, 1, $4) $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_quantile(
	rastertable text,
	rastercolumn text,
	quantiles double precision[],
	OUT quantile double precision,
	OUT value double precision
)
	RETURNS SETOF record
	AS $$ SELECT _st_quantile($1, $2, 1, TRUE, 1, $3) $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_quantile(rastertable text, rastercolumn text, nband int, exclude_nodata_value boolean, quantile double precision)
	RETURNS double precision
	AS $$ SELECT (_st_quantile($1, $2, $3, $4, 1, ARRAY[$5]::double precision[])).value $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_quantile(rastertable text, rastercolumn text, nband int, quantile double precision)
	RETURNS double precision
	AS $$ SELECT (_st_quantile($1, $2, $3, TRUE, 1, ARRAY[$4]::double precision[])).value $$
	LANGUAGE 'sql' STABLE STRICT;

-- Cannot be strict as "quantile" can be NULL
CREATE OR REPLACE FUNCTION st_quantile(rastertable text, rastercolumn text, exclude_nodata_value boolean, quantile double precision DEFAULT NULL)
	RETURNS double precision
	AS $$ SELECT (_st_quantile($1, $2, 1, $3, 1, ARRAY[$4]::double precision[])).value $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_quantile(rastertable text, rastercolumn text, quantile double precision)
	RETURNS double precision
	AS $$ SELECT (_st_quantile($1, $2, 1, TRUE, 1, ARRAY[$3]::double precision[])).value $$
	LANGUAGE 'sql' STABLE STRICT;

-- Cannot be strict as "quantiles" can be NULL
CREATE OR REPLACE FUNCTION st_approxquantile(
	rastertable text,
	rastercolumn text,
	nband int DEFAULT 1,
	exclude_nodata_value boolean DEFAULT TRUE,
	sample_percent double precision DEFAULT 0.1,
	quantiles double precision[] DEFAULT NULL,
	OUT quantile double precision,
	OUT value double precision
)
	RETURNS SETOF record
	AS $$ SELECT _st_quantile($1, $2, $3, $4, $5, $6) $$
	LANGUAGE 'sql' STABLE;

-- Cannot be strict as "quantiles" can be NULL
CREATE OR REPLACE FUNCTION st_approxquantile(
	rastertable text,
	rastercolumn text,
	nband int,
	sample_percent double precision,
	quantiles double precision[] DEFAULT NULL,
	OUT quantile double precision,
	OUT value double precision
)
	RETURNS SETOF record
	AS $$ SELECT _st_quantile($1, $2, $3, TRUE, $4, $5) $$
	LANGUAGE 'sql' STABLE;

-- Cannot be strict as "quantiles" can be NULL
CREATE OR REPLACE FUNCTION st_approxquantile(
	rastertable text,
	rastercolumn text,
	sample_percent double precision,
	quantiles double precision[] DEFAULT NULL,
	OUT quantile double precision,
	OUT value double precision
)
	RETURNS SETOF record
	AS $$ SELECT _st_quantile($1, $2, 1, TRUE, $3, $4) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_approxquantile(
	rastertable text,
	rastercolumn text,
	quantiles double precision[],
	OUT quantile double precision,
	OUT value double precision
)
	RETURNS SETOF record
	AS $$ SELECT _st_quantile($1, $2, 1, TRUE, 0.1, $3) $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_approxquantile(rastertable text, rastercolumn text, nband int, exclude_nodata_value boolean, sample_percent double precision, quantile double precision)
	RETURNS double precision
	AS $$ SELECT (_st_quantile($1, $2, $3, $4, $5, ARRAY[$6]::double precision[])).value $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_approxquantile(rastertable text, rastercolumn text, nband int, sample_percent double precision, quantile double precision)
	RETURNS double precision
	AS $$ SELECT (_st_quantile($1, $2, $3, TRUE, $4, ARRAY[$5]::double precision[])).value $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_approxquantile(rastertable text, rastercolumn text, sample_percent double precision, quantile double precision)
	RETURNS double precision
	AS $$ SELECT (_st_quantile($1, $2, 1, TRUE, $3, ARRAY[$4]::double precision[])).value $$
	LANGUAGE 'sql' STABLE STRICT;

-- Cannot be strict as "quantile" can be NULL
CREATE OR REPLACE FUNCTION st_approxquantile(rastertable text, rastercolumn text, exclude_nodata_value boolean, quantile double precision DEFAULT NULL)
	RETURNS double precision
	AS $$ SELECT (_st_quantile($1, $2, 1, $3, 0.1, ARRAY[$4]::double precision[])).value $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_approxquantile(rastertable text, rastercolumn text, quantile double precision)
	RETURNS double precision
	AS $$ SELECT (_st_quantile($1, $2, 1, TRUE, 0.1, ARRAY[$3]::double precision[])).value $$
	LANGUAGE 'sql' STABLE;

-----------------------------------------------------------------------
-- ST_ValueCount and ST_ValuePercent
-----------------------------------------------------------------------

-- None of the "valuecount" functions with "searchvalues" can be strict as "searchvalues" and "roundto" can be NULL
-- Allowing "searchvalues" to be NULL instructs the function to count all values

CREATE OR REPLACE FUNCTION _st_valuecount(
	rast raster, nband integer DEFAULT 1,
	exclude_nodata_value boolean DEFAULT TRUE,
	searchvalues double precision[] DEFAULT NULL,
	roundto double precision DEFAULT 0,
	OUT value double precision,
	OUT count integer,
	OUT percent double precision
)
	RETURNS SETOF record
	AS '$libdir/rtpostgis-2.2', 'RASTER_valueCount'
	LANGUAGE 'c' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_valuecount(
	rast raster, nband integer DEFAULT 1,
	exclude_nodata_value boolean DEFAULT TRUE,
	searchvalues double precision[] DEFAULT NULL,
	roundto double precision DEFAULT 0,
	OUT value double precision, OUT count integer
)
	RETURNS SETOF record
	AS $$ SELECT value, count FROM _st_valuecount($1, $2, $3, $4, $5) $$
	LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_valuecount(rast raster, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
	RETURNS SETOF record
	AS $$ SELECT value, count FROM _st_valuecount($1, $2, TRUE, $3, $4) $$
	LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_valuecount(rast raster, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
	RETURNS SETOF record
	AS $$ SELECT value, count FROM _st_valuecount($1, 1, TRUE, $2, $3) $$
	LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_valuecount(rast raster, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
	RETURNS integer
	AS $$ SELECT (_st_valuecount($1, $2, $3, ARRAY[$4]::double precision[], $5)).count $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_valuecount(rast raster, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
	RETURNS integer
	AS $$ SELECT (_st_valuecount($1, $2, TRUE, ARRAY[$3]::double precision[], $4)).count $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_valuecount(rast raster, searchvalue double precision, roundto double precision DEFAULT 0)
	RETURNS integer
	AS $$ SELECT (_st_valuecount($1, 1, TRUE, ARRAY[$2]::double precision[], $3)).count $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_valuepercent(
	rast raster, nband integer DEFAULT 1,
	exclude_nodata_value boolean DEFAULT TRUE,
	searchvalues double precision[] DEFAULT NULL,
	roundto double precision DEFAULT 0,
	OUT value double precision, OUT percent double precision
)
	RETURNS SETOF record
	AS $$ SELECT value, percent FROM _st_valuecount($1, $2, $3, $4, $5) $$
	LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_valuepercent(rast raster, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
	RETURNS SETOF record
	AS $$ SELECT value, percent FROM _st_valuecount($1, $2, TRUE, $3, $4) $$
	LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_valuepercent(rast raster, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
	RETURNS SETOF record
	AS $$ SELECT value, percent FROM _st_valuecount($1, 1, TRUE, $2, $3) $$
	LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_valuepercent(rast raster, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
	RETURNS double precision
	AS $$ SELECT (_st_valuecount($1, $2, $3, ARRAY[$4]::double precision[], $5)).percent $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_valuepercent(rast raster, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
	RETURNS double precision
	AS $$ SELECT (_st_valuecount($1, $2, TRUE, ARRAY[$3]::double precision[], $4)).percent $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_valuepercent(rast raster, searchvalue double precision, roundto double precision DEFAULT 0)
	RETURNS double precision
	AS $$ SELECT (_st_valuecount($1, 1, TRUE, ARRAY[$2]::double precision[], $3)).percent $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION _st_valuecount(
	rastertable text,
	rastercolumn text,
	nband integer DEFAULT 1,
	exclude_nodata_value boolean DEFAULT TRUE,
	searchvalues double precision[] DEFAULT NULL,
	roundto double precision DEFAULT 0,
	OUT value double precision,
	OUT count integer,
	OUT percent double precision
)
	RETURNS SETOF record
	AS '$libdir/rtpostgis-2.2', 'RASTER_valueCountCoverage'
	LANGUAGE 'c' STABLE;

CREATE OR REPLACE FUNCTION st_valuecount(
	rastertable text, rastercolumn text,
	nband integer DEFAULT 1,
	exclude_nodata_value boolean DEFAULT TRUE,
	searchvalues double precision[] DEFAULT NULL,
	roundto double precision DEFAULT 0,
	OUT value double precision, OUT count integer
)
	RETURNS SETOF record
	AS $$ SELECT value, count FROM _st_valuecount($1, $2, $3, $4, $5, $6) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_valuecount(rastertable text, rastercolumn text, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
	RETURNS SETOF record
	AS $$ SELECT value, count FROM _st_valuecount($1, $2, $3, TRUE, $4, $5) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_valuecount(rastertable text, rastercolumn text, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT count integer)
	RETURNS SETOF record
	AS $$ SELECT value, count FROM _st_valuecount($1, $2, 1, TRUE, $3, $4) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_valuecount(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
	RETURNS integer
	AS $$ SELECT (_st_valuecount($1, $2, $3, $4, ARRAY[$5]::double precision[], $6)).count $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_valuecount(rastertable text, rastercolumn text, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
	RETURNS integer
	AS $$ SELECT (_st_valuecount($1, $2, $3, TRUE, ARRAY[$4]::double precision[], $5)).count $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_valuecount(rastertable text, rastercolumn text, searchvalue double precision, roundto double precision DEFAULT 0)
	RETURNS integer
	AS $$ SELECT (_st_valuecount($1, $2, 1, TRUE, ARRAY[$3]::double precision[], $4)).count $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_valuepercent(
	rastertable text, rastercolumn text,
	nband integer DEFAULT 1,
	exclude_nodata_value boolean DEFAULT TRUE,
	searchvalues double precision[] DEFAULT NULL,
	roundto double precision DEFAULT 0,
	OUT value double precision, OUT percent double precision
)
	RETURNS SETOF record
	AS $$ SELECT value, percent FROM _st_valuecount($1, $2, $3, $4, $5, $6) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_valuepercent(rastertable text, rastercolumn text, nband integer, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
	RETURNS SETOF record
	AS $$ SELECT value, percent FROM _st_valuecount($1, $2, $3, TRUE, $4, $5) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_valuepercent(rastertable text, rastercolumn text, searchvalues double precision[], roundto double precision DEFAULT 0, OUT value double precision, OUT percent double precision)
	RETURNS SETOF record
	AS $$ SELECT value, percent FROM _st_valuecount($1, $2, 1, TRUE, $3, $4) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_valuepercent(rastertable text, rastercolumn text, nband integer, exclude_nodata_value boolean, searchvalue double precision, roundto double precision DEFAULT 0)
	RETURNS double precision
	AS $$ SELECT (_st_valuecount($1, $2, $3, $4, ARRAY[$5]::double precision[], $6)).percent $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_valuepercent(rastertable text, rastercolumn text, nband integer, searchvalue double precision, roundto double precision DEFAULT 0)
	RETURNS double precision
	AS $$ SELECT (_st_valuecount($1, $2, $3, TRUE, ARRAY[$4]::double precision[], $5)).percent $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_valuepercent(rastertable text, rastercolumn text, searchvalue double precision, roundto double precision DEFAULT 0)
	RETURNS double precision
	AS $$ SELECT (_st_valuecount($1, $2, 1, TRUE, ARRAY[$3]::double precision[], $4)).percent $$
	LANGUAGE 'sql' STABLE STRICT;

-----------------------------------------------------------------------
-- ST_Reclass
-----------------------------------------------------------------------
-- Availability: 2.0.0
CREATE TYPE reclassarg AS (
	nband int,
	reclassexpr text,
	pixeltype text,
	nodataval double precision
);

CREATE OR REPLACE FUNCTION _st_reclass(rast raster, VARIADIC reclassargset reclassarg[])
	RETURNS raster
	AS '$libdir/rtpostgis-2.2', 'RASTER_reclass'
	LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_reclass(rast raster, VARIADIC reclassargset reclassarg[])
	RETURNS raster
	AS $$
	DECLARE
		i int;
		expr text;
	BEGIN
		-- for each reclassarg, validate elements as all except nodataval cannot be NULL
		FOR i IN SELECT * FROM generate_subscripts($2, 1) LOOP
			IF $2[i].nband IS NULL OR $2[i].reclassexpr IS NULL OR $2[i].pixeltype IS NULL THEN
				RAISE WARNING 'Values are required for the nband, reclassexpr and pixeltype attributes.';
				RETURN rast;
			END IF;
		END LOOP;

		RETURN _st_reclass($1, VARIADIC $2);
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE STRICT;

-- Cannot be strict as "nodataval" can be NULL
CREATE OR REPLACE FUNCTION st_reclass(rast raster, nband int, reclassexpr text, pixeltype text, nodataval double precision DEFAULT NULL)
	RETURNS raster
	AS $$ SELECT st_reclass($1, ROW($2, $3, $4, $5)) $$
	LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_reclass(rast raster, reclassexpr text, pixeltype text)
	RETURNS raster
	AS $$ SELECT st_reclass($1, ROW(1, $2, $3, NULL)) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

-----------------------------------------------------------------------
-- ST_ColorMap
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION _st_colormap(
	rast raster, nband int,
	colormap text,
	method text DEFAULT 'INTERPOLATE'
)
	RETURNS raster
	AS '$libdir/rtpostgis-2.2', 'RASTER_colorMap'
	LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_colormap(
	rast raster, nband int DEFAULT 1,
	colormap text DEFAULT 'grayscale',
	method text DEFAULT 'INTERPOLATE'
)
	RETURNS raster
	AS $$
	DECLARE
		_ismap boolean;
		_colormap text;
		_element text[];
	BEGIN
		_ismap := TRUE;

		-- clean colormap to see what it is
		_colormap := split_part(colormap, E'\n', 1);
		_colormap := regexp_replace(_colormap, E':+', ' ', 'g');
		_colormap := regexp_replace(_colormap, E',+', ' ', 'g');
		_colormap := regexp_replace(_colormap, E'\\t+', ' ', 'g');
		_colormap := regexp_replace(_colormap, E' +', ' ', 'g');
		_element := regexp_split_to_array(_colormap, ' ');

		-- treat as colormap
		IF (array_length(_element, 1) > 1) THEN
			_colormap := colormap;
		-- treat as keyword
		ELSE
			method := 'INTERPOLATE';
			CASE lower(trim(both from _colormap))
				WHEN 'grayscale', 'greyscale' THEN
					_colormap := '
100%   0
  0% 254
  nv 255 
					';
				WHEN 'pseudocolor' THEN
					_colormap := '
100% 255   0   0 255
 50%   0 255   0 255
  0%   0   0 255 255
  nv   0   0   0   0
					';
				WHEN 'fire' THEN
					_colormap := '
  100% 243 255 221 255
93.75% 242 255 178 255
 87.5% 255 255 135 255
81.25% 255 228  96 255
   75% 255 187  53 255
68.75% 255 131   7 255
 62.5% 255  84   0 255
56.25% 255  42   0 255
   50% 255   0   0 255
43.75% 255  42   0 255
 37.5% 224  74   0 255
31.25% 183  91   0 255
   25% 140  93   0 255
18.75%  99  82   0 255
 12.5%  58  58   1 255
 6.25%  12  15   0 255
    0%   0   0   0 255
    nv   0   0   0   0
					';
				WHEN 'bluered' THEN
					_colormap := '
100.00% 165   0  33 255
 94.12% 216  21  47 255
 88.24% 247  39  53 255
 82.35% 255  61  61 255
 76.47% 255 120  86 255
 70.59% 255 172 117 255
 64.71% 255 214 153 255
 58.82% 255 241 188 255
 52.94% 255 255 234 255
 47.06% 234 255 255 255
 41.18% 188 249 255 255
 35.29% 153 234 255 255
 29.41% 117 211 255 255
 23.53%  86 176 255 255
 17.65%  61 135 255 255
 11.76%  40  87 255 255
  5.88%  24  28 247 255
  0.00%  36   0 216 255
     nv   0   0   0   0
					';
				ELSE
					RAISE EXCEPTION 'Unknown colormap keyword: %', colormap;
			END CASE;
		END IF;

		RETURN _st_colormap($1, $2, _colormap, $4);
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_colormap(
	rast raster,
	colormap text,
	method text DEFAULT 'INTERPOLATE'
)
	RETURNS RASTER
	AS $$ SELECT ST_ColorMap($1, 1, $2, $3) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

-----------------------------------------------------------------------
-- ST_FromGDALRaster
-----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION st_fromgdalraster(gdaldata bytea, srid integer DEFAULT NULL)
	RETURNS raster
	AS '$libdir/rtpostgis-2.2', 'RASTER_fromGDALRaster'
	LANGUAGE 'c' IMMUTABLE;

-----------------------------------------------------------------------
-- ST_AsGDALRaster and supporting functions
-----------------------------------------------------------------------
-- returns set of available and usable GDAL drivers
CREATE OR REPLACE FUNCTION st_gdaldrivers(OUT idx int, OUT short_name text, OUT long_name text, OUT create_options text)
  RETURNS SETOF record
	AS '$libdir/rtpostgis-2.2', 'RASTER_getGDALDrivers'
	LANGUAGE 'c' IMMUTABLE STRICT;

-- Cannot be strict as "options" and "srid" can be NULL
CREATE OR REPLACE FUNCTION st_asgdalraster(rast raster, format text, options text[] DEFAULT NULL, srid integer DEFAULT NULL)
	RETURNS bytea
	AS '$libdir/rtpostgis-2.2', 'RASTER_asGDALRaster'
	LANGUAGE 'c' IMMUTABLE;

-----------------------------------------------------------------------
-- ST_AsTIFF
-----------------------------------------------------------------------
-- Cannot be strict as "options" and "srid" can be NULL
CREATE OR REPLACE FUNCTION st_astiff(rast raster, options text[] DEFAULT NULL, srid integer DEFAULT NULL)
	RETURNS bytea
	AS $$
	DECLARE
		i int;
		num_bands int;
		nodata double precision;
		last_nodata double precision;
	BEGIN
		IF rast IS NULL THEN
			RETURN NULL;
		END IF;

		num_bands := st_numbands($1);

		-- TIFF only allows one NODATA value for ALL bands
		FOR i IN 1..num_bands LOOP
			nodata := st_bandnodatavalue($1, i);
			IF last_nodata IS NULL THEN
				last_nodata := nodata;
			ELSEIF nodata != last_nodata THEN
				RAISE NOTICE 'The TIFF format only permits one NODATA value for all bands.  The value used will be the last band with a NODATA value.';
			END IF;
		END LOOP;

		RETURN st_asgdalraster($1, 'GTiff', $2, $3);
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE;

-- Cannot be strict as "options" and "srid" can be NULL
CREATE OR REPLACE FUNCTION st_astiff(rast raster, nbands int[], options text[] DEFAULT NULL, srid integer DEFAULT NULL)
	RETURNS bytea
	AS $$ SELECT st_astiff(st_band($1, $2), $3, $4) $$
	LANGUAGE 'sql' IMMUTABLE;

-- Cannot be strict as "srid" can be NULL
CREATE OR REPLACE FUNCTION st_astiff(rast raster, compression text, srid integer DEFAULT NULL)
	RETURNS bytea
	AS $$
	DECLARE
		compression2 text;
		c_type text;
		c_level int;
		i int;
		num_bands int;
		options text[];
	BEGIN
		IF rast IS NULL THEN
			RETURN NULL;
		END IF;

		compression2 := trim(both from upper(compression));

		IF length(compression2) > 0 THEN
			-- JPEG
			IF position('JPEG' in compression2) != 0 THEN
				c_type := 'JPEG';
				c_level := substring(compression2 from '[0-9]+$');

				IF c_level IS NOT NULL THEN
					IF c_level > 100 THEN
						c_level := 100;
					ELSEIF c_level < 1 THEN
						c_level := 1;
					END IF;

					options := array_append(options, 'JPEG_QUALITY=' || c_level);
				END IF;

				-- per band pixel type check
				num_bands := st_numbands($1);
				FOR i IN 1..num_bands LOOP
					IF st_bandpixeltype($1, i) != '8BUI' THEN
						RAISE EXCEPTION 'The pixel type of band % in the raster is not 8BUI.  JPEG compression can only be used with the 8BUI pixel type.', i;
					END IF;
				END LOOP;

			-- DEFLATE
			ELSEIF position('DEFLATE' in compression2) != 0 THEN
				c_type := 'DEFLATE';
				c_level := substring(compression2 from '[0-9]+$');

				IF c_level IS NOT NULL THEN
					IF c_level > 9 THEN
						c_level := 9;
					ELSEIF c_level < 1 THEN
						c_level := 1;
					END IF;

					options := array_append(options, 'ZLEVEL=' || c_level);
				END IF;

			ELSE
				c_type := compression2;

				-- CCITT
				IF position('CCITT' in compression2) THEN
					-- per band pixel type check
					num_bands := st_numbands($1);
					FOR i IN 1..num_bands LOOP
						IF st_bandpixeltype($1, i) != '1BB' THEN
							RAISE EXCEPTION 'The pixel type of band % in the raster is not 1BB.  CCITT compression can only be used with the 1BB pixel type.', i;
						END IF;
					END LOOP;
				END IF;

			END IF;

			-- compression type check
			IF ARRAY[c_type] <@ ARRAY['JPEG', 'LZW', 'PACKBITS', 'DEFLATE', 'CCITTRLE', 'CCITTFAX3', 'CCITTFAX4', 'NONE'] THEN
				options := array_append(options, 'COMPRESS=' || c_type);
			ELSE
				RAISE NOTICE 'Unknown compression type: %.  The outputted TIFF will not be COMPRESSED.', c_type;
			END IF;
		END IF;

		RETURN st_astiff($1, options, $3);
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE;

-- Cannot be strict as "srid" can be NULL
CREATE OR REPLACE FUNCTION st_astiff(rast raster, nbands int[], compression text, srid integer DEFAULT NULL)
	RETURNS bytea
	AS $$ SELECT st_astiff(st_band($1, $2), $3, $4) $$
	LANGUAGE 'sql' IMMUTABLE;

-----------------------------------------------------------------------
-- ST_AsJPEG
-----------------------------------------------------------------------
-- Cannot be strict as "options" can be NULL
CREATE OR REPLACE FUNCTION st_asjpeg(rast raster, options text[] DEFAULT NULL)
	RETURNS bytea
	AS $$
	DECLARE
		rast2 raster;
		num_bands int;
		i int;
	BEGIN
		IF rast IS NULL THEN
			RETURN NULL;
		END IF;

		num_bands := st_numbands($1);

		-- JPEG allows 1 or 3 bands
		IF num_bands <> 1 AND num_bands <> 3 THEN
			RAISE NOTICE 'The JPEG format only permits one or three bands.  The first band will be used.';
			rast2 := st_band(rast, ARRAY[1]);
			num_bands := st_numbands(rast);
		ELSE
			rast2 := rast;
		END IF;

		-- JPEG only supports 8BUI pixeltype
		FOR i IN 1..num_bands LOOP
			IF st_bandpixeltype(rast, i) != '8BUI' THEN
				RAISE EXCEPTION 'The pixel type of band % in the raster is not 8BUI.  The JPEG format can only be used with the 8BUI pixel type.', i;
			END IF;
		END LOOP;

		RETURN st_asgdalraster(rast2, 'JPEG', $2, NULL);
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE;

-- Cannot be strict as "options" can be NULL
CREATE OR REPLACE FUNCTION st_asjpeg(rast raster, nbands int[], options text[] DEFAULT NULL)
	RETURNS bytea
	AS $$ SELECT st_asjpeg(st_band($1, $2), $3) $$
	LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_asjpeg(rast raster, nbands int[], quality int)
	RETURNS bytea
	AS $$
	DECLARE
		quality2 int;
		options text[];
	BEGIN
		IF quality IS NOT NULL THEN
			IF quality > 100 THEN
				quality2 := 100;
			ELSEIF quality < 10 THEN
				quality2 := 10;
			ELSE
				quality2 := quality;
			END IF;

			options := array_append(options, 'QUALITY=' || quality2);
		END IF;

		RETURN st_asjpeg(st_band($1, $2), options);
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE STRICT;

-- Cannot be strict as "options" can be NULL
CREATE OR REPLACE FUNCTION st_asjpeg(rast raster, nband int, options text[] DEFAULT NULL)
	RETURNS bytea
	AS $$ SELECT st_asjpeg(st_band($1, $2), $3) $$
	LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_asjpeg(rast raster, nband int, quality int)
	RETURNS bytea
	AS $$ SELECT st_asjpeg($1, ARRAY[$2], $3) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

-----------------------------------------------------------------------
-- ST_AsPNG
-----------------------------------------------------------------------
-- Cannot be strict as "options" can be NULL
CREATE OR REPLACE FUNCTION st_aspng(rast raster, options text[] DEFAULT NULL)
	RETURNS bytea
	AS $$
	DECLARE
		rast2 raster;
		num_bands int;
		i int;
		pt text;
	BEGIN
		IF rast IS NULL THEN
			RETURN NULL;
		END IF;

		num_bands := st_numbands($1);

		-- PNG allows 1, 3 or 4 bands
		IF num_bands <> 1 AND num_bands <> 3 AND num_bands <> 4 THEN
			RAISE NOTICE 'The PNG format only permits one, three or four bands.  The first band will be used.';
			rast2 := st_band($1, ARRAY[1]);
			num_bands := st_numbands(rast2);
		ELSE
			rast2 := rast;
		END IF;

		-- PNG only supports 8BUI and 16BUI pixeltype
		FOR i IN 1..num_bands LOOP
			pt = st_bandpixeltype(rast, i);
			IF pt != '8BUI' AND pt != '16BUI' THEN
				RAISE EXCEPTION 'The pixel type of band % in the raster is not 8BUI or 16BUI.  The PNG format can only be used with 8BUI and 16BUI pixel types.', i;
			END IF;
		END LOOP;

		RETURN st_asgdalraster(rast2, 'PNG', $2, NULL);
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE;

-- Cannot be strict as "options" can be NULL
CREATE OR REPLACE FUNCTION st_aspng(rast raster, nbands int[], options text[] DEFAULT NULL)
	RETURNS bytea
	AS $$ SELECT st_aspng(st_band($1, $2), $3) $$
	LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_aspng(rast raster, nbands int[], compression int)
	RETURNS bytea
	AS $$
	DECLARE
		compression2 int;
		options text[];
	BEGIN
		IF compression IS NOT NULL THEN
			IF compression > 9 THEN
				compression2 := 9;
			ELSEIF compression < 1 THEN
				compression2 := 1;
			ELSE
				compression2 := compression;
			END IF;

			options := array_append(options, 'ZLEVEL=' || compression2);
		END IF;

		RETURN st_aspng(st_band($1, $2), options);
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_aspng(rast raster, nband int, options text[] DEFAULT NULL)
	RETURNS bytea
	AS $$ SELECT st_aspng(st_band($1, $2), $3) $$
	LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_aspng(rast raster, nband int, compression int)
	RETURNS bytea
	AS $$ SELECT st_aspng($1, ARRAY[$2], $3) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

-----------------------------------------------------------------------
-- ST_AsRaster
-----------------------------------------------------------------------
-- None of the ST_AsRaster can be strict as some parameters can be NULL
CREATE OR REPLACE FUNCTION _st_asraster(
	geom geometry,
	scalex double precision DEFAULT 0, scaley double precision DEFAULT 0,
	width integer DEFAULT 0, height integer DEFAULT 0,
	pixeltype text[] DEFAULT ARRAY['8BUI']::text[],
	value double precision[] DEFAULT ARRAY[1]::double precision[],
	nodataval double precision[] DEFAULT ARRAY[0]::double precision[],
	upperleftx double precision DEFAULT NULL, upperlefty double precision DEFAULT NULL,
	gridx double precision DEFAULT NULL, gridy double precision DEFAULT NULL,
	skewx double precision DEFAULT 0, skewy double precision DEFAULT 0,
	touched boolean DEFAULT FALSE
)
	RETURNS raster
	AS '$libdir/rtpostgis-2.2', 'RASTER_asRaster'
	LANGUAGE 'c' STABLE;

CREATE OR REPLACE FUNCTION st_asraster(
	geom geometry,
	scalex double precision, scaley double precision,
	gridx double precision DEFAULT NULL, gridy double precision DEFAULT NULL,
	pixeltype text[] DEFAULT ARRAY['8BUI']::text[],
	value double precision[] DEFAULT ARRAY[1]::double precision[],
	nodataval double precision[] DEFAULT ARRAY[0]::double precision[],
	skewx double precision DEFAULT 0, skewy double precision DEFAULT 0,
	touched boolean DEFAULT FALSE
)
	RETURNS raster
	AS $$ SELECT _st_asraster($1, $2, $3, NULL, NULL, $6, $7, $8, NULL, NULL, $4, $5, $9, $10, $11) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_asraster(
	geom geometry,
	scalex double precision, scaley double precision,
	pixeltype text[],
	value double precision[] DEFAULT ARRAY[1]::double precision[],
	nodataval double precision[] DEFAULT ARRAY[0]::double precision[],
	upperleftx double precision DEFAULT NULL, upperlefty double precision DEFAULT NULL,
	skewx double precision DEFAULT 0, skewy double precision DEFAULT 0,
	touched boolean DEFAULT FALSE
)
	RETURNS raster
	AS $$ SELECT _st_asraster($1, $2, $3, NULL, NULL, $4, $5, $6, $7, $8, NULL, NULL,	$9, $10, $11) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_asraster(
	geom geometry,
	width integer, height integer,
	gridx double precision DEFAULT NULL, gridy double precision DEFAULT NULL,
	pixeltype text[] DEFAULT ARRAY['8BUI']::text[],
	value double precision[] DEFAULT ARRAY[1]::double precision[],
	nodataval double precision[] DEFAULT ARRAY[0]::double precision[],
	skewx double precision DEFAULT 0, skewy double precision DEFAULT 0,
	touched boolean DEFAULT FALSE
)
	RETURNS raster
	AS $$ SELECT _st_asraster($1, NULL, NULL, $2, $3, $6, $7, $8, NULL, NULL, $4, $5, $9, $10, $11) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_asraster(
	geom geometry,
	width integer, height integer,
	pixeltype text[],
	value double precision[] DEFAULT ARRAY[1]::double precision[],
	nodataval double precision[] DEFAULT ARRAY[0]::double precision[],
	upperleftx double precision DEFAULT NULL, upperlefty double precision DEFAULT NULL,
	skewx double precision DEFAULT 0, skewy double precision DEFAULT 0,
	touched boolean DEFAULT FALSE
)
	RETURNS raster
	AS $$ SELECT _st_asraster($1, NULL, NULL, $2, $3, $4, $5, $6, $7, $8, NULL, NULL,	$9, $10, $11) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_asraster(
	geom geometry,
	scalex double precision, scaley double precision,
	gridx double precision, gridy double precision,
	pixeltype text,
	value double precision DEFAULT 1,
	nodataval double precision DEFAULT 0,
	skewx double precision DEFAULT 0, skewy double precision DEFAULT 0,
	touched boolean DEFAULT FALSE
)
	RETURNS raster
	AS $$ SELECT _st_asraster($1, $2, $3, NULL, NULL, ARRAY[$6]::text[], ARRAY[$7]::double precision[], ARRAY[$8]::double precision[], NULL, NULL, $4, $5, $9, $10, $11) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_asraster(
	geom geometry,
	scalex double precision, scaley double precision,
	pixeltype text,
	value double precision DEFAULT 1,
	nodataval double precision DEFAULT 0,
	upperleftx double precision DEFAULT NULL, upperlefty double precision DEFAULT NULL,
	skewx double precision DEFAULT 0, skewy double precision DEFAULT 0,
	touched boolean DEFAULT FALSE
)
	RETURNS raster
	AS $$ SELECT _st_asraster($1, $2, $3, NULL, NULL, ARRAY[$4]::text[], ARRAY[$5]::double precision[], ARRAY[$6]::double precision[], $7, $8, NULL, NULL, $9, $10, $11) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_asraster(
	geom geometry,
	width integer, height integer,
	gridx double precision, gridy double precision,
	pixeltype text,
	value double precision DEFAULT 1,
	nodataval double precision DEFAULT 0,
	skewx double precision DEFAULT 0, skewy double precision DEFAULT 0,
	touched boolean DEFAULT FALSE
)
	RETURNS raster
	AS $$ SELECT _st_asraster($1, NULL, NULL, $2, $3, ARRAY[$6]::text[], ARRAY[$7]::double precision[], ARRAY[$8]::double precision[], NULL, NULL, $4, $5, $9, $10, $11) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_asraster(
	geom geometry,
	width integer, height integer,
	pixeltype text,
	value double precision DEFAULT 1,
	nodataval double precision DEFAULT 0,
	upperleftx double precision DEFAULT NULL, upperlefty double precision DEFAULT NULL,
	skewx double precision DEFAULT 0, skewy double precision DEFAULT 0,
	touched boolean DEFAULT FALSE
)
	RETURNS raster
	AS $$ SELECT _st_asraster($1, NULL, NULL, $2, $3, ARRAY[$4]::text[], ARRAY[$5]::double precision[], ARRAY[$6]::double precision[], $7, $8, NULL, NULL,$9, $10, $11) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_asraster(
	geom geometry,
	ref raster,
	pixeltype text[] DEFAULT ARRAY['8BUI']::text[],
	value double precision[] DEFAULT ARRAY[1]::double precision[],
	nodataval double precision[] DEFAULT ARRAY[0]::double precision[],
	touched boolean DEFAULT FALSE
)
	RETURNS raster
	AS $$
	DECLARE
		g geometry;
		g_srid integer;

		ul_x double precision;
		ul_y double precision;
		scale_x double precision;
		scale_y double precision;
		skew_x double precision;
		skew_y double precision;
		sr_id integer;
	BEGIN
		SELECT upperleftx, upperlefty, scalex, scaley, skewx, skewy, srid INTO ul_x, ul_y, scale_x, scale_y, skew_x, skew_y, sr_id FROM ST_Metadata(ref);
		--RAISE NOTICE '%, %, %, %, %, %, %', ul_x, ul_y, scale_x, scale_y, skew_x, skew_y, sr_id;

		-- geometry and raster has different SRID
		g_srid := ST_SRID(geom);
		IF g_srid != sr_id THEN
			RAISE NOTICE 'The geometry''s SRID (%) is not the same as the raster''s SRID (%).  The geometry will be transformed to the raster''s projection', g_srid, sr_id;
			g := ST_Transform(geom, sr_id);
		ELSE
			g := geom;
		END IF;

		RETURN _st_asraster(g, scale_x, scale_y, NULL, NULL, $3, $4, $5, NULL, NULL, ul_x, ul_y, skew_x, skew_y, $6);
	END;
	$$ LANGUAGE 'plpgsql' STABLE;

CREATE OR REPLACE FUNCTION st_asraster(
	geom geometry,
	ref raster,
	pixeltype text,
	value double precision DEFAULT 1,
	nodataval double precision DEFAULT 0,
	touched boolean DEFAULT FALSE
)
	RETURNS raster
	AS $$ SELECT st_asraster($1, $2, ARRAY[$3]::text[], ARRAY[$4]::double precision[], ARRAY[$5]::double precision[], $6) $$
	LANGUAGE 'sql' STABLE;

-----------------------------------------------------------------------
-- ST_GDALWarp
-- has no public functions
-----------------------------------------------------------------------
-- cannot be strict as almost all parameters can be NULL
CREATE OR REPLACE FUNCTION _st_gdalwarp(
	rast raster,
	algorithm text DEFAULT 'NearestNeighbour', maxerr double precision DEFAULT 0.125,
	srid integer DEFAULT NULL,
	scalex double precision DEFAULT 0, scaley double precision DEFAULT 0,
	gridx double precision DEFAULT NULL, gridy double precision DEFAULT NULL,
	skewx double precision DEFAULT 0, skewy double precision DEFAULT 0,
	width integer DEFAULT NULL, height integer DEFAULT NULL
)
	RETURNS raster
	AS '$libdir/rtpostgis-2.2', 'RASTER_GDALWarp'
	LANGUAGE 'c' STABLE;

-----------------------------------------------------------------------
-- ST_Resample
-----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION st_resample(
	rast raster,
	scalex double precision DEFAULT 0, scaley double precision DEFAULT 0,
	gridx double precision DEFAULT NULL, gridy double precision DEFAULT NULL,
	skewx double precision DEFAULT 0, skewy double precision DEFAULT 0,
	algorithm text DEFAULT 'NearestNeighbour', maxerr double precision DEFAULT 0.125
)
	RETURNS raster
	AS $$ SELECT _st_gdalwarp($1, $8,	$9, NULL, $2, $3, $4, $5, $6, $7) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_resample(
	rast raster,
	width integer, height integer,
	gridx double precision DEFAULT NULL, gridy double precision DEFAULT NULL,
	skewx double precision DEFAULT 0, skewy double precision DEFAULT 0,
	algorithm text DEFAULT 'NearestNeighbour', maxerr double precision DEFAULT 0.125
)
	RETURNS raster
	AS $$ SELECT _st_gdalwarp($1, $8,	$9, NULL, NULL, NULL, $4, $5, $6, $7, $2, $3) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_resample(
	rast raster,
	ref raster,
	algorithm text DEFAULT 'NearestNeighbour',
	maxerr double precision DEFAULT 0.125,
	usescale boolean DEFAULT TRUE
)
	RETURNS raster
	AS $$
	DECLARE
		rastsrid int;

		_srid int;
		_dimx int;
		_dimy int;
		_scalex double precision;
		_scaley double precision;
		_gridx double precision;
		_gridy double precision;
		_skewx double precision;
		_skewy double precision;
	BEGIN
		SELECT srid, width, height, scalex, scaley, upperleftx, upperlefty, skewx, skewy INTO _srid, _dimx, _dimy, _scalex, _scaley, _gridx, _gridy, _skewx, _skewy FROM st_metadata($2);

		rastsrid := ST_SRID($1);

		-- both rasters must have the same SRID
		IF (rastsrid != _srid) THEN
			RAISE EXCEPTION 'The raster to be resampled has a different SRID from the reference raster';
			RETURN NULL;
		END IF;

		IF usescale IS TRUE THEN
			_dimx := NULL;
			_dimy := NULL;
		ELSE
			_scalex := NULL;
			_scaley := NULL;
		END IF;

		RETURN _st_gdalwarp($1, $3, $4, NULL, _scalex, _scaley, _gridx, _gridy, _skewx, _skewy, _dimx, _dimy);
	END;
	$$ LANGUAGE 'plpgsql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_resample(
	rast raster,
	ref raster,
	usescale boolean,
	algorithm text DEFAULT 'NearestNeighbour',
	maxerr double precision DEFAULT 0.125
)
	RETURNS raster
	AS $$ SELECT st_resample($1, $2, $4, $5, $3) $$
	LANGUAGE 'sql' STABLE STRICT;

-----------------------------------------------------------------------
-- ST_Transform
-----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION st_transform(rast raster, srid integer, algorithm text DEFAULT 'NearestNeighbour', maxerr double precision DEFAULT 0.125, scalex double precision DEFAULT 0, scaley double precision DEFAULT 0)
	RETURNS raster
	AS $$ SELECT _st_gdalwarp($1, $3, $4, $2, $5, $6) $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_transform(rast raster, srid integer, scalex double precision, scaley double precision, algorithm text DEFAULT 'NearestNeighbour', maxerr double precision DEFAULT 0.125)
	RETURNS raster
	AS $$ SELECT _st_gdalwarp($1, $5, $6, $2, $3, $4) $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_transform(rast raster, srid integer, scalexy double precision, algorithm text DEFAULT 'NearestNeighbour', maxerr double precision DEFAULT 0.125)
	RETURNS raster
	AS $$ SELECT _st_gdalwarp($1, $4, $5, $2, $3, $3) $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_transform(
	rast raster, 
	alignto raster,
	algorithm text DEFAULT 'NearestNeighbour', maxerr double precision DEFAULT 0.125
)
	RETURNS raster
	AS $$
	DECLARE
		_srid integer;
		_scalex double precision;
		_scaley double precision;
		_gridx double precision;
		_gridy double precision;
		_skewx double precision;
		_skewy double precision;
	BEGIN
		SELECT srid, scalex, scaley, upperleftx, upperlefty, skewx, skewy INTO _srid, _scalex, _scaley, _gridx, _gridy, _skewx, _skewy FROM st_metadata($2);

		RETURN _st_gdalwarp($1, $3, $4, _srid, _scalex, _scaley, _gridx, _gridy, _skewx, _skewy, NULL, NULL);
	END;
	$$ LANGUAGE 'plpgsql' STABLE STRICT;

-----------------------------------------------------------------------
-- ST_Rescale
-----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION st_rescale(rast raster, scalex double precision, scaley double precision, algorithm text DEFAULT 'NearestNeighbour', maxerr double precision DEFAULT 0.125)
	RETURNS raster
	AS $$ SELECT _st_gdalwarp($1, $4, $5, NULL, $2, $3) $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_rescale(rast raster, scalexy double precision, algorithm text DEFAULT 'NearestNeighbour', maxerr double precision DEFAULT 0.125)
	RETURNS raster
	AS $$ SELECT _st_gdalwarp($1, $3, $4, NULL, $2, $2) $$
	LANGUAGE 'sql' STABLE STRICT;

-----------------------------------------------------------------------
-- ST_Reskew
-----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION st_reskew(rast raster, skewx double precision, skewy double precision, algorithm text DEFAULT 'NearestNeighbour', maxerr double precision DEFAULT 0.125)
	RETURNS raster
	AS $$ SELECT _st_gdalwarp($1, $4, $5, NULL, 0, 0, NULL, NULL, $2, $3) $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_reskew(rast raster, skewxy double precision, algorithm text DEFAULT 'NearestNeighbour', maxerr double precision DEFAULT 0.125)
	RETURNS raster
	AS $$ SELECT _st_gdalwarp($1, $3, $4, NULL, 0, 0, NULL, NULL, $2, $2) $$
	LANGUAGE 'sql' STABLE STRICT;

-----------------------------------------------------------------------
-- ST_SnapToGrid
-----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION st_snaptogrid(
	rast raster,
	gridx double precision, gridy double precision,
	algorithm text DEFAULT 'NearestNeighbour', maxerr double precision DEFAULT 0.125,
	scalex double precision DEFAULT 0, scaley double precision DEFAULT 0
)
	RETURNS raster
	AS $$ SELECT _st_gdalwarp($1, $4, $5, NULL, $6, $7, $2, $3) $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_snaptogrid(
	rast raster,
	gridx double precision, gridy double precision,
	scalex double precision, scaley double precision,
	algorithm text DEFAULT 'NearestNeighbour', maxerr double precision DEFAULT 0.125
)
	RETURNS raster
	AS $$ SELECT _st_gdalwarp($1, $6, $7, NULL, $4, $5, $2, $3) $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_snaptogrid(
	rast raster,
	gridx double precision, gridy double precision,
	scalexy double precision,
	algorithm text DEFAULT 'NearestNeighbour', maxerr double precision DEFAULT 0.125
)
	RETURNS raster
	AS $$ SELECT _st_gdalwarp($1, $5, $6, NULL, $4, $4, $2, $3) $$
	LANGUAGE 'sql' STABLE STRICT;

-----------------------------------------------------------------------
-- ST_Resize
-----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION st_resize(
	rast raster,
	width text, height text,
	algorithm text DEFAULT 'NearestNeighbour', maxerr double precision DEFAULT 0.125
)
	RETURNS raster
	AS $$
	DECLARE
		i integer;

		wh text[2];

		whi integer[2];
		whd double precision[2];

		_width integer;
		_height integer;
	BEGIN
		wh[1] := trim(both from $2);
		wh[2] := trim(both from $3);

		-- see if width and height are percentages
		FOR i IN 1..2 LOOP
			IF position('%' in wh[i]) > 0 THEN
				BEGIN
					wh[i] := (regexp_matches(wh[i], E'^(\\d*.?\\d*)%{1}$'))[1];
					IF length(wh[i]) < 1 THEN
						RAISE invalid_parameter_value;
					END IF;

					whd[i] := wh[i]::double precision * 0.01;
				EXCEPTION WHEN OTHERS THEN -- TODO: WHEN invalid_parameter_value !
					RAISE EXCEPTION 'Invalid percentage value provided for width/height';
					RETURN NULL;
				END;
			ELSE
				BEGIN
					whi[i] := abs(wh[i]::integer);
				EXCEPTION WHEN OTHERS THEN -- TODO: only handle appropriate SQLSTATE
					RAISE EXCEPTION 'Non-integer value provided for width/height';
					RETURN NULL;
				END;
			END IF;
		END LOOP;

		IF whd[1] IS NOT NULL OR whd[2] IS NOT NULL THEN
			SELECT foo.width, foo.height INTO _width, _height FROM ST_Metadata($1) AS foo;

			IF whd[1] IS NOT NULL THEN
				whi[1] := round(_width::double precision * whd[1])::integer;
			END IF;

			IF whd[2] IS NOT NULL THEN
				whi[2] := round(_height::double precision * whd[2])::integer;
			END IF;

		END IF;

		-- should NEVER be here
		IF whi[1] IS NULL OR whi[2] IS NULL THEN
			RAISE EXCEPTION 'Unable to determine appropriate width or height';
			RETURN NULL;
		END IF;

		FOR i IN 1..2 LOOP
			IF whi[i] < 1 THEN
				whi[i] = 1;
			END IF;
		END LOOP;

		RETURN _st_gdalwarp(
			$1,
			$4, $5,
			NULL,
			NULL, NULL,
			NULL, NULL,
			NULL, NULL,
			whi[1], whi[2]
		);
	END;
	$$ LANGUAGE 'plpgsql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_resize(
	rast raster,
	width integer, height integer,
	algorithm text DEFAULT 'NearestNeighbour', maxerr double precision DEFAULT 0.125
)
	RETURNS raster
	AS $$ SELECT _st_gdalwarp($1, $4, $5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, abs($2), abs($3)) $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION st_resize(
	rast raster,
	percentwidth double precision, percentheight double precision,
	algorithm text DEFAULT 'NearestNeighbour', maxerr double precision DEFAULT 0.125
)
	RETURNS raster
	AS $$
	DECLARE
		_width integer;
		_height integer;
	BEGIN
		-- range check
		IF $2 <= 0. OR $2 > 1. OR $3 <= 0. OR $3 > 1. THEN
			RAISE EXCEPTION 'Percentages must be a value greater than zero and less than or equal to one, e.g. 0.5 for 50%%';
		END IF;

		SELECT width, height INTO _width, _height FROM ST_Metadata($1);

		_width := round(_width::double precision * $2)::integer;
		_height:= round(_height::double precision * $3)::integer;

		IF _width < 1 THEN
			_width := 1;
		END IF;
		IF _height < 1 THEN
			_height := 1;
		END IF;

		RETURN _st_gdalwarp(
			$1,
			$4, $5,
			NULL,
			NULL, NULL,
			NULL, NULL,
			NULL, NULL,
			_width, _height
		);
	END;
	$$ LANGUAGE 'plpgsql' STABLE STRICT;

-----------------------------------------------------------------------
-- One Raster ST_MapAlgebra
-----------------------------------------------------------------------
-- This function can not be STRICT, because nodataval can be NULL
-- or pixeltype can not be determined (could be st_bandpixeltype(raster, band) though)
CREATE OR REPLACE FUNCTION st_mapalgebraexpr(rast raster, band integer, pixeltype text,
        expression text, nodataval double precision DEFAULT NULL)
    RETURNS raster
    AS '$libdir/rtpostgis-2.2', 'RASTER_mapAlgebraExpr'
    LANGUAGE 'c' IMMUTABLE;

-- This function can not be STRICT, because nodataval can be NULL
-- or pixeltype can not be determined (could be st_bandpixeltype(raster, band) though)
CREATE OR REPLACE FUNCTION st_mapalgebraexpr(rast raster, pixeltype text, expression text,
        nodataval double precision DEFAULT NULL)
    RETURNS raster
    AS $$ SELECT st_mapalgebraexpr($1, 1, $2, $3, $4) $$
    LANGUAGE 'sql';

-- All arguments supplied, use the C implementation.
CREATE OR REPLACE FUNCTION st_mapalgebrafct(rast raster, band integer,
        pixeltype text, onerastuserfunc regprocedure, variadic args text[])
    RETURNS raster
    AS '$libdir/rtpostgis-2.2', 'RASTER_mapAlgebraFct'
    LANGUAGE 'c' IMMUTABLE;

-- Variant 1: missing user args
CREATE OR REPLACE FUNCTION st_mapalgebrafct(rast raster, band integer,
        pixeltype text, onerastuserfunc regprocedure)
    RETURNS raster
    AS $$ SELECT st_mapalgebrafct($1, $2, $3, $4, NULL) $$
    LANGUAGE 'sql';

-- Variant 2: missing pixeltype; default to pixeltype of rast
CREATE OR REPLACE FUNCTION st_mapalgebrafct(rast raster, band integer,
        onerastuserfunc regprocedure, variadic args text[])
    RETURNS raster
    AS $$ SELECT st_mapalgebrafct($1, $2, NULL, $3, VARIADIC $4) $$
    LANGUAGE 'sql';

-- Variant 3: missing pixeltype and user args; default to pixeltype of rast
CREATE OR REPLACE FUNCTION st_mapalgebrafct(rast raster, band integer,
        onerastuserfunc regprocedure)
    RETURNS raster
    AS $$ SELECT st_mapalgebrafct($1, $2, NULL, $3, NULL) $$
    LANGUAGE 'sql';

-- Variant 4: missing band; default to band 1
CREATE OR REPLACE FUNCTION st_mapalgebrafct(rast raster, pixeltype text,
        onerastuserfunc regprocedure, variadic args text[])
    RETURNS raster
    AS $$ SELECT st_mapalgebrafct($1, 1, $2, $3, VARIADIC $4) $$
    LANGUAGE 'sql';

-- Variant 5: missing band and user args; default to band 1
CREATE OR REPLACE FUNCTION st_mapalgebrafct(rast raster, pixeltype text,
        onerastuserfunc regprocedure)
    RETURNS raster
    AS $$ SELECT st_mapalgebrafct($1, 1, $2, $3, NULL) $$
    LANGUAGE 'sql';

-- Variant 6: missing band, and pixeltype; default to band 1, pixeltype of rast.
CREATE OR REPLACE FUNCTION st_mapalgebrafct(rast raster, onerastuserfunc regprocedure,
        variadic args text[])
    RETURNS raster
    AS $$ SELECT st_mapalgebrafct($1, 1, NULL, $2, VARIADIC $3) $$
    LANGUAGE 'sql';

-- Variant 7: missing band, pixeltype, and user args; default to band 1, pixeltype of rast.
CREATE OR REPLACE FUNCTION st_mapalgebrafct(rast raster, onerastuserfunc regprocedure)
    RETURNS raster
    AS $$ SELECT st_mapalgebrafct($1, 1, NULL, $2, NULL) $$
    LANGUAGE 'sql';

-----------------------------------------------------------------------
-- Two Raster ST_MapAlgebra
-----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION st_mapalgebraexpr(
	rast1 raster, band1 integer,
	rast2 raster, band2 integer,
	expression text,
	pixeltype text DEFAULT NULL, extenttype text DEFAULT 'INTERSECTION',
	nodata1expr text DEFAULT NULL, nodata2expr text DEFAULT NULL,
	nodatanodataval double precision DEFAULT NULL
)
	RETURNS raster
	AS '$libdir/rtpostgis-2.2', 'RASTER_mapAlgebra2'
	LANGUAGE 'c' STABLE;

CREATE OR REPLACE FUNCTION st_mapalgebraexpr(
	rast1 raster,
	rast2 raster,
	expression text,
	pixeltype text DEFAULT NULL, extenttype text DEFAULT 'INTERSECTION',
	nodata1expr text DEFAULT NULL, nodata2expr text DEFAULT NULL,
	nodatanodataval double precision DEFAULT NULL
)
	RETURNS raster
	AS $$ SELECT st_mapalgebraexpr($1, 1, $2, 1, $3, $4, $5, $6, $7, $8) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_mapalgebrafct(
	rast1 raster, band1 integer,
	rast2 raster, band2 integer,
	tworastuserfunc regprocedure,
	pixeltype text DEFAULT NULL, extenttype text DEFAULT 'INTERSECTION',
	VARIADIC userargs text[] DEFAULT NULL
)
	RETURNS raster
	AS '$libdir/rtpostgis-2.2', 'RASTER_mapAlgebra2'
	LANGUAGE 'c' STABLE;

CREATE OR REPLACE FUNCTION st_mapalgebrafct(
	rast1 raster,
	rast2 raster,
	tworastuserfunc regprocedure,
	pixeltype text DEFAULT NULL, extenttype text DEFAULT 'INTERSECTION',
	VARIADIC userargs text[] DEFAULT NULL
)
	RETURNS raster
	AS $$ SELECT st_mapalgebrafct($1, 1, $2, 1, $3, $4, $5, VARIADIC $6) $$
	LANGUAGE 'sql' STABLE;

-----------------------------------------------------------------------
-- Neighborhood single raster map algebra
-----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION st_mapalgebrafctngb(
    rast raster,
    band integer,
    pixeltype text,
    ngbwidth integer,
    ngbheight integer,
    onerastngbuserfunc regprocedure,
    nodatamode text,
    variadic args text[]
)
    RETURNS raster
    AS '$libdir/rtpostgis-2.2', 'RASTER_mapAlgebraFctNgb'
    LANGUAGE 'c' IMMUTABLE;

-----------------------------------------------------------------------
-- ST_MapAlgebraFctNgb() Neighborhood MapAlgebra processing functions.
-----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION st_max4ma(matrix float[][], nodatamode text, variadic args text[])
    RETURNS float AS
    $$
    DECLARE
        _matrix float[][];
        max float;
    BEGIN
        _matrix := matrix;
        max := '-Infinity'::float;
        FOR x in array_lower(_matrix, 1)..array_upper(_matrix, 1) LOOP
            FOR y in array_lower(_matrix, 2)..array_upper(_matrix, 2) LOOP
                IF _matrix[x][y] IS NULL THEN
                    IF NOT nodatamode = 'ignore' THEN
                        _matrix[x][y] := nodatamode::float;
                    END IF;
                END IF;
                IF max < _matrix[x][y] THEN
                    max := _matrix[x][y];
                END IF;
            END LOOP;
        END LOOP;
        RETURN max;
    END;
    $$
    LANGUAGE 'plpgsql' IMMUTABLE;


CREATE OR REPLACE FUNCTION st_min4ma(matrix float[][], nodatamode text, variadic args text[])
    RETURNS float AS
    $$
    DECLARE
        _matrix float[][];
        min float;
    BEGIN
        _matrix := matrix;
        min := 'Infinity'::float;
        FOR x in array_lower(_matrix, 1)..array_upper(_matrix, 1) LOOP
            FOR y in array_lower(_matrix, 2)..array_upper(_matrix, 2) LOOP
                IF _matrix[x][y] IS NULL THEN
                    IF NOT nodatamode = 'ignore' THEN
                        _matrix[x][y] := nodatamode::float;
                    END IF;
                END IF;
                IF min > _matrix[x][y] THEN
                    min := _matrix[x][y];
                END IF;
            END LOOP;
        END LOOP;
        RETURN min;
    END;
    $$
    LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_sum4ma(matrix float[][], nodatamode text, variadic args text[])
    RETURNS float AS
    $$
    DECLARE
        _matrix float[][];
        sum float;
    BEGIN
        _matrix := matrix;
        sum := 0;
        FOR x in array_lower(matrix, 1)..array_upper(matrix, 1) LOOP
            FOR y in array_lower(matrix, 2)..array_upper(matrix, 2) LOOP
                IF _matrix[x][y] IS NULL THEN
                    IF nodatamode = 'ignore' THEN
                        _matrix[x][y] := 0;
                    ELSE
                        _matrix[x][y] := nodatamode::float;
                    END IF;
                END IF;
                sum := sum + _matrix[x][y];
            END LOOP;
        END LOOP;
        RETURN sum;
    END;
    $$
    LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_mean4ma(matrix float[][], nodatamode text, variadic args text[])
    RETURNS float AS
    $$
    DECLARE
        _matrix float[][];
        sum float;
        count float;
    BEGIN
        _matrix := matrix;
        sum := 0;
        count := 0;
        FOR x in array_lower(matrix, 1)..array_upper(matrix, 1) LOOP
            FOR y in array_lower(matrix, 2)..array_upper(matrix, 2) LOOP
                IF _matrix[x][y] IS NULL THEN
                    IF nodatamode = 'ignore' THEN
                        _matrix[x][y] := 0;
                    ELSE
                        _matrix[x][y] := nodatamode::float;
                        count := count + 1;
                    END IF;
                ELSE
                    count := count + 1;
                END IF;
                sum := sum + _matrix[x][y];
            END LOOP;
        END LOOP;
        IF count = 0 THEN
            RETURN NULL;
        END IF;
        RETURN sum / count;
    END;
    $$
    LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_range4ma(matrix float[][], nodatamode text, variadic args text[])
    RETURNS float AS
    $$
    DECLARE
        _matrix float[][];
        min float;
        max float;
    BEGIN
        _matrix := matrix;
        min := 'Infinity'::float;
        max := '-Infinity'::float;
        FOR x in array_lower(matrix, 1)..array_upper(matrix, 1) LOOP
            FOR y in array_lower(matrix, 2)..array_upper(matrix, 2) LOOP
                IF _matrix[x][y] IS NULL THEN
                    IF NOT nodatamode = 'ignore' THEN
                        _matrix[x][y] := nodatamode::float;
                    END IF;
                END IF;
                IF min > _matrix[x][y] THEN
                    min = _matrix[x][y];
                END IF;
                IF max < _matrix[x][y] THEN
                    max = _matrix[x][y];
                END IF;
            END LOOP;
        END LOOP;
        IF max = '-Infinity'::float OR min = 'Infinity'::float THEN
            RETURN NULL;
        END IF;
        RETURN max - min;
    END;
    $$
    LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_distinct4ma(matrix float[][], nodatamode TEXT, VARIADIC args TEXT[])
    RETURNS float AS
    $$ SELECT COUNT(DISTINCT unnest)::float FROM unnest($1) $$
    LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_stddev4ma(matrix float[][], nodatamode TEXT, VARIADIC args TEXT[])
    RETURNS float AS
    $$ SELECT stddev(unnest) FROM unnest($1) $$
    LANGUAGE 'sql' IMMUTABLE;

-----------------------------------------------------------------------
-- n-Raster ST_MapAlgebra
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION _st_mapalgebra(
	rastbandargset rastbandarg[],
	callbackfunc regprocedure,
	pixeltype text DEFAULT NULL,
	distancex integer DEFAULT 0, distancey integer DEFAULT 0,
	extenttype text DEFAULT 'INTERSECTION', customextent raster DEFAULT NULL,
	mask double precision[][] DEFAULT NULL, weighted boolean DEFAULT NULL,
	VARIADIC userargs text[] DEFAULT NULL
)
	RETURNS raster
	AS '$libdir/rtpostgis-2.2', 'RASTER_nMapAlgebra'
	LANGUAGE 'c' STABLE;



CREATE OR REPLACE FUNCTION st_mapalgebra(
	rastbandargset rastbandarg[],
	callbackfunc regprocedure,
	pixeltype text DEFAULT NULL,
	extenttype text DEFAULT 'INTERSECTION', customextent raster DEFAULT NULL,
	distancex integer DEFAULT 0, distancey integer DEFAULT 0,
	VARIADIC userargs text[] DEFAULT NULL
)
	RETURNS raster
	AS $$ SELECT _ST_MapAlgebra($1, $2, $3, $6, $7, $4, $5,NULL::double precision [],NULL::boolean, VARIADIC $8) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_mapalgebra(
	rast raster, nband int[],
	callbackfunc regprocedure,
	pixeltype text DEFAULT NULL,
	extenttype text DEFAULT 'FIRST', customextent raster DEFAULT NULL,
	distancex integer DEFAULT 0, distancey integer DEFAULT 0,
	VARIADIC userargs text[] DEFAULT NULL
)
	RETURNS raster
	AS $$
	DECLARE
		x int;
		argset rastbandarg[];
	BEGIN
		IF $2 IS NULL OR array_ndims($2) < 1 OR array_length($2, 1) < 1 THEN
			RAISE EXCEPTION 'Populated 1D array must be provided for nband';
			RETURN NULL;
		END IF;

		FOR x IN array_lower($2, 1)..array_upper($2, 1) LOOP
			IF $2[x] IS NULL THEN
				CONTINUE;
			END IF;

			argset := argset || ROW($1, $2[x])::rastbandarg;
		END LOOP;

		IF array_length(argset, 1) < 1 THEN
			RAISE EXCEPTION 'Populated 1D array must be provided for nband';
			RETURN NULL;
		END IF;

		RETURN _ST_MapAlgebra(argset, $3, $4, $7, $8, $5, $6,NULL::double precision [],NULL::boolean, VARIADIC $9);
	END;
	$$ LANGUAGE 'plpgsql' STABLE;

CREATE OR REPLACE FUNCTION st_mapalgebra(
	rast raster, nband int,
	callbackfunc regprocedure,
	pixeltype text DEFAULT NULL,
	extenttype text DEFAULT 'FIRST', customextent raster DEFAULT NULL,
	distancex integer DEFAULT 0, distancey integer DEFAULT 0,
	VARIADIC userargs text[] DEFAULT NULL
)
	RETURNS raster
	AS $$ SELECT _ST_MapAlgebra(ARRAY[ROW($1, $2)]::rastbandarg[], $3, $4, $7, $8, $5, $6,NULL::double precision [],NULL::boolean, VARIADIC $9) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_mapalgebra(
	rast1 raster, nband1 int,
	rast2 raster, nband2 int,
	callbackfunc regprocedure,
	pixeltype text DEFAULT NULL,
	extenttype text DEFAULT 'INTERSECTION', customextent raster DEFAULT NULL,
	distancex integer DEFAULT 0, distancey integer DEFAULT 0,
	VARIADIC userargs text[] DEFAULT NULL
)
	RETURNS raster
	AS $$ SELECT _ST_MapAlgebra(ARRAY[ROW($1, $2), ROW($3, $4)]::rastbandarg[], $5, $6, $9, $10, $7, $8,NULL::double precision [],NULL::boolean, VARIADIC $11) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_mapalgebra(
	rast raster, nband int,
	callbackfunc regprocedure,
	mask double precision [][], weighted boolean,
	pixeltype text DEFAULT NULL,
	extenttype text DEFAULT 'INTERSECTION', customextent raster DEFAULT NULL,
	VARIADIC userargs text[] DEFAULT NULL
)
	RETURNS raster
	AS $$
	select _st_mapalgebra(ARRAY[ROW($1,$2)]::rastbandarg[],$3,$6,NULL::integer,NULL::integer,$7,$8,$4,$5,VARIADIC $9)
	$$ LANGUAGE 'sql' STABLE;

-----------------------------------------------------------------------
-- 1 or 2-Raster ST_MapAlgebra with expressions
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION _st_mapalgebra(
	rastbandargset rastbandarg[],
	expression text,
	pixeltype text DEFAULT NULL, extenttype text DEFAULT 'INTERSECTION',
	nodata1expr text DEFAULT NULL, nodata2expr text DEFAULT NULL,
	nodatanodataval double precision DEFAULT NULL
)
	RETURNS raster
	AS '$libdir/rtpostgis-2.2', 'RASTER_nMapAlgebraExpr'
	LANGUAGE 'c' STABLE;

CREATE OR REPLACE FUNCTION st_mapalgebra(
	rast raster, nband integer,
	pixeltype text,
	expression text, nodataval double precision DEFAULT NULL
)
	RETURNS raster
	AS $$ SELECT _st_mapalgebra(ARRAY[ROW($1, $2)]::rastbandarg[], $4, $3, 'FIRST', $5::text) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_mapalgebra(
	rast raster,
	pixeltype text,
	expression text, nodataval double precision DEFAULT NULL
)
	RETURNS raster
	AS $$ SELECT st_mapalgebra($1, 1, $2, $3, $4) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_mapalgebra(
	rast1 raster, band1 integer,
	rast2 raster, band2 integer,
	expression text,
	pixeltype text DEFAULT NULL, extenttype text DEFAULT 'INTERSECTION',
	nodata1expr text DEFAULT NULL, nodata2expr text DEFAULT NULL,
	nodatanodataval double precision DEFAULT NULL
)
	RETURNS raster
	AS $$ SELECT _st_mapalgebra(ARRAY[ROW($1, $2), ROW($3, $4)]::rastbandarg[], $5, $6, $7, $8, $9, $10) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_mapalgebra(
	rast1 raster,
	rast2 raster,
	expression text,
	pixeltype text DEFAULT NULL, extenttype text DEFAULT 'INTERSECTION',
	nodata1expr text DEFAULT NULL, nodata2expr text DEFAULT NULL,
	nodatanodataval double precision DEFAULT NULL
)
	RETURNS raster
	AS $$ SELECT st_mapalgebra($1, 1, $2, 1, $3, $4, $5, $6, $7, $8) $$
	LANGUAGE 'sql' STABLE;

-----------------------------------------------------------------------
-- ST_MapAlgebra callback functions
-- Should be called with values for distancex and distancey
-- These functions are meant for one raster
-----------------------------------------------------------------------

-- helper function to convert 2D array to 3D array
CREATE OR REPLACE FUNCTION _st_convertarray4ma(value double precision[][])
	RETURNS double precision[][][]
	AS $$
	DECLARE
		_value double precision[][][];
		x int;
		y int;
	BEGIN
		IF array_ndims(value) != 2 THEN
			RAISE EXCEPTION 'Function parameter must be a 2-dimension array';
		END IF;

		_value := array_fill(NULL::double precision, ARRAY[1, array_length(value, 1), array_length(value, 2)]::int[], ARRAY[1, array_lower(value, 1), array_lower(value, 2)]::int[]);

		-- row
		FOR y IN array_lower(value, 1)..array_upper(value, 1) LOOP
			-- column
			FOR x IN array_lower(value, 2)..array_upper(value, 2) LOOP
				_value[1][y][x] = value[y][x];
			END LOOP;
		END LOOP;

		RETURN _value;
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_max4ma(value double precision[][][], pos integer[][], VARIADIC userargs text[] DEFAULT NULL)
	RETURNS double precision
	AS $$
	DECLARE
		_value double precision[][][];
		max double precision;
		x int;
		y int;
		z int;
		ndims int;
	BEGIN
		max := '-Infinity'::double precision;

		ndims := array_ndims(value);
		-- add a third dimension if 2-dimension
		IF ndims = 2 THEN
			_value := _st_convertarray4ma(value);
		ELSEIF ndims != 3 THEN
			RAISE EXCEPTION 'First parameter of function must be a 3-dimension array';
		ELSE
			_value := value;
		END IF;

		-- raster
		FOR z IN array_lower(_value, 1)..array_upper(_value, 1) LOOP
			-- row
			FOR y IN array_lower(_value, 2)..array_upper(_value, 2) LOOP
				-- column
				FOR x IN array_lower(_value, 3)..array_upper(_value, 3) LOOP
					IF _value[z][y][x] IS NULL THEN
						IF array_length(userargs, 1) > 0 THEN
							_value[z][y][x] = userargs[array_lower(userargs, 1)]::double precision;
						ELSE
							CONTINUE;
						END IF;
					END IF;

					IF _value[z][y][x] > max THEN
						max := _value[z][y][x];
					END IF;
				END LOOP;
			END LOOP;
		END LOOP;

		IF max = '-Infinity'::double precision THEN
			RETURN NULL;
		END IF;

		RETURN max;
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_min4ma(value double precision[][][], pos integer[][], VARIADIC userargs text[] DEFAULT NULL)
	RETURNS double precision
	AS $$
	DECLARE
		_value double precision[][][];
		min double precision;
		x int;
		y int;
		z int;
		ndims int;
	BEGIN
		min := 'Infinity'::double precision;

		ndims := array_ndims(value);
		-- add a third dimension if 2-dimension
		IF ndims = 2 THEN
			_value := _st_convertarray4ma(value);
		ELSEIF ndims != 3 THEN
			RAISE EXCEPTION 'First parameter of function must be a 3-dimension array';
		ELSE
			_value := value;
		END IF;

		-- raster
		FOR z IN array_lower(_value, 1)..array_upper(_value, 1) LOOP
			-- row
			FOR y IN array_lower(_value, 2)..array_upper(_value, 2) LOOP
				-- column
				FOR x IN array_lower(_value, 3)..array_upper(_value, 3) LOOP
					IF _value[z][y][x] IS NULL THEN
						IF array_length(userargs, 1) > 0 THEN
							_value[z][y][x] = userargs[array_lower(userargs, 1)]::double precision;
						ELSE
							CONTINUE;
						END IF;
					END IF;

					IF _value[z][y][x] < min THEN
						min := _value[z][y][x];
					END IF;
				END LOOP;
			END LOOP;
		END LOOP;

		IF min = 'Infinity'::double precision THEN
			RETURN NULL;
		END IF;

		RETURN min;
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_sum4ma(value double precision[][][], pos integer[][], VARIADIC userargs text[] DEFAULT NULL)
	RETURNS double precision
	AS $$
	DECLARE
		_value double precision[][][];
		sum double precision;
		x int;
		y int;
		z int;
		ndims int;
	BEGIN
		sum := 0;

		ndims := array_ndims(value);
		-- add a third dimension if 2-dimension
		IF ndims = 2 THEN
			_value := _st_convertarray4ma(value);
		ELSEIF ndims != 3 THEN
			RAISE EXCEPTION 'First parameter of function must be a 3-dimension array';
		ELSE
			_value := value;
		END IF;

		-- raster
		FOR z IN array_lower(_value, 1)..array_upper(_value, 1) LOOP
			-- row
			FOR y IN array_lower(_value, 2)..array_upper(_value, 2) LOOP
				-- column
				FOR x IN array_lower(_value, 3)..array_upper(_value, 3) LOOP
					IF _value[z][y][x] IS NULL THEN
						IF array_length(userargs, 1) > 0 THEN
							_value[z][y][x] = userargs[array_lower(userargs, 1)]::double precision;
						ELSE
							CONTINUE;
						END IF;
					END IF;

					sum := sum + _value[z][y][x];
				END LOOP;
			END LOOP;
		END LOOP;

		RETURN sum;
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_mean4ma(value double precision[][][], pos integer[][], VARIADIC userargs text[] DEFAULT NULL)
	RETURNS double precision
	AS $$
	DECLARE
		_value double precision[][][];
		sum double precision;
		count int;
		x int;
		y int;
		z int;
		ndims int;
	BEGIN
		sum := 0;
		count := 0;

		ndims := array_ndims(value);
		-- add a third dimension if 2-dimension
		IF ndims = 2 THEN
			_value := _st_convertarray4ma(value);
		ELSEIF ndims != 3 THEN
			RAISE EXCEPTION 'First parameter of function must be a 3-dimension array';
		ELSE
			_value := value;
		END IF;

		-- raster
		FOR z IN array_lower(_value, 1)..array_upper(_value, 1) LOOP
			-- row
			FOR y IN array_lower(_value, 2)..array_upper(_value, 2) LOOP
				-- column
				FOR x IN array_lower(_value, 3)..array_upper(_value, 3) LOOP
					IF _value[z][y][x] IS NULL THEN
						IF array_length(userargs, 1) > 0 THEN
							_value[z][y][x] = userargs[array_lower(userargs, 1)]::double precision;
						ELSE
							CONTINUE;
						END IF;
					END IF;

					sum := sum + _value[z][y][x];
					count := count + 1;
				END LOOP;
			END LOOP;
		END LOOP;

		IF count < 1 THEN
			RETURN NULL;
		END IF;

		RETURN sum / count::double precision;
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_range4ma(value double precision[][][], pos integer[][], VARIADIC userargs text[] DEFAULT NULL)
	RETURNS double precision
	AS $$
	DECLARE
		_value double precision[][][];
		min double precision;
		max double precision;
		x int;
		y int;
		z int;
		ndims int;
	BEGIN
		min := 'Infinity'::double precision;
		max := '-Infinity'::double precision;

		ndims := array_ndims(value);
		-- add a third dimension if 2-dimension
		IF ndims = 2 THEN
			_value := _st_convertarray4ma(value);
		ELSEIF ndims != 3 THEN
			RAISE EXCEPTION 'First parameter of function must be a 3-dimension array';
		ELSE
			_value := value;
		END IF;

		-- raster
		FOR z IN array_lower(_value, 1)..array_upper(_value, 1) LOOP
			-- row
			FOR y IN array_lower(_value, 2)..array_upper(_value, 2) LOOP
				-- column
				FOR x IN array_lower(_value, 3)..array_upper(_value, 3) LOOP
					IF _value[z][y][x] IS NULL THEN
						IF array_length(userargs, 1) > 0 THEN
							_value[z][y][x] = userargs[array_lower(userargs, 1)]::double precision;
						ELSE
							CONTINUE;
						END IF;
					END IF;

					IF _value[z][y][x] < min THEN
						min := _value[z][y][x];
					END IF;
					IF _value[z][y][x] > max THEN
						max := _value[z][y][x];
					END IF;
				END LOOP;
			END LOOP;
		END LOOP;

		IF max = '-Infinity'::double precision OR min = 'Infinity'::double precision THEN
			RETURN NULL;
		END IF;

		RETURN max - min;
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_distinct4ma(value double precision[][][], pos integer[][], VARIADIC userargs text[] DEFAULT NULL)
	RETURNS double precision
	AS $$ SELECT COUNT(DISTINCT unnest)::double precision FROM unnest($1) $$
	LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_stddev4ma(value double precision[][][], pos integer[][], VARIADIC userargs text[] DEFAULT NULL)
	RETURNS double precision
	AS $$ SELECT stddev(unnest) FROM unnest($1) $$
	LANGUAGE 'sql' IMMUTABLE;

-- Inverse distance weight equation is based upon Equation 3.51 from the book
-- Spatial Analysis A Guide for Ecologists
-- by Marie-Josee Fortin and Mark Dale
-- published by Cambridge University Press
-- ISBN 0-521-00973-1
CREATE OR REPLACE FUNCTION st_invdistweight4ma(value double precision[][][], pos integer[][], VARIADIC userargs text[] DEFAULT NULL)
	RETURNS double precision
	AS $$
	DECLARE
		_value double precision[][][];
		ndims int;

		k double precision DEFAULT 1.;
		_k double precision DEFAULT 1.;
		z double precision[];
		d double precision[];
		_d double precision;
		z0 double precision;

		_z integer;
		x integer;
		y integer;

		cx integer;
		cy integer;
		cv double precision;
		cw double precision DEFAULT NULL;

		w integer;
		h integer;
		max_dx double precision;
		max_dy double precision;
	BEGIN
--		RAISE NOTICE 'value = %', value;
--		RAISE NOTICE 'userargs = %', userargs;

		ndims := array_ndims(value);
		-- add a third dimension if 2-dimension
		IF ndims = 2 THEN
			_value := _st_convertarray4ma(value);
		ELSEIF ndims != 3 THEN
			RAISE EXCEPTION 'First parameter of function must be a 3-dimension array';
		ELSE
			_value := value;
		END IF;

		-- only use the first raster passed to this function
		IF array_length(_value, 1) > 1 THEN
			RAISE NOTICE 'Only using the values from the first raster';
		END IF;
		_z := array_lower(_value, 1);

		-- width and height (0-based)
		h := array_upper(_value, 2) - array_lower(_value, 2);
		w := array_upper(_value, 3) - array_lower(_value, 3);

		-- max distance from center pixel
		max_dx := w / 2;
		max_dy := h / 2;
--		RAISE NOTICE 'max_dx, max_dy = %, %', max_dx, max_dy;

		-- correct width and height (1-based)
		w := w + 1;
		h := h + 1;
--		RAISE NOTICE 'w, h = %, %', w, h;

		-- width and height should be odd numbers
		IF w % 2. != 1 THEN
			RAISE EXCEPTION 'Width of neighborhood array does not permit for a center pixel';
		END IF;
		IF h % 2. != 1 THEN
			RAISE EXCEPTION 'Height of neighborhood array does not permit for a center pixel';
		END IF;

		-- center pixel's coordinates
		cy := max_dy + array_lower(_value, 2);
		cx := max_dx + array_lower(_value, 3);
--		RAISE NOTICE 'cx, cy = %, %', cx, cy;

		-- if userargs provided, only use the first two args
		IF userargs IS NOT NULL AND array_ndims(userargs) = 1 THEN
			-- first arg is power factor
			k := userargs[array_lower(userargs, 1)]::double precision;
			IF k IS NULL THEN
				k := _k;
			ELSEIF k < 0. THEN
				RAISE NOTICE 'Power factor (< 0) must be between 0 and 1.  Defaulting to 0';
				k := 0.;
			ELSEIF k > 1. THEN
				RAISE NOTICE 'Power factor (> 1) must be between 0 and 1.  Defaulting to 1';
				k := 1.;
			END IF;

			-- second arg is what to do if center pixel has a value
			-- this will be a weight to apply for the center pixel
			IF array_length(userargs, 1) > 1 THEN
				cw := abs(userargs[array_lower(userargs, 1) + 1]::double precision);
				IF cw IS NOT NULL THEN
					IF cw < 0. THEN
						RAISE NOTICE 'Weight (< 0) of center pixel value must be between 0 and 1.  Defaulting to 0';
						cw := 0.;
					ELSEIF cw > 1 THEN
						RAISE NOTICE 'Weight (> 1) of center pixel value must be between 0 and 1.  Defaulting to 1';
						cw := 1.;
					END IF;
				END IF;
			END IF;
		END IF;
--		RAISE NOTICE 'k = %', k;
		k = abs(k) * -1;

		-- center pixel value
		cv := _value[_z][cy][cx];

		-- check to see if center pixel has value
--		RAISE NOTICE 'cw = %', cw;
		IF cw IS NULL AND cv IS NOT NULL THEN
			RETURN cv;
		END IF;

		FOR y IN array_lower(_value, 2)..array_upper(_value, 2) LOOP
			FOR x IN array_lower(_value, 3)..array_upper(_value, 3) LOOP
--				RAISE NOTICE 'value[%][%][%] = %', _z, y, x, _value[_z][y][x];

				-- skip NODATA values and center pixel
				IF _value[_z][y][x] IS NULL OR (x = cx AND y = cy) THEN
					CONTINUE;
				END IF;

				z := z || _value[_z][y][x];

				-- use pythagorean theorem
				_d := sqrt(power(cx - x, 2) + power(cy - y, 2));
--				RAISE NOTICE 'distance = %', _d;

				d := d || _d;
			END LOOP;
		END LOOP;
--		RAISE NOTICE 'z = %', z;
--		RAISE NOTICE 'd = %', d;

		-- neighborhood is NODATA
		IF z IS NULL OR array_length(z, 1) < 1 THEN
			-- center pixel has value
			IF cv IS NOT NULL THEN
				RETURN cv;
			ELSE
				RETURN NULL;
			END IF;
		END IF;

		z0 := 0;
		_d := 0;
		FOR x IN array_lower(z, 1)..array_upper(z, 1) LOOP
			d[x] := power(d[x], k);
			z[x] := z[x] * d[x];
			_d := _d + d[x];
			z0 := z0 + z[x];
		END LOOP;
		z0 := z0 / _d;
--		RAISE NOTICE 'z0 = %', z0;

		-- apply weight for center pixel if center pixel has value
		IF cv IS NOT NULL THEN
			z0 := (cw * cv) + ((1 - cw) * z0);
--			RAISE NOTICE '*z0 = %', z0;
		END IF;

		RETURN z0;
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_mindist4ma(value double precision[][][], pos integer[][], VARIADIC userargs text[] DEFAULT NULL)
	RETURNS double precision
	AS $$
	DECLARE
		_value double precision[][][];
		ndims int;

		d double precision DEFAULT NULL;
		_d double precision;

		z integer;
		x integer;
		y integer;

		cx integer;
		cy integer;
		cv double precision;

		w integer;
		h integer;
		max_dx double precision;
		max_dy double precision;
	BEGIN

		ndims := array_ndims(value);
		-- add a third dimension if 2-dimension
		IF ndims = 2 THEN
			_value := _st_convertarray4ma(value);
		ELSEIF ndims != 3 THEN
			RAISE EXCEPTION 'First parameter of function must be a 3-dimension array';
		ELSE
			_value := value;
		END IF;

		-- only use the first raster passed to this function
		IF array_length(_value, 1) > 1 THEN
			RAISE NOTICE 'Only using the values from the first raster';
		END IF;
		z := array_lower(_value, 1);

		-- width and height (0-based)
		h := array_upper(_value, 2) - array_lower(_value, 2);
		w := array_upper(_value, 3) - array_lower(_value, 3);

		-- max distance from center pixel
		max_dx := w / 2;
		max_dy := h / 2;

		-- correct width and height (1-based)
		w := w + 1;
		h := h + 1;

		-- width and height should be odd numbers
		IF w % 2. != 1 THEN
			RAISE EXCEPTION 'Width of neighborhood array does not permit for a center pixel';
		END IF;
		IF h % 2. != 1 THEN
			RAISE EXCEPTION 'Height of neighborhood array does not permit for a center pixel';
		END IF;

		-- center pixel's coordinates
		cy := max_dy + array_lower(_value, 2);
		cx := max_dx + array_lower(_value, 3);

		-- center pixel value
		cv := _value[z][cy][cx];

		-- check to see if center pixel has value
		IF cv IS NOT NULL THEN
			RETURN 0.;
		END IF;

		FOR y IN array_lower(_value, 2)..array_upper(_value, 2) LOOP
			FOR x IN array_lower(_value, 3)..array_upper(_value, 3) LOOP

				-- skip NODATA values and center pixel
				IF _value[z][y][x] IS NULL OR (x = cx AND y = cy) THEN
					CONTINUE;
				END IF;

				-- use pythagorean theorem
				_d := sqrt(power(cx - x, 2) + power(cy - y, 2));
--				RAISE NOTICE 'distance = %', _d;

				IF d IS NULL OR _d < d THEN
					d := _d;
				END IF;
			END LOOP;
		END LOOP;
--		RAISE NOTICE 'd = %', d;

		RETURN d;
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE;

-----------------------------------------------------------------------
-- ST_Slope
-- http://webhelp.esri.com/arcgisdesktop/9.3/index.cfm?TopicName=How%20Hillshade%20works
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION _st_slope4ma(value double precision[][][], pos integer[][], VARIADIC userargs text[] DEFAULT NULL)
	RETURNS double precision
	AS $$
	DECLARE
		x integer;
		y integer;
		z integer;

		_pixwidth double precision;
		_pixheight double precision;
		_width double precision;
		_height double precision;
		_units text;
		_scale double precision;

		dz_dx double precision;
		dz_dy double precision;

		slope double precision;

		_value double precision[][][];
		ndims int;
	BEGIN

		ndims := array_ndims(value);
		-- add a third dimension if 2-dimension
		IF ndims = 2 THEN
			_value := _st_convertarray4ma(value);
		ELSEIF ndims != 3 THEN
			RAISE EXCEPTION 'First parameter of function must be a 3-dimension array';
		ELSE
			_value := value;
		END IF;

		-- only use the first raster passed to this function
		IF array_length(_value, 1) > 1 THEN
			RAISE NOTICE 'Only using the values from the first raster';
		END IF;
		z := array_lower(_value, 1);

		IF (
			array_lower(_value, 2) != 1 OR array_upper(_value, 2) != 3 OR
			array_lower(_value, 3) != 1 OR array_upper(_value, 3) != 3
		) THEN
			RAISE EXCEPTION 'First parameter of function must be a 1x3x3 array with each of the lower bounds starting from 1';
		END IF;

		IF array_length(userargs, 1) < 6 THEN
			RAISE EXCEPTION 'At least six elements must be provided for the third parameter';
		END IF;

		_pixwidth := userargs[1]::double precision;
		_pixheight := userargs[2]::double precision;
		_width := userargs[3]::double precision;
		_height := userargs[4]::double precision;
		_units := userargs[5];
		_scale := userargs[6]::double precision;

		





		-- check that center pixel isn't NODATA
		IF _value[z][2][2] IS NULL THEN
			RETURN NULL;
		-- substitute center pixel for any neighbor pixels that are NODATA
		ELSE
			FOR y IN 1..3 LOOP
				FOR x IN 1..3 LOOP
					IF _value[z][y][x] IS NULL THEN
						_value[z][y][x] = _value[z][2][2];
					END IF;
				END LOOP;
			END LOOP;
		END IF;

		dz_dy := ((_value[z][3][1] + _value[z][3][2] + _value[z][3][2] + _value[z][3][3]) -
			(_value[z][1][1] + _value[z][1][2] + _value[z][1][2] + _value[z][1][3])) / _pixheight;
		dz_dx := ((_value[z][1][3] + _value[z][2][3] + _value[z][2][3] + _value[z][3][3]) -
			(_value[z][1][1] + _value[z][2][1] + _value[z][2][1] + _value[z][3][1])) / _pixwidth;

		slope := sqrt(dz_dx * dz_dx + dz_dy * dz_dy) / (8 * _scale);

		-- output depends on user preference
		CASE substring(upper(trim(leading from _units)) for 3)
			-- percentages
			WHEN 'PER' THEN
				slope := 100.0 * slope;
			-- radians
			WHEN 'rad' THEN
				slope := atan(slope);
			-- degrees (default)
			ELSE
				slope := degrees(atan(slope));
		END CASE;

		RETURN slope;
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_slope(
	rast raster, nband integer,
	customextent raster,
	pixeltype text DEFAULT '32BF', units text DEFAULT 'DEGREES',
	scale double precision DEFAULT 1.0,	interpolate_nodata boolean DEFAULT FALSE
)
	RETURNS raster
	AS $$
	DECLARE
		_rast raster;
		_nband integer;
		_pixtype text;
		_pixwidth double precision;
		_pixheight double precision;
		_width integer;
		_height integer;
		_customextent raster;
		_extenttype text;
	BEGIN
		_customextent := customextent;
		IF _customextent IS NULL THEN
			_extenttype := 'FIRST';
		ELSE
			_extenttype := 'CUSTOM';
		END IF;

		IF interpolate_nodata IS TRUE THEN
			_rast := ST_MapAlgebra(
				ARRAY[ROW(rast, nband)]::rastbandarg[],
				'st_invdistweight4ma(double precision[][][], integer[][], text[])'::regprocedure,
				pixeltype,
				'FIRST', NULL,
				1, 1
			);
			_nband := 1;
			_pixtype := NULL;
		ELSE
			_rast := rast;
			_nband := nband;
			_pixtype := pixeltype;
		END IF;

		-- get properties
		_pixwidth := ST_PixelWidth(_rast);
		_pixheight := ST_PixelHeight(_rast);
		SELECT width, height INTO _width, _height FROM ST_Metadata(_rast);

		RETURN ST_MapAlgebra(
			ARRAY[ROW(_rast, _nband)]::rastbandarg[],
			'_st_slope4ma(double precision[][][], integer[][], text[])'::regprocedure,
			_pixtype,
			_extenttype, _customextent,
			1, 1,
			_pixwidth::text, _pixheight::text,
			_width::text, _height::text,
			units::text, scale::text
		);
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_slope(
	rast raster, nband integer DEFAULT 1,
	pixeltype text DEFAULT '32BF', units text DEFAULT 'DEGREES',
	scale double precision DEFAULT 1.0,	interpolate_nodata boolean DEFAULT FALSE
)
	RETURNS raster
	AS $$ SELECT st_slope($1, $2, NULL::raster, $3, $4, $5, $6) $$
	LANGUAGE 'sql' IMMUTABLE;

-----------------------------------------------------------------------
-- ST_Aspect
-- http://webhelp.esri.com/arcgisdesktop/9.3/index.cfm?TopicName=How%20Hillshade%20works
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION _st_aspect4ma(value double precision[][][], pos integer[][], VARIADIC userargs text[] DEFAULT NULL)
	RETURNS double precision
	AS $$
	DECLARE
		x integer;
		y integer;
		z integer;

		_width double precision;
		_height double precision;
		_units text;

		dz_dx double precision;
		dz_dy double precision;
		aspect double precision;
		halfpi double precision;

		_value double precision[][][];
		ndims int;
	BEGIN
		ndims := array_ndims(value);
		-- add a third dimension if 2-dimension
		IF ndims = 2 THEN
			_value := _st_convertarray4ma(value);
		ELSEIF ndims != 3 THEN
			RAISE EXCEPTION 'First parameter of function must be a 3-dimension array';
		ELSE
			_value := value;
		END IF;

		IF (
			array_lower(_value, 2) != 1 OR array_upper(_value, 2) != 3 OR
			array_lower(_value, 3) != 1 OR array_upper(_value, 3) != 3
		) THEN
			RAISE EXCEPTION 'First parameter of function must be a 1x3x3 array with each of the lower bounds starting from 1';
		END IF;

		IF array_length(userargs, 1) < 3 THEN
			RAISE EXCEPTION 'At least three elements must be provided for the third parameter';
		END IF;

		-- only use the first raster passed to this function
		IF array_length(_value, 1) > 1 THEN
			RAISE NOTICE 'Only using the values from the first raster';
		END IF;
		z := array_lower(_value, 1);

		_width := userargs[1]::double precision;
		_height := userargs[2]::double precision;
		_units := userargs[3];

		





		-- check that center pixel isn't NODATA
		IF _value[z][2][2] IS NULL THEN
			RETURN NULL;
		-- substitute center pixel for any neighbor pixels that are NODATA
		ELSE
			FOR y IN 1..3 LOOP
				FOR x IN 1..3 LOOP
					IF _value[z][y][x] IS NULL THEN
						_value[z][y][x] = _value[z][2][2];
					END IF;
				END LOOP;
			END LOOP;
		END IF;

		dz_dy := ((_value[z][3][1] + _value[z][3][2] + _value[z][3][2] + _value[z][3][3]) -
			(_value[z][1][1] + _value[z][1][2] + _value[z][1][2] + _value[z][1][3]));
		dz_dx := ((_value[z][1][3] + _value[z][2][3] + _value[z][2][3] + _value[z][3][3]) -
			(_value[z][1][1] + _value[z][2][1] + _value[z][2][1] + _value[z][3][1]));

		-- aspect is flat
		IF abs(dz_dx) = 0::double precision AND abs(dz_dy) = 0::double precision THEN
			RETURN -1;
		END IF;

		-- aspect is in radians
		aspect := atan2(dz_dy, -dz_dx);

		-- north = 0, pi/2 = east, 3pi/2 = west
		halfpi := pi() / 2.0;
		IF aspect > halfpi THEN
			aspect := (5.0 * halfpi) - aspect;
		ELSE
			aspect := halfpi - aspect;
		END IF;

		IF aspect = 2 * pi() THEN
			aspect := 0.;
		END IF;

		-- output depends on user preference
		CASE substring(upper(trim(leading from _units)) for 3)
			-- radians
			WHEN 'rad' THEN
				RETURN aspect;
			-- degrees (default)
			ELSE
				RETURN degrees(aspect);
		END CASE;

	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_aspect(
	rast raster, nband integer,
	customextent raster,
	pixeltype text DEFAULT '32BF', units text DEFAULT 'DEGREES',
	interpolate_nodata boolean DEFAULT FALSE
)
	RETURNS raster
	AS $$
	DECLARE
		_rast raster;
		_nband integer;
		_pixtype text;
		_width integer;
		_height integer;
		_customextent raster;
		_extenttype text;
	BEGIN
		_customextent := customextent;
		IF _customextent IS NULL THEN
			_extenttype := 'FIRST';
		ELSE
			_extenttype := 'CUSTOM';
		END IF;

		IF interpolate_nodata IS TRUE THEN
			_rast := ST_MapAlgebra(
				ARRAY[ROW(rast, nband)]::rastbandarg[],
				'st_invdistweight4ma(double precision[][][], integer[][], text[])'::regprocedure,
				pixeltype,
				'FIRST', NULL,
				1, 1
			);
			_nband := 1;
			_pixtype := NULL;
		ELSE
			_rast := rast;
			_nband := nband;
			_pixtype := pixeltype;
		END IF;

		-- get properties
		SELECT width, height INTO _width, _height FROM ST_Metadata(_rast);

		RETURN ST_MapAlgebra(
			ARRAY[ROW(_rast, _nband)]::rastbandarg[],
			'_st_aspect4ma(double precision[][][], integer[][], text[])'::regprocedure,
			_pixtype,
			_extenttype, _customextent,
			1, 1,
			_width::text, _height::text,
			units::text
		);
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_aspect(
	rast raster, nband integer DEFAULT 1,
	pixeltype text DEFAULT '32BF', units text DEFAULT 'DEGREES',
	interpolate_nodata boolean DEFAULT FALSE
)
	RETURNS raster
	AS $$ SELECT st_aspect($1, $2, NULL::raster, $3, $4, $5) $$
	LANGUAGE 'sql' IMMUTABLE;

-----------------------------------------------------------------------
-- ST_HillShade
-- http://webhelp.esri.com/arcgisdesktop/9.3/index.cfm?TopicName=How%20Hillshade%20works
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION _st_hillshade4ma(value double precision[][][], pos integer[][], VARIADIC userargs text[] DEFAULT NULL)
	RETURNS double precision
	AS $$
	DECLARE
		_pixwidth double precision;
		_pixheight double precision;
		_width double precision;
		_height double precision;
		_azimuth double precision;
		_altitude double precision;
		_bright double precision;
		_scale double precision;

		dz_dx double precision;
		dz_dy double precision;
		azimuth double precision;
		zenith double precision;
		slope double precision;
		aspect double precision;
		shade double precision;

		_value double precision[][][];
		ndims int;
		z int;
	BEGIN
		ndims := array_ndims(value);
		-- add a third dimension if 2-dimension
		IF ndims = 2 THEN
			_value := _st_convertarray4ma(value);
		ELSEIF ndims != 3 THEN
			RAISE EXCEPTION 'First parameter of function must be a 3-dimension array';
		ELSE
			_value := value;
		END IF;

		IF (
			array_lower(_value, 2) != 1 OR array_upper(_value, 2) != 3 OR
			array_lower(_value, 3) != 1 OR array_upper(_value, 3) != 3
		) THEN
			RAISE EXCEPTION 'First parameter of function must be a 1x3x3 array with each of the lower bounds starting from 1';
		END IF;

		IF array_length(userargs, 1) < 8 THEN
			RAISE EXCEPTION 'At least eight elements must be provided for the third parameter';
		END IF;

		-- only use the first raster passed to this function
		IF array_length(_value, 1) > 1 THEN
			RAISE NOTICE 'Only using the values from the first raster';
		END IF;
		z := array_lower(_value, 1);

		_pixwidth := userargs[1]::double precision;
		_pixheight := userargs[2]::double precision;
		_width := userargs[3]::double precision;
		_height := userargs[4]::double precision;
		_azimuth := userargs[5]::double precision;
		_altitude := userargs[6]::double precision;
		_bright := userargs[7]::double precision;
		_scale := userargs[8]::double precision;

		-- check that pixel is not edge pixel
		IF (pos[1][1] = 1 OR pos[1][2] = 1) OR (pos[1][1] = _width OR pos[1][2] = _height) THEN
			RETURN NULL;
		END IF;

		-- clamp azimuth
		IF _azimuth < 0. THEN
			RAISE NOTICE 'Clamping provided azimuth value % to 0', _azimuth;
			_azimuth := 0.;
		ELSEIF _azimuth >= 360. THEN
			RAISE NOTICE 'Converting provided azimuth value % to be between 0 and 360', _azimuth;
			_azimuth := _azimuth - (360. * floor(_azimuth / 360.));
		END IF;
		azimuth := 360. - _azimuth + 90.;
		IF azimuth >= 360. THEN
			azimuth := azimuth - 360.;
		END IF;
		azimuth := radians(azimuth);
		--RAISE NOTICE 'azimuth = %', azimuth;

		-- clamp altitude
		IF _altitude < 0. THEN
			RAISE NOTICE 'Clamping provided altitude value % to 0', _altitude;
			_altitude := 0.;
		ELSEIF _altitude > 90. THEN
			RAISE NOTICE 'Clamping provided altitude value % to 90', _altitude;
			_altitude := 90.;
		END IF;
		zenith := radians(90. - _altitude);
		--RAISE NOTICE 'zenith = %', zenith;

		-- clamp bright
		IF _bright < 0. THEN
			RAISE NOTICE 'Clamping provided bright value % to 0', _bright;
			_bright := 0.;
		ELSEIF _bright > 255. THEN
			RAISE NOTICE 'Clamping provided bright value % to 255', _bright;
			_bright := 255.;
		END IF;

		dz_dy := ((_value[z][3][1] + _value[z][3][2] + _value[z][3][2] + _value[z][3][3]) -
			(_value[z][1][1] + _value[z][1][2] + _value[z][1][2] + _value[z][1][3])) / (8 * _pixheight);
		dz_dx := ((_value[z][1][3] + _value[z][2][3] + _value[z][2][3] + _value[z][3][3]) -
			(_value[z][1][1] + _value[z][2][1] + _value[z][2][1] + _value[z][3][1])) / (8 * _pixwidth);

		slope := atan(sqrt(dz_dx * dz_dx + dz_dy * dz_dy) / _scale);

		IF dz_dx != 0. THEN
			aspect := atan2(dz_dy, -dz_dx);

			IF aspect < 0. THEN
				aspect := aspect + (2.0 * pi());
			END IF;
		ELSE
			IF dz_dy > 0. THEN
				aspect := pi() / 2.;
			ELSEIF dz_dy < 0. THEN
				aspect := (2. * pi()) - (pi() / 2.);
			-- set to pi as that is the expected PostgreSQL answer in Linux
			ELSE
				aspect := pi();
			END IF;
		END IF;

		shade := _bright * ((cos(zenith) * cos(slope)) + (sin(zenith) * sin(slope) * cos(azimuth - aspect)));

		IF shade < 0. THEN
			shade := 0;
		END IF;

		RETURN shade;
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_hillshade(
	rast raster, nband integer,
	customextent raster,
	pixeltype text DEFAULT '32BF',
	azimuth double precision DEFAULT 315.0, altitude double precision DEFAULT 45.0,
	max_bright double precision DEFAULT 255.0, scale double precision DEFAULT 1.0,
	interpolate_nodata boolean DEFAULT FALSE
)
	RETURNS RASTER
	AS $$
	DECLARE
		_rast raster;
		_nband integer;
		_pixtype text;
		_pixwidth double precision;
		_pixheight double precision;
		_width integer;
		_height integer;
		_customextent raster;
		_extenttype text;
	BEGIN
		_customextent := customextent;
		IF _customextent IS NULL THEN
			_extenttype := 'FIRST';
		ELSE
			_extenttype := 'CUSTOM';
		END IF;

		IF interpolate_nodata IS TRUE THEN
			_rast := ST_MapAlgebra(
				ARRAY[ROW(rast, nband)]::rastbandarg[],
				'st_invdistweight4ma(double precision[][][], integer[][], text[])'::regprocedure,
				pixeltype,
				'FIRST', NULL,
				1, 1
			);
			_nband := 1;
			_pixtype := NULL;
		ELSE
			_rast := rast;
			_nband := nband;
			_pixtype := pixeltype;
		END IF;

		-- get properties
		_pixwidth := ST_PixelWidth(_rast);
		_pixheight := ST_PixelHeight(_rast);
		SELECT width, height, scalex INTO _width, _height FROM ST_Metadata(_rast);

		RETURN ST_MapAlgebra(
			ARRAY[ROW(_rast, _nband)]::rastbandarg[],
			'_st_hillshade4ma(double precision[][][], integer[][], text[])'::regprocedure,
			_pixtype,
			_extenttype, _customextent,
			1, 1,
			_pixwidth::text, _pixheight::text,
			_width::text, _height::text,
			$5::text, $6::text,
			$7::text, $8::text
		);
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_hillshade(
	rast raster, nband integer DEFAULT 1,
	pixeltype text DEFAULT '32BF',
	azimuth double precision DEFAULT 315.0, altitude double precision DEFAULT 45.0,
	max_bright double precision DEFAULT 255.0, scale double precision DEFAULT 1.0,
	interpolate_nodata boolean DEFAULT FALSE
)
	RETURNS RASTER
	AS $$ SELECT st_hillshade($1, $2, NULL::raster, $3, $4, $5, $6, $7, $8) $$
	LANGUAGE 'sql' IMMUTABLE;

-----------------------------------------------------------------------
-- ST_TPI
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION _st_tpi4ma(value double precision[][][], pos integer[][], VARIADIC userargs text[] DEFAULT NULL)
	RETURNS double precision
	AS $$
	DECLARE
		x integer;
		y integer;
		z integer;

		Z1 double precision;
		Z2 double precision;
		Z3 double precision;
		Z4 double precision;
		Z5 double precision;
		Z6 double precision;
		Z7 double precision;
		Z8 double precision;
		Z9 double precision;

		tpi double precision;
		mean double precision;
		_value double precision[][][];
		ndims int;
	BEGIN
		ndims := array_ndims(value);
		-- add a third dimension if 2-dimension
		IF ndims = 2 THEN
			_value := _st_convertarray4ma(value);
		ELSEIF ndims != 3 THEN
			RAISE EXCEPTION 'First parameter of function must be a 3-dimension array';
		ELSE
			_value := value;
		END IF;

		-- only use the first raster passed to this function
		IF array_length(_value, 1) > 1 THEN
			RAISE NOTICE 'Only using the values from the first raster';
		END IF;
		z := array_lower(_value, 1);

		IF (
			array_lower(_value, 2) != 1 OR array_upper(_value, 2) != 3 OR
			array_lower(_value, 3) != 1 OR array_upper(_value, 3) != 3
		) THEN
			RAISE EXCEPTION 'First parameter of function must be a 1x3x3 array with each of the lower bounds starting from 1';
		END IF;

		-- check that center pixel isn't NODATA
		IF _value[z][2][2] IS NULL THEN
			RETURN NULL;
		-- substitute center pixel for any neighbor pixels that are NODATA
		ELSE
			FOR y IN 1..3 LOOP
				FOR x IN 1..3 LOOP
					IF _value[z][y][x] IS NULL THEN
						_value[z][y][x] = _value[z][2][2];
					END IF;
				END LOOP;
			END LOOP;
		END IF;

		-------------------------------------------------
		--|   Z1= Z(-1,1) |  Z2= Z(0,1)	| Z3= Z(1,1)  |--
		-------------------------------------------------
		--|   Z4= Z(-1,0) |  Z5= Z(0,0) | Z6= Z(1,0)  |--
		-------------------------------------------------
		--|   Z7= Z(-1,-1)|  Z8= Z(0,-1)|  Z9= Z(1,-1)|--
		-------------------------------------------------

		Z1 := _value[z][1][1];
		Z2 := _value[z][2][1];
		Z3 := _value[z][3][1];
		Z4 := _value[z][1][2];
		Z5 := _value[z][2][2];
		Z6 := _value[z][3][2];
		Z7 := _value[z][1][3];
		Z8 := _value[z][2][3];
		Z9 := _value[z][3][3];

		mean := (Z1 + Z2 + Z3 + Z4 + Z6 + Z7 + Z8 + Z9)/8;
		tpi := Z5-mean;
		
		return tpi;
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_tpi(
	rast raster, nband integer,
	customextent raster,
	pixeltype text DEFAULT '32BF', interpolate_nodata boolean DEFAULT FALSE
)
	RETURNS raster
	AS $$
	DECLARE
		_rast raster;
		_nband integer;
		_pixtype text;
		_pixwidth double precision;
		_pixheight double precision;
		_width integer;
		_height integer;
		_customextent raster;
		_extenttype text;
	BEGIN
		_customextent := customextent;
		IF _customextent IS NULL THEN
			_extenttype := 'FIRST';
		ELSE
			_extenttype := 'CUSTOM';
		END IF;

		IF interpolate_nodata IS TRUE THEN
			_rast := ST_MapAlgebra(
				ARRAY[ROW(rast, nband)]::rastbandarg[],
				'st_invdistweight4ma(double precision[][][], integer[][], text[])'::regprocedure,
				pixeltype,
				'FIRST', NULL,
				1, 1
			);
			_nband := 1;
			_pixtype := NULL;
		ELSE
			_rast := rast;
			_nband := nband;
			_pixtype := pixeltype;
		END IF;

		-- get properties
		_pixwidth := ST_PixelWidth(_rast);
		_pixheight := ST_PixelHeight(_rast);
		SELECT width, height INTO _width, _height FROM ST_Metadata(_rast);

		RETURN ST_MapAlgebra(
			ARRAY[ROW(_rast, _nband)]::rastbandarg[],
			'_st_tpi4ma(double precision[][][], integer[][], text[])'::regprocedure,
			_pixtype,
			_extenttype, _customextent,
			1, 1);
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_tpi(
	rast raster, nband integer DEFAULT 1,
	pixeltype text DEFAULT '32BF', interpolate_nodata boolean DEFAULT FALSE
)
	RETURNS RASTER
	AS $$ SELECT st_tpi($1, $2, NULL::raster, $3, $4) $$
	LANGUAGE 'sql' IMMUTABLE;

-----------------------------------------------------------------------
-- ST_Roughness
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION _st_roughness4ma(value double precision[][][], pos integer[][], VARIADIC userargs text[] DEFAULT NULL)
	RETURNS double precision
	AS $$
	DECLARE
		x integer;
		y integer;
		z integer;

		minimum double precision;
		maximum double precision;

		_value double precision[][][];
		ndims int;
	BEGIN

		ndims := array_ndims(value);
		-- add a third dimension if 2-dimension
		IF ndims = 2 THEN
			_value := _st_convertarray4ma(value);
		ELSEIF ndims != 3 THEN
			RAISE EXCEPTION 'First parameter of function must be a 3-dimension array';
		ELSE
			_value := value;
		END IF;

		-- only use the first raster passed to this function
		IF array_length(_value, 1) > 1 THEN
			RAISE NOTICE 'Only using the values from the first raster';
		END IF;
		z := array_lower(_value, 1);

		IF (
			array_lower(_value, 2) != 1 OR array_upper(_value, 2) != 3 OR
			array_lower(_value, 3) != 1 OR array_upper(_value, 3) != 3
		) THEN
			RAISE EXCEPTION 'First parameter of function must be a 1x3x3 array with each of the lower bounds starting from 1';
		END IF;

		-- check that center pixel isn't NODATA
		IF _value[z][2][2] IS NULL THEN
			RETURN NULL;
		-- substitute center pixel for any neighbor pixels that are NODATA
		ELSE
			FOR y IN 1..3 LOOP
				FOR x IN 1..3 LOOP
					IF _value[z][y][x] IS NULL THEN
						_value[z][y][x] = _value[z][2][2];
					END IF;
				END LOOP;
			END LOOP;
		END IF;

		minimum := _value[z][1][1];
		maximum := _value[z][1][1];

		FOR Y IN 1..3 LOOP
		    FOR X IN 1..3 LOOP
		    	 IF _value[z][y][x] < minimum THEN
			    minimum := _value[z][y][x];
			 ELSIF _value[z][y][x] > maximum THEN
			    maximum := _value[z][y][x];
			 END IF;
		    END LOOP;
		END LOOP;

		RETURN maximum - minimum;
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_roughness(
	rast raster, nband integer,
	customextent raster,
	pixeltype text DEFAULT '32BF', interpolate_nodata boolean DEFAULT FALSE
)
	RETURNS raster
	AS $$
	DECLARE
		_rast raster;
		_nband integer;
		_pixtype text;
		_pixwidth double precision;
		_pixheight double precision;
		_width integer;
		_height integer;
		_customextent raster;
		_extenttype text;
	BEGIN
		_customextent := customextent;
		IF _customextent IS NULL THEN
			_extenttype := 'FIRST';
		ELSE
			_extenttype := 'CUSTOM';
		END IF;

		IF interpolate_nodata IS TRUE THEN
			_rast := ST_MapAlgebra(
				ARRAY[ROW(rast, nband)]::rastbandarg[],
				'st_invdistweight4ma(double precision[][][], integer[][], text[])'::regprocedure,
				pixeltype,
				'FIRST', NULL,
				1, 1
			);
			_nband := 1;
			_pixtype := NULL;
		ELSE
			_rast := rast;
			_nband := nband;
			_pixtype := pixeltype;
		END IF;

		RETURN ST_MapAlgebra(
			ARRAY[ROW(_rast, _nband)]::rastbandarg[],
			'_st_roughness4ma(double precision[][][], integer[][], text[])'::regprocedure,
			_pixtype,
			_extenttype, _customextent,
			1, 1);
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_roughness(
	rast raster, nband integer DEFAULT 1,
	pixeltype text DEFAULT '32BF', interpolate_nodata boolean DEFAULT FALSE
)
	RETURNS RASTER
	AS $$ SELECT st_roughness($1, $2, NULL::raster, $3, $4) $$
	LANGUAGE 'sql' IMMUTABLE;

-----------------------------------------------------------------------
-- ST_TRI
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION _st_tri4ma(value double precision[][][], pos integer[][], VARIADIC userargs text[] DEFAULT NULL)
	RETURNS double precision
	AS $$
	DECLARE
		x integer;
		y integer;
		z integer;

		Z1 double precision;
		Z2 double precision;
		Z3 double precision;
		Z4 double precision;
		Z5 double precision;
		Z6 double precision;
		Z7 double precision;
		Z8 double precision;
		Z9 double precision;

		tri double precision;
		_value double precision[][][];
		ndims int;
	BEGIN
		ndims := array_ndims(value);
		-- add a third dimension if 2-dimension
		IF ndims = 2 THEN
			_value := _st_convertarray4ma(value);
		ELSEIF ndims != 3 THEN
			RAISE EXCEPTION 'First parameter of function must be a 3-dimension array';
		ELSE
			_value := value;
		END IF;

		-- only use the first raster passed to this function
		IF array_length(_value, 1) > 1 THEN
			RAISE NOTICE 'Only using the values from the first raster';
		END IF;
		z := array_lower(_value, 1);

		IF (
			array_lower(_value, 2) != 1 OR array_upper(_value, 2) != 3 OR
			array_lower(_value, 3) != 1 OR array_upper(_value, 3) != 3
		) THEN
			RAISE EXCEPTION 'First parameter of function must be a 1x3x3 array with each of the lower bounds starting from 1';
		END IF;

		-- check that center pixel isn't NODATA
		IF _value[z][2][2] IS NULL THEN
			RETURN NULL;
		-- substitute center pixel for any neighbor pixels that are NODATA
		ELSE
			FOR y IN 1..3 LOOP
				FOR x IN 1..3 LOOP
					IF _value[z][y][x] IS NULL THEN
						_value[z][y][x] = _value[z][2][2];
					END IF;
				END LOOP;
			END LOOP;
		END IF;

		-------------------------------------------------
		--|   Z1= Z(-1,1) |  Z2= Z(0,1)	| Z3= Z(1,1)  |--
		-------------------------------------------------
		--|   Z4= Z(-1,0) |  Z5= Z(0,0) | Z6= Z(1,0)  |--
		-------------------------------------------------
		--|   Z7= Z(-1,-1)|  Z8= Z(0,-1)|  Z9= Z(1,-1)|--
		-------------------------------------------------

		-- _scale width and height units / z units to make z units equal to height width units
		Z1 := _value[z][1][1];
		Z2 := _value[z][2][1];
		Z3 := _value[z][3][1];
		Z4 := _value[z][1][2];
		Z5 := _value[z][2][2];
		Z6 := _value[z][3][2];
		Z7 := _value[z][1][3];
		Z8 := _value[z][2][3];
		Z9 := _value[z][3][3];

		tri := ( abs(Z1 - Z5 ) + abs( Z2 - Z5 ) + abs( Z3 - Z5 ) + abs( Z4 - Z5 ) + abs( Z6 - Z5 ) + abs( Z7 - Z5 ) + abs( Z8 - Z5 ) + abs ( Z9 - Z5 )) / 8;
		
		return tri;  
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_tri(
	rast raster, nband integer,
	customextent raster,
	pixeltype text DEFAULT '32BF',	interpolate_nodata boolean DEFAULT FALSE
)
	RETURNS raster
	AS $$
	DECLARE
		_rast raster;
		_nband integer;
		_pixtype text;
		_pixwidth double precision;
		_pixheight double precision;
		_width integer;
		_height integer;
		_customextent raster;
		_extenttype text;
	BEGIN
		_customextent := customextent;
		IF _customextent IS NULL THEN
			_extenttype := 'FIRST';
		ELSE
			_extenttype := 'CUSTOM';
		END IF;

		IF interpolate_nodata IS TRUE THEN
			_rast := ST_MapAlgebra(
				ARRAY[ROW(rast, nband)]::rastbandarg[],
				'st_invdistweight4ma(double precision[][][], integer[][], text[])'::regprocedure,
				pixeltype,
				'FIRST', NULL,
				1, 1
			);
			_nband := 1;
			_pixtype := NULL;
		ELSE
			_rast := rast;
			_nband := nband;
			_pixtype := pixeltype;
		END IF;

		-- get properties
		_pixwidth := ST_PixelWidth(_rast);
		_pixheight := ST_PixelHeight(_rast);
		SELECT width, height INTO _width, _height FROM ST_Metadata(_rast);

		RETURN ST_MapAlgebra(
			ARRAY[ROW(_rast, _nband)]::rastbandarg[],
			'_st_tri4ma(double precision[][][], integer[][], text[])'::regprocedure,
			_pixtype,
			_extenttype, _customextent,
			1, 1);
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_tri(
	rast raster, nband integer DEFAULT 1,
	pixeltype text DEFAULT '32BF', interpolate_nodata boolean DEFAULT FALSE
)
	RETURNS RASTER
	AS $$ SELECT st_tri($1, $2, NULL::raster, $3, $4) $$
	LANGUAGE 'sql' IMMUTABLE;

-----------------------------------------------------------------------
-- Get information about the raster
-----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION st_isempty(rast raster)
    RETURNS boolean
    AS '$libdir/rtpostgis-2.2', 'RASTER_isEmpty'
    LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_hasnoband(rast raster, nband int DEFAULT 1)
    RETURNS boolean
    AS '$libdir/rtpostgis-2.2', 'RASTER_hasNoBand'
    LANGUAGE 'c' IMMUTABLE STRICT;

-----------------------------------------------------------------------
-- Raster Band Accessors
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION st_bandnodatavalue(rast raster, band integer DEFAULT 1)
    RETURNS double precision
    AS '$libdir/rtpostgis-2.2','RASTER_getBandNoDataValue'
    LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_bandisnodata(rast raster, band integer DEFAULT 1, forceChecking boolean DEFAULT FALSE)
    RETURNS boolean
    AS '$libdir/rtpostgis-2.2', 'RASTER_bandIsNoData'
    LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_bandisnodata(rast raster, forceChecking boolean)
    RETURNS boolean
    AS $$ SELECT st_bandisnodata($1, 1, $2) $$
    LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_bandpath(rast raster, band integer DEFAULT 1)
    RETURNS text
    AS '$libdir/rtpostgis-2.2','RASTER_getBandPath'
    LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_bandpixeltype(rast raster, band integer DEFAULT 1)
    RETURNS text
    AS '$libdir/rtpostgis-2.2','RASTER_getBandPixelTypeName'
    LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_bandmetadata(
	rast raster,
	band int[],
	OUT bandnum int,
	OUT pixeltype text,
	OUT nodatavalue double precision,
	OUT isoutdb boolean,
	OUT path text
)
	AS '$libdir/rtpostgis-2.2','RASTER_bandmetadata'
	LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_bandmetadata(
	rast raster,
	band int DEFAULT 1,
	OUT pixeltype text,
	OUT nodatavalue double precision,
	OUT isoutdb boolean,
	OUT path text
)
	AS $$ SELECT pixeltype, nodatavalue, isoutdb, path FROM st_bandmetadata($1, ARRAY[$2]::int[]) LIMIT 1 $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

-----------------------------------------------------------------------
-- Raster Pixel Accessors
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION st_value(rast raster, band integer, x integer, y integer, exclude_nodata_value boolean DEFAULT TRUE)
    RETURNS float8
    AS '$libdir/rtpostgis-2.2','RASTER_getPixelValue'
    LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_value(rast raster, x integer, y integer, exclude_nodata_value boolean DEFAULT TRUE)
    RETURNS float8
    AS $$ SELECT st_value($1, 1, $2, $3, $4) $$
    LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_value(rast raster, band integer, pt geometry, exclude_nodata_value boolean DEFAULT TRUE)
    RETURNS float8 AS
    $$
    DECLARE
        x float8;
        y float8;
        gtype text;
    BEGIN
        gtype := st_geometrytype(pt);
        IF ( gtype != 'ST_Point' ) THEN
            RAISE EXCEPTION 'Attempting to get the value of a pixel with a non-point geometry';
        END IF;

				IF ST_SRID(pt) != ST_SRID(rast) THEN
            RAISE EXCEPTION 'Raster and geometry do not have the same SRID';
				END IF;

        x := st_x(pt);
        y := st_y(pt);
        RETURN st_value(rast,
                        band,
                        st_worldtorastercoordx(rast, x, y),
                        st_worldtorastercoordy(rast, x, y),
                        exclude_nodata_value);
    END;
    $$
    LANGUAGE 'plpgsql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_value(rast raster, pt geometry, exclude_nodata_value boolean DEFAULT TRUE)
    RETURNS float8
    AS $$ SELECT st_value($1, 1, $2, $3) $$
    LANGUAGE 'sql' IMMUTABLE STRICT;

-----------------------------------------------------------------------
-- ST_PixelOfValue()
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION st_pixelofvalue(
	rast raster,
	nband integer,
	search double precision[],
	exclude_nodata_value boolean DEFAULT TRUE,
	OUT val double precision,
	OUT x integer,
	OUT y integer
)
	RETURNS SETOF record
	AS '$libdir/rtpostgis-2.2', 'RASTER_pixelOfValue'
	LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_pixelofvalue(
	rast raster,
	search double precision[],
	exclude_nodata_value boolean DEFAULT TRUE,
	OUT val double precision,
	OUT x integer,
	OUT y integer
)
	RETURNS SETOF record
	AS $$ SELECT val, x, y FROM st_pixelofvalue($1, 1, $2, $3) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_pixelofvalue(
	rast raster,
	nband integer,
	search double precision,
	exclude_nodata_value boolean DEFAULT TRUE,
	OUT x integer,
	OUT y integer
)
	RETURNS SETOF record
	AS $$ SELECT x, y FROM st_pixelofvalue($1, $2, ARRAY[$3], $4) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_pixelofvalue(
	rast raster,
	search double precision,
	exclude_nodata_value boolean DEFAULT TRUE,
	OUT x integer,
	OUT y integer
)
	RETURNS SETOF record
	AS $$ SELECT x, y FROM st_pixelofvalue($1, 1, ARRAY[$2], $3) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

-----------------------------------------------------------------------
-- Raster Accessors ST_Georeference()
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION st_georeference(rast raster, format text DEFAULT 'GDAL')
    RETURNS text AS
    $$
    DECLARE
				scale_x numeric;
				scale_y numeric;
				skew_x numeric;
				skew_y numeric;
				ul_x numeric;
				ul_y numeric;

        result text;
    BEGIN
			SELECT scalex::numeric, scaley::numeric, skewx::numeric, skewy::numeric, upperleftx::numeric, upperlefty::numeric
				INTO scale_x, scale_y, skew_x, skew_y, ul_x, ul_y FROM ST_Metadata(rast);

						-- scale x
            result := trunc(scale_x, 10) || E'\n';

						-- skew y
            result := result || trunc(skew_y, 10) || E'\n';

						-- skew x
            result := result || trunc(skew_x, 10) || E'\n';

						-- scale y
            result := result || trunc(scale_y, 10) || E'\n';

        IF format = 'ESRI' THEN
						-- upper left x
            result := result || trunc((ul_x + scale_x * 0.5), 10) || E'\n';

						-- upper left y
            result = result || trunc((ul_y + scale_y * 0.5), 10) || E'\n';
        ELSE -- IF format = 'GDAL' THEN
						-- upper left x
            result := result || trunc(ul_x, 10) || E'\n';

						-- upper left y
            result := result || trunc(ul_y, 10) || E'\n';
        END IF;

        RETURN result;
    END;
    $$
    LANGUAGE 'plpgsql' IMMUTABLE STRICT; -- WITH (isstrict);

-----------------------------------------------------------------------
-- Raster Editors
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION st_setscale(rast raster, scale float8)
    RETURNS raster
    AS '$libdir/rtpostgis-2.2','RASTER_setScale'
    LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_setscale(rast raster, scalex float8, scaley float8)
    RETURNS raster
    AS '$libdir/rtpostgis-2.2','RASTER_setScaleXY'
    LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_setskew(rast raster, skew float8)
    RETURNS raster
    AS '$libdir/rtpostgis-2.2','RASTER_setSkew'
    LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_setskew(rast raster, skewx float8, skewy float8)
    RETURNS raster
    AS '$libdir/rtpostgis-2.2','RASTER_setSkewXY'
    LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_setsrid(rast raster, srid integer)
    RETURNS raster
    AS '$libdir/rtpostgis-2.2','RASTER_setSRID'
    LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_setupperleft(rast raster, upperleftx float8, upperlefty float8)
    RETURNS raster
    AS '$libdir/rtpostgis-2.2','RASTER_setUpperLeftXY'
    LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_setrotation(rast raster, rotation float8)
    RETURNS raster
    AS '$libdir/rtpostgis-2.2','RASTER_setRotation'
    LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_setgeotransform(rast raster,
    imag double precision, 
    jmag double precision,
    theta_i double precision,
    theta_ij double precision,
    xoffset double precision,
    yoffset double precision)
    RETURNS raster
    AS '$libdir/rtpostgis-2.2','RASTER_setGeotransform'
    LANGUAGE 'c' IMMUTABLE;

-----------------------------------------------------------------------
-- Raster Editors ST_SetGeoreference()
-----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION st_setgeoreference(rast raster, georef text, format text DEFAULT 'GDAL')
    RETURNS raster AS
    $$
    DECLARE
        params text[];
        rastout raster;
    BEGIN
        IF rast IS NULL THEN
            RAISE WARNING 'Cannot set georeferencing on a null raster in st_setgeoreference.';
            RETURN rastout;
        END IF;

        SELECT regexp_matches(georef,
            E'(-?\\d+(?:\\.\\d+)?)\\s(-?\\d+(?:\\.\\d+)?)\\s(-?\\d+(?:\\.\\d+)?)\\s' ||
            E'(-?\\d+(?:\\.\\d+)?)\\s(-?\\d+(?:\\.\\d+)?)\\s(-?\\d+(?:\\.\\d+)?)') INTO params;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'st_setgeoreference requires a string with 6 floating point values.';
        END IF;

        IF format = 'ESRI' THEN
            -- params array is now:
            -- {scalex, skewy, skewx, scaley, upperleftx, upperlefty}
            rastout := st_setscale(rast, params[1]::float8, params[4]::float8);
            rastout := st_setskew(rastout, params[3]::float8, params[2]::float8);
            rastout := st_setupperleft(rastout,
                                   params[5]::float8 - (params[1]::float8 * 0.5),
                                   params[6]::float8 - (params[4]::float8 * 0.5));
        ELSE
            IF format != 'GDAL' THEN
                RAISE WARNING 'Format ''%'' is not recognized, defaulting to GDAL format.', format;
            END IF;
            -- params array is now:
            -- {scalex, skewy, skewx, scaley, upperleftx, upperlefty}

            rastout := st_setscale(rast, params[1]::float8, params[4]::float8);
            rastout := st_setskew( rastout, params[3]::float8, params[2]::float8);
            rastout := st_setupperleft(rastout, params[5]::float8, params[6]::float8);
        END IF;
        RETURN rastout;
    END;
    $$
    LANGUAGE 'plpgsql' IMMUTABLE STRICT; -- WITH (isstrict);

CREATE OR REPLACE FUNCTION st_setgeoreference(
	rast raster,
	upperleftx double precision, upperlefty double precision,
	scalex double precision, scaley double precision,
	skewx double precision, skewy double precision
)
	RETURNS raster
	AS $$ SELECT st_setgeoreference($1, array_to_string(ARRAY[$4, $7, $6, $5, $2, $3], ' ')) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

-----------------------------------------------------------------------
-- ST_Tile(raster)
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION _st_tile(
	rast raster,
	width integer, height integer,
	nband integer[] DEFAULT NULL,
	padwithnodata boolean DEFAULT FALSE, nodataval double precision DEFAULT NULL
)
	RETURNS SETOF raster
	AS '$libdir/rtpostgis-2.2','RASTER_tile'
	LANGUAGE 'c' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_tile(
	rast raster, nband integer[],
	width integer, height integer,
	padwithnodata boolean DEFAULT FALSE, nodataval double precision DEFAULT NULL
)
	RETURNS SETOF raster
	AS $$ SELECT _st_tile($1, $3, $4, $2, $5, $6) $$
	LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_tile(
	rast raster, nband integer,
	width integer, height integer,
	padwithnodata boolean DEFAULT FALSE, nodataval double precision DEFAULT NULL
)
	RETURNS SETOF raster
	AS $$ SELECT _st_tile($1, $3, $4, ARRAY[$2]::integer[], $5, $6) $$
	LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_tile(
	rast raster,
	width integer, height integer,
	padwithnodata boolean DEFAULT FALSE, nodataval double precision DEFAULT NULL
)
	RETURNS SETOF raster
	AS $$ SELECT _st_tile($1, $2, $3, NULL::integer[], $4, $5) $$
	LANGUAGE 'sql' IMMUTABLE;

-----------------------------------------------------------------------
-- Raster Band Editors
-----------------------------------------------------------------------

-- This function can not be STRICT, because nodatavalue can be NULL indicating that no nodata value should be set
CREATE OR REPLACE FUNCTION st_setbandnodatavalue(rast raster, band integer, nodatavalue float8, forceChecking boolean DEFAULT FALSE)
    RETURNS raster
    AS '$libdir/rtpostgis-2.2','RASTER_setBandNoDataValue'
    LANGUAGE 'c' IMMUTABLE;

-- This function can not be STRICT, because nodatavalue can be NULL indicating that no nodata value should be set
CREATE OR REPLACE FUNCTION st_setbandnodatavalue(rast raster, nodatavalue float8)
    RETURNS raster
    AS $$ SELECT st_setbandnodatavalue($1, 1, $2, FALSE) $$
    LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION st_setbandisnodata(rast raster, band integer DEFAULT 1)
    RETURNS raster
    AS '$libdir/rtpostgis-2.2', 'RASTER_setBandIsNoData'
    LANGUAGE 'c' IMMUTABLE STRICT;

-----------------------------------------------------------------------
-- Raster Pixel Editors
-----------------------------------------------------------------------

-----------------------------------------------------------------------
-- ST_SetValues (set one or more pixels to a one or more values)
-----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION _st_setvalues(
	rast raster, nband integer,
	x integer, y integer,
	newvalueset double precision[][],
	noset boolean[][] DEFAULT NULL,
	hasnosetvalue boolean DEFAULT FALSE,
	nosetvalue double precision DEFAULT NULL,
	keepnodata boolean DEFAULT FALSE
)
	RETURNS raster
	AS '$libdir/rtpostgis-2.2', 'RASTER_setPixelValuesArray'
	LANGUAGE 'c' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_setvalues(
	rast raster, nband integer,
	x integer, y integer,
	newvalueset double precision[][],
	noset boolean[][] DEFAULT NULL,
	keepnodata boolean DEFAULT FALSE
)
	RETURNS raster
	AS $$ SELECT _st_setvalues($1, $2, $3, $4, $5, $6, FALSE, NULL, $7) $$
	LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_setvalues(
	rast raster, nband integer,
	x integer, y integer,
	newvalueset double precision[][],
	nosetvalue double precision,
	keepnodata boolean DEFAULT FALSE
)
	RETURNS raster
	AS $$ SELECT _st_setvalues($1, $2, $3, $4, $5, NULL, TRUE, $6, $7) $$
	LANGUAGE 'sql' IMMUTABLE;

-- cannot be STRICT as newvalue can be NULL
CREATE OR REPLACE FUNCTION st_setvalues(
	rast raster, nband integer,
	x integer, y integer,
	width integer, height integer,
	newvalue double precision,
	keepnodata boolean DEFAULT FALSE
)
	RETURNS raster AS
	$$
	BEGIN
		IF width <= 0 OR height <= 0 THEN
			RAISE EXCEPTION 'Values for width and height must be greater than zero';
			RETURN NULL;
		END IF;
		RETURN _st_setvalues($1, $2, $3, $4, array_fill($7, ARRAY[$6, $5]::int[]), NULL, FALSE, NULL, $8);
	END;
	$$
	LANGUAGE 'plpgsql' IMMUTABLE;

-- cannot be STRICT as newvalue can be NULL
CREATE OR REPLACE FUNCTION st_setvalues(
	rast raster,
	x integer, y integer,
	width integer, height integer,
	newvalue double precision,
	keepnodata boolean DEFAULT FALSE
)
	RETURNS raster AS
	$$
	BEGIN
		IF width <= 0 OR height <= 0 THEN
			RAISE EXCEPTION 'Values for width and height must be greater than zero';
			RETURN NULL;
		END IF;
		RETURN _st_setvalues($1, 1, $2, $3, array_fill($6, ARRAY[$5, $4]::int[]), NULL, FALSE, NULL, $7);
	END;
	$$
	LANGUAGE 'plpgsql' IMMUTABLE;

-- cannot be STRICT as newvalue can be NULL
CREATE OR REPLACE FUNCTION st_setvalues(
	rast raster, nband integer,
	geomvalset geomval[],
	keepnodata boolean DEFAULT FALSE
)
	RETURNS raster
	AS '$libdir/rtpostgis-2.2', 'RASTER_setPixelValuesGeomval'
	LANGUAGE 'c' IMMUTABLE;

-----------------------------------------------------------------------
-- ST_SetValue (set one or more pixels to a single value)
-----------------------------------------------------------------------

-- This function can not be STRICT, because newvalue can be NULL for nodata
CREATE OR REPLACE FUNCTION st_setvalue(rast raster, band integer, x integer, y integer, newvalue float8)
    RETURNS raster
    AS '$libdir/rtpostgis-2.2','RASTER_setPixelValue'
    LANGUAGE 'c' IMMUTABLE;

-- This function can not be STRICT, because newvalue can be NULL for nodata
CREATE OR REPLACE FUNCTION st_setvalue(rast raster, x integer, y integer, newvalue float8)
    RETURNS raster
    AS $$ SELECT st_setvalue($1, 1, $2, $3, $4) $$
    LANGUAGE 'sql';

-- cannot be STRICT as newvalue can be NULL
CREATE OR REPLACE FUNCTION st_setvalue(
	rast raster, nband integer,
	geom geometry, newvalue double precision
)
	RETURNS raster
	AS $$ SELECT st_setvalues($1, $2, ARRAY[ROW($3, $4)]::geomval[], FALSE) $$
	LANGUAGE 'sql' IMMUTABLE;

-- cannot be STRICT as newvalue can be NULL
CREATE OR REPLACE FUNCTION st_setvalue(
	rast raster,
	geom geometry, newvalue double precision
)
	RETURNS raster
	AS $$ SELECT st_setvalues($1, 1, ARRAY[ROW($2, $3)]::geomval[], FALSE) $$
	LANGUAGE 'sql' IMMUTABLE;

-----------------------------------------------------------------------
-- Raster Processing Functions
-----------------------------------------------------------------------

-----------------------------------------------------------------------
-- ST_DumpAsPolygons
-----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION st_dumpaspolygons(rast raster, band integer DEFAULT 1, exclude_nodata_value boolean DEFAULT TRUE)
	RETURNS SETOF geomval
	AS '$libdir/rtpostgis-2.2','RASTER_dumpAsPolygons'
	LANGUAGE 'c' IMMUTABLE STRICT;

-----------------------------------------------------------------------
-- ST_DumpValues
-----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION st_dumpvalues(
	rast raster, nband integer[] DEFAULT NULL, exclude_nodata_value boolean DEFAULT TRUE,
	OUT nband integer, OUT valarray double precision[][]
)
	RETURNS SETOF record
	AS '$libdir/rtpostgis-2.2','RASTER_dumpValues'
	LANGUAGE 'c' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_dumpvalues(rast raster, nband integer, exclude_nodata_value boolean DEFAULT TRUE)
	RETURNS double precision[][]
	AS $$ SELECT valarray FROM st_dumpvalues($1, ARRAY[$2]::integer[], $3) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

-----------------------------------------------------------------------
-- ST_Polygon
-----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION st_polygon(rast raster, band integer DEFAULT 1)
	RETURNS geometry
	AS '$libdir/rtpostgis-2.2','RASTER_getPolygon'
	LANGUAGE 'c' IMMUTABLE STRICT;

-----------------------------------------------------------------------
-- ST_PixelAsPolygons
-- Return all the pixels of a raster as a geom, val, x, y record
-- Should be called like this:
-- SELECT (gv).geom, (gv).val FROM (SELECT ST_PixelAsPolygons(rast) gv FROM mytable) foo
-----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION _st_pixelaspolygons(
	rast raster,
	band integer DEFAULT 1,
	columnx integer DEFAULT NULL,
	rowy integer DEFAULT NULL,
	exclude_nodata_value boolean DEFAULT TRUE,
	OUT geom geometry,
	OUT val double precision,
	OUT x integer,
	OUT y integer
)
	RETURNS SETOF record
	AS '$libdir/rtpostgis-2.2', 'RASTER_getPixelPolygons'
	LANGUAGE 'c' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_pixelaspolygons(
	rast raster,
	band integer DEFAULT 1,
	exclude_nodata_value boolean DEFAULT TRUE,
	OUT geom geometry,
	OUT val double precision,
	OUT x int,
	OUT y int
)
	RETURNS SETOF record
	AS $$ SELECT geom, val, x, y FROM _st_pixelaspolygons($1, $2, NULL, NULL, $3) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

-----------------------------------------------------------------------
-- ST_PixelAsPolygon
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION st_pixelaspolygon(rast raster, x integer, y integer)
	RETURNS geometry
	AS $$ SELECT geom FROM _st_pixelaspolygons($1, NULL, $2, $3) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

-----------------------------------------------------------------------
-- ST_PixelAsPoints
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION st_pixelaspoints(
	rast raster,
	band integer DEFAULT 1,
	exclude_nodata_value boolean DEFAULT TRUE,
	OUT geom geometry,
	OUT val double precision,
	OUT x int,
	OUT y int
)
	RETURNS SETOF record
	AS $$ SELECT ST_PointN(ST_ExteriorRing(geom), 1), val, x, y FROM _st_pixelaspolygons($1, $2, NULL, NULL, $3) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

-----------------------------------------------------------------------
-- ST_PixelAsPoint
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION st_pixelaspoint(rast raster, x integer, y integer)
	RETURNS geometry
	AS $$ SELECT ST_PointN(ST_ExteriorRing(geom), 1) FROM _st_pixelaspolygons($1, NULL, $2, $3) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

-----------------------------------------------------------------------
-- ST_PixelAsCentroids
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION st_pixelascentroids(
	rast raster,
	band integer DEFAULT 1,
	exclude_nodata_value boolean DEFAULT TRUE,
	OUT geom geometry,
	OUT val double precision,
	OUT x int,
	OUT y int
)
	RETURNS SETOF record
	AS $$ SELECT ST_Centroid(geom), val, x, y FROM _st_pixelaspolygons($1, $2, NULL, NULL, $3) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

-----------------------------------------------------------------------
-- ST_PixelAsCentroid
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION st_pixelascentroid(rast raster, x integer, y integer)
	RETURNS geometry
	AS $$ SELECT ST_Centroid(geom) FROM _st_pixelaspolygons($1, NULL, $2, $3) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

-----------------------------------------------------------------------
-- Raster Utility Functions
-----------------------------------------------------------------------

-----------------------------------------------------------------------
-- ST_WorldToRasterCoord
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION _st_worldtorastercoord(
	rast raster,
	longitude double precision DEFAULT NULL, latitude double precision DEFAULT NULL,
	OUT columnx integer,
	OUT rowy integer
)
	AS '$libdir/rtpostgis-2.2', 'RASTER_worldToRasterCoord'
	LANGUAGE 'c' IMMUTABLE;

---------------------------------------------------------------------------------
-- ST_WorldToRasterCoord(rast raster, longitude float8, latitude float8)
-- Returns the pixel column and row covering the provided X and Y world
-- coordinates.
-- This function works even if the world coordinates are outside the raster extent.
---------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION st_worldtorastercoord(
	rast raster,
	longitude double precision, latitude double precision,
	OUT columnx integer,
	OUT rowy integer
)
	AS $$ SELECT columnx, rowy FROM _st_worldtorastercoord($1, $2, $3) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

---------------------------------------------------------------------------------
-- ST_WorldToRasterCoordX(rast raster, pt geometry)
-- Returns the pixel column and row covering the provided point geometry. 
-- This function works even if the point is outside the raster extent.
---------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION st_worldtorastercoord(
	rast raster, pt geometry,
	OUT columnx integer,
	OUT rowy integer
)
	AS
	$$
	DECLARE
		rx integer;
		ry integer;
	BEGIN
		IF st_geometrytype(pt) != 'ST_Point' THEN
			RAISE EXCEPTION 'Attempting to compute raster coordinate with a non-point geometry';
		END IF;
		IF ST_SRID(rast) != ST_SRID(pt) THEN
			RAISE EXCEPTION 'Raster and geometry do not have the same SRID';
		END IF;

		SELECT rc.columnx AS x, rc.rowy AS y INTO columnx, rowy FROM _st_worldtorastercoord($1, st_x(pt), st_y(pt)) AS rc;
		RETURN;
	END;
	$$
	LANGUAGE 'plpgsql' IMMUTABLE STRICT;

---------------------------------------------------------------------------------
-- ST_WorldToRasterCoordX(rast raster, xw float8, yw float8)
-- Returns the column number of the pixel covering the provided X and Y world
-- coordinates.
-- This function works even if the world coordinates are outside the raster extent.
---------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION st_worldtorastercoordx(rast raster, xw float8, yw float8)
	RETURNS int
	AS $$ SELECT columnx FROM _st_worldtorastercoord($1, $2, $3) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

---------------------------------------------------------------------------------
-- ST_WorldToRasterCoordX(rast raster, xw float8)
-- Returns the column number of the pixels covering the provided world X coordinate
-- for a non-rotated raster.
-- This function works even if the world coordinate is outside the raster extent.
-- This function returns an error if the raster is rotated. In this case you must
-- also provide a Y.
---------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION st_worldtorastercoordx(rast raster, xw float8)
	RETURNS int
	AS $$ SELECT columnx FROM _st_worldtorastercoord($1, $2, NULL) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

---------------------------------------------------------------------------------
-- ST_WorldToRasterCoordX(rast raster, pt geometry)
-- Returns the column number of the pixel covering the provided point geometry.
-- This function works even if the point is outside the raster extent.
---------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION st_worldtorastercoordx(rast raster, pt geometry)
	RETURNS int AS
	$$
	DECLARE
		xr integer;
	BEGIN
		IF ( st_geometrytype(pt) != 'ST_Point' ) THEN
			RAISE EXCEPTION 'Attempting to compute raster coordinate with a non-point geometry';
		END IF;
		IF ST_SRID(rast) != ST_SRID(pt) THEN
			RAISE EXCEPTION 'Raster and geometry do not have the same SRID';
		END IF;
		SELECT columnx INTO xr FROM _st_worldtorastercoord($1, st_x(pt), st_y(pt));
		RETURN xr;
	END;
	$$
	LANGUAGE 'plpgsql' IMMUTABLE STRICT;

---------------------------------------------------------------------------------
-- ST_WorldToRasterCoordY(rast raster, xw float8, yw float8)
-- Returns the row number of the pixel covering the provided X and Y world
-- coordinates.
-- This function works even if the world coordinates are outside the raster extent.
---------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION st_worldtorastercoordy(rast raster, xw float8, yw float8)
	RETURNS int
	AS $$ SELECT rowy FROM _st_worldtorastercoord($1, $2, $3) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

---------------------------------------------------------------------------------
-- ST_WorldToRasterCoordY(rast raster, yw float8)
-- Returns the row number of the pixels covering the provided world Y coordinate
-- for a non-rotated raster.
-- This function works even if the world coordinate is outside the raster extent.
-- This function returns an error if the raster is rotated. In this case you must
-- also provide an X.
---------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION st_worldtorastercoordy(rast raster, yw float8)
	RETURNS int
	AS $$ SELECT rowy FROM _st_worldtorastercoord($1, NULL, $2) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

---------------------------------------------------------------------------------
-- ST_WorldToRasterCoordY(rast raster, pt geometry)
-- Returns the row number of the pixel covering the provided point geometry.
-- This function works even if the point is outside the raster extent.
---------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION st_worldtorastercoordy(rast raster, pt geometry)
	RETURNS int AS
	$$
	DECLARE
		yr integer;
	BEGIN
		IF ( st_geometrytype(pt) != 'ST_Point' ) THEN
			RAISE EXCEPTION 'Attempting to compute raster coordinate with a non-point geometry';
		END IF;
		IF ST_SRID(rast) != ST_SRID(pt) THEN
			RAISE EXCEPTION 'Raster and geometry do not have the same SRID';
		END IF;
		SELECT rowy INTO yr FROM _st_worldtorastercoord($1, st_x(pt), st_y(pt));
		RETURN yr;
	END;
	$$
	LANGUAGE 'plpgsql' IMMUTABLE STRICT;

---------------------------------------------------------------------------------
-- ST_RasterToWorldCoord
---------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION _st_rastertoworldcoord(
	rast raster,
	columnx integer DEFAULT NULL, rowy integer DEFAULT NULL,
	OUT longitude double precision,
	OUT latitude double precision
)
	AS '$libdir/rtpostgis-2.2', 'RASTER_rasterToWorldCoord'
	LANGUAGE 'c' IMMUTABLE;

---------------------------------------------------------------------------------
-- ST_RasterToWorldCoordX(rast raster, xr int, yr int)
-- Returns the longitude and latitude of the upper left corner of the pixel
-- located at the provided pixel column and row.
-- This function works even if the provided raster column and row are beyond or
-- below the raster width and height.
---------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION st_rastertoworldcoord(
	rast raster,
	columnx integer, rowy integer,
	OUT longitude double precision,
	OUT latitude double precision
)
	AS $$ SELECT longitude, latitude FROM _st_rastertoworldcoord($1, $2, $3) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

---------------------------------------------------------------------------------
-- ST_RasterToWorldCoordX(rast raster, xr int, yr int)
-- Returns the X world coordinate of the upper left corner of the pixel located at
-- the provided column and row numbers.
-- This function works even if the provided raster column and row are beyond or
-- below the raster width and height.
---------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION st_rastertoworldcoordx(rast raster, xr int, yr int)
	RETURNS float8
	AS $$ SELECT longitude FROM _st_rastertoworldcoord($1, $2, $3) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

---------------------------------------------------------------------------------
-- ST_RasterToWorldCoordX(rast raster, xr int)
-- Returns the X world coordinate of the upper left corner of the pixel located at
-- the provided column number for a non-rotated raster.
-- This function works even if the provided raster column is beyond or below the
-- raster width.
-- This function returns an error if the raster is rotated. In this case you must
-- also provide a Y.
---------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION st_rastertoworldcoordx(rast raster, xr int)
	RETURNS float8
	AS $$ SELECT longitude FROM _st_rastertoworldcoord($1, $2, NULL) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

---------------------------------------------------------------------------------
-- ST_RasterToWorldCoordY(rast raster, xr int, yr int)
-- Returns the Y world coordinate of the upper left corner of the pixel located at
-- the provided column and row numbers.
-- This function works even if the provided raster column and row are beyond or
-- below the raster width and height.
---------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION st_rastertoworldcoordy(rast raster, xr int, yr int)
	RETURNS float8
	AS $$ SELECT latitude FROM _st_rastertoworldcoord($1, $2, $3) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

---------------------------------------------------------------------------------
-- ST_RasterToWorldCoordY(rast raster, yr int)
-- Returns the Y world coordinate of the upper left corner of the pixel located at
-- the provided row number for a non-rotated raster.
-- This function works even if the provided raster row is beyond or below the
-- raster height.
-- This function returns an error if the raster is rotated. In this case you must
-- also provide an X.
---------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION st_rastertoworldcoordy(rast raster, yr int)
	RETURNS float8
	AS $$ SELECT latitude FROM _st_rastertoworldcoord($1, NULL, $2) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

-----------------------------------------------------------------------
-- ST_MinPossibleValue(pixeltype text)
-- Return the smallest value for a given pixeltyp.
-- Should be called like this:
-- SELECT ST_MinPossibleValue(ST_BandPixelType(rast, band))
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION st_minpossiblevalue(pixeltype text)
	RETURNS double precision
	AS '$libdir/rtpostgis-2.2', 'RASTER_minPossibleValue'
	LANGUAGE 'c' IMMUTABLE STRICT;

-----------------------------------------------------------------------
-- Raster Outputs
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION st_asbinary(raster, outasin boolean DEFAULT FALSE)
    RETURNS bytea
    AS '$libdir/rtpostgis-2.2', 'RASTER_to_binary'
    LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bytea(raster)
    RETURNS bytea
    AS '$libdir/rtpostgis-2.2', 'RASTER_to_bytea'
    LANGUAGE 'c' IMMUTABLE STRICT;

------------------------------------------------------------------------------
--  Casts
------------------------------------------------------------------------------

CREATE CAST (raster AS box3d)
    WITH FUNCTION box3d(raster) AS ASSIGNMENT;

CREATE CAST (raster AS geometry)
    WITH FUNCTION st_convexhull(raster) AS ASSIGNMENT;

CREATE CAST (raster AS bytea)
    WITH FUNCTION bytea(raster) AS ASSIGNMENT;

-------------------------------------------------------------------
-- HASH operators
-------------------------------------------------------------------

-- call PostgreSQL's hashvarlena() function
-- Availability: 2.1.0
CREATE OR REPLACE FUNCTION raster_hash(raster)
	RETURNS integer
	AS 'hashvarlena'
	LANGUAGE 'internal' IMMUTABLE STRICT;

-- use raster_hash() to compare
-- Availability: 2.1.0
CREATE OR REPLACE FUNCTION raster_eq(raster, raster)
	RETURNS bool
	AS $$ SELECT raster_hash($1) = raster_hash($2) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

-- Availability: 2.1.0
CREATE OPERATOR = (
	LEFTARG = raster, RIGHTARG = raster, PROCEDURE = raster_eq,
	COMMUTATOR = '=',
	RESTRICT = eqsel, JOIN = eqjoinsel
);

-- Availability: 2.1.0
CREATE OPERATOR CLASS hash_raster_ops
	DEFAULT FOR TYPE raster USING hash AS
	OPERATOR	1	= ,
	FUNCTION	1	raster_hash (raster);

------------------------------------------------------------------------------
--  GiST index OPERATOR support functions
------------------------------------------------------------------------------
-- raster/raster functions
CREATE OR REPLACE FUNCTION raster_overleft(raster, raster)
    RETURNS bool
    AS 'select $1::geometry &< $2::geometry'
    LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION raster_overright(raster, raster)
    RETURNS bool
    AS 'select $1::geometry &> $2::geometry'
    LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION raster_left(raster, raster)
    RETURNS bool
    AS 'select $1::geometry << $2::geometry'
    LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION raster_right(raster, raster)
    RETURNS bool
    AS 'select $1::geometry >> $2::geometry'
    LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION raster_overabove(raster, raster)
    RETURNS bool
    AS 'select $1::geometry |&> $2::geometry'
    LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION raster_overbelow(raster, raster)
    RETURNS bool
    AS 'select $1::geometry &<| $2::geometry'
    LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION raster_above(raster, raster)
    RETURNS bool
    AS 'select $1::geometry |>> $2::geometry'
    LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION raster_below(raster, raster)
    RETURNS bool
    AS 'select $1::geometry <<| $2::geometry'
    LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION raster_same(raster, raster)
    RETURNS bool
    AS 'select $1::geometry ~= $2::geometry'
    LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION raster_contained(raster, raster)
    RETURNS bool
    AS 'select $1::geometry @ $2::geometry'
    LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION raster_contain(raster, raster)
    RETURNS bool
    AS 'select $1::geometry ~ $2::geometry'
    LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION raster_overlap(raster, raster)
    RETURNS bool
    AS 'select $1::geometry && $2::geometry'
    LANGUAGE 'sql' IMMUTABLE STRICT;

-- raster/geometry functions

-- Availability: 2.0.0
CREATE OR REPLACE FUNCTION raster_geometry_contain(raster, geometry)
    RETURNS bool
    AS 'select $1::geometry ~ $2'
    LANGUAGE 'sql' IMMUTABLE STRICT;

-- Availability: 2.0.5
CREATE OR REPLACE FUNCTION raster_contained_by_geometry(raster, geometry)
    RETURNS bool
    AS 'select $1::geometry @ $2'
    LANGUAGE 'sql' IMMUTABLE STRICT;

-- Availability: 2.0.0
CREATE OR REPLACE FUNCTION raster_geometry_overlap(raster, geometry)
    RETURNS bool
    AS 'select $1::geometry && $2'
    LANGUAGE 'sql' IMMUTABLE STRICT;
    
-- geometry/raster functions

-- Availability: 2.0.0
CREATE OR REPLACE FUNCTION geometry_raster_contain(geometry, raster)
    RETURNS bool
    AS 'select $1 ~ $2::geometry'
    LANGUAGE 'sql' IMMUTABLE STRICT;

-- Availability: 2.0.5
CREATE OR REPLACE FUNCTION geometry_contained_by_raster(geometry, raster)
    RETURNS bool
    AS 'select $1 @ $2::geometry'
    LANGUAGE 'sql' IMMUTABLE STRICT;

-- Availability: 2.0.0
CREATE OR REPLACE FUNCTION geometry_raster_overlap(geometry, raster)
    RETURNS bool
    AS 'select $1 && $2::geometry'
    LANGUAGE 'sql' IMMUTABLE STRICT;
    
------------------------------------------------------------------------------
--  GiST index OPERATORs
------------------------------------------------------------------------------
-- raster/raster operators

-- Availability: 2.0.0
CREATE OPERATOR << (
    LEFTARG = raster, RIGHTARG = raster, PROCEDURE = raster_left,
    COMMUTATOR = '>>',
    RESTRICT = positionsel, JOIN = positionjoinsel
    );

-- Availability: 2.0.0
CREATE OPERATOR &< (
    LEFTARG = raster, RIGHTARG = raster, PROCEDURE = raster_overleft,
    COMMUTATOR = '&>',
    RESTRICT = positionsel, JOIN = positionjoinsel
    );

-- Availability: 2.0.0
CREATE OPERATOR <<| (
    LEFTARG = raster, RIGHTARG = raster, PROCEDURE = raster_below,
    COMMUTATOR = '|>>',
    RESTRICT = positionsel, JOIN = positionjoinsel
    );

-- Availability: 2.0.0
CREATE OPERATOR &<| (
    LEFTARG = raster, RIGHTARG = raster, PROCEDURE = raster_overbelow,
    COMMUTATOR = '|&>',
    RESTRICT = positionsel, JOIN = positionjoinsel
    );

-- Availability: 2.0.0
CREATE OPERATOR && (
    LEFTARG = raster, RIGHTARG = raster, PROCEDURE = raster_overlap,
    COMMUTATOR = '&&',
    RESTRICT = contsel, JOIN = contjoinsel
    );

-- Availability: 2.0.0
CREATE OPERATOR &> (
    LEFTARG = raster, RIGHTARG = raster, PROCEDURE = raster_overright,
    COMMUTATOR = '&<',
    RESTRICT = positionsel, JOIN = positionjoinsel
    );

-- Availability: 2.0.0
CREATE OPERATOR >> (
    LEFTARG = raster, RIGHTARG = raster, PROCEDURE = raster_right,
    COMMUTATOR = '<<',
    RESTRICT = positionsel, JOIN = positionjoinsel
    );

-- Availability: 2.0.0
CREATE OPERATOR |&> (
    LEFTARG = raster, RIGHTARG = raster, PROCEDURE = raster_overabove,
    COMMUTATOR = '&<|',
    RESTRICT = positionsel, JOIN = positionjoinsel
    );

-- Availability: 2.0.0
CREATE OPERATOR |>> (
    LEFTARG = raster, RIGHTARG = raster, PROCEDURE = raster_above,
    COMMUTATOR = '<<|',
    RESTRICT = positionsel, JOIN = positionjoinsel
    );

-- Availability: 2.0.0
CREATE OPERATOR ~= (
    LEFTARG = raster, RIGHTARG = raster, PROCEDURE = raster_same,
    COMMUTATOR = '~=',
    RESTRICT = eqsel, JOIN = eqjoinsel
    );

-- Availability: 2.0.0
CREATE OPERATOR @ (
    LEFTARG = raster, RIGHTARG = raster, PROCEDURE = raster_contained,
    COMMUTATOR = '~',
    RESTRICT = contsel, JOIN = contjoinsel
    );

-- Availability: 2.0.0
CREATE OPERATOR ~ (
    LEFTARG = raster, RIGHTARG = raster, PROCEDURE = raster_contain,
    COMMUTATOR = '@',
    RESTRICT = contsel, JOIN = contjoinsel
    );

-- raster/geometry operators

-- Availability: 2.0.0
-- NOTE: 2.1.2 removed the commutator spec but it was wrong
--       See http://trac.osgeo.org/postgis/ticket/3039
CREATE OPERATOR ~ (
    LEFTARG = raster, RIGHTARG = geometry, PROCEDURE = raster_geometry_contain,
    -- COMMUTATOR = '@', -- see http://trac.osgeo.org/postgis/ticket/2532
    RESTRICT = contsel, JOIN = contjoinsel
    );

-- Availability: 2.0.5
-- NOTE: was missing in 2.1.0 but was added in 2.1.1
CREATE OPERATOR @ (
    LEFTARG = raster, RIGHTARG = geometry, PROCEDURE = raster_contained_by_geometry,
    COMMUTATOR = '~',
    RESTRICT = contsel, JOIN = contjoinsel
    );

-- Availability: 2.0.0
CREATE OPERATOR && (
    LEFTARG = raster, RIGHTARG = geometry, PROCEDURE = raster_geometry_overlap,
    COMMUTATOR = '&&',
    RESTRICT = contsel, JOIN = contjoinsel
    );

-- geometry/raster operators

-- Availability: 2.0.0
-- NOTE: 2.1.2 removed the commutator spec but it was wrong
--       See http://trac.osgeo.org/postgis/ticket/3039
CREATE OPERATOR ~ (
    LEFTARG = geometry, RIGHTARG = raster, PROCEDURE = geometry_raster_contain,
    -- COMMUTATOR = '@', -- see http://trac.osgeo.org/postgis/ticket/2532
    RESTRICT = contsel, JOIN = contjoinsel
    );

-- Availability: 2.0.5
-- NOTE: was missing in 2.1.0 but was added in 2.1.1
CREATE OPERATOR @ (
    LEFTARG = geometry, RIGHTARG = raster, PROCEDURE = geometry_contained_by_raster,
    COMMUTATOR = '~',
    RESTRICT = contsel, JOIN = contjoinsel
    );

-- Availability: 2.0.0
CREATE OPERATOR && (
    LEFTARG = geometry, RIGHTARG = raster, PROCEDURE = geometry_raster_overlap,
    COMMUTATOR = '&&',
    RESTRICT = contsel, JOIN = contjoinsel
    );

-----------------------------------------------------------------------
-- Raster/Raster Spatial Relationship
-----------------------------------------------------------------------

-----------------------------------------------------------------------
-- ST_SameAlignment
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION st_samealignment(rast1 raster, rast2 raster)
	RETURNS boolean
	AS '$libdir/rtpostgis-2.2', 'RASTER_sameAlignment'
	LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_samealignment(
	ulx1 double precision, uly1 double precision, scalex1 double precision, scaley1 double precision, skewx1 double precision, skewy1 double precision,
	ulx2 double precision, uly2 double precision, scalex2 double precision, scaley2 double precision, skewx2 double precision, skewy2 double precision
)
	RETURNS boolean
	AS $$ SELECT st_samealignment(st_makeemptyraster(1, 1, $1, $2, $3, $4, $5, $6), st_makeemptyraster(1, 1, $7, $8, $9, $10, $11, $12)) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

-- Availability: 2.1.0
CREATE TYPE agg_samealignment AS (
	refraster raster,
	aligned boolean
);

CREATE OR REPLACE FUNCTION _st_samealignment_transfn(agg agg_samealignment, rast raster)
	RETURNS agg_samealignment AS $$
	DECLARE
		m record;
		aligned boolean;
	BEGIN
		IF agg IS NULL THEN
			agg.refraster := NULL;
			agg.aligned := NULL;
		END IF;

		IF rast IS NULL THEN
			agg.aligned := NULL;
		ELSE
			IF agg.refraster IS NULL THEN
				m := ST_Metadata(rast);
				agg.refraster := ST_MakeEmptyRaster(1, 1, m.upperleftx, m.upperlefty, m.scalex, m.scaley, m.skewx, m.skewy, m.srid);
				agg.aligned := TRUE;
			ELSE IF agg.aligned IS TRUE THEN
					agg.aligned := ST_SameAlignment(agg.refraster, rast);
				END IF;
			END IF;
		END IF;
		RETURN agg;
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION _st_samealignment_finalfn(agg agg_samealignment)
	RETURNS boolean
	AS $$ SELECT $1.aligned $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

-- Availability: 2.1.0
CREATE AGGREGATE st_samealignment(raster) (
	SFUNC = _st_samealignment_transfn,
	STYPE = agg_samealignment,
	FINALFUNC = _st_samealignment_finalfn
);

-----------------------------------------------------------------------
-- ST_NotSameAlignmentReason
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION st_notsamealignmentreason(rast1 raster, rast2 raster)
	RETURNS text
	AS '$libdir/rtpostgis-2.2', 'RASTER_notSameAlignmentReason'
	LANGUAGE 'c' IMMUTABLE STRICT;

-----------------------------------------------------------------------
-- ST_IsCoverageTile
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION st_iscoveragetile(rast raster, coverage raster, tilewidth integer, tileheight integer)
	RETURNS boolean
	AS $$
	DECLARE
		_rastmeta record;
		_covmeta record;
		cr record;
		max integer[];
		tile integer[];
		edge integer[];
	BEGIN
		IF NOT ST_SameAlignment(rast, coverage) THEN
			RAISE NOTICE 'Raster and coverage are not aligned';
			RETURN FALSE;
		END IF;

		_rastmeta := ST_Metadata(rast);
		_covmeta := ST_Metadata(coverage);

		-- get coverage grid coordinates of upper-left of rast
		cr := ST_WorldToRasterCoord(coverage, _rastmeta.upperleftx, _rastmeta.upperlefty);

		-- rast is not part of coverage
		IF
			(cr.columnx < 1 OR cr.columnx > _covmeta.width) OR
			(cr.rowy < 1 OR cr.rowy > _covmeta.height)
		THEN
			RAISE NOTICE 'Raster is not in the coverage';
			RETURN FALSE;
		END IF;

		-- rast isn't on the coverage's grid
		IF
			((cr.columnx - 1) % tilewidth != 0) OR
			((cr.rowy - 1) % tileheight != 0)
		THEN
			RAISE NOTICE 'Raster is not aligned to tile grid of coverage';
			RETURN FALSE;
		END IF;

		-- max # of tiles on X and Y for coverage
		max[0] := ceil(_covmeta.width::double precision / tilewidth::double precision)::integer;
		max[1] := ceil(_covmeta.height::double precision / tileheight::double precision)::integer;

		-- tile # of rast in coverge
		tile[0] := (cr.columnx / tilewidth) + 1;
		tile[1] := (cr.rowy / tileheight) + 1;

		-- inner tile
		IF tile[0] < max[0] AND tile[1] < max[1] THEN
			IF
				(_rastmeta.width != tilewidth) OR
				(_rastmeta.height != tileheight)
			THEN
				RAISE NOTICE 'Raster width/height is invalid for interior tile of coverage';
				RETURN FALSE;
			ELSE
				RETURN TRUE;
			END IF;
		END IF;

		-- edge tile

		-- edge tile may have same size as inner tile
		IF 
			(_rastmeta.width = tilewidth) AND
			(_rastmeta.height = tileheight)
		THEN
			RETURN TRUE;
		END IF;

		-- get edge tile width and height
		edge[0] := _covmeta.width - ((max[0] - 1) * tilewidth);
		edge[1] := _covmeta.height - ((max[1] - 1) * tileheight);

		-- edge tile not of expected tile size
		-- right and bottom
		IF tile[0] = max[0] AND tile[1] = max[1] THEN
			IF
				_rastmeta.width != edge[0] OR
				_rastmeta.height != edge[1]
			THEN
				RAISE NOTICE 'Raster width/height is invalid for right-most AND bottom-most tile of coverage';
				RETURN FALSE;
			END IF;
		ELSEIF tile[0] = max[0] THEN
			IF
				_rastmeta.width != edge[0] OR
				_rastmeta.height != tileheight
			THEN
				RAISE NOTICE 'Raster width/height is invalid for right-most tile of coverage';
				RETURN FALSE;
			END IF;
		ELSE
			IF
				_rastmeta.width != tilewidth OR
				_rastmeta.height != edge[1]
			THEN
				RAISE NOTICE 'Raster width/height is invalid for bottom-most tile of coverage';
				RETURN FALSE;
			END IF;
		END IF;

		RETURN TRUE;
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE STRICT;

-----------------------------------------------------------------------
-- ST_Intersects(raster, raster)
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION _st_intersects(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
	RETURNS boolean
	AS '$libdir/rtpostgis-2.2', 'RASTER_intersects'
	LANGUAGE 'c' IMMUTABLE STRICT
	COST 1000;

CREATE OR REPLACE FUNCTION st_intersects(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
	RETURNS boolean
	AS $$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_intersects(st_convexhull($1), st_convexhull($3)) ELSE _st_intersects($1, $2, $3, $4) END $$
	LANGUAGE 'sql' IMMUTABLE
	COST 1000;

CREATE OR REPLACE FUNCTION st_intersects(rast1 raster, rast2 raster)
	RETURNS boolean
	AS $$ SELECT st_intersects($1, NULL::integer, $2, NULL::integer) $$
	LANGUAGE 'sql' IMMUTABLE
	COST 1000;

-----------------------------------------------------------------------
-- ST_Intersects(geometry, raster)
-----------------------------------------------------------------------

-- This function can not be STRICT
CREATE OR REPLACE FUNCTION _st_intersects(geom geometry, rast raster, nband integer DEFAULT NULL)
	RETURNS boolean AS $$
	DECLARE
		hasnodata boolean := TRUE;
		_geom geometry;
	BEGIN
		IF ST_SRID(rast) != ST_SRID(geom) THEN
			RAISE EXCEPTION 'Raster and geometry do not have the same SRID';
		END IF;

		_geom := ST_ConvexHull(rast);
		IF nband IS NOT NULL THEN
			SELECT CASE WHEN bmd.nodatavalue IS NULL THEN FALSE ELSE NULL END INTO hasnodata FROM ST_BandMetaData(rast, nband) AS bmd;
		END IF;

		IF ST_Intersects(geom, _geom) IS NOT TRUE THEN
			RETURN FALSE;
		ELSEIF nband IS NULL OR hasnodata IS FALSE THEN
			RETURN TRUE;
		END IF;

		SELECT ST_Collect(t.geom) INTO _geom FROM ST_PixelAsPolygons(rast, nband) AS t;
		RETURN ST_Intersects(geom, _geom);
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE
	COST 1000;

-- This function can not be STRICT
CREATE OR REPLACE FUNCTION st_intersects(geom geometry, rast raster, nband integer DEFAULT NULL)
	RETURNS boolean AS
	$$ SELECT $1 && $2::geometry AND _st_intersects($1, $2, $3); $$
	LANGUAGE 'sql' IMMUTABLE
	COST 1000;

-----------------------------------------------------------------------
-- ST_Intersects(raster, geometry)
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION st_intersects(rast raster, geom geometry, nband integer DEFAULT NULL)
	RETURNS boolean
	AS $$ SELECT $1::geometry && $2 AND _st_intersects($2, $1, $3) $$
	LANGUAGE 'sql' IMMUTABLE
	COST 1000;

CREATE OR REPLACE FUNCTION st_intersects(rast raster, nband integer, geom geometry)
	RETURNS boolean
	AS $$ SELECT $1::geometry && $3 AND _st_intersects($3, $1, $2) $$
	LANGUAGE 'sql' IMMUTABLE
	COST 1000;

-----------------------------------------------------------------------
-- ST_Overlaps(raster, raster)
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION _st_overlaps(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
	RETURNS boolean
	AS '$libdir/rtpostgis-2.2', 'RASTER_overlaps'
	LANGUAGE 'c' IMMUTABLE STRICT
	COST 1000;

CREATE OR REPLACE FUNCTION st_overlaps(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
	RETURNS boolean
	AS $$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_overlaps(st_convexhull($1), st_convexhull($3)) ELSE _st_overlaps($1, $2, $3, $4) END $$
	LANGUAGE 'sql' IMMUTABLE
	COST 1000;

CREATE OR REPLACE FUNCTION st_overlaps(rast1 raster, rast2 raster)
	RETURNS boolean
	AS $$ SELECT st_overlaps($1, NULL::integer, $2, NULL::integer) $$
	LANGUAGE 'sql' IMMUTABLE
	COST 1000;

-----------------------------------------------------------------------
-- ST_Touches(raster, raster)
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION _st_touches(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
	RETURNS boolean
	AS '$libdir/rtpostgis-2.2', 'RASTER_touches'
	LANGUAGE 'c' IMMUTABLE STRICT
	COST 1000;

CREATE OR REPLACE FUNCTION st_touches(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
	RETURNS boolean
	AS $$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_touches(st_convexhull($1), st_convexhull($3)) ELSE _st_touches($1, $2, $3, $4) END $$
	LANGUAGE 'sql' IMMUTABLE
	COST 1000;

CREATE OR REPLACE FUNCTION st_touches(rast1 raster, rast2 raster)
	RETURNS boolean
	AS $$ SELECT st_touches($1, NULL::integer, $2, NULL::integer) $$
	LANGUAGE 'sql' IMMUTABLE
	COST 1000;

-----------------------------------------------------------------------
-- ST_Contains(raster, raster)
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION _st_contains(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
	RETURNS boolean
	AS '$libdir/rtpostgis-2.2', 'RASTER_contains'
	LANGUAGE 'c' IMMUTABLE STRICT
	COST 1000;

CREATE OR REPLACE FUNCTION st_contains(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
	RETURNS boolean
	AS $$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_contains(st_convexhull($1), st_convexhull($3)) ELSE _st_contains($1, $2, $3, $4) END $$
	LANGUAGE 'sql' IMMUTABLE
	COST 1000;

CREATE OR REPLACE FUNCTION st_contains(rast1 raster, rast2 raster)
	RETURNS boolean
	AS $$ SELECT st_contains($1, NULL::integer, $2, NULL::integer) $$
	LANGUAGE 'sql' IMMUTABLE
	COST 1000;

-----------------------------------------------------------------------
-- ST_ContainsProperly(raster, raster)
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION _st_containsproperly(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
	RETURNS boolean
	AS '$libdir/rtpostgis-2.2', 'RASTER_containsProperly'
	LANGUAGE 'c' IMMUTABLE STRICT
	COST 1000;

CREATE OR REPLACE FUNCTION st_containsproperly(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
	RETURNS boolean
	AS $$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_containsproperly(st_convexhull($1), st_convexhull($3)) ELSE _st_containsproperly($1, $2, $3, $4) END $$
	LANGUAGE 'sql' IMMUTABLE
	COST 1000;

CREATE OR REPLACE FUNCTION st_containsproperly(rast1 raster, rast2 raster)
	RETURNS boolean
	AS $$ SELECT st_containsproperly($1, NULL::integer, $2, NULL::integer) $$
	LANGUAGE 'sql' IMMUTABLE
	COST 1000;

-----------------------------------------------------------------------
-- ST_Covers(raster, raster)
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION _st_covers(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
	RETURNS boolean
	AS '$libdir/rtpostgis-2.2', 'RASTER_covers'
	LANGUAGE 'c' IMMUTABLE STRICT
	COST 1000;

CREATE OR REPLACE FUNCTION st_covers(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
	RETURNS boolean
	AS $$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_covers(st_convexhull($1), st_convexhull($3)) ELSE _st_covers($1, $2, $3, $4) END $$
	LANGUAGE 'sql' IMMUTABLE
	COST 1000;

CREATE OR REPLACE FUNCTION st_covers(rast1 raster, rast2 raster)
	RETURNS boolean
	AS $$ SELECT st_covers($1, NULL::integer, $2, NULL::integer) $$
	LANGUAGE 'sql' IMMUTABLE
	COST 1000;

-----------------------------------------------------------------------
-- ST_CoveredBy(raster, raster)
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION _st_coveredby(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
	RETURNS boolean
	AS '$libdir/rtpostgis-2.2', 'RASTER_coveredby'
	LANGUAGE 'c' IMMUTABLE STRICT
	COST 1000;

CREATE OR REPLACE FUNCTION st_coveredby(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
	RETURNS boolean
	AS $$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_coveredby(st_convexhull($1), st_convexhull($3)) ELSE _st_coveredby($1, $2, $3, $4) END $$
	LANGUAGE 'sql' IMMUTABLE
	COST 1000;

CREATE OR REPLACE FUNCTION st_coveredby(rast1 raster, rast2 raster)
	RETURNS boolean
	AS $$ SELECT st_coveredby($1, NULL::integer, $2, NULL::integer) $$
	LANGUAGE 'sql' IMMUTABLE
	COST 1000;

-----------------------------------------------------------------------
-- ST_Within(raster, raster)
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION _st_within(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
	RETURNS boolean
	AS $$ SELECT _st_contains($3, $4, $1, $2) $$
	LANGUAGE 'sql' IMMUTABLE
	COST 1000;

CREATE OR REPLACE FUNCTION st_within(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
	RETURNS boolean
	AS $$ SELECT $1 && $3 AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_within(st_convexhull($1), st_convexhull($3)) ELSE _st_contains($3, $4, $1, $2) END $$
	LANGUAGE 'sql' IMMUTABLE
	COST 1000;

CREATE OR REPLACE FUNCTION st_within(rast1 raster, rast2 raster)
	RETURNS boolean
	AS $$ SELECT st_within($1, NULL::integer, $2, NULL::integer) $$
	LANGUAGE 'sql' IMMUTABLE
	COST 1000;

-----------------------------------------------------------------------
-- ST_DWithin(raster, raster)
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION _st_dwithin(rast1 raster, nband1 integer, rast2 raster, nband2 integer, distance double precision)
	RETURNS boolean
	AS '$libdir/rtpostgis-2.2', 'RASTER_dwithin'
	LANGUAGE 'c' IMMUTABLE STRICT
	COST 1000;

CREATE OR REPLACE FUNCTION st_dwithin(rast1 raster, nband1 integer, rast2 raster, nband2 integer, distance double precision)
	RETURNS boolean
	AS $$ SELECT $1::geometry && ST_Expand(ST_ConvexHull($3), $5) AND $3::geometry && ST_Expand(ST_ConvexHull($1), $5) AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_dwithin(st_convexhull($1), st_convexhull($3), $5) ELSE _st_dwithin($1, $2, $3, $4, $5) END $$
	LANGUAGE 'sql' IMMUTABLE
	COST 1000;

CREATE OR REPLACE FUNCTION st_dwithin(rast1 raster, rast2 raster, distance double precision)
	RETURNS boolean
	AS $$ SELECT st_dwithin($1, NULL::integer, $2, NULL::integer, $3) $$
	LANGUAGE 'sql' IMMUTABLE
	COST 1000;

-----------------------------------------------------------------------
-- ST_DFullyWithin(raster, raster)
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION _st_dfullywithin(rast1 raster, nband1 integer, rast2 raster, nband2 integer, distance double precision)
	RETURNS boolean
	AS '$libdir/rtpostgis-2.2', 'RASTER_dfullywithin'
	LANGUAGE 'c' IMMUTABLE STRICT
	COST 1000;

CREATE OR REPLACE FUNCTION st_dfullywithin(rast1 raster, nband1 integer, rast2 raster, nband2 integer, distance double precision)
	RETURNS boolean
	AS $$ SELECT $1::geometry && ST_Expand(ST_ConvexHull($3), $5) AND $3::geometry && ST_Expand(ST_ConvexHull($1), $5) AND CASE WHEN $2 IS NULL OR $4 IS NULL THEN _st_dfullywithin(st_convexhull($1), st_convexhull($3), $5) ELSE _st_dfullywithin($1, $2, $3, $4, $5) END $$
	LANGUAGE 'sql' IMMUTABLE
	COST 1000;

CREATE OR REPLACE FUNCTION st_dfullywithin(rast1 raster, rast2 raster, distance double precision)
	RETURNS boolean
	AS $$ SELECT st_dfullywithin($1, NULL::integer, $2, NULL::integer, $3) $$
	LANGUAGE 'sql' IMMUTABLE
	COST 1000;

-----------------------------------------------------------------------
-- ST_Disjoint(raster, raster)
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION st_disjoint(rast1 raster, nband1 integer, rast2 raster, nband2 integer)
	RETURNS boolean
	AS $$ SELECT CASE WHEN $2 IS NULL OR $4 IS NULL THEN st_disjoint(st_convexhull($1), st_convexhull($3)) ELSE NOT _st_intersects($1, $2, $3, $4) END $$
	LANGUAGE 'sql' IMMUTABLE
	COST 1000;

CREATE OR REPLACE FUNCTION st_disjoint(rast1 raster, rast2 raster)
	RETURNS boolean
	AS $$ SELECT st_disjoint($1, NULL::integer, $2, NULL::integer) $$
	LANGUAGE 'sql' IMMUTABLE
	COST 1000;

-----------------------------------------------------------------------
-- ST_Intersection(geometry, raster) in geometry-space
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION st_intersection(geomin geometry, rast raster, band integer DEFAULT 1)
	RETURNS SETOF geomval AS $$
	DECLARE
		intersects boolean := FALSE;
	BEGIN
		intersects := ST_Intersects(geomin, rast, band);
		IF intersects THEN
			-- Return the intersections of the geometry with the vectorized parts of
			-- the raster and the values associated with those parts, if really their
			-- intersection is not empty.
			RETURN QUERY
				SELECT
					intgeom,
					val
				FROM (
					SELECT
						ST_Intersection((gv).geom, geomin) AS intgeom,
						(gv).val
					FROM ST_DumpAsPolygons(rast, band) gv
					WHERE ST_Intersects((gv).geom, geomin)
				) foo
				WHERE NOT ST_IsEmpty(intgeom);
		ELSE
			-- If the geometry does not intersect with the raster, return an empty
			-- geometry and a null value
			RETURN QUERY
				SELECT
					emptygeom,
					NULL::float8
				FROM ST_GeomCollFromText('GEOMETRYCOLLECTION EMPTY', ST_SRID($1)) emptygeom;
		END IF;
	END;
	$$
	LANGUAGE 'plpgsql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_intersection(rast raster, band integer, geomin geometry)
	RETURNS SETOF geomval AS
	$$ SELECT st_intersection($3, $1, $2) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_intersection(rast raster, geomin geometry)
	RETURNS SETOF geomval AS
	$$ SELECT st_intersection($2, $1, 1) $$
	LANGUAGE 'sql' STABLE;

-----------------------------------------------------------------------
-- ST_Intersection(raster, raster)
-----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION st_intersection(
	rast1 raster, band1 int,
	rast2 raster, band2 int,
	returnband text DEFAULT 'BOTH',
	nodataval double precision[] DEFAULT NULL
)
	RETURNS raster
	AS $$
	DECLARE
		rtn raster;
		_returnband text;
		newnodata1 float8;
		newnodata2 float8;
	BEGIN
		IF ST_SRID(rast1) != ST_SRID(rast2) THEN
			RAISE EXCEPTION 'The two rasters do not have the same SRID';
		END IF;

		newnodata1 := coalesce(nodataval[1], ST_BandNodataValue(rast1, band1), ST_MinPossibleValue(ST_BandPixelType(rast1, band1)));
		newnodata2 := coalesce(nodataval[2], ST_BandNodataValue(rast2, band2), ST_MinPossibleValue(ST_BandPixelType(rast2, band2)));
		
		_returnband := upper(returnband);

		rtn := NULL;
		CASE
			WHEN _returnband = 'BAND1' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast1.val]', ST_BandPixelType(rast1, band1), 'INTERSECTION', newnodata1::text, newnodata1::text, newnodata1);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata1);
			WHEN _returnband = 'BAND2' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast2.val]', ST_BandPixelType(rast2, band2), 'INTERSECTION', newnodata2::text, newnodata2::text, newnodata2);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata2);
			WHEN _returnband = 'BOTH' THEN
				rtn := ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast1.val]', ST_BandPixelType(rast1, band1), 'INTERSECTION', newnodata1::text, newnodata1::text, newnodata1);
				rtn := ST_SetBandNodataValue(rtn, 1, newnodata1);
				rtn := ST_AddBand(rtn, ST_MapAlgebraExpr(rast1, band1, rast2, band2, '[rast2.val]', ST_BandPixelType(rast2, band2), 'INTERSECTION', newnodata2::text, newnodata2::text, newnodata2));
				rtn := ST_SetBandNodataValue(rtn, 2, newnodata2);
			ELSE
				RAISE EXCEPTION 'Unknown value provided for returnband: %', returnband;
				RETURN NULL;
		END CASE;

		RETURN rtn;
	END;
	$$ LANGUAGE 'plpgsql' STABLE;

CREATE OR REPLACE FUNCTION st_intersection(
	rast1 raster, band1 int,
	rast2 raster, band2 int,
	returnband text,
	nodataval double precision
)
	RETURNS raster AS
	$$ SELECT st_intersection($1, $2, $3, $4, $5, ARRAY[$6, $6]) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_intersection(
	rast1 raster, band1 int,
	rast2 raster, band2 int,
	nodataval double precision[]
)
	RETURNS raster AS
	$$ SELECT st_intersection($1, $2, $3, $4, 'BOTH', $5) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_intersection(
	rast1 raster, band1 int,
	rast2 raster, band2 int,
	nodataval double precision
)
	RETURNS raster AS
	$$ SELECT st_intersection($1, $2, $3, $4, 'BOTH', ARRAY[$5, $5]) $$
	LANGUAGE 'sql' STABLE;

-- Variants without band number
CREATE OR REPLACE FUNCTION st_intersection(
	rast1 raster,
	rast2 raster,
	returnband text DEFAULT 'BOTH',
	nodataval double precision[] DEFAULT NULL
)
	RETURNS raster AS
	$$ SELECT st_intersection($1, 1, $2, 1, $3, $4) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_intersection(
	rast1 raster,
	rast2 raster,
	returnband text,
	nodataval double precision
)
	RETURNS raster AS
	$$ SELECT st_intersection($1, 1, $2, 1, $3, ARRAY[$4, $4]) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_intersection(
	rast1 raster,
	rast2 raster,
	nodataval double precision[]
)
	RETURNS raster AS
	$$ SELECT st_intersection($1, 1, $2, 1, 'BOTH', $3) $$
	LANGUAGE 'sql' STABLE;

CREATE OR REPLACE FUNCTION st_intersection(
	rast1 raster,
	rast2 raster,
	nodataval double precision
)
	RETURNS raster AS
	$$ SELECT st_intersection($1, 1, $2, 1, 'BOTH', ARRAY[$3, $3]) $$
	LANGUAGE 'sql' STABLE;

-----------------------------------------------------------------------
-- ST_Union aggregate
-----------------------------------------------------------------------

-- Availability: 2.1.0
CREATE TYPE unionarg AS (
	nband int,
	uniontype text
);

CREATE OR REPLACE FUNCTION _st_union_finalfn(internal)
	RETURNS raster
	AS '$libdir/rtpostgis-2.2', 'RASTER_union_finalfn'
	LANGUAGE 'c' IMMUTABLE;

CREATE OR REPLACE FUNCTION _st_union_transfn(internal, raster, unionarg[])
	RETURNS internal
	AS '$libdir/rtpostgis-2.2', 'RASTER_union_transfn'
	LANGUAGE 'c' IMMUTABLE;

-- Availability: 2.1.0
CREATE AGGREGATE st_union(raster, unionarg[]) (
	SFUNC = _st_union_transfn,
	STYPE = internal,
	FINALFUNC = _st_union_finalfn
);

CREATE OR REPLACE FUNCTION _st_union_transfn(internal, raster, integer, text)
	RETURNS internal
	AS '$libdir/rtpostgis-2.2', 'RASTER_union_transfn'
	LANGUAGE 'c' IMMUTABLE;

-- Availability: 2.0.0
-- Changed: 2.1.0 changed definition
CREATE AGGREGATE st_union(raster, integer, text) (
	SFUNC = _st_union_transfn,
	STYPE = internal,
	FINALFUNC = _st_union_finalfn
);

CREATE OR REPLACE FUNCTION _st_union_transfn(internal, raster, integer)
	RETURNS internal
	AS '$libdir/rtpostgis-2.2', 'RASTER_union_transfn'
	LANGUAGE 'c' IMMUTABLE;

-- Availability: 2.0.0
-- Changed: 2.1.0 changed definition
CREATE AGGREGATE st_union(raster, integer) (
	SFUNC = _st_union_transfn,
	STYPE = internal,
	FINALFUNC = _st_union_finalfn
);

CREATE OR REPLACE FUNCTION _st_union_transfn(internal, raster)
	RETURNS internal
	AS '$libdir/rtpostgis-2.2', 'RASTER_union_transfn'
	LANGUAGE 'c' IMMUTABLE;

-- Availability: 2.0.0
-- Changed: 2.1.0 changed definition
CREATE AGGREGATE st_union(raster) (
	SFUNC = _st_union_transfn,
	STYPE = internal,
	FINALFUNC = _st_union_finalfn
);

CREATE OR REPLACE FUNCTION _st_union_transfn(internal, raster, text)
	RETURNS internal
	AS '$libdir/rtpostgis-2.2', 'RASTER_union_transfn'
	LANGUAGE 'c' IMMUTABLE;

-- Availability: 2.0.0
-- Changed: 2.1.0 changed definition
CREATE AGGREGATE st_union(raster, text) (
	SFUNC = _st_union_transfn,
	STYPE = internal,
	FINALFUNC = _st_union_finalfn
);

-----------------------------------------------------------------------
-- ST_Clip
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION _st_clip(
	rast raster, nband integer[],
	geom geometry,
	nodataval double precision[] DEFAULT NULL, crop boolean DEFAULT TRUE
)
	RETURNS raster
	AS '$libdir/rtpostgis-2.2', 'RASTER_clip'
	LANGUAGE 'c' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_clip(
	rast raster, nband integer[],
	geom geometry,
	nodataval double precision[] DEFAULT NULL, crop boolean DEFAULT TRUE
)
	RETURNS raster
 	AS $$
	BEGIN
		-- short-cut if geometry's extent fully contains raster's extent
		IF (nodataval IS NULL OR array_length(nodataval, 1) < 1) AND geom ~ ST_Envelope(rast) THEN
			RETURN rast;
		END IF;

		RETURN _ST_Clip($1, $2, $3, $4, $5);
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_clip(
	rast raster, nband integer,
	geom geometry,
	nodataval double precision, crop boolean DEFAULT TRUE
)
	RETURNS raster AS
	$$ SELECT ST_Clip($1, ARRAY[$2]::integer[], $3, ARRAY[$4]::double precision[], $5) $$
	LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_clip(
	rast raster, nband integer,
	geom geometry,
	crop boolean
)
	RETURNS raster AS
	$$ SELECT ST_Clip($1, ARRAY[$2]::integer[], $3, null::double precision[], $4) $$
	LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_clip(
	rast raster,
	geom geometry,
	nodataval double precision[] DEFAULT NULL, crop boolean DEFAULT TRUE
)
	RETURNS raster AS
	$$ SELECT ST_Clip($1, NULL, $2, $3, $4) $$
	LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_clip(
	rast raster,
	geom geometry,
	nodataval double precision, crop boolean DEFAULT TRUE
)
	RETURNS raster AS
	$$ SELECT ST_Clip($1, NULL, $2, ARRAY[$3]::double precision[], $4) $$
	LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE FUNCTION st_clip(
	rast raster,
	geom geometry,
	crop boolean
)
	RETURNS raster AS
	$$ SELECT ST_Clip($1, NULL, $2, null::double precision[], $3) $$
	LANGUAGE 'sql' IMMUTABLE;

-----------------------------------------------------------------------
-- ST_NearestValue
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION st_nearestvalue(
	rast raster, band integer,
	pt geometry,
	exclude_nodata_value boolean DEFAULT TRUE
)
	RETURNS double precision
	AS '$libdir/rtpostgis-2.2', 'RASTER_nearestValue'
	LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_nearestvalue(
	rast raster,
	pt geometry,
	exclude_nodata_value boolean DEFAULT TRUE
)
	RETURNS double precision
	AS $$ SELECT st_nearestvalue($1, 1, $2, $3) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_nearestvalue(
	rast raster, band integer,
	columnx integer, rowy integer,
	exclude_nodata_value boolean DEFAULT TRUE
)
	RETURNS double precision
	AS $$ SELECT st_nearestvalue($1, $2, st_setsrid(st_makepoint(st_rastertoworldcoordx($1, $3, $4), st_rastertoworldcoordy($1, $3, $4)), st_srid($1)), $5) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_nearestvalue(
	rast raster,
	columnx integer, rowy integer,
	exclude_nodata_value boolean DEFAULT TRUE
)
	RETURNS double precision
	AS $$ SELECT st_nearestvalue($1, 1, st_setsrid(st_makepoint(st_rastertoworldcoordx($1, $2, $3), st_rastertoworldcoordy($1, $2, $3)), st_srid($1)), $4) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

-----------------------------------------------------------------------
-- ST_Neighborhood
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION _st_neighborhood(
	rast raster, band integer,
	columnx integer, rowy integer,
	distancex integer, distancey integer,
	exclude_nodata_value boolean DEFAULT TRUE
)
	RETURNS double precision[][]
	AS '$libdir/rtpostgis-2.2', 'RASTER_neighborhood'
	LANGUAGE 'c' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_neighborhood(
	rast raster, band integer,
	columnx integer, rowy integer,
	distancex integer, distancey integer,
	exclude_nodata_value boolean DEFAULT TRUE
)
	RETURNS double precision[][]
	AS $$ SELECT _st_neighborhood($1, $2, $3, $4, $5, $6, $7) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_neighborhood(
	rast raster,
	columnx integer, rowy integer,
	distancex integer, distancey integer,
	exclude_nodata_value boolean DEFAULT TRUE
)
	RETURNS double precision[][]
	AS $$ SELECT _st_neighborhood($1, 1, $2, $3, $4, $5, $6) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_neighborhood(
	rast raster, band integer,
	pt geometry,
	distancex integer, distancey integer,
	exclude_nodata_value boolean DEFAULT TRUE
)
	RETURNS double precision[][]
	AS $$
	DECLARE
		wx double precision;
		wy double precision;
		rtn double precision[][];
	BEGIN
		IF (st_geometrytype($3) != 'ST_Point') THEN
			RAISE EXCEPTION 'Attempting to get the neighbor of a pixel with a non-point geometry';
		END IF;

		IF ST_SRID(rast) != ST_SRID(pt) THEN
			RAISE EXCEPTION 'Raster and geometry do not have the same SRID';
		END IF;

		wx := st_x($3);
		wy := st_y($3);

		SELECT _st_neighborhood(
			$1, $2,
			st_worldtorastercoordx(rast, wx, wy),
			st_worldtorastercoordy(rast, wx, wy),
			$4, $5,
			$6
		) INTO rtn;
		RETURN rtn;
	END;
	$$ LANGUAGE 'plpgsql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION st_neighborhood(
	rast raster,
	pt geometry,
	distancex integer, distancey integer,
	exclude_nodata_value boolean DEFAULT TRUE
)
	RETURNS double precision[][]
	AS $$ SELECT st_neighborhood($1, 1, $2, $3, $4, $5) $$
	LANGUAGE 'sql' IMMUTABLE STRICT;

------------------------------------------------------------------------------
-- raster constraint functions
-------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION _add_raster_constraint(cn name, sql text)
	RETURNS boolean AS $$
	BEGIN
		BEGIN
			EXECUTE sql;
		EXCEPTION
			WHEN duplicate_object THEN
				RAISE NOTICE 'The constraint "%" already exists.  To replace the existing constraint, delete the constraint and call ApplyRasterConstraints again', cn;
			WHEN OTHERS THEN
				RAISE NOTICE 'Unable to add constraint: %', cn;
				RAISE NOTICE 'SQL used for failed constraint: %', sql;
				RAISE NOTICE 'Returned error message: % (%)', SQLERRM, SQLSTATE;
				RETURN FALSE;
		END;

		RETURN TRUE;
	END;
	$$ LANGUAGE 'plpgsql' VOLATILE STRICT
	COST 100;

CREATE OR REPLACE FUNCTION _drop_raster_constraint(rastschema name, rasttable name, cn name)
	RETURNS boolean AS $$
	DECLARE
		fqtn text;
	BEGIN
		fqtn := '';
		IF length($1) > 0 THEN
			fqtn := quote_ident($1) || '.';
		END IF;
		fqtn := fqtn || quote_ident($2);

		BEGIN
			EXECUTE 'ALTER TABLE '
				|| fqtn
				|| ' DROP CONSTRAINT '
				|| quote_ident(cn);
			RETURN TRUE;
		EXCEPTION
			WHEN undefined_object THEN
				RAISE NOTICE 'The constraint "%" does not exist.  Skipping', cn;
			WHEN OTHERS THEN
				RAISE NOTICE 'Unable to drop constraint "%": % (%)',
          cn, SQLERRM, SQLSTATE;
				RETURN FALSE;
		END;

		RETURN TRUE;
	END;
	$$ LANGUAGE 'plpgsql' VOLATILE STRICT
	COST 100;

CREATE OR REPLACE FUNCTION _raster_constraint_info_srid(rastschema name, rasttable name, rastcolumn name)
	RETURNS integer AS $$
	SELECT
		regexp_replace(
			split_part(s.consrc, ' = ', 2),
			'[\(\)]', '', 'g'
		)::integer
	FROM pg_class c, pg_namespace n, pg_attribute a, pg_constraint s
	WHERE n.nspname = $1
		AND c.relname = $2
		AND a.attname = $3
		AND a.attrelid = c.oid
		AND s.connamespace = n.oid
		AND s.conrelid = c.oid
		AND a.attnum = ANY (s.conkey)
		AND s.consrc LIKE '%st_srid(% = %';
	$$ LANGUAGE sql STABLE STRICT
  COST 100;

CREATE OR REPLACE FUNCTION _add_raster_constraint_srid(rastschema name, rasttable name, rastcolumn name)
	RETURNS boolean AS $$
	DECLARE
		fqtn text;
		cn name;
		sql text;
		attr int;
	BEGIN
		fqtn := '';
		IF length($1) > 0 THEN
			fqtn := quote_ident($1) || '.';
		END IF;
		fqtn := fqtn || quote_ident($2);

		cn := 'enforce_srid_' || $3;

		sql := 'SELECT st_srid('
			|| quote_ident($3)
			|| ') FROM ' || fqtn
			|| ' LIMIT 1';
		BEGIN
			EXECUTE sql INTO attr;
		EXCEPTION WHEN OTHERS THEN
			RAISE NOTICE 'Unable to get the SRID of a sample raster: % (%)',
        SQLERRM, SQLSTATE;
			RETURN FALSE;
		END;

		sql := 'ALTER TABLE ' || fqtn
			|| ' ADD CONSTRAINT ' || quote_ident(cn)
			|| ' CHECK (st_srid('
			|| quote_ident($3)
			|| ') = ' || attr || ')';

		RETURN _add_raster_constraint(cn, sql);
	END;
	$$ LANGUAGE 'plpgsql' VOLATILE STRICT
	COST 100;

CREATE OR REPLACE FUNCTION _drop_raster_constraint_srid(rastschema name, rasttable name, rastcolumn name)
	RETURNS boolean AS
	$$ SELECT _drop_raster_constraint($1, $2, 'enforce_srid_' || $3) $$
	LANGUAGE 'sql' VOLATILE STRICT
	COST 100;

CREATE OR REPLACE FUNCTION _raster_constraint_info_scale(rastschema name, rasttable name, rastcolumn name, axis char)
	RETURNS double precision AS $$
	WITH c AS (SELECT
		regexp_replace(
			replace(
				split_part(
					split_part(s.consrc, ' = ', 2),
					'::', 1
				),
				'round(', ''
			),
			'[ ''''\(\)]', '', 'g'
		)::text AS val
	FROM pg_class c, pg_namespace n, pg_attribute a, pg_constraint s
	WHERE n.nspname = $1
		AND c.relname = $2
		AND a.attname = $3
		AND a.attrelid = c.oid
		AND s.connamespace = n.oid
		AND s.conrelid = c.oid
		AND a.attnum = ANY (s.conkey)
		AND s.consrc LIKE '%st_scale' || $4 || '(% = %') 
-- if it is a comma separated list of two numbers then need to use round
   SELECT CASE WHEN split_part(c.val,',', 2) > '' 
        THEN round( split_part(c.val, ',',1)::numeric, split_part(c.val,',',2)::integer )::float8 
        ELSE c.val::float8 END
        FROM c;
	$$ LANGUAGE sql STABLE STRICT
  COST 100;

CREATE OR REPLACE FUNCTION _add_raster_constraint_scale(rastschema name, rasttable name, rastcolumn name, axis char)
	RETURNS boolean AS $$
	DECLARE
		fqtn text;
		cn name;
		sql text;
		attr double precision;
	BEGIN
		IF lower($4) != 'x' AND lower($4) != 'y' THEN
			RAISE EXCEPTION 'axis must be either "x" or "y"';
			RETURN FALSE;
		END IF;

		fqtn := '';
		IF length($1) > 0 THEN
			fqtn := quote_ident($1) || '.';
		END IF;
		fqtn := fqtn || quote_ident($2);

		cn := 'enforce_scale' || $4 || '_' || $3;

		sql := 'SELECT st_scale' || $4 || '('
			|| quote_ident($3)
			|| ') FROM '
			|| fqtn
			|| ' LIMIT 1';
		BEGIN
			EXECUTE sql INTO attr;
		EXCEPTION WHEN OTHERS THEN
			RAISE NOTICE 'Unable to get the %-scale of a sample raster: % (%)',
        upper($4), SQLERRM, SQLSTATE;
			RETURN FALSE;
		END;

		sql := 'ALTER TABLE ' || fqtn
			|| ' ADD CONSTRAINT ' || quote_ident(cn)
			|| ' CHECK (round(st_scale' || $4 || '('
			|| quote_ident($3)
			|| ')::numeric, 10) = round(' || text(attr) || '::numeric, 10))';
		RETURN _add_raster_constraint(cn, sql);
	END;
	$$ LANGUAGE 'plpgsql' VOLATILE STRICT
	COST 100;

CREATE OR REPLACE FUNCTION _drop_raster_constraint_scale(rastschema name, rasttable name, rastcolumn name, axis char)
	RETURNS boolean AS $$
	BEGIN
		IF lower($4) != 'x' AND lower($4) != 'y' THEN
			RAISE EXCEPTION 'axis must be either "x" or "y"';
			RETURN FALSE;
		END IF;

		RETURN _drop_raster_constraint($1, $2, 'enforce_scale' || $4 || '_' || $3);
	END;
	$$ LANGUAGE 'plpgsql' VOLATILE STRICT
	COST 100;

CREATE OR REPLACE FUNCTION _raster_constraint_info_blocksize(rastschema name, rasttable name, rastcolumn name, axis text)
	RETURNS integer AS $$
	SELECT
		CASE
			WHEN strpos(s.consrc, 'ANY (ARRAY[') > 0 THEN
				split_part((regexp_matches(s.consrc, E'ARRAY\\[(.*?){1}\\]'))[1], ',', 1)::integer
			ELSE
				regexp_replace(
					split_part(s.consrc, '= ', 2),
					'[\(\)]', '', 'g'
				)::integer
			END
	FROM pg_class c, pg_namespace n, pg_attribute a, pg_constraint s
	WHERE n.nspname = $1
		AND c.relname = $2
		AND a.attname = $3
		AND a.attrelid = c.oid
		AND s.connamespace = n.oid
		AND s.conrelid = c.oid
		AND a.attnum = ANY (s.conkey)
		AND s.consrc LIKE '%st_' || $4 || '(%= %';
	$$ LANGUAGE sql STABLE STRICT
  COST 100;

CREATE OR REPLACE FUNCTION _add_raster_constraint_blocksize(rastschema name, rasttable name, rastcolumn name, axis text)
	RETURNS boolean AS $$
	DECLARE
		fqtn text;
		cn name;
		sql text;
		attrset integer[];
		attr integer;
	BEGIN
		IF lower($4) != 'width' AND lower($4) != 'height' THEN
			RAISE EXCEPTION 'axis must be either "width" or "height"';
			RETURN FALSE;
		END IF;

		fqtn := '';
		IF length($1) > 0 THEN
			fqtn := quote_ident($1) || '.';
		END IF;
		fqtn := fqtn || quote_ident($2);

		cn := 'enforce_' || $4 || '_' || $3;

		sql := 'SELECT st_' || $4 || '('
			|| quote_ident($3)
			|| ') FROM ' || fqtn
			|| ' GROUP BY 1 ORDER BY count(*) DESC';
		BEGIN
			attrset := ARRAY[]::integer[];
			FOR attr IN EXECUTE sql LOOP
				attrset := attrset || attr;
			END LOOP;
		EXCEPTION WHEN OTHERS THEN
			RAISE NOTICE 'Unable to get the % of a sample raster: % (%)',
        $4, SQLERRM, SQLSTATE;
			RETURN FALSE;
		END;

		sql := 'ALTER TABLE ' || fqtn
			|| ' ADD CONSTRAINT ' || quote_ident(cn)
			|| ' CHECK (st_' || $4 || '('
			|| quote_ident($3)
			|| ') IN (' || array_to_string(attrset, ',') || '))';
		RETURN _add_raster_constraint(cn, sql);
	END;
	$$ LANGUAGE 'plpgsql' VOLATILE STRICT
	COST 100;

CREATE OR REPLACE FUNCTION _drop_raster_constraint_blocksize(rastschema name, rasttable name, rastcolumn name, axis text)
	RETURNS boolean AS $$
	BEGIN
		IF lower($4) != 'width' AND lower($4) != 'height' THEN
			RAISE EXCEPTION 'axis must be either "width" or "height"';
			RETURN FALSE;
		END IF;

		RETURN _drop_raster_constraint($1, $2, 'enforce_' || $4 || '_' || $3);
	END;
	$$ LANGUAGE 'plpgsql' VOLATILE STRICT
	COST 100;

CREATE OR REPLACE FUNCTION _raster_constraint_info_extent(rastschema name, rasttable name, rastcolumn name)
	RETURNS geometry AS $$
	SELECT
		trim(both '''' from split_part(trim(split_part(s.consrc, ' @ ', 2)), '::', 1))::geometry
	FROM pg_class c, pg_namespace n, pg_attribute a, pg_constraint s
	WHERE n.nspname = $1
		AND c.relname = $2
		AND a.attname = $3
		AND a.attrelid = c.oid
		AND s.connamespace = n.oid
		AND s.conrelid = c.oid
		AND a.attnum = ANY (s.conkey)
		AND s.consrc LIKE '%st_envelope(% @ %';
	$$ LANGUAGE sql STABLE STRICT
  COST 100;

CREATE OR REPLACE FUNCTION _add_raster_constraint_extent(rastschema name, rasttable name, rastcolumn name)
	RETURNS boolean AS $$
	DECLARE
		fqtn text;
		cn name;
		sql text;
		attr text;
	BEGIN
		fqtn := '';
		IF length($1) > 0 THEN
			fqtn := quote_ident($1) || '.';
		END IF;
		fqtn := fqtn || quote_ident($2);

		cn := 'enforce_max_extent_' || $3;

		sql := 'SELECT st_ashexewkb(st_envelope(st_collect(st_envelope('
			|| quote_ident($3)
			|| ')))) FROM '
			|| fqtn;
		EXECUTE sql INTO attr;

		sql := 'ALTER TABLE ' || fqtn
			|| ' ADD CONSTRAINT ' || quote_ident(cn)
			|| ' CHECK (st_envelope('
			|| quote_ident($3)
			|| ') @ ''' || attr || '''::geometry)';
		RETURN _add_raster_constraint(cn, sql);
	END;
	$$ LANGUAGE 'plpgsql' VOLATILE STRICT
	COST 100;

CREATE OR REPLACE FUNCTION _drop_raster_constraint_extent(rastschema name, rasttable name, rastcolumn name)
	RETURNS boolean AS
	$$ SELECT _drop_raster_constraint($1, $2, 'enforce_max_extent_' || $3) $$
	LANGUAGE 'sql' VOLATILE STRICT
	COST 100;

CREATE OR REPLACE FUNCTION _raster_constraint_info_alignment(rastschema name, rasttable name, rastcolumn name)
	RETURNS boolean AS $$
	SELECT
		TRUE
	FROM pg_class c, pg_namespace n, pg_attribute a, pg_constraint s
	WHERE n.nspname = $1
		AND c.relname = $2
		AND a.attname = $3
		AND a.attrelid = c.oid
		AND s.connamespace = n.oid
		AND s.conrelid = c.oid
		AND a.attnum = ANY (s.conkey)
		AND s.consrc LIKE '%st_samealignment(%';
	$$ LANGUAGE sql STABLE STRICT
  COST 100;

CREATE OR REPLACE FUNCTION _add_raster_constraint_alignment(rastschema name, rasttable name, rastcolumn name)
	RETURNS boolean AS $$
	DECLARE
		fqtn text;
		cn name;
		sql text;
		attr text;
	BEGIN
		fqtn := '';
		IF length($1) > 0 THEN
			fqtn := quote_ident($1) || '.';
		END IF;
		fqtn := fqtn || quote_ident($2);

		cn := 'enforce_same_alignment_' || $3;

		sql := 'SELECT st_makeemptyraster(1, 1, upperleftx, upperlefty, scalex, scaley, skewx, skewy, srid) FROM st_metadata((SELECT '
			|| quote_ident($3)
			|| ' FROM ' || fqtn || ' LIMIT 1))';
		BEGIN
			EXECUTE sql INTO attr;
		EXCEPTION WHEN OTHERS THEN
			RAISE NOTICE 'Unable to get the alignment of a sample raster: % (%)',
        SQLERRM, SQLSTATE;
			RETURN FALSE;
		END;

		sql := 'ALTER TABLE ' || fqtn ||
			' ADD CONSTRAINT ' || quote_ident(cn) ||
			' CHECK (st_samealignment(' || quote_ident($3) || ', ''' || attr || '''::raster))';
		RETURN _add_raster_constraint(cn, sql);
	END;
	$$ LANGUAGE 'plpgsql' VOLATILE STRICT
	COST 100;

CREATE OR REPLACE FUNCTION _drop_raster_constraint_alignment(rastschema name, rasttable name, rastcolumn name)
	RETURNS boolean AS
	$$ SELECT _drop_raster_constraint($1, $2, 'enforce_same_alignment_' || $3) $$
	LANGUAGE 'sql' VOLATILE STRICT
	COST 100;

CREATE OR REPLACE FUNCTION _raster_constraint_info_spatially_unique(rastschema name, rasttable name, rastcolumn name)
	RETURNS boolean AS $$
	SELECT
		TRUE
	FROM pg_class c, pg_namespace n, pg_attribute a, pg_constraint s, pg_index idx, pg_operator op
	WHERE n.nspname = $1
		AND c.relname = $2
		AND a.attname = $3
		AND a.attrelid = c.oid
		AND s.connamespace = n.oid
		AND s.conrelid = c.oid
		AND s.contype = 'x'
		AND 0::smallint = ANY (s.conkey)
		AND idx.indexrelid = s.conindid
		AND pg_get_indexdef(idx.indexrelid, 1, true) LIKE '(' || quote_ident($3) || '::geometry)'
		AND s.conexclop[1] = op.oid
		AND op.oprname = '=';
	$$ LANGUAGE sql STABLE STRICT
  COST 100;

CREATE OR REPLACE FUNCTION _add_raster_constraint_spatially_unique(rastschema name, rasttable name, rastcolumn name)
	RETURNS boolean AS $$
	DECLARE
		fqtn text;
		cn name;
		sql text;
		attr text;
		meta record;
	BEGIN
		fqtn := '';
		IF length($1) > 0 THEN
			fqtn := quote_ident($1) || '.';
		END IF;
		fqtn := fqtn || quote_ident($2);

		cn := 'enforce_spatially_unique_' || quote_ident($2) || '_'|| $3;

		sql := 'ALTER TABLE ' || fqtn ||
			' ADD CONSTRAINT ' || quote_ident(cn) ||
			' EXCLUDE ((' || quote_ident($3) || '::geometry) WITH =)';
		RETURN _add_raster_constraint(cn, sql);
	END;
	$$ LANGUAGE 'plpgsql' VOLATILE STRICT
	COST 100;

CREATE OR REPLACE FUNCTION _drop_raster_constraint_spatially_unique(rastschema name, rasttable name, rastcolumn name)
	RETURNS boolean AS $$
	DECLARE
		cn text;
	BEGIN
		SELECT
			s.conname INTO cn
		FROM pg_class c, pg_namespace n, pg_attribute a, pg_constraint s, pg_index idx, pg_operator op
		WHERE n.nspname = $1
			AND c.relname = $2
			AND a.attname = $3
			AND a.attrelid = c.oid
			AND s.connamespace = n.oid
			AND s.conrelid = c.oid
			AND s.contype = 'x'
			AND 0::smallint = ANY (s.conkey)
			AND idx.indexrelid = s.conindid
			AND pg_get_indexdef(idx.indexrelid, 1, true) LIKE '(' || quote_ident($3) || '::geometry)'
			AND s.conexclop[1] = op.oid
			AND op.oprname = '=';

		RETURN _drop_raster_constraint($1, $2, cn); 
	END;
	$$ LANGUAGE 'plpgsql' VOLATILE STRICT
	COST 100;

CREATE OR REPLACE FUNCTION _raster_constraint_info_coverage_tile(rastschema name, rasttable name, rastcolumn name)
	RETURNS boolean AS $$
	SELECT
		TRUE
	FROM pg_class c, pg_namespace n, pg_attribute a, pg_constraint s
	WHERE n.nspname = $1
		AND c.relname = $2
		AND a.attname = $3
		AND a.attrelid = c.oid
		AND s.connamespace = n.oid
		AND s.conrelid = c.oid
		AND a.attnum = ANY (s.conkey)
		AND s.consrc LIKE '%st_iscoveragetile(%';
	$$ LANGUAGE sql STABLE STRICT
  COST 100;

CREATE OR REPLACE FUNCTION _add_raster_constraint_coverage_tile(rastschema name, rasttable name, rastcolumn name)
	RETURNS boolean AS $$
	DECLARE
		fqtn text;
		cn name;
		sql text;

		_scalex double precision;
		_scaley double precision;
		_skewx double precision;
		_skewy double precision;
		_tilewidth integer;
		_tileheight integer;
		_alignment boolean;

		_covextent geometry;
		_covrast raster;
	BEGIN
		fqtn := '';
		IF length($1) > 0 THEN
			fqtn := quote_ident($1) || '.';
		END IF;
		fqtn := fqtn || quote_ident($2);

		cn := 'enforce_coverage_tile_' || $3;

		-- metadata
		BEGIN
			sql := 'WITH foo AS (SELECT ST_Metadata(' || quote_ident($3) || ') AS meta, ST_ConvexHull(' || quote_ident($3) || ') AS hull FROM ' || fqtn || ') SELECT max((meta).scalex), max((meta).scaley), max((meta).skewx), max((meta).skewy), max((meta).width), max((meta).height), ST_Union(hull) FROM foo';
			EXECUTE sql INTO _scalex, _scaley, _skewx, _skewy, _tilewidth, _tileheight, _covextent;
		EXCEPTION WHEN OTHERS THEN
			RAISE DEBUG 'Unable to get coverage metadata for %.%: % (%)',
        fqtn, quote_ident($3), SQLERRM, SQLSTATE;
      -- TODO: Why not return false here ?
		END;

		-- rasterize extent
		BEGIN
			_covrast := ST_AsRaster(_covextent, _scalex, _scaley, '8BUI', 1, 0, NULL, NULL, _skewx, _skewy);
			IF _covrast IS NULL THEN
				RAISE NOTICE 'Unable to create coverage raster. Cannot add coverage tile constraint: % (%)',
          SQLERRM, SQLSTATE;
				RETURN FALSE;
			END IF;

			-- remove band
			_covrast := ST_MakeEmptyRaster(_covrast);
		EXCEPTION WHEN OTHERS THEN
			RAISE NOTICE 'Unable to create coverage raster. Cannot add coverage tile constraint: % (%)',
        SQLERRM, SQLSTATE;
			RETURN FALSE;
		END;

		sql := 'ALTER TABLE ' || fqtn ||
			' ADD CONSTRAINT ' || quote_ident(cn) ||
			' CHECK (st_iscoveragetile(' || quote_ident($3) || ', ''' || _covrast || '''::raster, ' || _tilewidth || ', ' || _tileheight || '))';
		RETURN _add_raster_constraint(cn, sql);
	END;
	$$ LANGUAGE 'plpgsql' VOLATILE STRICT
	COST 100;

CREATE OR REPLACE FUNCTION _drop_raster_constraint_coverage_tile(rastschema name, rasttable name, rastcolumn name)
	RETURNS boolean AS
	$$ SELECT _drop_raster_constraint($1, $2, 'enforce_coverage_tile_' || $3) $$
	LANGUAGE 'sql' VOLATILE STRICT
	COST 100;

CREATE OR REPLACE FUNCTION _raster_constraint_info_regular_blocking(rastschema name, rasttable name, rastcolumn name)
	RETURNS boolean
	AS $$
	DECLARE
		covtile boolean;
		spunique boolean;
	BEGIN
		-- check existance of constraints
		-- coverage tile constraint
		covtile := COALESCE(_raster_constraint_info_coverage_tile($1, $2, $3), FALSE);

		-- spatially unique constraint
		spunique := COALESCE(_raster_constraint_info_spatially_unique($1, $2, $3), FALSE);

		RETURN (covtile AND spunique);
	END;
	$$ LANGUAGE 'plpgsql' STABLE STRICT
  COST 100;

CREATE OR REPLACE FUNCTION _drop_raster_constraint_regular_blocking(rastschema name, rasttable name, rastcolumn name)
	RETURNS boolean AS
	$$ SELECT _drop_raster_constraint($1, $2, 'enforce_regular_blocking_' || $3) $$
	LANGUAGE 'sql' VOLATILE STRICT
	COST 100;

CREATE OR REPLACE FUNCTION _raster_constraint_info_num_bands(rastschema name, rasttable name, rastcolumn name)
	RETURNS integer AS $$
	SELECT
		regexp_replace(
			split_part(s.consrc, ' = ', 2),
			'[\(\)]', '', 'g'
		)::integer
	FROM pg_class c, pg_namespace n, pg_attribute a, pg_constraint s
	WHERE n.nspname = $1
		AND c.relname = $2
		AND a.attname = $3
		AND a.attrelid = c.oid
		AND s.connamespace = n.oid
		AND s.conrelid = c.oid
		AND a.attnum = ANY (s.conkey)
		AND s.consrc LIKE '%st_numbands(%';
	$$ LANGUAGE sql STABLE STRICT
  COST 100;

CREATE OR REPLACE FUNCTION _add_raster_constraint_num_bands(rastschema name, rasttable name, rastcolumn name)
	RETURNS boolean AS $$
	DECLARE
		fqtn text;
		cn name;
		sql text;
		attr int;
	BEGIN
		fqtn := '';
		IF length($1) > 0 THEN
			fqtn := quote_ident($1) || '.';
		END IF;
		fqtn := fqtn || quote_ident($2);

		cn := 'enforce_num_bands_' || $3;

		sql := 'SELECT st_numbands(' || quote_ident($3)
			|| ') FROM ' || fqtn
			|| ' LIMIT 1';
		BEGIN
			EXECUTE sql INTO attr;
		EXCEPTION WHEN OTHERS THEN
			RAISE NOTICE 'Unable to get the number of bands of a sample raster: % (%)',
        SQLERRM, SQLSTATE;
			RETURN FALSE;
		END;

		sql := 'ALTER TABLE ' || fqtn
			|| ' ADD CONSTRAINT ' || quote_ident(cn)
			|| ' CHECK (st_numbands(' || quote_ident($3)
			|| ') = ' || attr
			|| ')';
		RETURN _add_raster_constraint(cn, sql);
	END;
	$$ LANGUAGE 'plpgsql' VOLATILE STRICT
	COST 100;

CREATE OR REPLACE FUNCTION _drop_raster_constraint_num_bands(rastschema name, rasttable name, rastcolumn name)
	RETURNS boolean AS
	$$ SELECT _drop_raster_constraint($1, $2, 'enforce_num_bands_' || $3) $$
	LANGUAGE 'sql' VOLATILE STRICT
	COST 100;

CREATE OR REPLACE FUNCTION _raster_constraint_info_pixel_types(rastschema name, rasttable name, rastcolumn name)
	RETURNS text[] AS $$
	SELECT
		trim(
			both '''' from split_part(
				regexp_replace(
					split_part(s.consrc, ' = ', 2),
					'[\(\)]', '', 'g'
				),
				'::', 1
			)
		)::text[]
	FROM pg_class c, pg_namespace n, pg_attribute a, pg_constraint s
	WHERE n.nspname = $1
		AND c.relname = $2
		AND a.attname = $3
		AND a.attrelid = c.oid
		AND s.connamespace = n.oid
		AND s.conrelid = c.oid
		AND a.attnum = ANY (s.conkey)
		AND s.consrc LIKE '%_raster_constraint_pixel_types(%';
	$$ LANGUAGE sql STABLE STRICT
  COST 100;

CREATE OR REPLACE FUNCTION _raster_constraint_pixel_types(rast raster)
	RETURNS text[] AS
	$$ SELECT array_agg(pixeltype)::text[] FROM st_bandmetadata($1, ARRAY[]::int[]); $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION _add_raster_constraint_pixel_types(rastschema name, rasttable name, rastcolumn name)
	RETURNS boolean AS $$
	DECLARE
		fqtn text;
		cn name;
		sql text;
		attr text[];
		max int;
	BEGIN
		fqtn := '';
		IF length($1) > 0 THEN
			fqtn := quote_ident($1) || '.';
		END IF;
		fqtn := fqtn || quote_ident($2);

		cn := 'enforce_pixel_types_' || $3;

		sql := 'SELECT _raster_constraint_pixel_types(' || quote_ident($3)
			|| ') FROM ' || fqtn
			|| ' LIMIT 1';
		BEGIN
			EXECUTE sql INTO attr;
		EXCEPTION WHEN OTHERS THEN
			RAISE NOTICE 'Unable to get the pixel types of a sample raster: % (%)',
        SQLERRM, SQLSTATE;
			RETURN FALSE;
		END;
		max := array_length(attr, 1);
		IF max < 1 OR max IS NULL THEN
			RAISE NOTICE 'Unable to get the pixel types of a sample raster (max < 1 or null)';
			RETURN FALSE;
		END IF;

		sql := 'ALTER TABLE ' || fqtn
			|| ' ADD CONSTRAINT ' || quote_ident(cn)
			|| ' CHECK (_raster_constraint_pixel_types(' || quote_ident($3)
			|| ') = ''{';
		FOR x in 1..max LOOP
			sql := sql || '"' || attr[x] || '"';
			IF x < max THEN
				sql := sql || ',';
			END IF;
		END LOOP;
		sql := sql || '}''::text[])';

		RETURN _add_raster_constraint(cn, sql);
	END;
	$$ LANGUAGE 'plpgsql' VOLATILE STRICT
	COST 100;

CREATE OR REPLACE FUNCTION _drop_raster_constraint_pixel_types(rastschema name, rasttable name, rastcolumn name)
	RETURNS boolean AS
	$$ SELECT _drop_raster_constraint($1, $2, 'enforce_pixel_types_' || $3) $$
	LANGUAGE 'sql' VOLATILE STRICT
	COST 100;

CREATE OR REPLACE FUNCTION _raster_constraint_info_nodata_values(rastschema name, rasttable name, rastcolumn name)
	RETURNS double precision[] AS $$
	SELECT
		trim(both '''' from
			split_part(
				regexp_replace(
					split_part(s.consrc, ' = ', 2),
					'[\(\)]', '', 'g'
				),
				'::', 1
			)
		)::double precision[]
	FROM pg_class c, pg_namespace n, pg_attribute a, pg_constraint s
	WHERE n.nspname = $1
		AND c.relname = $2
		AND a.attname = $3
		AND a.attrelid = c.oid
		AND s.connamespace = n.oid
		AND s.conrelid = c.oid
		AND a.attnum = ANY (s.conkey)
		AND s.consrc LIKE '%_raster_constraint_nodata_values(%';
	$$ LANGUAGE sql STABLE STRICT
  COST 100;

-- Availability: 2.0.0
-- Changed: 2.2.0
CREATE OR REPLACE FUNCTION _raster_constraint_nodata_values(rast raster)
	RETURNS numeric[] AS
	$$ SELECT array_agg(round(nodatavalue::numeric, 10))::numeric[] FROM st_bandmetadata($1, ARRAY[]::int[]); $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION _add_raster_constraint_nodata_values(rastschema name, rasttable name, rastcolumn name)
	RETURNS boolean AS $$
	DECLARE
		fqtn text;
		cn name;
		sql text;
		attr numeric[];
		max int;
	BEGIN
		fqtn := '';
		IF length($1) > 0 THEN
			fqtn := quote_ident($1) || '.';
		END IF;
		fqtn := fqtn || quote_ident($2);

		cn := 'enforce_nodata_values_' || $3;

		sql := 'SELECT _raster_constraint_nodata_values(' || quote_ident($3)
			|| ') FROM ' || fqtn
			|| ' LIMIT 1';
		BEGIN
			EXECUTE sql INTO attr;
		EXCEPTION WHEN OTHERS THEN
			RAISE NOTICE 'Unable to get the nodata values of a sample raster: % (%)',
        SQLERRM, SQLSTATE;
			RETURN FALSE;
		END;
		max := array_length(attr, 1);
		IF max < 1 OR max IS NULL THEN
			RAISE NOTICE 'Unable to get the nodata values of a sample raster (max < 1 or null)';
			RETURN FALSE;
		END IF;

		sql := 'ALTER TABLE ' || fqtn
			|| ' ADD CONSTRAINT ' || quote_ident(cn)
			|| ' CHECK (_raster_constraint_nodata_values(' || quote_ident($3)
			|| ')::numeric[] = ''{';
		FOR x in 1..max LOOP
			IF attr[x] IS NULL THEN
				sql := sql || 'NULL';
			ELSE
				sql := sql || attr[x];
			END IF;
			IF x < max THEN
				sql := sql || ',';
			END IF;
		END LOOP;
		sql := sql || '}''::numeric[])';

		RETURN _add_raster_constraint(cn, sql);
	END;
	$$ LANGUAGE 'plpgsql' VOLATILE STRICT
	COST 100;

CREATE OR REPLACE FUNCTION _drop_raster_constraint_nodata_values(rastschema name, rasttable name, rastcolumn name)
	RETURNS boolean AS
	$$ SELECT _drop_raster_constraint($1, $2, 'enforce_nodata_values_' || $3) $$
	LANGUAGE 'sql' VOLATILE STRICT
	COST 100;

CREATE OR REPLACE FUNCTION _raster_constraint_info_out_db(rastschema name, rasttable name, rastcolumn name)
	RETURNS boolean[] AS $$
	SELECT
		trim(
			both '''' from split_part(
				regexp_replace(
					split_part(s.consrc, ' = ', 2),
					'[\(\)]', '', 'g'
				),
				'::', 1
			)
		)::boolean[]
	FROM pg_class c, pg_namespace n, pg_attribute a, pg_constraint s
	WHERE n.nspname = $1
		AND c.relname = $2
		AND a.attname = $3
		AND a.attrelid = c.oid
		AND s.connamespace = n.oid
		AND s.conrelid = c.oid
		AND a.attnum = ANY (s.conkey)
		AND s.consrc LIKE '%_raster_constraint_out_db(%';
	$$ LANGUAGE sql STABLE STRICT
  COST 100;

CREATE OR REPLACE FUNCTION _raster_constraint_out_db(rast raster)
	RETURNS boolean[] AS
	$$ SELECT array_agg(isoutdb)::boolean[] FROM st_bandmetadata($1, ARRAY[]::int[]); $$
	LANGUAGE 'sql' STABLE STRICT;

CREATE OR REPLACE FUNCTION _add_raster_constraint_out_db(rastschema name, rasttable name, rastcolumn name)
	RETURNS boolean AS $$
	DECLARE
		fqtn text;
		cn name;
		sql text;
		attr boolean[];
		max int;
	BEGIN
		fqtn := '';
		IF length($1) > 0 THEN
			fqtn := quote_ident($1) || '.';
		END IF;
		fqtn := fqtn || quote_ident($2);

		cn := 'enforce_out_db_' || $3;

		sql := 'SELECT _raster_constraint_out_db(' || quote_ident($3)
			|| ') FROM ' || fqtn
			|| ' LIMIT 1';
		BEGIN
			EXECUTE sql INTO attr;
		EXCEPTION WHEN OTHERS THEN
			RAISE NOTICE 'Unable to get the out-of-database bands of a sample raster: % (%)',
        SQLERRM, SQLSTATE;
			RETURN FALSE;
		END;
		max := array_length(attr, 1);
		IF max < 1 OR max IS NULL THEN
			RAISE NOTICE 'Unable to get the out-of-database bands of a sample raster (max < 1 or null)';
			RETURN FALSE;
		END IF;

		sql := 'ALTER TABLE ' || fqtn
			|| ' ADD CONSTRAINT ' || quote_ident(cn)
			|| ' CHECK (_raster_constraint_out_db(' || quote_ident($3)
			|| ') = ''{';
		FOR x in 1..max LOOP
			IF attr[x] IS FALSE THEN
				sql := sql || 'FALSE';
			ELSE
				sql := sql || 'TRUE';
			END IF;
			IF x < max THEN
				sql := sql || ',';
			END IF;
		END LOOP;
		sql := sql || '}''::boolean[])';

		RETURN _add_raster_constraint(cn, sql);
	END;
	$$ LANGUAGE 'plpgsql' VOLATILE STRICT
	COST 100;

CREATE OR REPLACE FUNCTION _drop_raster_constraint_out_db(rastschema name, rasttable name, rastcolumn name)
	RETURNS boolean AS
	$$ SELECT _drop_raster_constraint($1, $2, 'enforce_out_db_' || $3) $$
	LANGUAGE 'sql' VOLATILE STRICT
	COST 100;

CREATE OR REPLACE FUNCTION _raster_constraint_info_index(rastschema name, rasttable name, rastcolumn name)
	RETURNS boolean AS $$
		SELECT
			TRUE
		FROM pg_catalog.pg_class c
		JOIN pg_catalog.pg_index i
			ON i.indexrelid = c.oid
		JOIN pg_catalog.pg_class c2
			ON i.indrelid = c2.oid
		JOIN pg_catalog.pg_namespace n
			ON n.oid = c.relnamespace
		JOIN pg_am am
			ON c.relam = am.oid
		JOIN pg_attribute att
			ON att.attrelid = c2.oid
				AND pg_catalog.format_type(att.atttypid, att.atttypmod) = 'raster'
		WHERE c.relkind IN ('i')
			AND n.nspname = $1
			AND c2.relname = $2
			AND att.attname = $3
			AND am.amname = 'gist'
			AND strpos(pg_catalog.pg_get_expr(i.indexprs, i.indrelid), att.attname) > 0;
	$$ LANGUAGE sql STABLE STRICT
  COST 100;

------------------------------------------------------------------------------
-- AddRasterConstraints
------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION AddRasterConstraints (
	rastschema name,
	rasttable name,
	rastcolumn name,
	VARIADIC constraints text[]
)
	RETURNS boolean
	AS $$
	DECLARE
		max int;
		cnt int;
		sql text;
		schema name;
		x int;
		kw text;
		rtn boolean;
	BEGIN
		cnt := 0;
		max := array_length(constraints, 1);
		IF max < 1 THEN
			RAISE NOTICE 'No constraints indicated to be added.  Doing nothing';
			RETURN TRUE;
		END IF;

		-- validate schema
		schema := NULL;
		IF length($1) > 0 THEN
			sql := 'SELECT nspname FROM pg_namespace '
				|| 'WHERE nspname = ' || quote_literal($1)
				|| 'LIMIT 1';
			EXECUTE sql INTO schema;

			IF schema IS NULL THEN
				RAISE EXCEPTION 'The value provided for schema is invalid';
				RETURN FALSE;
			END IF;
		END IF;

		IF schema IS NULL THEN
			sql := 'SELECT n.nspname AS schemaname '
				|| 'FROM pg_catalog.pg_class c '
				|| 'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace '
				|| 'WHERE c.relkind = ' || quote_literal('r')
				|| ' AND n.nspname NOT IN (' || quote_literal('pg_catalog')
				|| ', ' || quote_literal('pg_toast')
				|| ') AND pg_catalog.pg_table_is_visible(c.oid)'
				|| ' AND c.relname = ' || quote_literal($2);
			EXECUTE sql INTO schema;

			IF schema IS NULL THEN
				RAISE EXCEPTION 'The table % does not occur in the search_path', quote_literal($2);
				RETURN FALSE;
			END IF;
		END IF;

		<<kwloop>>
		FOR x in 1..max LOOP
			kw := trim(both from lower(constraints[x]));

			BEGIN
				CASE
					WHEN kw = 'srid' THEN
						RAISE NOTICE 'Adding SRID constraint';
						rtn := _add_raster_constraint_srid(schema, $2, $3);
					WHEN kw IN ('scale_x', 'scalex') THEN
						RAISE NOTICE 'Adding scale-X constraint';
						rtn := _add_raster_constraint_scale(schema, $2, $3, 'x');
					WHEN kw IN ('scale_y', 'scaley') THEN
						RAISE NOTICE 'Adding scale-Y constraint';
						rtn := _add_raster_constraint_scale(schema, $2, $3, 'y');
					WHEN kw = 'scale' THEN
						RAISE NOTICE 'Adding scale-X constraint';
						rtn := _add_raster_constraint_scale(schema, $2, $3, 'x');
						RAISE NOTICE 'Adding scale-Y constraint';
						rtn := _add_raster_constraint_scale(schema, $2, $3, 'y');
					WHEN kw IN ('blocksize_x', 'blocksizex', 'width') THEN
						RAISE NOTICE 'Adding blocksize-X constraint';
						rtn := _add_raster_constraint_blocksize(schema, $2, $3, 'width');
					WHEN kw IN ('blocksize_y', 'blocksizey', 'height') THEN
						RAISE NOTICE 'Adding blocksize-Y constraint';
						rtn := _add_raster_constraint_blocksize(schema, $2, $3, 'height');
					WHEN kw = 'blocksize' THEN
						RAISE NOTICE 'Adding blocksize-X constraint';
						rtn := _add_raster_constraint_blocksize(schema, $2, $3, 'width');
						RAISE NOTICE 'Adding blocksize-Y constraint';
						rtn := _add_raster_constraint_blocksize(schema, $2, $3, 'height');
					WHEN kw IN ('same_alignment', 'samealignment', 'alignment') THEN
						RAISE NOTICE 'Adding alignment constraint';
						rtn := _add_raster_constraint_alignment(schema, $2, $3);
					WHEN kw IN ('regular_blocking', 'regularblocking') THEN
						RAISE NOTICE 'Adding coverage tile constraint required for regular blocking';
						rtn := _add_raster_constraint_coverage_tile(schema, $2, $3);
						IF rtn IS NOT FALSE THEN
							RAISE NOTICE 'Adding spatially unique constraint required for regular blocking';
							rtn := _add_raster_constraint_spatially_unique(schema, $2, $3);
						END IF;
					WHEN kw IN ('num_bands', 'numbands') THEN
						RAISE NOTICE 'Adding number of bands constraint';
						rtn := _add_raster_constraint_num_bands(schema, $2, $3);
					WHEN kw IN ('pixel_types', 'pixeltypes') THEN
						RAISE NOTICE 'Adding pixel type constraint';
						rtn := _add_raster_constraint_pixel_types(schema, $2, $3);
					WHEN kw IN ('nodata_values', 'nodatavalues', 'nodata') THEN
						RAISE NOTICE 'Adding nodata value constraint';
						rtn := _add_raster_constraint_nodata_values(schema, $2, $3);
					WHEN kw IN ('out_db', 'outdb') THEN
						RAISE NOTICE 'Adding out-of-database constraint';
						rtn := _add_raster_constraint_out_db(schema, $2, $3);
					WHEN kw = 'extent' THEN
						RAISE NOTICE 'Adding maximum extent constraint';
						rtn := _add_raster_constraint_extent(schema, $2, $3);
					ELSE
						RAISE NOTICE 'Unknown constraint: %.  Skipping', quote_literal(constraints[x]);
						CONTINUE kwloop;
				END CASE;
			END;

			IF rtn IS FALSE THEN
				cnt := cnt + 1;
				RAISE WARNING 'Unable to add constraint: %.  Skipping', quote_literal(constraints[x]);
			END IF;

		END LOOP kwloop;

		IF cnt = max THEN
			RAISE EXCEPTION 'None of the constraints specified could be added.  Is the schema name, table name or column name incorrect?';
			RETURN FALSE;
		END IF;

		RETURN TRUE;
	END;
	$$ LANGUAGE 'plpgsql' VOLATILE STRICT
	COST 100;

CREATE OR REPLACE FUNCTION AddRasterConstraints (
	rasttable name,
	rastcolumn name,
	VARIADIC constraints text[]
)
	RETURNS boolean AS
	$$ SELECT AddRasterConstraints('', $1, $2, VARIADIC $3) $$
	LANGUAGE 'sql' VOLATILE STRICT
	COST 100;

CREATE OR REPLACE FUNCTION AddRasterConstraints (
	rastschema name,
	rasttable name,
	rastcolumn name,
	srid boolean DEFAULT TRUE,
	scale_x boolean DEFAULT TRUE,
	scale_y boolean DEFAULT TRUE,
	blocksize_x boolean DEFAULT TRUE,
	blocksize_y boolean DEFAULT TRUE,
	same_alignment boolean DEFAULT TRUE,
	regular_blocking boolean DEFAULT FALSE, -- false as regular_blocking is an enhancement
	num_bands boolean DEFAULT TRUE,
	pixel_types boolean DEFAULT TRUE,
	nodata_values boolean DEFAULT TRUE,
	out_db boolean DEFAULT TRUE,
	extent boolean DEFAULT TRUE
)
	RETURNS boolean
	AS $$
	DECLARE
		constraints text[];
	BEGIN
		IF srid IS TRUE THEN
			constraints := constraints || 'srid'::text;
		END IF;

		IF scale_x IS TRUE THEN
			constraints := constraints || 'scale_x'::text;
		END IF;

		IF scale_y IS TRUE THEN
			constraints := constraints || 'scale_y'::text;
		END IF;

		IF blocksize_x IS TRUE THEN
			constraints := constraints || 'blocksize_x'::text;
		END IF;

		IF blocksize_y IS TRUE THEN
			constraints := constraints || 'blocksize_y'::text;
		END IF;

		IF same_alignment IS TRUE THEN
			constraints := constraints || 'same_alignment'::text;
		END IF;

		IF regular_blocking IS TRUE THEN
			constraints := constraints || 'regular_blocking'::text;
		END IF;

		IF num_bands IS TRUE THEN
			constraints := constraints || 'num_bands'::text;
		END IF;

		IF pixel_types IS TRUE THEN
			constraints := constraints || 'pixel_types'::text;
		END IF;

		IF nodata_values IS TRUE THEN
			constraints := constraints || 'nodata_values'::text;
		END IF;

		IF out_db IS TRUE THEN
			constraints := constraints || 'out_db'::text;
		END IF;

		IF extent IS TRUE THEN
			constraints := constraints || 'extent'::text;
		END IF;

		RETURN AddRasterConstraints($1, $2, $3, VARIADIC constraints);
	END;
	$$ LANGUAGE 'plpgsql' VOLATILE STRICT
	COST 100;

CREATE OR REPLACE FUNCTION AddRasterConstraints (
	rasttable name,
	rastcolumn name,
	srid boolean DEFAULT TRUE,
	scale_x boolean DEFAULT TRUE,
	scale_y boolean DEFAULT TRUE,
	blocksize_x boolean DEFAULT TRUE,
	blocksize_y boolean DEFAULT TRUE,
	same_alignment boolean DEFAULT TRUE,
	regular_blocking boolean DEFAULT FALSE, -- false as regular_blocking is an enhancement
	num_bands boolean DEFAULT TRUE,
	pixel_types boolean DEFAULT TRUE,
	nodata_values boolean DEFAULT TRUE,
	out_db boolean DEFAULT TRUE,
	extent boolean DEFAULT TRUE
)
	RETURNS boolean AS
	$$ SELECT AddRasterConstraints('', $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14) $$
	LANGUAGE 'sql' VOLATILE STRICT
	COST 100;

------------------------------------------------------------------------------
-- DropRasterConstraints
------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION DropRasterConstraints (
	rastschema name,
	rasttable name,
	rastcolumn name,
	VARIADIC constraints text[]
)
	RETURNS boolean
	AS $$
	DECLARE
		max int;
		x int;
		schema name;
		sql text;
		kw text;
		rtn boolean;
		cnt int;
	BEGIN
		cnt := 0;
		max := array_length(constraints, 1);
		IF max < 1 THEN
			RAISE NOTICE 'No constraints indicated to be dropped.  Doing nothing';
			RETURN TRUE;
		END IF;

		-- validate schema
		schema := NULL;
		IF length($1) > 0 THEN
			sql := 'SELECT nspname FROM pg_namespace '
				|| 'WHERE nspname = ' || quote_literal($1)
				|| 'LIMIT 1';
			EXECUTE sql INTO schema;

			IF schema IS NULL THEN
				RAISE EXCEPTION 'The value provided for schema is invalid';
				RETURN FALSE;
			END IF;
		END IF;

		IF schema IS NULL THEN
			sql := 'SELECT n.nspname AS schemaname '
				|| 'FROM pg_catalog.pg_class c '
				|| 'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace '
				|| 'WHERE c.relkind = ' || quote_literal('r')
				|| ' AND n.nspname NOT IN (' || quote_literal('pg_catalog')
				|| ', ' || quote_literal('pg_toast')
				|| ') AND pg_catalog.pg_table_is_visible(c.oid)'
				|| ' AND c.relname = ' || quote_literal($2);
			EXECUTE sql INTO schema;

			IF schema IS NULL THEN
				RAISE EXCEPTION 'The table % does not occur in the search_path', quote_literal($2);
				RETURN FALSE;
			END IF;
		END IF;

		<<kwloop>>
		FOR x in 1..max LOOP
			kw := trim(both from lower(constraints[x]));

			BEGIN
				CASE
					WHEN kw = 'srid' THEN
						RAISE NOTICE 'Dropping SRID constraint';
						rtn := _drop_raster_constraint_srid(schema, $2, $3);
					WHEN kw IN ('scale_x', 'scalex') THEN
						RAISE NOTICE 'Dropping scale-X constraint';
						rtn := _drop_raster_constraint_scale(schema, $2, $3, 'x');
					WHEN kw IN ('scale_y', 'scaley') THEN
						RAISE NOTICE 'Dropping scale-Y constraint';
						rtn := _drop_raster_constraint_scale(schema, $2, $3, 'y');
					WHEN kw = 'scale' THEN
						RAISE NOTICE 'Dropping scale-X constraint';
						rtn := _drop_raster_constraint_scale(schema, $2, $3, 'x');
						RAISE NOTICE 'Dropping scale-Y constraint';
						rtn := _drop_raster_constraint_scale(schema, $2, $3, 'y');
					WHEN kw IN ('blocksize_x', 'blocksizex', 'width') THEN
						RAISE NOTICE 'Dropping blocksize-X constraint';
						rtn := _drop_raster_constraint_blocksize(schema, $2, $3, 'width');
					WHEN kw IN ('blocksize_y', 'blocksizey', 'height') THEN
						RAISE NOTICE 'Dropping blocksize-Y constraint';
						rtn := _drop_raster_constraint_blocksize(schema, $2, $3, 'height');
					WHEN kw = 'blocksize' THEN
						RAISE NOTICE 'Dropping blocksize-X constraint';
						rtn := _drop_raster_constraint_blocksize(schema, $2, $3, 'width');
						RAISE NOTICE 'Dropping blocksize-Y constraint';
						rtn := _drop_raster_constraint_blocksize(schema, $2, $3, 'height');
					WHEN kw IN ('same_alignment', 'samealignment', 'alignment') THEN
						RAISE NOTICE 'Dropping alignment constraint';
						rtn := _drop_raster_constraint_alignment(schema, $2, $3);
					WHEN kw IN ('regular_blocking', 'regularblocking') THEN
						rtn := _drop_raster_constraint_regular_blocking(schema, $2, $3);

						RAISE NOTICE 'Dropping coverage tile constraint required for regular blocking';
						rtn := _drop_raster_constraint_coverage_tile(schema, $2, $3);

						IF rtn IS NOT FALSE THEN
							RAISE NOTICE 'Dropping spatially unique constraint required for regular blocking';
							rtn := _drop_raster_constraint_spatially_unique(schema, $2, $3);
						END IF;
					WHEN kw IN ('num_bands', 'numbands') THEN
						RAISE NOTICE 'Dropping number of bands constraint';
						rtn := _drop_raster_constraint_num_bands(schema, $2, $3);
					WHEN kw IN ('pixel_types', 'pixeltypes') THEN
						RAISE NOTICE 'Dropping pixel type constraint';
						rtn := _drop_raster_constraint_pixel_types(schema, $2, $3);
					WHEN kw IN ('nodata_values', 'nodatavalues', 'nodata') THEN
						RAISE NOTICE 'Dropping nodata value constraint';
						rtn := _drop_raster_constraint_nodata_values(schema, $2, $3);
					WHEN kw IN ('out_db', 'outdb') THEN
						RAISE NOTICE 'Dropping out-of-database constraint';
						rtn := _drop_raster_constraint_out_db(schema, $2, $3);
					WHEN kw = 'extent' THEN
						RAISE NOTICE 'Dropping maximum extent constraint';
						rtn := _drop_raster_constraint_extent(schema, $2, $3);
					ELSE
						RAISE NOTICE 'Unknown constraint: %.  Skipping', quote_literal(constraints[x]);
						CONTINUE kwloop;
				END CASE;
			END;

			IF rtn IS FALSE THEN
				cnt := cnt + 1;
				RAISE WARNING 'Unable to drop constraint: %.  Skipping', quote_literal(constraints[x]);
			END IF;

		END LOOP kwloop;

		IF cnt = max THEN
			RAISE EXCEPTION 'None of the constraints specified could be dropped.  Is the schema name, table name or column name incorrect?';
			RETURN FALSE;
		END IF;

		RETURN TRUE;
	END;
	$$ LANGUAGE 'plpgsql' VOLATILE STRICT
	COST 100;

CREATE OR REPLACE FUNCTION DropRasterConstraints (
	rasttable name,
	rastcolumn name,
	VARIADIC constraints text[]
)
	RETURNS boolean AS
	$$ SELECT DropRasterConstraints('', $1, $2, VARIADIC $3) $$
	LANGUAGE 'sql' VOLATILE STRICT
	COST 100;

CREATE OR REPLACE FUNCTION DropRasterConstraints (
	rastschema name,
	rasttable name,
	rastcolumn name,
	srid boolean DEFAULT TRUE,
	scale_x boolean DEFAULT TRUE,
	scale_y boolean DEFAULT TRUE,
	blocksize_x boolean DEFAULT TRUE,
	blocksize_y boolean DEFAULT TRUE,
	same_alignment boolean DEFAULT TRUE,
	regular_blocking boolean DEFAULT TRUE,
	num_bands boolean DEFAULT TRUE,
	pixel_types boolean DEFAULT TRUE,
	nodata_values boolean DEFAULT TRUE,
	out_db boolean DEFAULT TRUE,
	extent boolean DEFAULT TRUE
)
	RETURNS boolean
	AS $$
	DECLARE
		constraints text[];
	BEGIN
		IF srid IS TRUE THEN
			constraints := constraints || 'srid'::text;
		END IF;

		IF scale_x IS TRUE THEN
			constraints := constraints || 'scale_x'::text;
		END IF;

		IF scale_y IS TRUE THEN
			constraints := constraints || 'scale_y'::text;
		END IF;

		IF blocksize_x IS TRUE THEN
			constraints := constraints || 'blocksize_x'::text;
		END IF;

		IF blocksize_y IS TRUE THEN
			constraints := constraints || 'blocksize_y'::text;
		END IF;

		IF same_alignment IS TRUE THEN
			constraints := constraints || 'same_alignment'::text;
		END IF;

		IF regular_blocking IS TRUE THEN
			constraints := constraints || 'regular_blocking'::text;
		END IF;

		IF num_bands IS TRUE THEN
			constraints := constraints || 'num_bands'::text;
		END IF;

		IF pixel_types IS TRUE THEN
			constraints := constraints || 'pixel_types'::text;
		END IF;

		IF nodata_values IS TRUE THEN
			constraints := constraints || 'nodata_values'::text;
		END IF;

		IF out_db IS TRUE THEN
			constraints := constraints || 'out_db'::text;
		END IF;

		IF extent IS TRUE THEN
			constraints := constraints || 'extent'::text;
		END IF;

		RETURN DropRasterConstraints($1, $2, $3, VARIADIC constraints);
	END;
	$$ LANGUAGE 'plpgsql' VOLATILE STRICT
	COST 100;

CREATE OR REPLACE FUNCTION DropRasterConstraints (
	rasttable name,
	rastcolumn name,
	srid boolean DEFAULT TRUE,
	scale_x boolean DEFAULT TRUE,
	scale_y boolean DEFAULT TRUE,
	blocksize_x boolean DEFAULT TRUE,
	blocksize_y boolean DEFAULT TRUE,
	same_alignment boolean DEFAULT TRUE,
	regular_blocking boolean DEFAULT TRUE,
	num_bands boolean DEFAULT TRUE,
	pixel_types boolean DEFAULT TRUE,
	nodata_values boolean DEFAULT TRUE,
	out_db boolean DEFAULT TRUE,
	extent boolean DEFAULT TRUE
)
	RETURNS boolean AS
	$$ SELECT DropRasterConstraints('', $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14) $$
	LANGUAGE 'sql' VOLATILE STRICT
	COST 100;

------------------------------------------------------------------------------
-- raster_columns
--
-- The metadata is documented in the PostGIS Raster specification:
-- http://trac.osgeo.org/postgis/wiki/WKTRaster/SpecificationFinal01
------------------------------------------------------------------------------
-- Availability: 2.0.0
-- Changed: 2.2.0
CREATE OR REPLACE VIEW raster_columns AS
	SELECT
		current_database() AS r_table_catalog,
		n.nspname AS r_table_schema,
		c.relname AS r_table_name,
		a.attname AS r_raster_column,
		COALESCE(_raster_constraint_info_srid(n.nspname, c.relname, a.attname), (SELECT ST_SRID('POINT(0 0)'::geometry))) AS srid,
		_raster_constraint_info_scale(n.nspname, c.relname, a.attname, 'x') AS scale_x,
		_raster_constraint_info_scale(n.nspname, c.relname, a.attname, 'y') AS scale_y,
		_raster_constraint_info_blocksize(n.nspname, c.relname, a.attname, 'width') AS blocksize_x,
		_raster_constraint_info_blocksize(n.nspname, c.relname, a.attname, 'height') AS blocksize_y,
		COALESCE(_raster_constraint_info_alignment(n.nspname, c.relname, a.attname), FALSE) AS same_alignment,
		COALESCE(_raster_constraint_info_regular_blocking(n.nspname, c.relname, a.attname), FALSE) AS regular_blocking,
		_raster_constraint_info_num_bands(n.nspname, c.relname, a.attname) AS num_bands,
		_raster_constraint_info_pixel_types(n.nspname, c.relname, a.attname) AS pixel_types,
		_raster_constraint_info_nodata_values(n.nspname, c.relname, a.attname) AS nodata_values,
		_raster_constraint_info_out_db(n.nspname, c.relname, a.attname) AS out_db,
		_raster_constraint_info_extent(n.nspname, c.relname, a.attname) AS extent,
		COALESCE(_raster_constraint_info_index(n.nspname, c.relname, a.attname), FALSE) AS spatial_index
	FROM
		pg_class c,
		pg_attribute a,
		pg_type t,
		pg_namespace n
	WHERE t.typname = 'raster'::name
		AND a.attisdropped = false
		AND a.atttypid = t.oid
		AND a.attrelid = c.oid
		AND c.relnamespace = n.oid
		AND c.relkind = ANY(ARRAY['r'::char, 'v'::char, 'm'::char, 'f'::char])
		AND NOT pg_is_other_temp_schema(c.relnamespace)  AND has_table_privilege(c.oid, 'SELECT'::text);

------------------------------------------------------------------------------
-- overview constraint functions
-------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION _overview_constraint(ov raster, factor integer, refschema name, reftable name, refcolumn name)
	RETURNS boolean AS
	$$ SELECT COALESCE((SELECT TRUE FROM raster_columns WHERE r_table_catalog = current_database() AND r_table_schema = $3 AND r_table_name = $4 AND r_raster_column = $5), FALSE) $$
	LANGUAGE 'sql' STABLE
	COST 100;

CREATE OR REPLACE FUNCTION _overview_constraint_info(
	ovschema name, ovtable name, ovcolumn name,
	OUT refschema name, OUT reftable name, OUT refcolumn name, OUT factor integer
)
	AS $$
	SELECT
		split_part(split_part(s.consrc, '''::name', 1), '''', 2)::name,
		split_part(split_part(s.consrc, '''::name', 2), '''', 2)::name,
		split_part(split_part(s.consrc, '''::name', 3), '''', 2)::name,
		trim(both from split_part(s.consrc, ',', 2))::integer
	FROM pg_class c, pg_namespace n, pg_attribute a, pg_constraint s
	WHERE n.nspname = $1
		AND c.relname = $2
		AND a.attname = $3
		AND a.attrelid = c.oid
		AND s.connamespace = n.oid
		AND s.conrelid = c.oid
		AND a.attnum = ANY (s.conkey)
		AND s.consrc LIKE '%_overview_constraint(%'
	$$ LANGUAGE sql STABLE STRICT
  COST 100;

CREATE OR REPLACE FUNCTION _add_overview_constraint(
	ovschema name, ovtable name, ovcolumn name,
	refschema name, reftable name, refcolumn name,
	factor integer
)
	RETURNS boolean AS $$
	DECLARE
		fqtn text;
		cn name;
		sql text;
	BEGIN
		fqtn := '';
		IF length($1) > 0 THEN
			fqtn := quote_ident($1) || '.';
		END IF;
		fqtn := fqtn || quote_ident($2);

		cn := 'enforce_overview_' || $3;

		sql := 'ALTER TABLE ' || fqtn
			|| ' ADD CONSTRAINT ' || quote_ident(cn)
			|| ' CHECK (_overview_constraint(' || quote_ident($3)
			|| ',' || $7
			|| ',' || quote_literal($4)
			|| ',' || quote_literal($5)
			|| ',' || quote_literal($6)
			|| '))';

		RETURN _add_raster_constraint(cn, sql);
	END;
	$$ LANGUAGE 'plpgsql' VOLATILE STRICT
	COST 100;

CREATE OR REPLACE FUNCTION _drop_overview_constraint(ovschema name, ovtable name, ovcolumn name)
	RETURNS boolean AS
	$$ SELECT _drop_raster_constraint($1, $2, 'enforce_overview_' || $3) $$
	LANGUAGE 'sql' VOLATILE STRICT
	COST 100;

------------------------------------------------------------------------------
-- RASTER_OVERVIEWS
------------------------------------------------------------------------------
-- Availability: 2.0.0
-- Changed: 2.2.0
CREATE OR REPLACE VIEW raster_overviews AS
	SELECT
		current_database() AS o_table_catalog,
		n.nspname AS o_table_schema,
		c.relname AS o_table_name,
		a.attname AS o_raster_column,
		current_database() AS r_table_catalog,
		split_part(split_part(s.consrc, '''::name', 1), '''', 2)::name AS r_table_schema,
		split_part(split_part(s.consrc, '''::name', 2), '''', 2)::name AS r_table_name,
		split_part(split_part(s.consrc, '''::name', 3), '''', 2)::name AS r_raster_column,
		trim(both from split_part(s.consrc, ',', 2))::integer AS overview_factor
	FROM
		pg_class c,
		pg_attribute a,
		pg_type t,
		pg_namespace n,
		pg_constraint s
	WHERE t.typname = 'raster'::name
		AND a.attisdropped = false
		AND a.atttypid = t.oid
		AND a.attrelid = c.oid
		AND c.relnamespace = n.oid
		AND c.relkind = ANY(ARRAY['r'::char, 'v'::char, 'm'::char, 'f'::char])
		AND s.connamespace = n.oid
		AND s.conrelid = c.oid
		AND s.consrc LIKE '%_overview_constraint(%'
		AND NOT pg_is_other_temp_schema(c.relnamespace)  AND has_table_privilege(c.oid, 'SELECT'::text);

------------------------------------------------------------------------------
-- AddOverviewConstraints
------------------------------------------------------------------------------

-- Availability: 2.0.0
CREATE OR REPLACE FUNCTION AddOverviewConstraints (
	ovschema name, ovtable name, ovcolumn name,
	refschema name, reftable name, refcolumn name,
	ovfactor int
)
	RETURNS boolean
	AS $$
	DECLARE
		x int;
		s name;
		t name;
		oschema name;
		rschema name;
		sql text;
		rtn boolean;
	BEGIN
		FOR x IN 1..2 LOOP
			s := '';

			IF x = 1 THEN
				s := $1;
				t := $2;
			ELSE
				s := $4;
				t := $5;
			END IF;

			-- validate user-provided schema
			IF length(s) > 0 THEN
				sql := 'SELECT nspname FROM pg_namespace '
					|| 'WHERE nspname = ' || quote_literal(s)
					|| 'LIMIT 1';
				EXECUTE sql INTO s;

				IF s IS NULL THEN
					RAISE EXCEPTION 'The value % is not a valid schema', quote_literal(s);
					RETURN FALSE;
				END IF;
			END IF;

			-- no schema, determine what it could be using the table
			IF length(s) < 1 THEN
				sql := 'SELECT n.nspname AS schemaname '
					|| 'FROM pg_catalog.pg_class c '
					|| 'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace '
					|| 'WHERE c.relkind = ' || quote_literal('r')
					|| ' AND n.nspname NOT IN (' || quote_literal('pg_catalog')
					|| ', ' || quote_literal('pg_toast')
					|| ') AND pg_catalog.pg_table_is_visible(c.oid)'
					|| ' AND c.relname = ' || quote_literal(t);
				EXECUTE sql INTO s;

				IF s IS NULL THEN
					RAISE EXCEPTION 'The table % does not occur in the search_path', quote_literal(t);
					RETURN FALSE;
				END IF;
			END IF;

			IF x = 1 THEN
				oschema := s;
			ELSE
				rschema := s;
			END IF;
		END LOOP;

		-- reference raster
		rtn := _add_overview_constraint(oschema, $2, $3, rschema, $5, $6, $7);
		IF rtn IS FALSE THEN
			RAISE EXCEPTION 'Unable to add the overview constraint.  Is the schema name, table name or column name incorrect?';
			RETURN FALSE;
		END IF;

		RETURN TRUE;
	END;
	$$ LANGUAGE 'plpgsql' VOLATILE STRICT
	COST 100;

-- Availability: 2.0.0
CREATE OR REPLACE FUNCTION AddOverviewConstraints (
	ovtable name, ovcolumn name,
	reftable name, refcolumn name,
	ovfactor int
)
	RETURNS boolean
	AS $$ SELECT AddOverviewConstraints('', $1, $2, '', $3, $4, $5) $$
	LANGUAGE 'sql' VOLATILE STRICT
	COST 100;

------------------------------------------------------------------------------
-- DropOverviewConstraints
------------------------------------------------------------------------------

-- Availability: 2.0.0
CREATE OR REPLACE FUNCTION DropOverviewConstraints (
	ovschema name,
	ovtable name,
	ovcolumn name
)
	RETURNS boolean
	AS $$
	DECLARE
		schema name;
		sql text;
		rtn boolean;
	BEGIN
		-- validate schema
		schema := NULL;
		IF length($1) > 0 THEN
			sql := 'SELECT nspname FROM pg_namespace '
				|| 'WHERE nspname = ' || quote_literal($1)
				|| 'LIMIT 1';
			EXECUTE sql INTO schema;

			IF schema IS NULL THEN
				RAISE EXCEPTION 'The value provided for schema is invalid';
				RETURN FALSE;
			END IF;
		END IF;

		IF schema IS NULL THEN
			sql := 'SELECT n.nspname AS schemaname '
				|| 'FROM pg_catalog.pg_class c '
				|| 'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace '
				|| 'WHERE c.relkind = ' || quote_literal('r')
				|| ' AND n.nspname NOT IN (' || quote_literal('pg_catalog')
				|| ', ' || quote_literal('pg_toast')
				|| ') AND pg_catalog.pg_table_is_visible(c.oid)'
				|| ' AND c.relname = ' || quote_literal($2);
			EXECUTE sql INTO schema;

			IF schema IS NULL THEN
				RAISE EXCEPTION 'The table % does not occur in the search_path', quote_literal($2);
				RETURN FALSE;
			END IF;
		END IF;

		rtn := _drop_overview_constraint(schema, $2, $3);
		IF rtn IS FALSE THEN
			RAISE EXCEPTION 'Unable to drop the overview constraint .  Is the schema name, table name or column name incorrect?';
			RETURN FALSE;
		END IF;

		RETURN TRUE;
	END;
	$$ LANGUAGE 'plpgsql' VOLATILE STRICT
	COST 100;

-- Availability: 2.0.0
CREATE OR REPLACE FUNCTION DropOverviewConstraints (
	ovtable name,
	ovcolumn name
)
	RETURNS boolean
	AS $$ SELECT DropOverviewConstraints('', $1, $2) $$
	LANGUAGE 'sql' VOLATILE STRICT
	COST 100;

------------------------------------------------------------------------------
-- UpdateRasterSRID
------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION _UpdateRasterSRID(
	schema_name name, table_name name, column_name name,
	new_srid integer
)
	RETURNS boolean
	AS $$
	DECLARE
		fqtn text;
		schema name;
		sql text;
		srid integer;
		ct boolean;
	BEGIN
		-- validate schema
		schema := NULL;
		IF length($1) > 0 THEN
			sql := 'SELECT nspname FROM pg_namespace '
				|| 'WHERE nspname = ' || quote_literal($1)
				|| 'LIMIT 1';
			EXECUTE sql INTO schema;

			IF schema IS NULL THEN
				RAISE EXCEPTION 'The value provided for schema is invalid';
				RETURN FALSE;
			END IF;
		END IF;

		IF schema IS NULL THEN
			sql := 'SELECT n.nspname AS schemaname '
				|| 'FROM pg_catalog.pg_class c '
				|| 'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace '
				|| 'WHERE c.relkind = ' || quote_literal('r')
				|| ' AND n.nspname NOT IN (' || quote_literal('pg_catalog')
				|| ', ' || quote_literal('pg_toast')
				|| ') AND pg_catalog.pg_table_is_visible(c.oid)'
				|| ' AND c.relname = ' || quote_literal($2);
			EXECUTE sql INTO schema;

			IF schema IS NULL THEN
				RAISE EXCEPTION 'The table % does not occur in the search_path', quote_literal($2);
				RETURN FALSE;
			END IF;
		END IF;

		-- clamp SRID
		IF new_srid < 0 THEN
			srid := ST_SRID('POINT EMPTY'::geometry);
			RAISE NOTICE 'SRID % converted to the officially unknown SRID %', new_srid, srid;
		ELSE
			srid := new_srid;
		END IF;

		-- drop coverage tile constraint
		-- done separately just in case constraint doesn't exist
		ct := _raster_constraint_info_coverage_tile(schema, $2, $3);
		IF ct IS TRUE THEN
			PERFORM _drop_raster_constraint_coverage_tile(schema, $2, $3);
		END IF;

		-- drop SRID, extent, alignment constraints
		PERFORM DropRasterConstraints(schema, $2, $3, 'extent', 'alignment', 'srid');

		fqtn := '';
		IF length($1) > 0 THEN
			fqtn := quote_ident($1) || '.';
		END IF;
		fqtn := fqtn || quote_ident($2);

		-- update SRID
		sql := 'UPDATE ' || fqtn ||
			' SET ' || quote_ident($3) ||
			' = ST_SetSRID(' || quote_ident($3) ||
			'::raster, ' || srid || ')';
		RAISE NOTICE 'sql = %', sql;
		EXECUTE sql;

		-- add SRID constraint
		PERFORM AddRasterConstraints(schema, $2, $3, 'srid', 'extent', 'alignment');

		-- add coverage tile constraint if needed
		IF ct IS TRUE THEN
			PERFORM _add_raster_constraint_coverage_tile(schema, $2, $3);
		END IF;

		RETURN TRUE;
	END;
	$$ LANGUAGE 'plpgsql' VOLATILE;

CREATE OR REPLACE FUNCTION UpdateRasterSRID(
	schema_name name, table_name name, column_name name,
	new_srid integer
)
	RETURNS boolean
	AS $$ SELECT _UpdateRasterSRID($1, $2, $3, $4) $$
	LANGUAGE 'sql' VOLATILE STRICT;

CREATE OR REPLACE FUNCTION UpdateRasterSRID(
	table_name name, column_name name,
	new_srid integer
)
	RETURNS boolean
	AS $$ SELECT _UpdateRasterSRID('', $1, $2, $3) $$
	LANGUAGE 'sql' VOLATILE STRICT;

------------------------------------------------------------------------------
-- ST_Retile
------------------------------------------------------------------------------

-- Availability: 2.2.0
-- @param ext extent to create overviews for, also used for grid origin
--            SRID must match source tile srid.
-- @param sfx scale factor x (pixel width)
-- @param sfy scale factor y (pixel height, usually negative)
-- @param tw max tile width
-- @param th max tile height
--
CREATE OR REPLACE FUNCTION ST_Retile(tab regclass, col name, ext geometry, sfx float8, sfy float8, tw int, th int, algo text DEFAULT 'NearestNeighbour')
RETURNS SETOF raster AS $$
DECLARE
  rec RECORD;
  ipx FLOAT8;
  ipy FLOAT8;
  tx int;
  ty int;
  te GEOMETRY; -- tile extent
  ncols int;
  nlins int;
  srid int;
  sql TEXT;
BEGIN

  RAISE DEBUG 'Target coverage will have sfx=%, sfy=%', sfx, sfy;

  -- 2. Loop over each target tile and build it from source tiles
  ipx := st_xmin(ext);
  ncols := ceil((st_xmax(ext)-ipx)/sfx/tw);
  IF sfy < 0 THEN
    ipy := st_ymax(ext);
    nlins := ceil((st_ymin(ext)-ipy)/sfy/th);
  ELSE
    ipy := st_ymin(ext);
    nlins := ceil((st_ymax(ext)-ipy)/sfy/th);
  END IF;

  srid := ST_Srid(ext);

  RAISE DEBUG 'Target coverage will have % x % tiles, each of approx size % x %', ncols, nlins, tw, th;
  RAISE DEBUG 'Target coverage will cover extent %', ext::box2d;

  FOR tx IN 0..ncols-1 LOOP
    FOR ty IN 0..nlins-1 LOOP
      te := ST_MakeEnvelope(ipx + tx     *  tw  * sfx,
                             ipy + ty     *  th  * sfy,
                             ipx + (tx+1) *  tw  * sfx,
                             ipy + (ty+1) *  th  * sfy,
                             srid);
      --RAISE DEBUG 'sfx/sfy: %, %', sfx, sfy;
      --RAISE DEBUG 'tile extent %', te;
      sql := 'SELECT count(*), ST_Clip(ST_Union(ST_SnapToGrid(ST_Rescale(ST_Clip(' || quote_ident(col)
          || ', st_expand($3, greatest($1,$2))),$1, $2, $6), $4, $5, $1, $2)), $3) g FROM ' || tab::text
          || ' WHERE ST_Intersects(' || quote_ident(col) || ', $3)';
      --RAISE DEBUG 'SQL: %', sql;
      FOR rec IN EXECUTE sql USING sfx, sfy, te, ipx, ipy, algo LOOP
        --RAISE DEBUG '% source tiles intersect target tile %,% with extent %', rec.count, tx, ty, te::box2d;
        IF rec.g IS NULL THEN
          RAISE WARNING 'No source tiles cover target tile %,% with extent %',
            tx, ty, te::box2d;
        ELSE
          --RAISE DEBUG 'Tile for extent % has size % x %', te::box2d, st_width(rec.g), st_height(rec.g);
          RETURN NEXT rec.g;
        END IF;
      END LOOP;
    END LOOP;
  END LOOP;

  RETURN;
END;
$$ LANGUAGE 'plpgsql' STABLE STRICT;

------------------------------------------------------------------------------
-- ST_CreateOverview
------------------------------------------------------------------------------

-- Availability: 2.2.0
CREATE OR REPLACE FUNCTION ST_CreateOverview(tab regclass, col name, factor int, algo text DEFAULT 'NearestNeighbour')
RETURNS regclass AS $$
DECLARE
  sinfo RECORD; -- source info
  sql TEXT;
  ttab TEXT;
BEGIN

  -- 0. Check arguments, we need to ensure:
  --    a. Source table has a raster column with given name
  --    b. Source table has a fixed scale (or "factor" would have no meaning)
  --    c. Source table has a known extent ? (we could actually compute it)
  --    d. Source table has a fixed tile size (or "factor" would have no meaning?)
  -- # all of the above can be checked with a query to raster_columns
  sql := 'SELECT r.r_table_schema sch, r.r_table_name tab, '
      || 'r.scale_x sfx, r.scale_y sfy, r.blocksize_x tw, '
      || 'r.blocksize_y th, r.extent ext, r.srid FROM raster_columns r, '
      || 'pg_class c, pg_namespace n WHERE r.r_table_schema = n.nspname '
      || 'AND r.r_table_name = c.relname AND r_raster_column = $2 AND '
      || ' c.relnamespace = n.oid AND c.oid = $1'
  ;
  EXECUTE sql INTO sinfo USING tab, col;
  IF sinfo IS NULL THEN
      RAISE EXCEPTION '%.% raster column does not exist', tab::text, col;
  END IF;
  IF sinfo.sfx IS NULL or sinfo.sfy IS NULL THEN
    RAISE EXCEPTION 'cannot create overview without scale constraint, try select AddRasterConstraints(''%'', ''%'');', tab::text, col;
  END IF;
  IF sinfo.tw IS NULL or sinfo.tw IS NULL THEN
    RAISE EXCEPTION 'cannot create overview without tilesize constraint, try select AddRasterConstraints(''%'', ''%'');', tab::text, col;
  END IF;
  IF sinfo.ext IS NULL THEN
    RAISE EXCEPTION 'cannot create overview without extent constraint, try select AddRasterConstraints(''%'', ''%'');', tab::text, col;
  END IF;

  -- TODO: lookup in raster_overviews to see if there's any
  --       lower-resolution table to start from

  ttab := 'o_' || factor || '_' || sinfo.tab;
  sql := 'CREATE TABLE ' || quote_ident(sinfo.sch)
      || '.' || quote_ident(ttab)
      || ' AS SELECT ST_Retile($1, $2, $3, $4, $5, $6, $7) '
      || quote_ident(col);
  EXECUTE sql USING tab, col, sinfo.ext,
                    sinfo.sfx * factor, sinfo.sfy * factor,
                    sinfo.tw, sinfo.th, algo;

  -- TODO: optimize this using knowledge we have about
  --       the characteristics of the target column ?
  PERFORM AddRasterConstraints(sinfo.sch, ttab, col);

  PERFORM AddOverviewConstraints(sinfo.sch, ttab, col,
                                 sinfo.sch, sinfo.tab, col, factor);

  RETURN ttab;
END;
$$ LANGUAGE 'plpgsql' VOLATILE STRICT;

-------------------------------------------------------------------
--  Debugging
-------------------------------------------------------------------

-- Availability: 2.2.0
CREATE OR REPLACE FUNCTION postgis_noop(raster)
	RETURNS geometry
	AS '$libdir/rtpostgis-2.2', 'RASTER_noop'
	LANGUAGE 'c' VOLATILE STRICT;


-------------------------------------------------------------------
--  END
-------------------------------------------------------------------
-- make views public viewable --
GRANT SELECT ON TABLE raster_columns TO public;
GRANT SELECT ON TABLE raster_overviews TO public;
COMMIT;

