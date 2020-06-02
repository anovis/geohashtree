import 'dart:collection';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:proximity_hash/proximity_hash.dart';

class GeohashTreeNode<V> {
  final String geohash;
  V value;
  int level;
  HashMap<String,GeohashTreeNode<V>> children = HashMap();

  GeohashTreeNode(this.geohash,{this.value, this.level});
}

/// GeohashTree is a tree structure with geohashes as the indices and [GeohashTreeNode] as the nodes.
/// The depth of the GeohashTree can set using [maxDepth] parameter.  
class GeohashTree<V> {
  GeohashTreeNode<V> _root = GeohashTreeNode(null,level: 0);
  final int maxDepth; 
  int length = 0;

  GeohashTree({this.maxDepth=9});

  /// returns the root [GeohashTreeNode] node
  GeohashTreeNode<V> getRoot(){
    return _root;
  }

  /// Returns the list of values that contain geohashes in a certain [radius] (meters) of the center coordinate radius.
  /// A [precision] can be set which determines how precise the geohashes will be. For example a precision of 1 with return
  /// a geohash of length 1.
  List<V> getGeohashesByProximity(double latitude,double longitude,double radius,{int precision}){
    int _precision = precision ?? maxDepth;
    List<String> proximityGeohashes = createGeohashes(latitude, longitude, radius, _precision);
    HashSet<V> values = HashSet();
    for (var g in proximityGeohashes) {
      values.addAll(getGeohashes(g)??[]);
    }
    return values.toList();
  }

  /// Gets the value associated with the [geohash]. If the geohash is not found then it returns null.
  V getGeohash(String geohash){
    GeohashTreeNode<V> node = _getNode(_root, geohash);
    if (node == null) return null;
    return node.value;
  }

  /// Returns a list of values associated with the [geohash] with [precision]. For example a geohash "6wgdx" and precision 2
  /// will return all values that have a geohash that starts with "6w". If not precision is given then it defaults to the length 
  /// of the given geohash.
  List<V> getGeohashes(String geohash, {int precision}){
    int _precision = precision ?? geohash.length;

    if (_precision < 0) throw ArgumentError('Incorrect precision found'); 
    if (geohash.length < _precision) throw ArgumentError("geohash must be less than the precision");
    if (_precision > maxDepth) throw ArgumentError("precision is higher than the max tree depth");
    GeohashTreeNode<V> node = _getNode(_root, geohash.substring(0,_precision));
    if (node == null) return null;
    return _getValues(node);
  }

  List<V> _getValues(GeohashTreeNode<V> parent){
    List<V> values = parent.value != null ? [parent.value] : [];
    if (parent.children == null){
      return values;
    }
    parent.children.values.forEach((node)=>values.addAll(_getValues(node)));
    return values;
  }

  List<String> _getGeohashes(GeohashTreeNode<V> parent){
    List<String> geohashes = parent.geohash != null && parent.value != null ? [parent.geohash] : [];
    if (parent.children == null){
      return geohashes;
    }
    parent.children.forEach((s,node)=>geohashes.addAll(_getGeohashes(node)));
    return geohashes;
  }

  List<GeohashTreeNode> _getNodes(GeohashTreeNode<V> parent){
    List<GeohashTreeNode> nodes = parent.children.values.toList() ?? [];
    if (parent.children == null){
      return nodes;
    }
    parent.children.forEach((s,node)=>nodes.addAll(_getNodes(node)));
    return nodes;
  }
 
  /// Add a value using coordinates. This converts the coordiantes to a geohash given the 
  /// precision. If no precision is given then it defaults to [maxDepth] 
  void addLatLng(double lat, double long,V v, {int precision}){
    int _precision = precision ?? maxDepth;
    String hashedKey = GeoHasher().encode(long, lat,precision: _precision);
    _putNode(_root, hashedKey, v);
  }

  ///Add a value with the geohash as the key
  void add(String geohash, V v){
    _putNode(_root, geohash, v, level:0);
  }
  
  /// Add [GeohashTreeNode] to the tree.
  void addNodes(Iterable<GeohashTreeNode<V>> newNodes){
    for (var node in newNodes) {
      _putNode(_root,node.geohash,node.value);
    }
  }

  /// Returns true if the tree contains at least 1 of [value]
  bool containsValue(V value){
    List<V> values = _getValues(_root);
    return values.contains(value);
  }

  /// Returns true if the tree contains the [geohash]
  bool containsGeohash(String geohash){
    List<String> geohashes = _getGeohashes(_root);
    return geohashes.contains(geohash);
  }

  /// Updates a geohashes [value] by calling [update]. If the geohash doesn't exist
  /// in the tree then [ifAbsent] is called. 
  V update(String geohash, V update(V value),{V ifAbsent()}){
    GeohashTreeNode<V> node = _getNode(_root,geohash);
    if (node == null){
      if (ifAbsent == null){
        throw(ArgumentError("Geohash not found and ifAbsent() is not provided"));
      }
      _putNode(_root, geohash, ifAbsent());
      return ifAbsent();
    }
    else{
      node.value = update(node.value);
      return node.value;
    }
  }

  /// Updates a geohashes [value] by calling [update]. This converts the coordiantes to a geohash given the 
  /// precision. If no precision is given then it defaults to [maxDepth] If the geohash doesn't exist
  /// in the tree then [ifAbsent] is called. 
  V updateLatLng(double lat, double long,V updateValue(V value),{int precision, V ifAbsent()}) {
    int _precision = precision ?? maxDepth;
    String geohash = GeoHasher().encode(long, lat,precision: _precision);
    return update(geohash,updateValue,ifAbsent:ifAbsent);
  }

  /// Removes nodes that evaluate [f] to true. The function takes in a geohash and a value. 
  void removeWhere(bool f(String geohash, V value)){
    List<GeohashTreeNode<V>> nodes = _getNodes(_root);
    Iterable<GeohashTreeNode<V>> removeNodes = nodes.where((node)=>f(node.geohash,node.value));
    removeNodes.forEach((n)=> remove(n.geohash));
  }

  /// Removes node with [geohash] from the tree.
  V remove(String geohash){
    GeohashTreeNode<V> parentNode = _getNode(_root, geohash.substring(0,geohash.length-1).substring(0,maxDepth));    
    GeohashTreeNode<V> removedNode = parentNode.children.remove(geohash.substring(maxDepth,geohash.length));
    if (removedNode == null){
      return null;
    }
    length -= 1;
    return removedNode.value;
  }

  ///Iterate through tree nodes
  void forEach(void f(String geohash, V value)){
    List<GeohashTreeNode> nodes = _getNodes(_root);
    nodes.forEach((node)=>f(node.geohash,node.value));
  }

  /// All geohashes in the tree
  Iterable<String> get geohashes{
    return _getGeohashes(_root);
  }

  /// All values in the tree
  Iterable<V> get values{
    return _getValues(_root);
  }

  /// Returns true if the tree is empty. 
  bool get isEmpty{
    return length == 0? true: false; 
  }

  /// Factory method to create a new [GeohashTree] from an existing [GeohashTree]
  factory GeohashTree.from(GeohashTree<V> other){
    List<GeohashTreeNode<V>> otherNodes = other._getNodes(other._root);
    GeohashTree<V> n = GeohashTree<V>(maxDepth: other.maxDepth);
    n.addNodes(otherNodes.where((n)=>n.value!=null));
    return n;
  }

  /// Allows the use of the bracket operator to get a value. For example `Tree["hash"]`
  V operator [](String geohash) {
    if (_root != null) {
      return getGeohash(geohash);
    }
    return null;
  }

  /// Allows the use of the bracket operator to set a value. For example `Tree["hash"]="value"`
  void operator []=(String geohash, V value) {
    if (geohash == null) throw ArgumentError(geohash);
    _putNode(_root, geohash, value);
  }

  void _putNode(GeohashTreeNode<V> parent, String geohash,V v,{int level=0}){
    String hashLetter = level == maxDepth? geohash.substring(level) : geohash.substring(level, level+1);
    
    // insert at maximum depth 
    if (level == maxDepth)
    {
      if (parent.children.containsKey(hashLetter)){
        return;
      }
      parent.children[hashLetter] = GeohashTreeNode(geohash,value: v,level:level);
      length = length +1;
      return;
    }

    if (parent.children.containsKey(hashLetter))
    {
      _putNode(parent.children[hashLetter], geohash, v, level:level+1);
    }
    else{
       parent.children[hashLetter] = GeohashTreeNode(null,level:level);
      _putNode(parent.children[hashLetter], geohash, v, level:level+1);
    }
  }

  GeohashTreeNode<V> _getNode(GeohashTreeNode<V> parent,String geohash, {int level=0}){
    String hashLetter = geohash.substring(level, level+1);
    
    // maximum depth 
    if (parent.children.containsKey(geohash.substring(level)))
    {
      return parent.children[geohash.substring(level)];
    }

    if (parent.children.containsKey(hashLetter))
    {
      return _getNode(parent.children[hashLetter],geohash, level:level+1);
    }
    else{
       return null;
    }
  }

}
