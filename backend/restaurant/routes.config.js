const RestaurantController = require('./controllers/restaurant.controller')
const PermissionMiddleware = require('../common/middlewares/auth.permission.middleware')
const ValidationMiddleware = require('../common/middlewares/auth.validation.middleware')

const VERSION = process.env.API_VERSION

exports.routeConfig = (app) => {
    app.get(VERSION + '/qeats/restaurants', [
        RestaurantController.restaurantList
    ])

    app.get(VERSION + '/qeats/restaurant/:restaurantId/menu', [
        ValidationMiddleware.validJWTNeeded,
        PermissionMiddleware.minimumPermissionLevelRequired(process.env.PERMISSION_ALL),
        RestaurantController.menuList
    ])

    // app.get(VERSION + '/qeats/')
}