# resize the layout
window.resize = (t) ->
  w = window.innerWidth
  h = window.innerHeight
  top = t.find('#map').offsetTop
  c = w - 40
  m = (h-top) - 30
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
  L.tileLayer "http://{s}.tile.cloudmade.com/#{window.cloudmade}/997/256/{z}/{x}/{y}.png", 
    attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, 
    <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © 
    <a href="http://cloudmade.com">CloudMade</a>, Dataset was updated on 2012-11-19
    <br> This information is provided by the 
    <a href="http://www2.gov.bc.ca/">Province of British Columbia</a> under the 
    <a href="http://www.data.gov.bc.ca/dbc/admin/terms.page">Open Government License for Government of BC Information v.BC1.0</a>'
  .addTo(window.map)
  
  # add popup to each marker
  onEachFeature = (feature, layer) ->
    if feature.properties
      name = feature.properties["Name"]
      description = feature.properties["Description"]
      matches = description.match(/Address:\s(.*)\sCity:\s(.*)\sP/)
      popup = "#{name}<br>#{matches[1]}<br>#{matches[2]}"
      layer.bindPopup(popup)
  
  # add geojson to map
  L.geoJson geojson,
    onEachFeature: onEachFeature
  .addTo(map)