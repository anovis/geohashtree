# GeohashTree

# Dart GeohashTree
![Pub Version](https://img.shields.io/pub/v/geohashtree)
![Master](https://github.com/anovis/geohashtree/workflows/Dart%20CI/badge.svg?branch=master)

**GeohashTree** is a tree implimentation to speed up spacial queries through geohash indexing. This is useful for dynamically querying small selections of locations in a certain radius for example to display in a map as the user scrolls. The GeohashTree can have a variable depth with the default set at 9. This corresponds to a geohash of precision or length 9.  

## Install

To get this plugin, add `geohashtree` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/). For example:

```yaml
dependencies:
  geohashtree: ^1.0.2
```

## Usage

It is possible to add spatial based values to the tree with a geohash or directly with lat lng coordinates.

``` dart
import 'package:geohashtree/geohashtree.dart';

GeohashTree<String> tree = GeohashTree<String>(); 
tree.add("6g3mc", "iguazu"); 
tree.addLatLng(-25.686667, -54.444722, "also iguazu");
```

To get all the coordinates in a tree within a radius of `5000` meters from the point `25.6953° S, 54.4367° W`  use `getGeohashesByProximity()`. The `precision` parameter dictates how specific the geohash match should be. Precision 5 return matches of geohash of length 5, which in this case would be all geohashes that start with "6g3mc". Precision 1 return matches of geohash of length 1, which in this case would be all geohashes that start with "6".

``` dart
List<String> values = tree.getGeohashesByProximity(-25.686667, -54.444722,5000, precision: 9);
```

## Issues

Please file any issues, bugs or feature requests as an issue on our [GitHub](https://github.com/anovis/geohashtree/issues) page. 

## Want to contribute

If you would like to contribute to the plugin (e.g. by improving the documentation, solving a bug or adding a cool new feature) submit a [pull request](https://github.com/anovis/geohashtree/pulls).



