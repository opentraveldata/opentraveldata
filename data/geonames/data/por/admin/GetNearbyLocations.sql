/*
From: http://forum.geonames.org/gforum/posts/list/2033.page 
wget http://forum.geonames.org/gforum/posts/downloadAttach/123.page
*/

CREATE FUNCTION [dbo].[Geo_GetNearbyLocations] 
(	
	@GeoNameID int,
	@Latitude decimal(23,20),
	@Longitude decimal(23,20),
	@MaxDistance int,
	@IncludeDisabledLocations bit, -- Added to support activity proximity searches where location may have been disabled after use by activity listing
	@OnlyInUseByActivityListings bit -- Added to allow better performance when we're only interested in locations in use by activity listings
)
RETURNS @GeoNameIDs TABLE
(
	GeoNameID int NOT NULL,
	Distance int NOT NULL
) 
AS
BEGIN
/*
Inspiration taken from:
http://forum.geonames.org/gforum/posts/list/0/522.page
*/
	IF @GeoNameID IS NOT NULL OR (@Latitude IS NOT NULL AND @Longitude IS NOT NULL)
	BEGIN
		-- Convert to decimal to avoid rounding errors
		DECLARE @MaxDistanceDec decimal
		SET @MaxDistanceDec = @MaxDistance

		/*
		Earth's radius:
		6378137 meters
		6378.137 km
		3963.191 miles
		3441.596 nautical miles
		*/
		DECLARE @EarthRadius decimal(10,3)
		SET @EarthRadius = 6378.137 -- km

		-- Get latitude and longitude
		IF NOT @GeoNameID IS NULL
			SELECT @Latitude = Latitude, @Longitude = Longitude FROM GeoName WHERE GeoNameID = @GeoNameID

		DECLARE @LatRange decimal(23,20)
		DECLARE @LongRange decimal(23,20)
		SET @LatRange = (@MaxDistanceDec / 111) -- 111 is number of km in 1 degree lat
		SET @LongRange = ((@MaxDistanceDec / 111) / cos(Radians(@Latitude)))

 		DECLARE @MinLatitude decimal(23,20), @MaxLatitude decimal(23,20), @MinLongitude decimal(23,20), @MaxLongitude decimal(23,20)
		SET @MinLatitude = @Latitude - @LatRange
 		SET @MaxLatitude = @Latitude + @LatRange
 		SET @MinLongitude = @Longitude - @LongRange
 		SET @MaxLongitude = @Longitude + @LongRange

		-- Search
		-- NOTE: There is a Geo_CalculateDistance function but it's far faster to perform calculations inline!
		DECLARE @GeoNameIDsTemp TABLE
		(
			GeoNameID varchar(255) NOT NULL,
			Distance int NOT NULL
		)
		IF @OnlyInUseByActivityListings = 0
		BEGIN
			INSERT INTO @GeoNameIDsTemp (GeoNameID, Distance)
 			SELECT geo.GeoNameID,
 				ROUND(@EarthRadius * ACOS(ROUND(
 					(SIN(RADIANS(@Latitude)) * SIN(RADIANS(geo.Latitude))) +
 					(COS(RADIANS(@Latitude)) * COS(RADIANS(geo.Latitude)) *
 					 COS(RADIANS(geo.Longitude) - RADIANS(@Longitude))),15)),0) AS Distance
 			FROM GeoName AS geo WITH(NOLOCK)
 			WHERE -- Below is rough proximity search to super speed the query up
 				(geo.Latitude >= @MinLatitude AND geo.Latitude <= @MaxLatitude AND geo.Longitude >= @MinLongitude AND geo.Longitude <= @MaxLongitude)
 				-- Below should result in accurate proximity search
 				AND ROUND(@EarthRadius * ACOS(ROUND(
 					(SIN(RADIANS(@Latitude)) * SIN(RADIANS(geo.Latitude))) +
 					(COS(RADIANS(@Latitude)) * COS(RADIANS(geo.Latitude)) *
 					 COS(RADIANS(geo.Longitude) - RADIANS(@Longitude))),15)),0) <= @MaxDistanceDec
 			ORDER BY 2 ASC
		END
		ELSE
		BEGIN
			INSERT INTO @GeoNameIDsTemp (GeoNameID, Distance)
 			SELECT geo.GeoNameID,
 				ROUND(@EarthRadius * ACOS(ROUND(
 					(SIN(RADIANS(@Latitude)) * SIN(RADIANS(geo.Latitude))) +
 					(COS(RADIANS(@Latitude)) * COS(RADIANS(geo.Latitude)) *
 					 COS(RADIANS(geo.Longitude) - RADIANS(@Longitude))),15)),0) AS Distance
 			FROM GeoName AS geo WITH(NOLOCK)
 			WHERE geo.GeoNameID IN (SELECT GeoNameID FROM vw_GeoNameInUseByActivityListing WITH(NOLOCK))
				-- Below is rough proximity search to super speed the query up
 				AND (geo.Latitude >= @MinLatitude AND geo.Latitude <= @MaxLatitude AND geo.Longitude >= @MinLongitude AND geo.Longitude <= @MaxLongitude)
 				-- Below should result in accurate proximity search
 				AND ROUND(@EarthRadius * ACOS(ROUND(
 					(SIN(RADIANS(@Latitude)) * SIN(RADIANS(geo.Latitude))) +
 					(COS(RADIANS(@Latitude)) * COS(RADIANS(geo.Latitude)) *
 					 COS(RADIANS(geo.Longitude) - RADIANS(@Longitude))),15)),0) <= @MaxDistanceDec
 			ORDER BY 2 ASC
		END

		IF @IncludeDisabledLocations = 1
		BEGIN
			-- Return all locations (including disabled ones)
			INSERT INTO @GeoNameIDs (GeoNameID, Distance)
			SELECT rslts.GeoNameID, rslts.Distance
			FROM @GeoNameIDsTemp AS rslts
		END
		ELSE
		BEGIN
			-- Strip out disabled features / locations from the results
			-- NOTE: It's quicker to do this as a second step instead of doing it as part of the initial search query!
			INSERT INTO @GeoNameIDs (GeoNameID, Distance)
			SELECT rslts.GeoNameID, rslts.Distance
			FROM @GeoNameIDsTemp AS rslts
				INNER JOIN GeoName AS geo WITH(NOLOCK) ON geo.GeoNameID = rslts.GeoNameID
				INNER JOIN GeoFeature AS ftr WITH(NOLOCK) ON ISNULL(geo.FeatureClass, '') = ftr.FeatureClass
					AND ISNULL(geo.FeatureCode, '') = ftr.FeatureCode
 			WHERE geo.IsDisabled = 0
				AND ftr.IsDisabled = 0
		END
	END
	RETURN
END
GO
