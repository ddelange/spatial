const _ = require('lodash')
const DELIM = ':'
const format = require('../../../format')
const Identity = require('../../../../model/Identity')
const Ontology = require('../../../../model/Ontology')
const Place = require('../../../../model/Place')

const map = {
  properties: require('./properties'),
  names: require('./names')
}

function mapper (doc) {
  // get document properties
  const properties = _.get(doc, 'properties')
  if (!_.isPlainObject(properties)) { return null }

  // instantiate a new place
  const place = new Place(
    new Identity('osm', _.get(properties, '@type') + DELIM + _.get(properties, '@id')),
    new Ontology('admin', _.get(properties, 'place', 'unknown'))
  )

  // add geometry
  const geometry = _.get(doc, 'geometry')
  if (geometry) {
    place.addGeometry(format.from('geometry', 'geojson', geometry))
  }

  // run mappers
  map.properties(place, properties)
  map.names(place, properties)

  return place
}

module.exports = mapper