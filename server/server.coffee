Libraries = new Meteor.Collection('libraries')
Meteor.publish 'libraries', -> Libraries.find()

Meteor.startup ->
  for feature in geojson.features
    name = feature.properties["Name"]
    description = feature.properties["Description"]
    matches = description.match(/Address:\s(.*)\sCity:\s(.*)\sPostCode:\s(.*)/)
    address = matches[1]
    city = matches[2]
    postcode = matches[3]
    if !name.isBlank() and !address.isBlank() and !city.isBlank() and !postcode.isBlank()
      Libraries.insert({name: name, address: address, city: city, postcode: postcode})