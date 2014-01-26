Libraries = new Meteor.Collection("libraries")
Meteor.publish 'libraries', -> Libraries.find()

Cities = new Meteor.Collection("cities")
Meteor.publish 'cities', -> Cities.find({}, {sort: {city: 1}})

Districts = new Meteor.Collection("districts")
Meteor.publish 'districts', -> Districts.find({}, {sort: {district: 1}})

Meteor.startup ->
  libraries = []
  for feature in geojson.features
    name = feature.properties["Name"]
    description = feature.properties["Description"]
    latlng = feature.geometry["coordinates"]
    lng = latlng[0]
    lat = latlng[1]
    matches = description.match(/District Number:\s(\S+).*Address:\s(.*)\sCity:\s(.*)\sPostal:\s(.*)\sPhone:\s(.*)/)
    district = matches[1]
    address = matches[2]
    city = matches[3]
    postcode = matches[4]
    phone = matches[5]
    library = {name: name, district: district, address: address, city: city, postcode: postcode, phone: phone, lat: lat, lng: lng}
    libraries.push(library)
  if Libraries.find().count() is 0
    for library in libraries
      Libraries.insert(library)
  cities = Libraries.distinct "city"
  if Cities.find().count() is 0
    for item in cities
      Cities.insert({city: item})
  districts = Libraries.distinct "district"
  if Districts.find().count() is 0
    for item in districts
      Districts.insert({district: item})