/********************************************************************************
 * Copyright (C) 2017-2020 German Aerospace Center (DLR). 
 * Eclipse ADORe, Automated Driving Open Research https://eclipse.org/adore
 *
 * This program and the accompanying materials are made available under the 
 * terms of the Eclipse Public License 2.0 which is available at
 * http://www.eclipse.org/legal/epl-2.0.
 *
 * SPDX-License-Identifier: EPL-2.0 
 *
 * Contributors: 
 *   Reza Dariani - initial API and implementation
 ********************************************************************************/

#pragma once
#include <math.h>
/**
 *  This class converts the Lat-Long to UTM and vice-versa. 
 */

//https://de.wikipedia.org/wiki/World_Geodetic_System_1984
//http://alephnull.net/software/gis/UTM_WGS84_C_plus_plus.shtml
//https://www.springer.com/de/book/9783211835340
// Hoffmann-Wellenhof, B., Lichtenegger, H., and Collins, J. GPS: Theory and Practice, 3rd ed.  New York: Springer-Verlag Wien, 1994
//Germany has 3 different UTM zones see: http://www.killetsoft.de/t_0901_d.htm

#define sm_a 6378137.0				//Ellipsoid model major axis
#define sm_b 6356752.314			//Ellipsoid model minor axis
#define sm_EccSquared 6.69437999013e-03
#define UTMScaleFactor 0.9996
#define PI 3.14159265358979
namespace adore
{
	namespace mad
	{
		class CoordinateConversion
		{

		public:
			/**
			* converts Lat-Lon coordinate to UTM
			* @param lat is the lattitude (input)
			* @param lon is the longitude (input)
			* @param x is the UTM x (output)
			* @param y is the UTM y (output)
			*/
			static int LatLonToUTMXY (double lat, double lon, int zone, double& x, double& y);
			/**
			* converts UTM coordinate to Lat-Lon
			* @param x is the UTM x (input)
			* @param y is the UTM y (input)
			* @param zone is the UTM zone (input)
			* @param zone is the UTM zone (southhemi), If the position is in the northern hemisphere then should be set to false, else true
			* @param lat is the lattitude (output)
			* @param lon is the longitude (output)
			*/
			static void UTMXYToLatLon (double x, double y, int zone, bool southhemi, double& lat, double& lon);
			/**
			* converts UTM coordinate to Lat-Lon (degree)
			* @param x is the UTM x (input)
			* @param y is the UTM y (input)
			* @param zone is the UTM zone (input)
			* @param zone is the UTM zone (southhemi), If the position is in the northern hemisphere then should be set to  false, else true
			* @param lat is the lattitude (output)
			* @param lon is the longitude (output)
			*/
			static void UTMXYToLatLonDegree (double x, double y, int zone, bool southhemi, double& lat, double& lon);
			/**
			* converts degree to radian
			* @param deg is degree (input)
			* @return the radian
			*/
			static double DegToRad(double deg);
			/**
			* converts radian to degree
			* @param rad is radian (input)
			* @return the degree
			*/
			static double RadToDeg(double rad);
			/**
			* normalize the radian [-2*pi , 2*pi]
			* @param rad is radian (input)
			* @return is the normialized radian
			*/
			static double twoPIrange(double rad);

		private:
			static double ArcLengthOfMeridian (double phi) ;
			static double UTMCentralMeridian(int zone);
			static double FootpointLatitude(double y);

			static void MapLatLonToXY (double phi, double lambda, double lambda0, double &x, double &y);
			static void MapXYToLatLon (double x, double y, double lambda0, double& phi, double& lambda);
		};
	}
}