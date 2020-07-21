const express = require('express')
const dotenv = require('dotenv')
const apiLimit = require('./common/config/slidingWindowCounter')
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
app.use(bodyParser.urlencoded({extended: true}))

// For requests to the root of the api
app.get(process.env.API_VERSION, (req, res) => {
    res.status(200).send({wel: ['You\'ve reached the food delivery api']})
})

// Implementation of a way to limit api access requests for all users
// All requests below this impose on apiRequest limit
if(process.env.ENV != 'dev')
    app.use(apiLimit.limitRequests(2, 100))

// Configurations for all routes used by api
AuthRouter.routesConfig(app)
UserRouter.routesConfig(app)

app.listen(process.env.PORT, _ => {
    console.log('API Server is listening at port %s', process.env.PORT)
})