// based on geohash.js (c) 2008 David Troy
// Distributed under the MIT License
// modified 2013 by Jacob Jay <jacob@verse.org> with grid functions and namespace
// parity with moonstalk.geo/geohash.lua

var geohash = {};

geohash.BITS =		[16, 8, 4, 2, 1];

geohash.BASE32 =    "0123456789bcdefghjkmnpqrstuvwxyz";
geohash.NEIGHBORS = { right  : { even :  "bc01fg45238967deuvhjyznpkmstqrwx" },
							left   : { even :  "238967debc01fg45kmstqrwxuvhjyznp" },
							top    : { even :  "p0r21436x8zb9dcf5h7kjnmqesgutwvy" },
							bottom : { even :  "14365h7k9dcfesgujnmqp0r2twvyx8zb" } };
							
geohash.BORDERS   = { right  : { even : "bcfguvyz" },
							left   : { even : "0145hjnp" },
							top    : { even : "prxz" },
							bottom : { even : "028b" } };
							
geohash.NEIGHBORS.bottom.odd = geohash.NEIGHBORS.left.even;
geohash.NEIGHBORS.top.odd = geohash.NEIGHBORS.right.even;
geohash.NEIGHBORS.left.odd = geohash.NEIGHBORS.bottom.even;
geohash.NEIGHBORS.right.odd = geohash.NEIGHBORS.top.even;
geohash.BORDERS.bottom.odd = geohash.BORDERS.left.even;

geohash.BORDERS.top.odd = geohash.BORDERS.right.even;
geohash.BORDERS.left.odd = geohash.BORDERS.bottom.even;
geohash.BORDERS.right.odd = geohash.BORDERS.top.even;

geohash.refine_interval = function(interval, cd, mask) {
	if (cd&mask) {
		interval[0] = (interval[0] + interval[1])/2;
	} else {
		interval[1] = (interval[0] + interval[1])/2;
	}
}

geohash.Adjacent = function(srcHash, dir) {
	srcHash = srcHash.toLowerCase();
	var lastChr = srcHash.charAt(srcHash.length-1);
	var type = (srcHash.length % 2) ? 'odd' : 'even';
	var base = srcHash.substring(0,srcHash.length-1);
	if (geohash.BORDERS[dir][type].indexOf(lastChr)!=-1)
		{ base = geohash.Adjacent(base, dir) }
	return base + geohash.BASE32[geohash.NEIGHBORS[dir][type].indexOf(lastChr)];
}

geohash.Decode = function(_geohash, precision) {
	precision = precision || _geohash.length
	var is_even = 1;
	var lat = [], lon = [];
	lat[0] = -90.0;  lat[1] = 90.0;
	lon[0] = -180.0; lon[1] = 180.0;
	var lat_err = 90.0, lon_err = 180.0;

	for (i=0; i<precision; i++) {
		var c = _geohash[i];
		var cd = geohash.BASE32.indexOf(c);
		for (j=0; j<5; j++) {
			var mask = geohash.BITS[j];
			if (is_even) {
				lon_err /= 2;
				geohash.refine_interval(lon, cd, mask);
			} else {
				lat_err /= 2;
				geohash.refine_interval(lat, cd, mask);
			}
			is_even = !is_even;
		}
	}
	lat[2] = (lat[0] + lat[1])/2;
	lon[2] = (lon[0] + lon[1])/2;

	return { latitude: lat[2], longitude: lon[2]};
}

geohash.Encode = function(latitude, longitude, precision) {
	precision = precision || 12
	var is_even=1;
	var i=0;
	var lat = []; var lon = [];
	var bit=0;
	var ch=0;
	var _geohash = "";

	lat[0] = -90.0;  lat[1] = 90.0;
	lon[0] = -180.0; lon[1] = 180.0;
	
	while (_geohash.length < precision) {
		var mid;
		if (is_even) {
			mid = (lon[0] + lon[1]) / 2;
	    if (longitude > mid) {
				ch |= geohash.BITS[bit];
				lon[0] = mid;
	    } else
				lon[1] = mid;
	  } else {
			mid = (lat[0] + lat[1]) / 2;
	    if (latitude > mid) {
				ch |= geohash.BITS[bit];
				lat[0] = mid;
	    } else
				lat[1] = mid;
	  }

		is_even = !is_even;
	  if (bit < 4)
			bit++;
	  else {
			_geohash += geohash.BASE32[ch];
			bit = 0;
			ch = 0;
	  }
	}
	return _geohash;
}

// original function names maintained for compatibility

var encodeGeoHashPr = geohash.Encode;
var encodeGeoHash = geohash.Encode;
var decodeGeoHashPr = geohash.Decode;
var decodeGeoHash = geohash.Decode;
var calculateAdjacent = geohash.Adjacent;

// helper functions

geohash.Neighbours = function(centre){
	// returns an array of geohashes surrounding and corresponding to length of the given centre geohash
	var neighbours = [];
	var left = geohash.Adjacent(centre,'left')
	var next = geohash.Adjacent(left,'top')
	neighbours.push(next);
	next = geohash.Adjacent(centre,'top')
	neighbours.push(next);
	next = geohash.Adjacent(next,'right')
	neighbours.push(next);
	next = geohash.Adjacent(centre,'right')
	neighbours.push(next);
	next = geohash.Adjacent(next,'bottom')
	neighbours.push(next);
	next = geohash.Adjacent(centre,'bottom')
	neighbours.push(next);
	next = geohash.Adjacent(next,'left')
	neighbours.push(next);
	neighbours.push(left);
	return neighbours
}

geohash.Sides = function(centre){
	// similar to Neighbours, but converted to a structure of sides suitable for iteration by Grid; the structures contains, individual side arrays, a hash for lookups, and an array for eventual results
	var neighbours = geohash.Neighbours(centre);
	var sides = {top:[neighbours[0],neighbours[1]],right:[neighbours[2],neighbours[3]],bottom:[neighbours[4],neighbours[5]],left:[neighbours[6],neighbours[7]],index:{},array:neighbours}
	for (var i = 0; i < 8; i++) { sides.index[neighbours[i]] = true }
	return sides
}

geohash.directions = {top:'left',right:'top',bottom:'right',left:'bottom'}
geohash.Edges = function(sides){
	// used by Grid to get the outward neighbours from Sides, but returning only its new edge neighbours (not the centre) in the same structure
	if (sides.centre) { return geohash.Sides(sides.centre) };
	var expanded = {top:[],right:[],bottom:[],left:[],index:{},array:[]}
	for (var side in geohash.directions) {
		var precorner = geohash.Adjacent(sides[side][0], geohash.directions[side]);
		var corner = geohash.Adjacent(precorner, side);
		expanded[side].push(precorner); // by handling the first item on each side separately we can fetch the new corner by looking up its appropriate direction
		expanded.array.push(precorner);
		expanded.index[precorner]=true
		expanded[side].push(corner);
		expanded.array.push(corner);
		expanded.index[corner]=true
		for (var i = 0; i < sides[side].length; i++) {
			var next = geohash.Adjacent(sides[side][i], side);
			expanded[side].push(next);
			expanded.array.push(next);
			expanded.index[next]=true			
		}
	}
	return expanded
}

geohash.Grid = function(centre, expand, pan){
	// returns an array of geohash boxes expanded outwards from the centre point, upto either a specified radius specified as the number of same-size geohashes (not including the centre), or upto an a fencepost geohash defining a single outermost area (in any direction such as a corner)
	// pan is an optional index of geohashes (i.e. {'geohash'=true,…}) to be excluded from the returned array (and added to the index), typically used when rendering only new boxes for a map pan
	var grid = [];
	var sides = {centre:centre,index:{}};
	var max;
	if (typeof(expand)=='number') { max=expand }; if (!max || max > 12) { max=12 };
	for (var i = 0; i < max; i++) {
		sides = geohash.Edges(sides);
		if (pan) {
			grid = grid.concat(geohash.Uniques(sides.array,pan))
		} else {
			grid = grid.concat(sides.array)
		}
		if (sides.index[expand]) { break; }
	}
	if (!pan || !pan[centre]) { grid.pop(centre) }
	return grid
}

geohash.Uniques = function(expanded, existing){
	// accepts an array of geohashes, and an index of geohashes, returns a new array of only the geohashes not in the index; used by Grid to filter out existing boxes during map panning
	var uniques = [];
	var count = expanded.length;
	for (var i = 0; i < count; i++) {
		if (!existing[expanded[i]]){
			var box = expanded[i]
			uniques.push(box)
			existing[box]=true
		}
	}
	return uniques
}