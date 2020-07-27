const RestaurantModel = require('../models/restaurant.model')

exports.menuList = (req, res) => {
    
}

exports.restaurantList = (req, res) => {
    RestaurantModel.list(100, 0).then(result => {
        res.status(200).send({
            data: result,
            success: true
        })
    }).catch(err=> {
        res.status(404).send({
            success: false
        })
    })
}