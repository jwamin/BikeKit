# BikeKit

## Swift Framework for NYC Bikeshare App with Test App

1. Include `BikeKit` framework
2. Pass a `UserDefaults` suite to the `NYCBikeModel.groupedUserDefaults`  to persist favourites data.
3. Make your subclass conform to the  `NYCBikeUIDelegate` to handle calls to `updated:` and `cooldown:`.
4. Pass a `CLLocation` to the `updateLocation` method. On delegate callback, call `getNearestStations()` for array of nearby stations.

## Test App

### Features

* Manage a list of your favourite stations on the NYC Bikeshare
* CoreGraphics representations of remaining Bikes / Docks
* `MapKitScreenshotter` view of the local area surrounding the dock and CoreGraphics status dot.
* View Station and status on a Map - 
* See station data on a 'Today` Widget

### Techniques 
* App groups with shared UserDefaults Suite - track favourites accross targets and extensions.

### Future
* Distances to station
* Group By Region
* Custom `UICollectionView`
* Locate nearest usable station, distance and number of bikes / docks taken into account.
* `WatchKit Extension` for most / all of the above features.

#### Frameworks Used
`UIKit`, `MapKit`, `CoreLocation`, `URLSession`, `CoreGraphics`
