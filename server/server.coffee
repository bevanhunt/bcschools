Libraries = new Meteor.Collection("libraries")
Meteor.publish 'libraries', -> Libraries.find()

Meteor.startup ->
  for feature in geojson.features
    name = feature.properties["Name"]
    description = feature.properties["Description"]
    latlng = feature.geometry["coordinates"]
    lng = latlng[0]
    lat = latlng[1]
    matches = description.match(/Address:\s(.*)\sCity:\s(.*)\sPostCode:\s(.*)/)
    address = matches[1]
    city = matches[2]
    postcode = matches[3]
    library = {name: name, address: address, city: city, postcode: postcode, lat: lat, lng: lng}
    Libraries.insert(library) 
 
  # insert adds duplicate records en-masse
  console.log Libraries.find({}).count()