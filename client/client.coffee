window.markers = []

createMarkers = -> 
  markers = new L.MarkerClusterGroup()
  Libraries.find().forEach (library) ->
    lat = library.lat
    lng = library.lng
    popup = "#{library.name}<br>#{library.address}<br>#{library.city}<br>#{library.postcode}<br>#{library.phone}"
    markers.addLayer(new L.marker([lat,lng]).bindPopup(popup))
  window.map.addLayer(markers)
  window.markers.push(markers)
  # turn off spinner - loaded
  window.map.spin(false)

@Cities = new Meteor.Collection('cities')
Meteor.subscribe('cities')

@Libraries = new Meteor.Collection('libraries')
Meteor.subscribe('libraries', createMarkers)

Template.search_city.rendered = ->
  AutoCompletion.init("input#searchBox")

Template.search_city.events
  'keyup input#searchBox': ->
    AutoCompletion.autocomplete
      element: 'input#searchBox'
      collection: Cities
      field: 'city'
      limit: 0
      sort: { city: 1 }
  'click #search_button': ->
    # if pulling from dropdown then exact match
    input_value = $("input#searchBox").val()
    regex = "^" + input_value + "$"
    matches = Libraries.find({ city: { $regex : regex, $options:"i" }})
    input_value = regex if matches.count() > 0
    libraries = Libraries.find({city: { $regex : input_value, $options:"i" }})
    # clear marker groups
    for marker in window.markers
      window.map.removeLayer(marker)
    # clear all markers
    layers = window.map._layers
    for key, val of layers
      window.map.removeLayer(val) if val._latlng
    # add markers based on search
    libraries.forEach (library) ->
      lat = library.lat
      lng = library.lng
      popup = "#{library.name}<br>#{library.address}<br>#{library.city}<br>#{library.postcode}<br>#{library.phone}"
      L.marker([lat,lng]).addTo(window.map).bindPopup(popup)
  'click #reset_button': ->
    # clear all markers
    layers = window.map._layers
    for key, val of layers
      window.map.removeLayer(val) if val._latlng
    $("#searchBox").val('')
    markers = new L.MarkerClusterGroup()
    Libraries.find().forEach (library) ->
      lat = library.lat
      lng = library.lng
      popup = "#{library.name}<br>#{library.address}<br>#{library.city}<br>#{library.postcode}<br>#{library.phone}"
      markers.addLayer(new L.marker([lat,lng]).bindPopup(popup))
    window.map.addLayer(markers)
    window.markers.push(markers)

# resize the layout
window.resize = (t) ->
  w = window.innerWidth
  h = window.innerHeight
  top = 190
  c = w - 40
  m = (h-top) - 20
  t.find('#container').style.width = "#{c}px"
  t.find('#map').style.height = "#{m}px" 

Template.map.rendered = ->  
  # resize on load
  window.resize(@)

  # resize on resize of window
  $(window).resize =>
    window.resize(@)

  # create default image path
  L.Icon.Default.imagePath = 'packages/leaflet/images'

  # create a map in the map div, set the view to a given place and zoom
  window.map = L.map 'map', 
    doubleClickZoom: false
  .setView([53.25044, -123.137], 5)

  # add a CloudMade tile layer with style #997 - use your own cloudmade api key
  L.tileLayer "http://{s}.tile.cloudmade.com/c337a7e5e7c241958df4332a8713a0a9/997/256/{z}/{x}/{y}.png", 
    attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, 
    <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © 
    <a href="http://cloudmade.com">CloudMade</a>, Dataset updated 2012-01-11, Created by
    <a href="http://www.bevanhunt.com">Bevan Hunt
    <br> This information is provided by the 
    <a href="http://www2.gov.bc.ca/">Province of British Columbia</a> under the 
    <a href="http://www.data.gov.bc.ca/dbc/admin/terms.page">Open Government License for Government of BC Information v.BC1.0</a>'
  .addTo(window.map)

  # add locate me
  L.control.locate().addTo(window.map)

  # loading spinner
  window.map.spin(true)