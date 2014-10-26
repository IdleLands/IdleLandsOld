module.exports = (req, res, next) ->
  {identifier, token} = req.body
  API.player.auth.isTokenValid identifier, token
  .then (resp) ->
    if resp.isSuccess
      next()
    else
      res.json {isSuccess: no, message: "Token validation failed."}