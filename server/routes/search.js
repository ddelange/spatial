const util = require('./util')

module.exports = function (req, res) {
  var service = req.app.locals.service

  // inputs
  let query = {
    text: util.flatten(req.query.text),
    wildcard: { start: false, end: true },
    limit: 100
  }

  // perform query
  // console.time('took')
  let rows = service.module.search.statement.search.all(query)
  // console.timeEnd('took')

  // send json
  res.status(200).json(rows)
}
