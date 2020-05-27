import 'package:test/test.dart';
import 'package:geohashtreemap/geohashtreemap.dart';

void main() {
  group('Adding values and nodes', () {
    test('Adding geohash', () {
        GeohashTree<String> addTree = GeohashTree<String>(maxDepth: 1);
        addTree.add("6g3mc", "iguazu");
        assert(addTree.getRoot().children.length==1);
        assert(addTree.getRoot().children["6"].children["g3mc"].value=="iguazu");
        assert(addTree.length==1);
        addTree.add("6g4mc", "iguazu");
        assert(addTree.length==2);
      });
    test('Adding geohash with operator', () {
      GeohashTree<String> addTree = GeohashTree<String>(maxDepth: 1);
      addTree["6g3mc"]= "iguazu";
      assert(addTree.getRoot().children.length==1);
      assert(addTree.getRoot().children["6"].children["g3mc"].value=="iguazu");
      assert(addTree.length==1);
    });
    test('Adding using lat long coordinates', () {
      GeohashTree<String> addTree = GeohashTree<String>(maxDepth: 1);
      addTree.addLatLng(-25.686667, -54.444722, "iguazu", precision: 5);
      assert(addTree.getRoot().children.length==1);
      assert(addTree.getRoot().children["6"].children["g3mc"].value=="iguazu");
      assert(addTree.length==1);
    });
    test('Adding GeohashTree node', () {
      GeohashTree<String> addTree = GeohashTree<String>(maxDepth: 1);
      GeohashTreeNode<String> node = GeohashTreeNode("6g3mc",value:"iguazu");
      addTree.addNodes([node]);
      assert(addTree.getRoot().children.length==1);
      assert(addTree.getRoot().children["6"].children["g3mc"].value=="iguazu");
      assert(addTree.length==1);
    });
  });
  group('Updating', () {
    GeohashTree<String> updateTree = GeohashTree<String>(maxDepth: 1);
    updateTree.add("6g3mc", "iguazu");

    test('Valid update', () {
        updateTree.update("6g3mc", (s)=>"iguazu_falls");  
        assert(updateTree.getRoot().children.length==1);
        assert(updateTree.getRoot().children["6"].children["g3mc"].value=="iguazu_falls");
      });

    test('Update ifAbsent', () {
      updateTree.update("7g3mc", (s)=>"iguazu_falls",ifAbsent: ()=>"niagara");  
      assert(updateTree.getRoot().children.length==2);
      assert(updateTree.getRoot().children["7"].children["g3mc"].value=="niagara");
    });
    test('Invalid update', () {
      expect(()=> updateTree.update("8g3mc", (s)=>"iguazu_falls"),throwsA(TypeMatcher<ArgumentError>())); 
    });
  });
 group('Getting', () {
    GeohashTree<String> getTree = GeohashTree<String>(maxDepth: 2);
    getTree.add("6g3mc", "iguazu");
    getTree.add("6g3md", "close");
    getTree.add("773md", "far");
    test('Get Geohash',(){
      assert(getTree.getGeohash('6g3mc')=="iguazu");
    });
    test('Return null',(){
      assert(getTree.getGeohash('1g3mc')==null);
    });
    test('Get operator',(){
      assert(getTree["6g3mc"]=="iguazu");
    });
    test('Get with precision',(){
      List<String> values = getTree.getGeohashes("6");
      assert(values.length==2);
      assert(values.contains("iguazu") && values.contains("close"));
    });
    test('Invalid Gets', () {
      expect(()=> getTree.getGeohashes("6",precision: 4),throwsA(TypeMatcher<ArgumentError>())); 
      expect(()=> getTree.getGeohashes("6jnkjsnckjsnk"),throwsA(TypeMatcher<ArgumentError>()));     
    });
    test('Get Proximity', () {
      List<String> values = getTree.getGeohashesByProximity(-25.686667, -54.444722,1000, precision: 1);
      assert(values.length==3);
      List<String> closerValues = getTree.getGeohashesByProximity(-25.686667, -54.444722,1000,precision:2);
      assert(closerValues.length==2);
    });
  });
  group('Removing', () {
    GeohashTree<String> removeTree = GeohashTree<String>(maxDepth: 1);
    removeTree.add("6g3mc", "iguazu");
    removeTree.add("6g4mc", "iguazu2");
    removeTree.add("6g5mc", "iguazu3");

    test('Remove ', () {
      removeTree.remove("6g3mc");  
      assert(removeTree.length ==2);
      assert(removeTree.getRoot().children["6"].children["g3mc"] == null);
    });
    test('RemoveWhere ', () {
      removeTree.removeWhere((geohash,_)=>"6g4mc"==geohash);  
      assert(removeTree.length ==2);
      assert(removeTree.getRoot().children["6"].children["g4mc"] == null);
    });
  });
  group('Properties', () {
    GeohashTree<String> propTree = GeohashTree<String>(maxDepth: 1);
    propTree.add("6g3mc", "iguazu");
    test('Geohashes', () {
      List<String> g = propTree.geohashes.toList();
      assert(g.length ==1);
      assert(g[0] == "6g3mc");
    });   
    test('Values', () {
      List<String> v = propTree.values.toList();
      assert(v.length ==1);
      assert(v[0] == "iguazu");
    });  
    test('isEmpty', () {
      assert(!propTree.isEmpty);
      assert(GeohashTree().isEmpty);
    });  
    test('Contains', () {
      assert(propTree.containsGeohash("6g3mc"));
      assert(propTree.containsValue("iguazu"));
    });  
  });
  group('Factories', () {
    GeohashTree<String> factTree = GeohashTree<String>(maxDepth: 1);
    factTree.add("6g3mc", "iguazu");
    test('From', () {
      GeohashTree newTree = GeohashTree.from(factTree);
      assert(newTree.length ==1);
      assert(newTree.containsGeohash("6g3mc"));
    });  
  });
}
