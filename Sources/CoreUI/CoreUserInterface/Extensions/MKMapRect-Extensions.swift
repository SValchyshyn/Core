//
//  MKMapRect-Extensions.swift
//  CoopM16
//
//  Created by Jens Willy Johannsen on 13/05/2016.
//  Copyright © 2016 Greener Pastures. All rights reserved.
//

import MapKit

/**
Function to convert a MKCoordinateRegion to a MKMapRect.

- parameter region: The region to convert
- returns: The corresponding MKMapRect
*/
public func mapRectForCoordinateRegion( _ region: MKCoordinateRegion ) -> MKMapRect {
	let topLeft = CLLocationCoordinate2D( latitude: region.center.latitude + (region.span.latitudeDelta/2), longitude: region.center.longitude - (region.span.longitudeDelta/2) )
	let bottomRight = CLLocationCoordinate2D( latitude: region.center.latitude - (region.span.latitudeDelta/2), longitude: region.center.longitude + (region.span.longitudeDelta/2) )

	let topLeftMapPoint = MKMapPoint( topLeft )
	let bottomRightMapPoint = MKMapPoint( bottomRight )

	return MKMapRect( origin: MKMapPoint( x: min(topLeftMapPoint.x, bottomRightMapPoint.x), y: min(topLeftMapPoint.y, bottomRightMapPoint.y)), size: MKMapSize( width: abs(topLeftMapPoint.x - bottomRightMapPoint.x), height: abs(topLeftMapPoint.y - bottomRightMapPoint.y) ))
}
