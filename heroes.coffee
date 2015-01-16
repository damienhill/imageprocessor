fs = require 'fs'
path = require 'path'
async = require 'async'
gm = require 'gm'


SOURCE = 'source'
OUTPUT = 'output'

QUALITY = 60
RETINA_QUALITY = 40

HOTELS_SUFFIX = '01'
TRAVEL_GUIDE_SUFFIX = '03'
FLIGHTS_SUFFIX = '07'


processImage = (imagePath, callback) ->
  originalName = path.basename(imagePath, '.jpg').split('_')[0]

  hotels = (done) ->
    console.log "#{imagePath}: Hotels"
    imageName = "#{originalName}.jpg"
    copyImage imagePath, imageName, (err) ->
      done(null)

  travelGuide = (done) ->
    console.log "#{imagePath}: Travel Guide"
    imageName = "travel-guide-#{originalName}.jpg"
    copyImage imagePath, imageName, (err) ->
      done(null)

  desktopRetina = (done) ->
    console.log "#{imagePath}: Flights desktopRetina"
    imageName = "#{originalName}-desktopRetina.jpg"
    gm "#{SOURCE}/#{imagePath}"
      .quality(RETINA_QUALITY)
      .write "#{OUTPUT}/#{imageName}", (err) ->
        done(null)      

  desktop = (done) ->
    console.log "#{imagePath}: Flights desktop"
    imageName = "#{originalName}-desktop.jpg"
    gm "#{SOURCE}/#{imagePath}"
      .resize(1320, 264)
      .quality(QUALITY)
      .write "#{OUTPUT}/#{imageName}", (err) ->
        done(null)

  tabletRetina = (done) ->
    console.log "#{imagePath}: Flights tabletRetina"
    imageName = "#{originalName}-tabletRetina.jpg"
    gm "#{SOURCE}/#{imagePath}"
      .resize(1918, 384)
      .quality(RETINA_QUALITY)
      .write "#{OUTPUT}/#{imageName}", (err) ->
        done(null)

  tablet = (done) ->
    console.log "#{imagePath}: Flights tablet"
    imageName = "#{originalName}-tablet.jpg"
    gm "#{SOURCE}/#{imagePath}"
      .resize(959, 192)
      .quality(QUALITY)
      .write "#{OUTPUT}/#{imageName}", (err) ->
        done(null)

  smallTabletRetina = (done) ->
    console.log "#{imagePath}: Flights smallTabletRetina"
    imageName = "#{originalName}-smallTabletRetina.jpg"
    gm "#{SOURCE}/#{imagePath}"
      .resize(1450, 290)
      .quality(RETINA_QUALITY)
      .write "#{OUTPUT}/#{imageName}", (err) ->
        done(null)

  smallTablet = (done) ->
    console.log "#{imagePath}: Flights smallTablet"
    imageName = "#{originalName}-smallTablet.jpg"
    gm "#{SOURCE}/#{imagePath}"
      .resize(725, 145)
      .quality(QUALITY)
      .write "#{OUTPUT}/#{imageName}", (err) ->
        done(null)     

  tasks = null
  suffix = path.basename(imagePath, '.jpg').split('_').pop()
  switch suffix
    when HOTELS_SUFFIX
      tasks = [hotels]
    when TRAVEL_GUIDE_SUFFIX
      tasks = [travelGuide]
    when FLIGHTS_SUFFIX
      tasks = [desktopRetina, desktop, tabletRetina, tablet, smallTabletRetina, smallTablet]
  
  async.series tasks, (err) ->
    callback(err)


copyImage = (imagePath, imageName, callback) ->
  readStream = fs.createReadStream "#{SOURCE}/#{imagePath}"
    .on 'error', (err) ->
      console.log 'error opening file', err
  writeStream = fs.createWriteStream "#{OUTPUT}/#{imageName}"
    .on 'finish', (err) ->
      callback(null)
  readStream.pipe writeStream


fs.readdir SOURCE, (err, files) ->
  if err
    console.log err
    return process.exit()

  # exclude any non-image files and hidden files
  images = (item for item in files when path.extname(item) is '.jpg')

  async.eachSeries images, (imagepath, callback) ->
    processImage imagepath, (err) ->
      callback(null)
  , (err) ->
    if err
      console.log 'error'
    else
      console.log 'success'
    process.exit() 

