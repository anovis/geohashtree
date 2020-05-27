import 'package:geohashtree/geohashtree.dart';

void main() { 

  // initialize tree
  GeohashTree<String> tree = GeohashTree<String>(); 

  // add values to the tree
  tree.add("6g3mc", "iguazu"); 
  tree.addLatLng(-25.686667, -54.444722, "also iguazu");

  //update value 
  tree.update("6g3mc", (s)=>"iguazu_falls");  

  //get value
  tree.getGeohash("6g3mc");

  //get all values and geohashes
  tree.geohashes;
  tree.values;

  //get all values in specific radius
  List<String> values = tree.getGeohashesByProximity(-25.686667, -54.444722,5000, precision: 9);
  print(values);

  //remove geohahs from the tree
  tree.remove("6g3mc");
  tree.removeWhere((geohash,value)=>geohash=="6g3mc");
  
}