const config = require('./common/config/env.config')
const express = require('express')
const dotenv = require('dotenv')
dotenv.config({ path: "common/config/config.env" })
const app = express()
var bodyParser = require('body-parser')

const AuthRouter = require('./auth/routes.config')
const UserRouter = require('./users/routes.config')

app.use( (req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*')
    res.header('Access-Control-Allow-Credentials', 'true')
    res.header('Access-Control-Allow-Methods', 'GET, POST', 'DELETE')
    res.header('Access-Control-Allow-Expose-Headers', 'Content-Length')
    res.header('Access-Control-Allow-Headers', 'Accept, x-api-key, Content-Type, X-Requested-With, Range')

    if(req.method === 'OPTIONS') {
        res.sendStatus(200)
    } else {
        return next()
    }
})
app.use(bodyParser.json())
app.use(bodyParser.urlencoded())

// Configurations for all routes used by api
AuthRouter.routesConfig(app)
UserRouter.routesConfig(app)

app.get(process.env.API_VERSION, (req, res) => {
    res.status(200).send({wel: ['You\'ve reached the food delivery api']})
})

app.listen(process.env.PORT, _ => {
    console.log('API Server is listening at port %s', process.env.PORT)
})